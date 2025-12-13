// Migrated logic derived from: bind9/terraform/lxc.tf
// This module provisions a Proxmox LXC container.
resource "proxmox_lxc" "container" {
  target_node  = var.target_node
  hostname     = var.hostname
  vmid         = var.vmid
  ostemplate   = var.ostemplate
  password     = var.password
  unprivileged = var.unprivileged

  cores    = var.cores
  cpulimit = var.cpulimit
  memory   = var.memory
  swap     = var.swap

  start      = var.start
  onboot     = var.onboot
  protection = var.protection

  ssh_public_keys = var.ssh_public_keys

  features {
    nesting = var.nesting
  }

  rootfs {
    storage = var.storage
    size    = var.disk_size
  }

  nameserver = var.nameserver

  network {
    name   = var.network_name
    bridge = var.network_bridge
    ip     = var.network_ip
    gw     = var.network_gw
  }

  startup = var.startup

  tags = var.tags
}
