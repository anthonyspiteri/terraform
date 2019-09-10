#===============================================================================
# vSphere Resources
#===============================================================================

# Create a vSphere VM in the folder #
resource "vsphere_virtual_machine" "TPM03-K8-NODE1" {
  # VM placement #
  name             = "${var.vsphere_vm_name_k8n1}"
  resource_pool_id = "${data.vsphere_resource_pool.resource_pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${var.vsphere_vm_folder}"

  #depends_on = ["vsphere_virtual_machine.TPM03-K8-MASTER"]

  # VM resources #
  num_cpus = "${var.vsphere_vcpu_number}"
  memory   = "${var.vsphere_memory_size}"

  # Guest OS #
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  # VM storage #
  disk {
    label            = "${var.vsphere_vm_name}.vmdk"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
  }

  # VM networking #
  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  # Customization of the VM #
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "${var.vsphere_vm_name_k8n1}"
        domain    = "${var.vsphere_domain}"
        #time_zone = "${var.vsphere_time_zone}"
      }

      network_interface {
        ipv4_address = "${var.vsphere_ipv4_address_k8n1}"
        ipv4_netmask = "${var.vsphere_ipv4_netmask}"
      }

      ipv4_gateway    = "${var.vsphere_ipv4_gateway}"
      dns_server_list = ["${var.vsphere_dns_servers}"]
      dns_suffix_list = ["${var.vsphere_domain}"]
    }
  }

provisioner "file" {
        source      = "configurek8node.sh"
        destination = "/tmp/configurek8node.sh"

        connection {
            type     = "ssh"
            user     = "root"
            password = "Veeam1!"
        }
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/configurek8node.sh",
            "/tmp/configurek8node.sh",
        ]
        connection {
            type     = "ssh"
            user     = "root"
            password = "Veeam1!"
        }
    }

}