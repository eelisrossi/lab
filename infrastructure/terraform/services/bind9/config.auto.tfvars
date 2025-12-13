network_bridge = "VLAN10"
network_gw     = "192.168.10.1"

nameservers = [
  {
    hostname    = "hlct-ns1"
    vmid        = 601
    target_node = "eddie"
    ip          = "192.168.10.5/24"
  },
  {
    hostname    = "hlct-ns2"
    vmid        = 602
    target_node = "hactar"
    ip          = "192.168.10.6/24"
  },
]
