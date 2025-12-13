variable "ct_root_password" {
  type      = string
  sensitive = true
}

variable "ct_ssh_keys" {
  type      = string
  sensitive = true
}

variable "bridge" {
  type    = string
  default = "VLAN10"
}
