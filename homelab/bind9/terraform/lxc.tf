variable "ct_root_password" {
  type      = string
  sensitive = true
}

variable "ct_ssh_keys" {
  type      = string
  sensitive = true
}

resource "proxmox_lxc" "bind9" {
  target_node  = "srv-mox"
  hostname     = "hlct-ns1"
  vmid         = 601
  ostemplate   = "local:vztmpl/almalinux-9-amd64-cloud-20250725-rootfs.tar.xz"
  password     = var.ct_root_password
  unprivileged = true

  cores    = 2
  cpulimit = 2
  memory   = 2048

  start  = true
  onboot = true

  ssh_public_keys = var.ct_ssh_keys

  features {
    nesting = true
  }

  rootfs {
    storage = "local-lvm"
    size    = "16G"
  }

  network {
    name   = "eth0"
    bridge = "VLAN10"
    ip     = "192.168.10.5/24"
    gw     = "192.168.10.1"
  }


  tags = "almalinux;iac;lxc"

  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../ansible/ansible.cfg ansible-playbook -i ../ansible/hosts.yml ../ansible/install-ssh.yml"
  }
}
