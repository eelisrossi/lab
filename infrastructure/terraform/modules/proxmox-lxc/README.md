Proxmox LXC module

This module provisions a Proxmox LXC container using the telmate/proxmox provider.

Usage example:

module "dns_ns1" {
  source        = "../../modules/proxmox-lxc"
  hostname      = "hlct-ns1"
  vmid          = 601
  target_node   = "eddie"
  ostemplate    = "local:vztmpl/almalinux-10-default_20250930_amd64.tar.xz"
  password      = var.ct_root_password
  ssh_public_keys = var.ct_ssh_keys
  network_bridge = "VLAN10"
  network_ip     = "192.168.10.5/24"
  network_gw     = "192.168.10.1"
  tags           = "almalinux;iac;lxc;dns"
}

Notes:
- This module was created by extracting logic from bind9/terraform/lxc.tf to allow reuse across services.
- Use relative module sources when referencing from services (e.g., source = "../../modules/proxmox-lxc").
