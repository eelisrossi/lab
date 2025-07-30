variable "ct_root_password" {
  type      = string
  sensitive = true
}

variable "ct_ssh_keys" {
  type      = string
  sensitive = true
}

resource "proxmox_lxc" "ns1" {
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

  nameserver = "1.1.1.1"

  network {
    name   = "eth0"
    bridge = "VLAN10"
    ip     = "192.168.10.5/24"
    gw     = "192.168.10.1"
  }

  tags = "almalinux;iac;lxc;dns"
}

resource "proxmox_lxc" "ns2" {
  target_node  = "srv-prox"
  hostname     = "hlct-ns2"
  vmid         = 602
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
    ip     = "192.168.10.6/24"
    gw     = "192.168.10.1"
  }


  tags = "almalinux;iac;lxc;dns"
}
