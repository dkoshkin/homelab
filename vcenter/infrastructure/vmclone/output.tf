output "id" {
  description = "The ID of the VM."
  value       = vsphere_virtual_machine.vm.id
}
output "default_ip_address" {
  description = "The private IP address of the VM."
  value       = vsphere_virtual_machine.vm.default_ip_address
}
