Proxmox VM module

This module provisions a Proxmox QEMU VM by cloning a template.

Usage example:

```hcl
module "k3s_worker_1" {
  source      = "../../modules/proxmox-vm"
  hostname    = "k3s-worker-1"
  vmid        = 611
  target_node = "srv-mox"
  clone       = "ubuntu-22.04-template"
  full_clone  = true
  cores       = 2
  memory      = 4096
  network_bridge = "vmbr0"
  network_ip     = "192.168.10.70/24"
  network_gw     = "192.168.10.1"
  ssh_public_keys = var.ssh_keys
}
```
