/*
Output Variables
*/
output "proxy_ip_addresses" {
  value = "${vsphere_virtual_machine.VBR-PROXY.*.default_ip_address}"
}
