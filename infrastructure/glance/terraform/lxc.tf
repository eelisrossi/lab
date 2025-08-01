variable "ct_root_password" {
  type      = string
  sensitive = true
}

variable "ct_ssh_keys" {
  type      = string
  sensitive = true
}

resource "proxmox_lxc" "glance" {
  target_node  = "srv-mox"
  hostname     = "hlct-glance"
  vmid         = 600
  ostemplate   = "local:vztmpl/almalinux-9-amd64-cloud-20250725-rootfs.tar.xz"
  password     = var.ct_root_password
  unprivileged = true

  cores    = 1
  cpulimit = 1
  memory   = 1024

  start  = true
  onboot = true

  ssh_public_keys = var.ct_ssh_keys

  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  nameserver = "192.168.10.20"

  network {
    name   = "eth0"
    bridge = "VLAN10"
    ip     = "192.168.10.50/24"
    gw     = "192.168.10.1"
  }

  tags = "almalinux;iac;lxc"

  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../ansible/ansible.cfg ansible-playbook -i ../ansible/hosts.yml ../ansible/install-ssh.yml"
  }
}
