// Generic Proxmox QEMU VM module (for k3s nodes, etc.)
resource "proxmox_vm_qemu" "vm" {
  name   = var.hostname
  vmid   = var.vmid
  target_node = var.target_node

  clone      = var.clone
  full_clone = var.full_clone

  cores  = var.cores
  memory = var.memory

  ssh_keys = var.ssh_public_keys

  disk {
    size    = var.disk_size
    storage = var.storage
  }

  network {
    model  = "virtio"
    bridge = var.network_bridge
    ip     = var.network_ip
    gw     = var.network_gw
    firewall = var.network_firewall
  }

  onboot = var.onboot
  start  = var.start
  tags   = var.tags
}
