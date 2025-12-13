output "nameserver_ips" {
  value = [for ns in module.nameservers : ns.ip_address]
}

output "nameserver_hostnames" {
  value = [for ns in module.nameservers : ns.hostname]
}
