bind9 Terraform service

This directory was created by migrating bind9/terraform/lxc.tf to a reusable module at terraform/modules/proxmox-lxc.

Deployment instructions:
1. Inspect variables.tf and terraform.tfvars; credentials were copied from bind9/terraform/credentials.auto.tfvars for testing purposes.
2. From this directory run: terraform init && terraform plan
3. Apply if desired: terraform apply

Notes:
- Do not modify original bind9/ directory. This service uses relative module source "../../modules/proxmox-lxc".
- Keep sensitive variables (API tokens, passwords, ssh keys) secure in CI or using a secrets manager.
