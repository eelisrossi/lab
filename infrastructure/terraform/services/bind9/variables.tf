// Variables extracted from bind9/terraform/lxc.tf (hardcoded values moved here)
variable "ns1_hostname" {
  type    = string
  default = "hlct-ns1"
}
variable "ns1_vmid" {
  type    = number
  default = 601
}
variable "ns1_target_node" {
  type    = string
  default = "eddie"
}

variable "ns2_hostname" {
  type    = string
  default = "hlct-ns2"
}
variable "ns2_vmid" {
  type    = number
  default = 602
}
variable "ns2_target_node" {
  type    = string
  default = "hactar"
}

variable "ostemplate" {
  type    = string
  default = "local:vztmpl/almalinux-10-default_20250930_amd64.tar.xz"
}

variable "ct_root_password" {
  type      = string
  sensitive = true
}
variable "ct_ssh_keys" {
  type      = string
  sensitive = true
}

variable "cores" {
  type    = number
  default = 1
}
variable "cpulimit" {
  type    = number
  default = 1
}
variable "memory" {
  type    = number
  default = 768
}
variable "swap" {
  type    = number
  default = 256
}

variable "storage" {
  type    = string
  default = "local-lvm"
}
variable "disk_size" {
  type    = string
  default = "8G"
}

variable "network_bridge" {
  type    = string
  default = "VLAN10"
}
variable "ns1_ip" {
  type    = string
  default = "192.168.10.5/24"
}
variable "ns2_ip" {
  type    = string
  default = "192.168.10.6/24"
}
variable "network_gw" {
  type    = string
  default = "192.168.10.1"
}

variable "nameserver" {
  type    = string
  default = "1.1.1.1"
}
variable "tags" {
  type    = string
  default = "almalinux;iac;lxc;dns"
}
