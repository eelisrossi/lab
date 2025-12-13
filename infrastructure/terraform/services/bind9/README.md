## bind9 Terraform Service

Provisions BIND9 nameserver LXC containers using the proxmox-lxc module.

### Usage

Configuration is managed via two files:

**config.auto.tfvars** (non-sensitive, can be committed):
```hcl
network_bridge = "VLAN10"
network_gw     = "192.168.10.1"

nameservers = [
  { hostname = "hlct-ns1", vmid = 601, target_node = "eddie", ip = "192.168.10.5/24" },
  { hostname = "hlct-ns2", vmid = 602, target_node = "hactar", ip = "192.168.10.6/24" },
]
```

**secrets.auto.tfvars** (sensitive, gitignored):
```hcl
ct_root_password = "your-password"
ct_ssh_keys = "ssh-ed25519 AAAA..."
```

### Deployment

```bash
terraform init
terraform plan
terraform apply
```

### Adding Nameservers

Simply add another entry to the `nameservers` list in config.auto.tfvars:

```hcl
nameservers = [
  { hostname = "hlct-ns1", vmid = 601, target_node = "eddie", ip = "192.168.10.5/24" },
  { hostname = "hlct-ns2", vmid = 602, target_node = "hactar", ip = "192.168.10.6/24" },
  { hostname = "hlct-ns3", vmid = 603, target_node = "eddie", ip = "192.168.10.7/24" },
]
```
