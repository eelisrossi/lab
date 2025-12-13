// Variables for k3s service. Map control plane and worker nodes.
variable "ostemplate" {
  description = "LXC template for k3s nodes"
  type        = string
  default     = "local:vztmpl/almalinux-9-amd64-cloud-20250725-rootfs.tar.xz"
}
variable "ct_root_password" {
  type      = string
  sensitive = true
}
variable "ct_ssh_keys" {
  type      = string
  sensitive = true
}
variable "network_bridge" {
  type    = string
  default = "VLAN10"
}
variable "network_gw" {
  type    = string
  default = "192.168.10.1"
}

variable "control_plane" {
  description = "List of control plane node definitions (objects with hostname, vmid, target_node, ip)"
  type = list(object({ hostname = string, vmid = number, target_node = string, ip = string }))
  default = []
}

variable "workers" {
  description = "List of worker node definitions (objects with hostname, vmid, target_node, ip)"
  type = list(object({ hostname = string, vmid = number, target_node = string, ip = string }))
  default = []
}
