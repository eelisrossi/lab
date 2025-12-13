// Placeholder module for Proxmox QEMU VMs
// NOTE: This is a placeholder to keep HCL valid. Replace with real proxmox_vm_qemu resource
// when provider schema is known/verified.
resource "null_resource" "vm_placeholder" {
  triggers = {
    hostname = var.hostname
    vmid     = tostring(var.vmid)
    node     = var.target_node
  }
}
