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
  description = "Template to clone from (e.g., 'ubuntu-22.04' or '9000')"
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

variable "cpu_type" {
  description = "CPU type (e.g., 'host', 'x86-64-v2-AES')"
  type        = string
  default     = "x86-64-v2-AES"
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "ciuser" {
  description = "Cloud-init user"
  type        = string
  default     = "srv-adm"
}

variable "ssh_public_keys" {
  description = "SSH public keys for VM"
  type        = string
  sensitive   = true
  default     = ""
}

variable "disk_size" {
  description = "Disk size (e.g., 30G) - must be >= template disk size"
  type        = string
  default     = "30G"
}

variable "storage" {
  description = "Storage backend"
  type        = string
  default     = "local-lvm"
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

variable "onboot" {
  description = "Start VM on boot"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for VM"
  type        = string
  default     = ""
}
