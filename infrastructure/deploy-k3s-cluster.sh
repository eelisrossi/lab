#!/usr/bin/env bash
#
# K3S Cluster Deployment Script
# 
# This script automates the complete deployment of a k3s cluster:
# 1. Provisions VMs using Terraform
# 2. Waits for VMs to be SSH accessible
# 3. Deploys k3s using Ansible
# 4. Retrieves kubeconfig for local kubectl access
#
# Usage: ./deploy-k3s-cluster.sh [options]
#
# Options:
#   --skip-terraform    Skip Terraform provisioning (use existing VMs)
#   --skip-ansible      Skip Ansible k3s installation
#   --skip-kubeconfig   Skip kubeconfig retrieval
#   --kubeconfig-only   Only retrieve kubeconfig (skip everything else)
#   --destroy           Destroy infrastructure and exit
#   -h, --help          Show this help message
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/terraform/services/k3s"
ANSIBLE_DIR="${SCRIPT_DIR}/ansible"
CONTROL_PLANE_IP="192.168.20.21"
CONTROL_PLANE_USER="srv-adm"

# Flags
SKIP_TERRAFORM=false
SKIP_ANSIBLE=false
SKIP_KUBECONFIG=false
KUBECONFIG_ONLY=false
DESTROY=false

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

show_help() {
    grep '^#' "$0" | grep -v '#!/usr/bin/env' | sed 's/^# *//'
    exit 0
}

check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing=()
    
    command -v terraform >/dev/null 2>&1 || missing+=("terraform")
    command -v ansible >/dev/null 2>&1 || missing+=("ansible")
    command -v ansible-playbook >/dev/null 2>&1 || missing+=("ansible-playbook")
    command -v ssh >/dev/null 2>&1 || missing+=("ssh")
    command -v kubectl >/dev/null 2>&1 || log_warning "kubectl not found (optional for kubeconfig retrieval)"
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing[*]}"
        exit 1
    fi
    
    log_success "All required dependencies found"
}

provision_vms() {
    log_info "Provisioning VMs with Terraform..."
    
    cd "${TERRAFORM_DIR}"
    
    log_info "Running terraform init..."
    if ! terraform init -upgrade 2>&1; then
        log_error "Terraform init failed - check internet connectivity"
        return 1
    fi
    
    log_info "Running terraform plan..."
    if ! terraform plan; then
        log_error "Terraform plan failed"
        return 1
    fi
    
    log_info "Running terraform apply..."
    if ! terraform apply -auto-approve; then
        log_error "Terraform apply failed"
        return 1
    fi
    
    log_success "VMs provisioned successfully"
}

clean_ssh_keys() {
    log_info "Cleaning old SSH host keys..."
    
    # Remove SSH keys for k3s cluster IPs
    ssh-keygen -R 192.168.20.21 >/dev/null 2>&1 || true
    ssh-keygen -R 192.168.20.31 >/dev/null 2>&1 || true
    ssh-keygen -R 192.168.20.32 >/dev/null 2>&1 || true
    
    log_success "SSH host keys cleaned"
}

wait_for_ssh() {
    log_info "Waiting for VMs to be SSH accessible..."
    
    cd "${ANSIBLE_DIR}"
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if ansible k3s_cluster -m ping >/dev/null 2>&1; then
            log_success "All VMs are SSH accessible"
            return 0
        fi
        
        attempt=$((attempt + 1))
        log_info "Waiting for SSH... (attempt $attempt/$max_attempts)"
        sleep 10
    done
    
    log_error "VMs did not become SSH accessible within timeout"
    return 1
}

deploy_k3s() {
    log_info "Deploying k3s with Ansible..."
    
    cd "${ANSIBLE_DIR}"
    
    log_info "Running ansible-playbook..."
    ansible-playbook k3s-deploy.yml
    
    log_success "k3s deployed successfully"
}

