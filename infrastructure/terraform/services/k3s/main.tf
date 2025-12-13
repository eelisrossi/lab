locals {
  templates = {
    eddie  = "templ-almalinux-10-eddie"
    hactar = "templ-almalinux-10-hactar"
  }
}

module "k3s_control_plane" {
  source   = "../../modules/proxmox-vm"
  for_each = { for node in var.control_plane : node.hostname => node }

  hostname    = each.value.hostname
  vmid        = each.value.vmid
  target_node = each.value.target_node
  clone       = local.templates[each.value.target_node]
  full_clone  = true

  cores  = var.control_plane_cores
  memory = var.control_plane_memory

  network_bridge = var.network_bridge
  network_ip     = "${each.value.ip}/${var.network_cidr}"
  network_gw     = var.network_gw
  nameserver     = var.nameserver

  ssh_public_keys = var.vm_ssh_keys
  tags            = "k3s,control-plane"
}

module "k3s_workers" {
  source   = "../../modules/proxmox-vm"
  for_each = { for node in var.workers : node.hostname => node }

  hostname    = each.value.hostname
  vmid        = each.value.vmid
  target_node = each.value.target_node
  clone       = local.templates[each.value.target_node]
  full_clone  = true

  cores  = var.worker_cores
  memory = var.worker_memory

  network_bridge = var.network_bridge
  network_ip     = "${each.value.ip}/${var.network_cidr}"
  network_gw     = var.network_gw
  nameserver     = var.nameserver

  ssh_public_keys = var.vm_ssh_keys
  tags            = "k3s,worker"
}
