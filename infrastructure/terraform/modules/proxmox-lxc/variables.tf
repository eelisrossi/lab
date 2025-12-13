variable "hostname" {
  description = "Container hostname"
  type        = string
}

variable "vmid" {
  description = "Numeric VMID for the container"
  type        = number
}

variable "target_node" {
  description = "Proxmox node to place the container on"
  type        = string
}

variable "ostemplate" {
  description = "LXC template path (e.g., local:vztmpl/almalinux-10...)"
  type        = string
}

variable "password" {
  description = "Root password for container"
  type        = string
  sensitive   = true
}

variable "ssh_public_keys" {
  description = "SSH public keys to inject into the container"
  type        = string
  sensitive   = true
  default     = ""
}

variable "unprivileged" {
  description = "Run as unprivileged container"
  type        = bool
  default     = true
}

variable "cores" {
  description = "CPU cores"
  type        = number
  default     = 1
}

variable "cpulimit" {
  description = "CPU limit"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 768
}

variable "swap" {
  description = "Swap in MB"
  type        = number
  default     = 256
}

variable "disk_size" {
  description = "Root disk size (e.g., 16G)"
  type        = string
  default     = "8G"
}

variable "storage" {
  description = "Storage backend"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Network bridge to attach container"
  type        = string
}

variable "network_ip" {
  description = "IP with CIDR (e.g., 192.168.1.10/24)"
  type        = string
}

variable "network_gw" {
  description = "Network gateway IP"
  type        = string
}

variable "nameserver" {
  description = "DNS nameserver"
  type        = string
  default     = "1.1.1.1"
}

variable "onboot" {
  description = "Start container on host boot"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for the container"
  type        = string
  default     = ""
}
