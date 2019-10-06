#===============================================================================
# vSphere Resources
#===============================================================================

# Create a vSphere VM in the folder #

resource "vsphere_virtual_machine" "VBR-PROXY" {
  # VM placement #
  count            = "${var.vsphere_proxy_number}"
  name             = "${var.vsphere_vm_name}-L${random_integer.priority.result}-${count.index + 1}"
  resource_pool_id = "${data.vsphere_resource_pool.resource_pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${var.vsphere_vm_folder}"
  tags             = ["${data.vsphere_tag.tag.id}"]

# VM resources #
  num_cpus = "${var.vsphere_vcpu_number}"
  memory   = "${var.vsphere_memory_size}"

  # Guest OS #
  guest_id              = "${data.vsphere_virtual_machine.template.guest_id}"

  # VM storage #
  disk {
    label            = "${var.vsphere_vm_name}.vmdk"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
  }

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }
 
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
 
    customize {
      linux_options {
        host_name = "${var.vsphere_vm_name}-L${random_integer.priority.result}-${count.index + 1}"
        domain    = "${var.vsphere_domain}"
        #time_zone = "${var.vsphere_time_zone}"
      }

      network_interface {
        ipv4_address = "${var.vsphere_ipv4_address_proxy_network}${"${var.vsphere_ipv4_address_proxy_host}" + count.index}"
        ipv4_netmask = "${var.vsphere_ipv4_netmask}"
      }

      ipv4_gateway    = "${var.vsphere_ipv4_gateway}"
      dns_server_list = ["${var.vsphere_dns_server1}", "${var.vsphere_dns_server2}"]
      dns_suffix_list = ["${var.vsphere_domain}"]
    }
  }

    provisioner "remote-exec" {
        inline = [
          "${lookup(var.remote_exec, var.vpshere_linux_distro)}",
        ]
      
        connection {
            type     = "ssh"
            user     = "root"
            password = "${lookup(var.linux_password, var.vpshere_linux_distro)}"
        }
    }
}