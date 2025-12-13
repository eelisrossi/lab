output "control_plane_ips" {
  value = [for node in module.k3s_control_plane : node.ip]
}

output "worker_ips" {
  value = [for node in module.k3s_workers : node.ip]
}
