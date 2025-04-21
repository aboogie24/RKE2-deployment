output "rke2_nodes" {
  value = [
    for vm in pvsphere_virtual_machine.rke2_node : {
      hostname = vm.name
      ip       = vm.default_ipv4_address
    }
  ]
}
