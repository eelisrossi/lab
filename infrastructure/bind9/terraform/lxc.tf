variable "ct_root_password" {
  type      = string
  sensitive = true
}

variable "ct_ssh_keys" {
  type      = string
  sensitive = true
}

resource "proxmox_lxc" "ns1" {
  target_node  = "eddie"
  hostname     = "hlct-ns1"
  vmid         = 601
  ostemplate   = "local:vztmpl/almalinux-10-default_20250930_amd64.tar.xz"
  password     = var.ct_root_password
  unprivileged = true

  cores    = 1
  cpulimit = 1
  memory   = 768
  swap = 256

  start  = true
  onboot = true
  protection = true

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

  startup = "order=1,up=10,down=60"

  tags = "almalinux;iac;lxc;dns"
}

resource "proxmox_lxc" "ns2" {
  target_node  = "hactar"
  hostname     = "hlct-ns2"
  vmid         = 602
  ostemplate   = "local:vztmpl/almalinux-10-default_20250930_amd64.tar.xz"
  password     = var.ct_root_password
  unprivileged = true

  cores    = 1
  cpulimit = 1
  memory   = 768
  swap = 256

  start  = true
  onboot = true
  protection = true

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

  startup = "order=1,up=10,down=60"

  tags = "almalinux;iac;lxc;dns"
}
