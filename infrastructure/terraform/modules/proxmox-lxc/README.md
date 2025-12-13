## Proxmox LXC Module

Provisions Proxmox LXC containers with sensible defaults.

### Usage

```hcl
module "dns_ns1" {
  source = "../../modules/proxmox-lxc"
  
  hostname    = "hlct-ns1"
  vmid        = 601
  target_node = "eddie"
  ostemplate  = "local:vztmpl/almalinux-10-default_20250930_amd64.tar.xz"
  
  password        = var.ct_root_password
  ssh_public_keys = var.ct_ssh_keys
  
  cores   = 1
  memory  = 768
  disk_size = "16G"
  
  network_bridge = "VLAN10"
  network_ip     = "192.168.10.5/24"
  network_gw     = "192.168.10.1"
  
  tags = "almalinux;iac;lxc;dns"
}
```

### Default Settings

- **Start behavior**: Containers start automatically on creation and host boot
- **Security**: Unprivileged containers with protection enabled
- **Networking**: eth0 interface with specified bridge
- **Features**: Nesting enabled for Docker/nested containers
