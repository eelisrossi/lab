k3s cluster provisioning plan

Generated: 2025-12-11T19:50:38.936Z

Purpose
- Provide an actionable implementation plan to provision the Proxmox LXCs and AlmaLinux VMs for a three-node k3s cluster using Terraform and Ansible, based on the infrastructure and requirements you supplied.

1) Inventory and network mapping

VLAN10 (192.168.10.0/24) — management / infra
- hlct-ns1 (LXC) — host: Eddie, 1 vCPU, 768 MB RAM, 256 MB swap, 16G disk, IP: 192.168.10.5/24, gw: 192.168.10.1, nameserver: 1.1.1.1
- hlct-ns2 (LXC) — host: Hactar, same sizing, IP: 192.168.10.6/24
- hlvm-nfs (LXC) — host: Eddie, 1–2 vCPU, 2–3 GB RAM, storage depends on needs, IP: 192.168.10.10/24
- hlt-haproxy (LXC) — host: Eddie, 0.5–1 vCPU, 512–1024 MB RAM, IP: 192.168.10.8/24 (static)
  - optional hlt-haproxy2 on Hactar: 192.168.10.9/24
- npm (LXC) — host: Hactar, 1 vCPU, 1–1.5 GB RAM, IP: 192.168.10.7/24

VLAN20 (192.168.20.0/24) — k3s cluster traffic
- hlvm-k3s1 (VM, server) — host: Eddie, 2 vCPU, 5 GB RAM, IP: 192.168.20.11/24, gw: 192.168.20.1
- hlvm-k3s2 (VM, worker) — host: Eddie, 2 vCPU, 4 GB RAM, IP: 192.168.20.12/24
- hlvm-k3s3 (VM, worker) — host: Hactar, 2 vCPU, 4 GB RAM, IP: 192.168.20.21/24

2) Terraform: repository layout and resources

Goal: Declaratively create LXCs and VMs in Proxmox, set startup ordering, assign IPs/VMIDs, and output addresses for Ansible.

Recommended repo structure (infrastructure/k3s/terraform)
- modules/
  - lxc/          # module to create unprivileged LXC containers
  - vm/           # module to clone QEMU VM templates (k3s AlmaLinux template)
  - network/      # optional: abstractions for bridges or VLAN attachments if provider supports
- environments/
  - lab/          # environment-specific main.tf, vars.tf, outputs.tf
- main.tf
- variables.tf
- outputs.tf
- providers.tf

Module: lxc
- Inputs: name, hostname, node (target Proxmox host), vmid, cores, memory, swap (in MB), disk size, root_password, ssh_keys, net_if (bridge/VLAN), static_ip, nameserver(s), unprivileged=true, nesting=true, protection=true
- Behavior: create container, set network (ip=192.168.x.x/24, gw), set startup order via `onboot` and `startup` params, enable features required for k3s (nesting) and resource constraints.

Module: vm (QEMU VM clone)
- Inputs: template_vmid (9000), name, node, vmid, cores, memory, disk_size(optional), cicustom_user_snippet (storage:path), ssh_keys, ipconfig0 (ip=192.168.20.x/24,gw), protection=true
- Behavior: clone template (full clone if no shared storage), set cloud-init/cicustom, set ipconfig0 for DHCP/static configuration, return vm.ip, vm.vmid

Provider and settings
- Use Telmate/Telmate or a maintained Proxmox provider; configure provider auth using API token or user/password.
- Enable protection=true on resources to prevent accidental deletes.
- Set unprivileged=true and nesting=true for CTs.
- Map VMIDs explicitly via variables so they’re stable across runs.

Startup ordering
- Use `depends_on` + Terraforms `proxmox_vm_qemu` provider ordering or provider-specific startup/boot settings (e.g., `startup` property and `onboot`) to ensure:
  1) DNS (hlct-ns1, hlct-ns2) and NFS come up first
  2) HAProxy + NPM
  3) k3s nodes (VMs)

Outputs
- Output map of hostnames -> IPs and TM access details; produce a local_file artifact (inventory) that Ansible consumes.

3) Ansible: roles and playbooks

Goal: configure containers/VMs after Terraform provisioning; keep roles idempotent and testable.

Playbooks
- playbooks/site.yml — orchestrates role execution across groups: lxc-infra (VLAN10) then k3s (VLAN20)
- playbooks/inventory_from_terraform.yml — helper to consume Terraform outputs and write dynamic inventory or static inventory file

Roles
- roles/common
  - create users (srv-adm), deploy user if required, install SSH keys, set sudo NOPASSWD for deploy accounts, configure time sync (chrony), basic hardening, sysctl tuning for k3s, disable/adjust swap
  - ensure /etc/hosts entries for infra
- roles/dns
  - bind/named or unbound or knot role; configure forwarders and zones
  - create SRV/A records for k3s-api.lab.local and wildcard apps
- roles/nfs
  - install nfs-server, export /export/k3s, set proper uid/gid, restrict by K3s IPs
- roles/haproxy
  - configure frontends (6443, 80, 443) and backends (k3s nodes), health checks, stats endpoint, TLS termination optional
