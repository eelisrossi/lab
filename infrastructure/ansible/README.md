# Ansible Infrastructure Management

Simple, flat structure for managing homelab infrastructure.

## Structure

```
ansible/
├── ansible.cfg       # Ansible configuration
├── inventory.yml     # All hosts and groups
├── k3s-deploy.yml    # Deploy k3s cluster
├── bind9-deploy.yml  # Deploy bind9 DNS
└── roles/           # Service-specific tasks
    ├── k3s_server/
    ├── k3s_agent/
    └── bind9/
```

## Quick Start

### Deploy k3s Cluster

```bash
# Deploy entire cluster (control plane + workers)
ansible-playbook k3s-deploy.yml

# Deploy only control plane
ansible-playbook k3s-deploy.yml --limit k3s_control_plane

# Deploy only workers
ansible-playbook k3s-deploy.yml --limit k3s_workers
```

### Manage bind9 DNS

```bash
# Deploy bind9
ansible-playbook bind9-deploy.yml

# Check DNS server status
ansible dns_servers -m shell -a "systemctl status named"
```

## Inventory

All hosts are defined in `inventory.yml`:

- **k3s_control_plane**: k3s server nodes
- **k3s_workers**: k3s agent nodes
- **dns_servers**: bind9 DNS servers

## Adding New Nodes

Edit `inventory.yml` and add to the appropriate group:

```yaml
k3s_workers:
  hosts:
    hlvm-k3s-w3:
      ansible_host: 192.168.20.33
      ansible_user: srv-adm
```

Then run the playbook:

```bash
ansible-playbook k3s-deploy.yml --limit hlvm-k3s-w3
```

## Requirements

- Ansible 2.9+
- SSH access to all hosts
- SSH key at `~/.ssh/homelab` (or configured in inventory)
- sudo/root access on target hosts

## Network Requirements

**Note**: VMs need internet connectivity to download k3s installer.

Ensure:
- VMs can reach internet (test: `ansible k3s_cluster -m shell -a "ping -c 2 8.8.8.8"`)
- DNS resolution works
- Gateway is configured correctly
- Firewall allows outbound HTTPS (443)
