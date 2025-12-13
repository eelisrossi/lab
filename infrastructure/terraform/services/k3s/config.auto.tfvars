network_bridge = "VLAN20"
network_gw     = "192.168.20.1"
nameserver     = "192.168.10.5 192.168.10.6"  # Use bind9 DNS servers

control_plane = [
  {
    hostname    = "hlvm-k3s-c1"
    vmid        = 321
    target_node = "eddie"
    ip          = "192.168.20.21"
  },
]

workers = [
  {
    hostname    = "hlvm-k3s-w1"
    vmid        = 331
    target_node = "eddie"
    ip          = "192.168.20.31"
  },
  {
    hostname    = "hlvm-k3s-w2"
    vmid        = 332
    target_node = "hactar"
    ip          = "192.168.20.32"
  },
]
