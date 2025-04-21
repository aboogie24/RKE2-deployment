output "rke2_nodes" {
  value = [
    for vm in proxmox_vm_qemu.rke2_node : {
      hostname = vm.name
      ip       = vm.default_ipv4_address
    }
  ]
}
