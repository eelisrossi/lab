Proxmox cloud‑init template for AlmaLinux (for k3s VMs)

Purpose
- Create a reusable cloud-init VM template on Proxmox using the AlmaLinux Cloud Image and make it easy to clone and provision with Terraform and Ansible.

Prerequisites
- Proxmox VE installed on your hosts and reachable via SSH as root (or a user with pve privileges).
- Enough local or shared storage for VM disks (e.g. local-lvm, local, or shared NFS/Ceph). Shared storage is recommended so a single template is available to all cluster nodes.
- An SSH public key for the deployment user (e.g. ~/.ssh/id_rsa.pub).
- Terraform installed where you will run provisioning automation and the Proxmox Terraform provider configured (e.g. Telmate/proxmox) and Ansible installed for configuration.

Why this layout
- Keep the template minimal: cloud-init handles user/SSH/qemu-agent so Terraform can clone and Ansible can perform k3s installation and join operations.
- Store reusable cloud-init snippets under Proxmox storage (local:snippets) so Terraform can reference the same userdata per-VM.

Quick outline
1) Download AlmaLinux cloud image on a Proxmox node
2) Create a minimal VM record and import the QCOW2 as its disk
3) Add a cloud-init drive and set defaults (user, ssh keys, qemu-agent)
4) Seed a snippets/user-data file for per-VM provisioning (keeps template generic)
5) Convert the VM into a template
6) Use Terraform to clone the template and attach cicustom userdata per VM
7) Use Ansible to configure k3s using the SSH key and inventory generated from Terraform

Step-by-step (example commands)

# 1. Download AlmaLinux cloud image (pick latest URL from https://cloud.almalinux.org/images/)
ALMA_IMG_URL="<ALMALINUX_CLOUD_QCOW2_URL>"

# Run on a Proxmox node that will host the template (proxmox-node1)
ssh root@proxmox-node1
cd /tmp
wget -O almalinux.qcow2 "$ALMA_IMG_URL"

# 2. Create a new VM record (VMID 9000 is an example - pick a free ID)
qm create 9000 \
  --name almalinux-cloud-template \
  --memory 2048 \
  --cores 2 \
  --net0 virtio,bridge=vmbr0 \
  --agent 1

# 3. Import the qcow2 into storage (replace <STORAGE> with local-lvm, local, etc.)
STORAGE=<STORAGE>
qm importdisk 9000 almalinux.qcow2 ${STORAGE} --format qcow2
qm set 9000 --scsihw virtio-scsi-pci --scsi0 ${STORAGE}:vm-9000-disk-0
qm set 9000 --boot order=scsi0
qm set 9000 --ide2 ${STORAGE}:cloudinit

# Set cloud-init defaults: create a non-root deploy user and inject your SSH public key
# Use a deploy user (e.g., 'deploy') that Ansible will SSH into
qm set 9000 --ciuser deploy --sshkeys "$(cat ~/.ssh/id_rsa.pub)"
qm set 9000 --agent enabled=1

# 4. Create a reusable cloud-init snippet (keeps the template generic so Terraform can override per-VM)
# Locally create a file k3s-seed.yaml with minimal settings that prepare the VM for Ansible (no k3s install here):
cat > k3s-seed.yaml <<'EOF'
#cloud-config
users:
  - name: deploy
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash
    ssh_authorized_keys:
      - SSH_PUB_KEY_PLACEHOLDER
disable_root: true
runcmd:
  - [ systemctl, enable, --now, qemu-guest-agent ]
  - [ swapoff, -a ]
write_files:
  - path: /etc/cloud/cloud.cfg.d/99-ansible.cfg
    content: |
      datasource_list: [ NoCloud, OVF ]
EOF

# Replace the placeholder with the actual key and copy to Proxmox snippets storage
sed -i "s|SSH_PUB_KEY_PLACEHOLDER|$(cat ~/.ssh/id_rsa.pub)|" k3s-seed.yaml
# If using the default 'local' storage for snippets, copy the file to /var/lib/vz/snippets/
cp k3s-seed.yaml /var/lib/vz/snippets/k3s-seed.yaml
# (Alternatively upload via Proxmox GUI or pvesh API if using different storage)

