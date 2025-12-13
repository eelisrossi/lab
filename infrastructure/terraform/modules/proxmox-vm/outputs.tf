output "vmid" {
  value = proxmox_vm_qemu.vm.vmid
}

output "hostname" {
  value = proxmox_vm_qemu.vm.name
}

output "ip" {
  value = split(",", split("=", proxmox_vm_qemu.vm.ipconfig0)[1])[0]
}
