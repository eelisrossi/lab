k3s Terraform service

This service provisions k3s nodes using the modules/proxmox-lxc module by default (the original k3s/terraform/main.tf references proxmox-lxc).

Usage:
- Populate terraform.tfvars (or use a secure backend) with ct_root_password and ct_ssh_keys and the control_plane/workers lists.
- Run terraform init && terraform apply in this directory.

Notes:
- This directory was created by analyzing k3s/terraform/main.tf; it intentionally uses module calls for node creation (examples provided in main.tf).
- Do not expose secrets in terraform.tfvars.example.
