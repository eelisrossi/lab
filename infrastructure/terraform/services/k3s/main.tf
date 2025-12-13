// k3s service root module using proxmox-lxc (based on existing k3s/terraform/main.tf)
// Original file: k3s/terraform/main.tf

// Create control plane nodes
locals {
  control = var.control_plane
  workers = var.workers
}

resource "null_resource" "placeholder" {
  provisioner "local-exec" {
    command = "echo 'This module should be expanded to create multiple control and worker nodes using the modules/proxmox-lxc or modules/proxmox-vm as appropriate.'"
  }
}

// Example of creating nodes via module (uncomment and adjust as needed):
/*
module "k3s_node_1" {
  source = "../../modules/proxmox-lxc"
  hostname = var.control_plane[0].hostname
  vmid     = var.control_plane[0].vmid
  target_node = var.control_plane[0].target_node
  ostemplate  = var.ostemplate
  password    = var.ct_root_password
  ssh_public_keys = var.ct_ssh_keys
  network_bridge = var.network_bridge
  network_ip     = var.control_plane[0].ip
  network_gw     = var.network_gw
  tags = "k3s;control"
}
*/
