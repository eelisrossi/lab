// Outputs for proxmox-lxc module
output "container_id" {
  value       = proxmox_lxc.container.vmid
  description = "Numeric VMID of the created container"
}

output "hostname" {
  value       = proxmox_lxc.container.hostname
  description = "Hostname of the created container"
}

output "ip_address" {
  value       = try(proxmox_lxc.container.network[0].ip, "")
  description = "IP address assigned to the primary network interface"
}
