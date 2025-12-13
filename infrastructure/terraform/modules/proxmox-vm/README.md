Proxmox VM module

This module provisions a Proxmox QEMU VM by cloning a template and configuring CPU, memory, disk and network.

Usage example:

module "k3s_worker_1" {
  source      = "../../modules/proxmox-vm"
  hostname    = "k3s-worker-1"
  vmid        = 611
  target_node = "srv-mox"
  clone       = "local:vztmpl/ubuntu-22.04-template"
  full_clone  = true
  cores       = 2
  memory      = 4096
  disk_size   = "20G"
  storage     = "local-lvm"
  network_bridge = "VLAN10"
  network_ip     = "192.168.10.70/24"
  network_gw     = "192.168.10.1"
  ssh_public_keys = var.ct_ssh_keys
}

Notes:
- Use relative source paths when calling from services, e.g., source = "../../modules/proxmox-vm".