retrieve_kubeconfig() {
    log_info "Retrieving kubeconfig..."
    
    local kubeconfig_dir="${HOME}/.kube"
    local kubeconfig_file="${kubeconfig_dir}/config"
    
    mkdir -p "${kubeconfig_dir}"
    
    # Check if kubeconfig already exists
    if [ -f "${kubeconfig_file}" ] && [ "$KUBECONFIG_ONLY" = false ]; then
        log_warning "Kubeconfig already exists at ${kubeconfig_file}"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Keeping existing kubeconfig"
            return 0
        fi
    fi
    
    # Retrieve kubeconfig from control plane (with SSH options to skip host key checking)
    if ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${CONTROL_PLANE_USER}@${CONTROL_PLANE_IP}" sudo cat /etc/rancher/k3s/k3s.yaml > "${kubeconfig_file}" 2>/dev/null; then
        log_success "Retrieved kubeconfig from control plane"
    else
        log_error "Failed to retrieve kubeconfig"
        log_error "Make sure the control plane is running at ${CONTROL_PLANE_IP}"
        return 1
    fi
    
    # Update server address
    sed -i.bak "s/127.0.0.1/${CONTROL_PLANE_IP}/g" "${kubeconfig_file}"
    rm -f "${kubeconfig_file}.bak"
    
    log_success "Kubeconfig saved to: ${kubeconfig_file}"
    
    # Test connection
    if command -v kubectl >/dev/null 2>&1; then
        log_info "Testing kubectl connection..."
        echo ""
        if kubectl get nodes 2>/dev/null; then
            echo ""
            log_success "kubectl is working! Try: kubectl get nodes"
        else
            log_warning "kubectl connection test failed, but kubeconfig was retrieved"
        fi
    else
        log_info "kubectl not found - install it to test connection"
        log_info "Kubeconfig is ready at: ${kubeconfig_file}"
    fi
}

destroy_infrastructure() {
    log_warning "Destroying infrastructure..."
    
    cd "${TERRAFORM_DIR}"
    
    log_info "Running terraform destroy..."
    terraform destroy -auto-approve
    
    log_success "Infrastructure destroyed"
}

show_cluster_info() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_success "K3S CLUSTER DEPLOYMENT COMPLETE!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Cluster Access:"
    echo "  Control Plane: ${CONTROL_PLANE_USER}@${CONTROL_PLANE_IP}"
    echo "  Kubeconfig: ~/.kube/k3s-config"
    echo ""
    echo "Quick Commands:"
    echo "  kubectl get nodes"
    echo "  kubectl get pods -A"
    echo "  kubectl cluster-info"
    echo ""
    log_info "Your k3s cluster is ready! 🚀"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-terraform)
            SKIP_TERRAFORM=true
            shift
            ;;
        --skip-ansible)
            SKIP_ANSIBLE=true
            shift
            ;;
        --skip-kubeconfig)
            SKIP_KUBECONFIG=true
            shift
            ;;
        --kubeconfig-only)
            KUBECONFIG_ONLY=true
            SKIP_TERRAFORM=true
            SKIP_ANSIBLE=true
            shift
            ;;
        --destroy)
            DESTROY=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            ;;
    esac
done

# Main execution
main() {
    log_info "Starting k3s cluster deployment..."
    echo ""
    
    # Check dependencies first
    check_dependencies
    echo ""
    
    # Handle destroy mode
    if [ "$DESTROY" = true ]; then
        destroy_infrastructure
        exit 0
    fi
    
    # Provision VMs
    if [ "$SKIP_TERRAFORM" = false ]; then
        provision_vms
        echo ""
        clean_ssh_keys
        echo ""
        wait_for_ssh
        echo ""
    else
        log_warning "Skipping Terraform provisioning"
        echo ""
    fi
    
    # Deploy k3s
    if [ "$SKIP_ANSIBLE" = false ]; then
        deploy_k3s
        echo ""
    else
        log_warning "Skipping Ansible deployment"
        echo ""
    fi
    
    # Retrieve kubeconfig
    if [ "$SKIP_KUBECONFIG" = false ]; then
        retrieve_kubeconfig
        echo ""
    else
        log_warning "Skipping kubeconfig retrieval"
        echo ""
    fi
    
    # Show final information (skip if only getting kubeconfig)
    if [ "$KUBECONFIG_ONLY" = false ]; then
        show_cluster_info
    fi
}

# Run main function
main
