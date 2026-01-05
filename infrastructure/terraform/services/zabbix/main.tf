module "nameservers" {
  source   = "../../modules/proxmox-lxc"
  for_each = { for ns in var.nameservers : ns.hostname => ns }

  hostname        = each.value.hostname
  vmid            = each.value.vmid
  target_node     = each.value.target_node
  ostemplate      = var.ostemplate
  password        = var.ct_root_password
  ssh_public_keys = var.ct_ssh_keys

  cores    = var.cores
  cpulimit = var.cpulimit
  memory   = var.memory
  swap     = var.swap

  storage   = var.storage
  disk_size = var.disk_size

  network_bridge = var.network_bridge
  network_ip     = each.value.ip
  network_gw     = var.network_gw

  nameserver = var.nameserver
  tags       = var.tags
}
