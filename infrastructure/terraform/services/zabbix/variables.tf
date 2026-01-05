variable "nameservers" {
  description = "List of nameserver container definitions"
  type        = list(object({ hostname = string, vmid = number, target_node = string, ip = string }))
  default     = []
}

variable "ostemplate" {
  description = "LXC template to use"
  type        = string
  default     = "local:vztmpl/almalinux-10-default_20250930_amd64.tar.xz"
}

variable "ct_root_password" {
  description = "Root password for containers"
  type        = string
  sensitive   = true
}

variable "ct_ssh_keys" {
  description = "SSH public keys for containers"
  type        = string
  sensitive   = true
}

variable "cores" {
  description = "CPU cores per container"
  type        = number
  default     = 1
}

variable "cpulimit" {
  description = "CPU limit"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory in MB per container"
  type        = number
  default     = 768
}

variable "swap" {
  description = "Swap in MB per container"
  type        = number
  default     = 256
}

variable "storage" {
  description = "Storage backend"
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Disk size per container"
  type        = string
  default     = "16G"
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "VLAN10"
}

variable "network_gw" {
  description = "Network gateway"
  type        = string
  default     = "192.168.10.1"
}

variable "nameserver" {
  description = "DNS nameserver for containers"
  type        = string
  default     = "1.1.1.1"
}

variable "tags" {
  description = "Tags for containers"
  type        = string
  default     = "almalinux;iac;lxc;dns"
}
