variable "ct_root_password" {
  type      = string
  sensitive = true
}

variable "ct_ssh_keys" {
  type      = string
  sensitive = true
}

resource "proxmox_lxc" "basic" {
  target_node  = "srv-mox"
  hostname     = "ct-test"
  ostemplate   = "local:vztmpl/almalinux-9-amd64-cloud-20250725-rootfs.tar.xz"
  password     = var.ct_root_password
  unprivileged = true

  cores    = 2
  cpulimit = 2
  memory   = 2048

  start  = true
  onboot = true

  ssh_public_keys = var.ct_ssh_keys

  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "VLAN10"
    ip     = "192.168.10.50/24"
    gw     = "192.168.10.1"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=./ansible/ansible.cfg ansible-playbook -i ./ansible/hosts.yml ./ansible/install-ssh.yml"
  }
}