- roles/npm (nginx-proxy-manager)
  - install docker/compose or docker-compose stack as recommended by npm docs, configure reverse proxy UI
- roles/k3s/server
  - on hlvm-k3s1: install k3s with flags: --disable traefik, --tls-san 192.168.10.8, --tls-san k3s-api.lab.local, --cluster-init
  - enable etcd snapshots: set schedule and retention, configure snapshot directory (as per plan)
  - configure backup job that rsyncs snapshots to NFS or S3
- roles/k3s/agent
  - join cluster using K3S_URL pointing to HAProxy (https://192.168.10.8:6443) and the token retrieved from server
- roles/monitoring (optional)
  - haproxy exporter, node exporter, basic Prometheus scrape config

Ansible vault
- Store srv-adm password, per-VM srv-usr passwords, and other secrets in pve/vault.yml (encrypted). Playbooks reference vault variables for setting container/VM passwords or for initial bootstrap if needed.

4) Provisioning workflow (day-0)

1. Prepare: update pve/vars.yml and pve/vault.yml (encrypted). Ensure Terraform provider credentials are in environment or providers.tf.
2. Terraform: terraform init && terraform plan && terraform apply -auto-approve in infrastructure/k3s/terraform.
   - Terraform should output an inventory file (e.g., /tmp/k3s_inventory.ini) mapping deploy/srv-adm to each host IP.
3. Ansible: run playbooks/site.yml -i /tmp/k3s_inventory.ini --vault-password-file ~/.secrets/vault_pass
   - Run infra roles first (common, dns, nfs, haproxy, npm), then k3s roles (server then agents).
4. Validation steps (see below).

5) Validation checklist
- Reachability: ping/ssh to all nodes using srv-adm (or deploy) user.
- DNS: resolve k3s-api.lab.local -> 192.168.10.8 and wildcard apps -> 192.168.10.8
- HAProxy: confirm backend health for k3s nodes, access stats endpoint
- Kubernetes: kubectl --kubeconfig from hlvm-k3s1 or via port-forwarding through HAProxy; kubectl get nodes should show 3 nodes
- Ingress: deploy sample app and access via https://sample.apps.lab.local (ensure TLS if terminating at HAProxy or ingress)
- Backups: check etcd snapshots and that rsync to NFS/S3 works

6) Firewall (FortiGate) guidance
- Allow VLAN20 to WAN only; allow VLAN20 → VLAN10 for DNS (53), NFS (2049 + helpers), and HAProxy (80/443/6443)
- Allow mgmt hosts/subnet full access to VLAN10/20
- Restrict external access to HAProxy ports 80/443/6443 to allowed source ranges

7) Operational notes and best practices
- Keep cloud-init template minimal; use Ansible for package installs and stateful configuration.
- Use protection=true in Terraform resources to avoid accidental deletions.
- Periodically rotate templates and rebuild VMs to apply base image security updates.
- Monitor etcd snapshot health and automate offsite copies.
- Consider MetalLB or external LB if you later need NodePort alternatives or bare-metal LoadBalancer service type.

8) Phase 2 / HA improvements (optional)
- Add hlt-haproxy2 on Hactar and use Keepalived to present a virtual IP (e.g., 192.168.10.20) for API/ingress.
- Add an additional k3s server and reconfigure etcd for 3 control-plane nodes only when you have a third fault domain.
- Consider Cilium or Calico for advanced networking and security policies.

9) Outputs and artifacts
- Terraform outputs: JSON file with vm names, ips, vmids for use in CI/CD and Ansible inventory generation.
- Ansible: idempotent playbooks and roles stored under infrastructure/k3s/ansible/roles and playbooks
- Documentation: this k3s-cluster.md and per-role READMEs describing variables and expected inputs

10) Next tasks (implementation plan)
- Implement Terraform modules: modules/lxc and modules/vm with variables described above.
- Implement Ansible roles skeletons: common, dns, nfs, haproxy, npm, k3s/server, k3s/agent.
- Wire CI or local scripts to run terraform apply -> generate inventory -> ansible-playbook.
- Test in lab: provision LXCs only first (DNS + NFS) then VMs and validate ordering and idempotence.

Appendix: quick Terraform hints
- For Proxmox LXC (example pseudo):
  resource "proxmox_lxc" "ct" {
    vmid      = var.vmid
    hostname  = var.name
    ostemplate = "local:vztmpl/almalinux-9-default_...tar.xz" # or use cloud image conversion
    cores     = var.cores
    memory    = var.memory
    rootfs    = "${var.storage}:${var.disk_size}"
    features  = { nesting = true }
    ssh_keys  = var.ct_ssh_keys
    net0      = "name=eth0,bridge=${var.bridge},ip=${var.ip}/24,gw=${var.gateway}"
    unprivileged = true
    protection = true
  }

- For QEMU clone: use `clone` attribute to clone template VMID, set `full_clone = true` if needed, and use `cicustom` to reference user-data snippets uploaded to Proxmox storage.


End of plan.
