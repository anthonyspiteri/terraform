/*
Output Variables
*/
output "Master IP Address" {
  value = "${var.vsphere_ipv4_address}"
}

output "Node IP Addresses" {
  value = "${vsphere_virtual_machine.TPM03-K8-NODE.*.default_ip_address}"
}
