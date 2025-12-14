resource "proxmox_vm_qemu" "vm" {
  vmid        = var.vmid
  name        = var.hostname
  target_node = var.target_node

  clone      = var.clone
  full_clone = var.full_clone

  os_type = "cloud-init"
  agent   = 1

  cpu {
    cores = var.cores
    type  = var.cpu_type
  }
  memory = var.memory
  scsihw = "virtio-scsi-pci"

  disks {
    scsi {
      scsi0 {
        disk {
          size    = var.disk_size
          storage = var.storage
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = var.storage
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.network_bridge
  }

  ipconfig0  = "ip=${var.network_ip},gw=${var.network_gw}"
  nameserver = var.nameserver
  ciuser     = var.ciuser
  sshkeys    = var.ssh_public_keys

  serial {
    id   = 0
    type = "socket"
  }

  onboot = var.onboot
  tags   = var.tags
}
