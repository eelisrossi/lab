// bind9 service migrated to use terraform/modules/proxmox-lxc
// Original resources migrated from: bind9/terraform/lxc.tf
module "ns1" {
  source = "../../modules/proxmox-lxc"

  hostname         = var.ns1_hostname
  vmid             = var.ns1_vmid
  target_node      = var.ns1_target_node
  ostemplate       = var.ostemplate
  password         = var.ct_root_password
  ssh_public_keys  = var.ct_ssh_keys

  cores            = var.cores
  cpulimit         = var.cpulimit
  memory           = var.memory
  swap             = var.swap

  storage          = var.storage
  disk_size        = var.disk_size

  network_bridge   = var.network_bridge
  network_ip       = var.ns1_ip
  network_gw       = var.network_gw

  nameserver       = var.nameserver
  tags             = var.tags
}

module "ns2" {
  source = "../../modules/proxmox-lxc"

  hostname         = var.ns2_hostname
  vmid             = var.ns2_vmid
  target_node      = var.ns2_target_node
  ostemplate       = var.ostemplate
  password         = var.ct_root_password
  ssh_public_keys  = var.ct_ssh_keys

  cores            = var.cores
  cpulimit         = var.cpulimit
  memory           = var.memory
  swap             = var.swap

  storage          = var.storage
  disk_size        = var.disk_size

  network_bridge   = var.network_bridge
  network_ip       = var.ns2_ip
  network_gw       = var.network_gw

  nameserver       = var.nameserver
  tags             = var.tags
}