# 5. Optional: Boot once to verify cloud-init and qemu-agent are present; install if necessary
# qm start 9000 && qm terminal 9000
# Inside the VM: sudo dnf install -y cloud-init qemu-guest-agent && sudo systemctl enable --now qemu-guest-agent
# After verification: shutdown the VM from inside (sudo poweroff)

# 6. Convert the VM to a template
qm template 9000

Terraform + Proxmox (example guidance)
- Use the community Proxmox provider (e.g. Telmate/proxmox) to clone the template and reference the snippet.
- Keep the cloud-init payload minimal (prepare user, ssh keys, qemu-agent); let Ansible do package install and k3s orchestration.
- Example Terraform resource (adapt to whichever provider you use):

# Example (pseudo-terraform - adjust provider and field names to match the provider's docs):
# provider "proxmox" { ... }
resource "proxmox_vm_qemu" "k3s" {
  count       = 3
  name        = "k3s-node-${count.index + 1}"
  target_node = "proxmox-node1"          # or use a list with spread across nodes
  clone       = 9000                      # template VMID
  full_clone  = true
  cores       = 2
  memory      = 2048
  scsihw      = "virtio-scsi-pci"
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  # Tell Proxmox to use the uploaded snippet as the cloud-init user-data
  cicustom = "user=local:snippets/k3s-seed.yaml"
  # ensure the ssh key is available for Terraform-provisioner or Ansible
  ssh_keys = file("~/.ssh/id_rsa.pub")
  # request a DHCP address; provider-specific key may be ipconfig0 = "ip=dhcp"
}

# Output the assigned IPs (provider-specific attribute names vary); Terraform outputs can be used to build an Ansible inventory.

Ansible integration and provisioning flow
- Best practice: use Terraform to create/clone the VMs and output the host IPs, then let Ansible connect with the 'deploy' user via SSH and perform the k3s installation and cluster join.
- Generate a simple static inventory from Terraform outputs (local_file resource or external script) and run ansible-playbook against it.
- Keep k3s install and cluster-join logic in Ansible roles so it's idempotent and testable.

Example Ansible flow (high level)
1) Terraform creates 3 VMs and writes out inventory file /tmp/k3s_hosts.ini with deploy@IP addresses.
2) ansible-playbook -i /tmp/k3s_hosts.ini site.yml
   - site.yml orchestrates: disable swap, install dependencies, install k3s on first node (server), gather token, join other nodes (agents).

Cloud-init user-data recommendations
- Keep seed userdata lightweight: create the deploy user with sudo NOPASSWD, install/enable qemu-guest-agent, disable swap, and inject SSH key.
- Do NOT install k3s from cloud-init if you plan to use Ansible for repeatable provisioning; cloud-init is useful for first-boot tasks only.

Snippets and cicustom
- Put per-environment user-data snippets under Proxmox storage snippets (e.g., local:snippets/k3s-seed.yaml) and reference them from Terraform with cicustom.
- If you need unique userdata per VM (different hostnames, IPs, or bootstrap roles), have Terraform generate per-VM snippet files and upload them to the node's snippets path before creating the VM (or use provider mechanisms to set cicustom with inline userdata if supported).

Security notes
- Use SSH keys and disable password auth for the deploy user.
- Rotate templates when base images get security updates; keep a process to rebuild templates periodically.

References
- Proxmox Cloud-Init wiki: https://pve.proxmox.com/wiki/Cloud-Init
- AlmaLinux cloud images: https://cloud.almalinux.org/images/
- Telmate Proxmox provider for Terraform (example provider): https://github.com/Telmate/terraform-provider-proxmox

That's the recommended flow: create a generic AlmaLinux cloud-init template, keep cloud-init minimal, use Terraform to clone and attach per-VM cicustom snippets, and use Ansible (with inventory generated from Terraform outputs) to install and configure k3s.