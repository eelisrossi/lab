output "control_plane_ips" {
  value = [for n in var.control_plane : n.ip]
}

output "worker_ips" {
  value = [for n in var.workers : n.ip]
}

output "control_plane_hostnames" { value = [for n in var.control_plane : n.hostname] }
output "worker_hostnames" { value = [for n in var.workers : n.hostname] }
