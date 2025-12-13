output "vm_id" {
  value       = proxmox_vm_qemu.vm.vmid
  description = "VMID of the created VM"
}

output "hostname" {
  value       = proxmox_vm_qemu.vm.name
  description = "Hostname of the VM"
}

output "ip_address" {
  value       = try(proxmox_vm_qemu.vm.network[0].ip, "")
  description = "IP address of the VM"
}
