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

resource "null_resource" "bootstrap" {
  count = var.bootstrap_enabled ? 1 : 0
  depends_on = [proxmox_lxc.container]

  provisioner "file" {
    content     = var.bootstrap_script
    destination = "/root/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/bootstrap.sh",
      "bash /root/bootstrap.sh"
    ]
  }

  connection {
    type        = "ssh"
    host        = split("/", try(proxmox_lxc.container.network[0].ip, ""))[0]
    user        = var.bootstrap_user
    private_key = var.bootstrap_private_key != "" ? var.bootstrap_private_key : null
    timeout     = var.bootstrap_timeout
  }
}
