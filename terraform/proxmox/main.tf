provider "proxmox" {
  pm_api_url = "https://your-proxmox-ip:8006/api2/json"
  user       = "root@pam"
  password   = "your-password"
  insecure   = true
}

resource "proxmox_vm_qemu" "rke2_node" {
  count       = 3
  name        = "rke2-node-${count.index}"
  target_node = "proxmox-node"
  clone       = "rhel-template"
  full_clone  = true
  cores       = 2
  memory      = 4096
  disk {
    size = "40G"
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  os_type = "cloud-init"

  ipconfig0 = "ip=dhcp"

  sshkeys = file("~/.ssh/id_rsa.pub")
}
