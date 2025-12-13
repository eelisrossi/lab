// Variables for proxmox-vm module
variable "hostname" {
  description = "VM hostname"
  type        = string
}
variable "vmid" {
  description = "Numeric VMID for VM"
  type        = number
}
variable "target_node" {
  description = "Proxmox node to place the VM on"
  type        = string
}
variable "clone" {
  description = "Template to clone from (path or VM)"
  type        = string
}
variable "full_clone" {
  description = "Use full clone"
  type        = bool
  default     = false
}
variable "cores" {
  description = "CPU cores"
  type        = number
  default     = 2
}
variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}
variable "disk_size" {
  description = "Disk size (e.g., 8G)"
  type        = string
  default     = "8G"
}
variable "storage" {
  description = "Storage for disk"
  type        = string
  default     = "local-lvm"
}
variable "ssh_public_keys" {
  description = "SSH public keys for VM"
  type        = string
  sensitive   = true
  default     = ""
}
variable "network_bridge" {
  description = "Bridge to attach VM"
  type        = string
}
variable "network_ip" {
  description = "IP with CIDR for VM"
  type        = string
}
variable "network_gw" {
  description = "Gateway IP"
  type        = string
}
variable "network_firewall" {
  description = "Enable proxmox network firewall for VM"
  type        = bool
  default     = false
}
variable "onboot" {
  description = "Start VM on boot"
  type        = bool
  default     = true
}
variable "start" {
  description = "Start VM after creation"
  type        = bool
  default     = true
}
variable "tags" {
  description = "Tags for VM"
  type        = string
  default     = ""
}
