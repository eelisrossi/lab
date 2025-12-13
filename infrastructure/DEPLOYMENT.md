# K3S Cluster Deployment Guide

Complete automation for deploying a k3s cluster from scratch.

## Quick Start

### Deploy Everything

```bash
cd infrastructure
./deploy-k3s-cluster.sh
```

This will:
1. ✅ Provision VMs with Terraform
2. ✅ Wait for SSH connectivity
3. ✅ Deploy k3s with Ansible
4. ✅ Retrieve kubeconfig for local access

### Verify Deployment

```bash
kubectl get nodes
kubectl get pods -A
```

## Script Options

### Skip Specific Steps

```bash
# Use existing VMs, just deploy k3s
./deploy-k3s-cluster.sh --skip-terraform

# Only provision VMs, skip k3s installation
./deploy-k3s-cluster.sh --skip-ansible

# Deploy but don't retrieve kubeconfig
./deploy-k3s-cluster.sh --skip-kubeconfig
```

### Get Kubeconfig Only

```bash
# Just retrieve/update kubeconfig (cluster already deployed)
./deploy-k3s-cluster.sh --kubeconfig-only
```

This is useful when:
- Your cluster is already running
- You need to refresh your kubeconfig
- You're setting up kubectl on a new machine
- Your kubeconfig was deleted or corrupted

### Destroy Infrastructure

```bash
# Destroy all VMs
./deploy-k3s-cluster.sh --destroy
```

### Help

```bash
./deploy-k3s-cluster.sh --help
```

## Manual Workflow

If you prefer to run steps manually:

### 1. Provision VMs

```bash
cd terraform/services/k3s
terraform init
terraform plan
terraform apply
```

### 2. Deploy k3s

```bash
cd ../../ansible
ansible k3s_cluster -m ping  # Test connectivity
ansible-playbook k3s-deploy.yml
```

### 3. Get kubeconfig

```bash
mkdir -p ~/.kube
ssh srv-adm@192.168.20.21 sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/k3s-config
sed -i 's/127.0.0.1/192.168.20.21/g' ~/.kube/k3s-config
export KUBECONFIG=~/.kube/k3s-config
kubectl get nodes
```

## Requirements

- **Terraform** >= 1.4.0
- **Ansible** >= 2.9
- **SSH access** to Proxmox hosts
- **Network connectivity** from VMs to internet (for k3s installer)

## Configuration

### Terraform Variables

Edit `terraform/services/k3s/config.auto.tfvars`:

```hcl
control_plane = [
  { hostname = "hlvm-k3s-c1", vmid = 321, target_node = "eddie", ip = "192.168.20.21" }
]

workers = [
  { hostname = "hlvm-k3s-w1", vmid = 331, target_node = "eddie", ip = "192.168.20.31" },
  { hostname = "hlvm-k3s-w2", vmid = 332, target_node = "hactar", ip = "192.168.20.32" },
]
```

### Ansible Inventory

Edit `ansible/inventory.yml` to match your Terraform configuration.

## Troubleshooting

### VMs not SSH accessible

```bash
# Check VM status in Proxmox
# Verify network connectivity
ansible k3s_cluster -m ping
```

### k3s installation fails

```bash
# Check internet connectivity
ansible k3s_cluster -m shell -a "ping -c 2 get.k3s.io"

# Check logs on VM
ssh srv-adm@192.168.20.21
sudo journalctl -u k3s -f
```

### kubectl connection fails

```bash
# Verify kubeconfig
cat ~/.kube/k3s-config

# Test connection
kubectl --kubeconfig ~/.kube/k3s-config get nodes

# Check if control plane is accessible
ssh srv-adm@192.168.20.21 sudo /usr/local/bin/k3s kubectl get nodes
```

## Adding Nodes

### Add a Worker Node

1. Update Terraform config:

```hcl
workers = [
  # ... existing workers
  { hostname = "hlvm-k3s-w3", vmid = 333, target_node = "eddie", ip = "192.168.20.33" },
]
```

2. Update Ansible inventory:

```yaml
k3s_workers:
  hosts:
    # ... existing workers
    hlvm-k3s-w3:
      ansible_host: 192.168.20.33
      ansible_user: srv-adm
```

3. Deploy:

```bash
# Provision new VM
cd terraform/services/k3s
terraform apply

# Install k3s agent
cd ../../ansible
ansible-playbook k3s-deploy.yml --limit hlvm-k3s-w3
```

Or use the automated script:

```bash
./deploy-k3s-cluster.sh
```

## Upgrading k3s

```bash
cd ansible
ansible-playbook k3s-upgrade.yml  # When implemented
```

Or manually:

```bash
# On each node
ssh srv-adm@192.168.20.21
curl -sfL https://get.k3s.io | sh -
```

## Best Practices

1. **Always run from infrastructure directory** - Script paths are relative
2. **Test with --skip flags** - Skip working steps to speed up testing
3. **Backup kubeconfig** - Before re-running deployment
4. **Use version control** - Commit config changes before deploying
5. **Document changes** - Update this file when modifying deployment

## What the Script Does

1. **Dependency Check** - Verifies terraform, ansible, ssh are installed
2. **Terraform Apply** - Provisions VMs on Proxmox
3. **SSH Wait** - Polls VMs until SSH is ready (max 5 minutes)
4. **Ansible Deploy** - Installs k3s server and agents
5. **Kubeconfig Retrieval** - Downloads and configures kubectl access
6. **Validation** - Tests kubectl connectivity

## Success Indicators

✅ All VMs show "Ready" in `kubectl get nodes`  
✅ System pods running in `kubectl get pods -A`  
✅ No errors in script output  
✅ kubectl commands work without `--kubeconfig` flag

## Next Steps

- Deploy applications with `kubectl`
- Install Helm charts
- Configure ingress
- Set up monitoring
- Deploy your workloads!
