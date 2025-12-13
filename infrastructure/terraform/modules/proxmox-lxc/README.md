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

Optional bootstrap (non-invasive)

This module provides an optional bootstrap provisioner to run a small one-time script inside the container after creation. This is intended for lightweight, first-boot tasks and testing only — Ansible should remain the primary tool for idempotent and complex in-guest configuration.

Usage example (enable when you want to test a tiny bootstrap):

module "example" {
  source = "../../modules/proxmox-lxc"
  # ... other required inputs ...

  bootstrap_enabled     = true
  bootstrap_user        = "root"
  bootstrap_private_key = var.bootstrap_private_key # or use agent
  bootstrap_script      = <<-EOT
    #!/bin/bash
    dnf update -y
    dnf install -y openssh-server
    systemctl enable --now sshd
  EOT
}

Notes:
- The bootstrap uses an SSH connection to the container's primary IP; ensure networking and SSH access are available.
- This feature is optional and non-destructive; it does not remove or modify your existing Ansible playbooks.
- Keep secrets out of Terraform code; prefer SSH agent or external secret storage for private keys.
