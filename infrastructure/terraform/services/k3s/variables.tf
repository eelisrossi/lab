variable "vm_ssh_keys" {
  description = "SSH public keys for VMs"
  type        = string
  sensitive   = true
}

variable "vm_root_password" {
  type      = string
  sensitive = true
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "network_cidr" {
  description = "Network CIDR suffix (e.g., 24 for /24)"
  type        = number
  default     = 24
}

variable "network_gw" {
  description = "Network gateway"
  type        = string
}

variable "nameserver" {
  description = "DNS nameservers (space-separated)"
  type        = string
  default     = "192.168.10.5 192.168.10.6"
}

variable "control_plane" {
  description = "Control plane nodes"
  type        = list(object({ hostname = string, vmid = number, target_node = string, ip = string }))
  default     = []
}

variable "control_plane_cores" {
  description = "CPU cores for control plane nodes"
  type        = number
  default     = 2
}

variable "control_plane_memory" {
  description = "Memory in MB for control plane nodes"
  type        = number
  default     = 4096
}

variable "workers" {
  description = "Worker nodes"
  type        = list(object({ hostname = string, vmid = number, target_node = string, ip = string }))
  default     = []
}

variable "worker_cores" {
  description = "CPU cores for worker nodes"
  type        = number
  default     = 2
}

variable "worker_memory" {
  description = "Memory in MB for worker nodes"
  type        = number
  default     = 4096
}
