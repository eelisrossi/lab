## k3s Cluster

### Templates

* name: templ-almalinux-10-eddie
    * ID in Proxmox: 9000
    * on host: eddie

* name: templ-almalinux-10-hactar
    * ID in Proxmox: 9001
    * on host: hactar

### VMs

* hlvm-k3s-c1: control plane node
    * on host: eddie
    * ID in Proxmox: 321
    * static ip: 192.168.20.21/24
    * gw: 192.168.20.1

* hlvm-k3s-w1: worker node
    * on host: eddie
    * ID in Proxmox: 331
    * static ip: 192.168.20.31/24
    * gw: 192.168.20.1

* hlvm-k3s-w2: worker node
    * on host: hactar
    * ID in Proxmox: 332
    * static ip: 192.168.20.32/24
    * gw: 192.168.20.1

