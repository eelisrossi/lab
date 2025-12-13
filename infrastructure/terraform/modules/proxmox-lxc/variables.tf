// Variables for proxmox-lxc module. Extracted from bind9/terraform/lxc.tf
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
  description = "Proxmox LXC template path (e.g., local:vztmpl/... )"
  type        = string
}

variable "password" {
  description = "Root password for container (sensitive)"
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
  description = "Whether the container is unprivileged"
  type        = bool
  default     = true
}

variable "cores" { description = "CPU cores for container" type = number default = 1 }
variable "cpulimit" { description = "CPU limit" type = number default = 1 }
variable "memory" { description = "Memory in MB" type = number default = 768 }
variable "swap" { description = "Swap in MB" type = number default = 256 }

variable "disk_size" { description = "Root disk size (e.g., 16G)" type = string default = "16G" }
variable "storage" { description = "Storage to use for rootfs" type = string default = "local-lvm" }

variable "network_name" { description = "Network interface name inside container" type = string default = "eth0" }
variable "network_bridge" { description = "Bridge to attach the container to" type = string }
variable "network_ip" { description = "IP with CIDR (e.g., 192.168.1.10/24)" type = string }
variable "network_gw" { description = "Gateway IP" type = string }

variable "nameserver" { description = "Container nameserver" type = string default = "1.1.1.1" }

variable "startup" { description = "Startup options" type = string default = "order=1,up=10,down=60" }
variable "start" { description = "Start container after creation" type = bool default = true }
variable "onboot" { description = "Start on boot" type = bool default = true }
variable "protection" { description = "Enable protection" type = bool default = true }
variable "nesting" { description = "Enable nesting feature" type = bool default = true }

variable "tags" { description = "Tags for the container" type = string default = "" }
