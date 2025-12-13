# k3s root module: uses modules/proxmox-lxc or modules/proxmox-vm to create nodes
# TODO: map existing variables to module inputs. Keep current variables for compatibility.

# Example usage (fill with actual values or wire from existing variables):
module "k3s_node_example" {
  source = "../../../modules/proxmox-lxc"

  name        = "k3s-node-1"
  vmid        = 610
  target_node = "srv-mox"
  template    = "local:vztmpl/almalinux-9-amd64-cloud-20250725-rootfs.tar.xz"
  cpu         = 2
  mem         = 2048
  disk_size   = "8G"
  storage     = "local-lvm"
  bridge      = var.bridge
  ip          = "192.168.10.60/24"
  gw          = "192.168.10.1"
  ssh_keys    = var.ct_ssh_keys
  password    = var.ct_root_password
  tags        = "k3s;node"
}
