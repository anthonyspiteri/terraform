#===============================================================================
# vSphere Resources
#===============================================================================

# Create a vSphere VM in the folder #
resource "vsphere_virtual_machine" "TPM03-ANSIBLE-01" {
  # VM placement #
  name             = var.vsphere_vm_name
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vsphere_vm_folder
  tags             = [data.vsphere_tag.tag.id]

  # VM resources #
  num_cpus = var.vsphere_vcpu_number
  memory   = var.vsphere_memory_size

  # Guest OS #
  guest_id = data.vsphere_virtual_machine.template.guest_id

  # VM storage #
  disk {
    label            = "${var.vsphere_vm_name}.vmdk"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
  }

  # VM networking #
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # Customization of the VM #
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.vsphere_vm_name
        domain    = var.vsphere_domain
        #time_zone = "${var.vsphere_time_zone}"
      }

      network_interface {
        ipv4_address = var.vsphere_ipv4_address
        ipv4_netmask = var.vsphere_ipv4_netmask
      }

      ipv4_gateway    = var.vsphere_ipv4_gateway
      dns_server_list = [var.vsphere_dns_servers]
      dns_suffix_list = [var.vsphere_domain]
    }
  }

  #Update CentOS and Prep Modules for Ansible #
  provisioner "file" {
    source      = "configure.sh"
    destination = "/tmp/configure.sh"

    connection {
      host     = self.default_ip_address
      type     = "ssh"
      user     = "root"
      password = var.vsphere_vm_password
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/configure.sh",
      "/tmp/configure.sh",
      "logout",
    ]

    on_failure = "continue"

    connection {
      host     = self.default_ip_address
      type     = "ssh"
      user     = "root"
      password = var.vsphere_vm_password
    }
  }

  #Install Extras for Windows, PowerShell and VMware Management
  provisioner "file" {
    source      = "configure2.sh"
    destination = "/tmp/configure2.sh"

    connection {
      host     = self.default_ip_address
      type     = "ssh"
      user     = "root"
      password = var.vsphere_vm_password
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/configure2.sh",
      "bash -x /tmp/configure2.sh",
      "exit",
    ]
    connection {
      host     = self.default_ip_address
      type     = "ssh"
      user     = "root"
      password = var.vsphere_vm_password
    }
  }

#Install PIP, WinRM and Ansible
  provisioner "remote-exec" {
    inline = [
      "python3 -m pip install --upgrade --force-reinstall pip",
      "pip3 install pyvmomi",
      "pip3 install pywinrm",
      "pip3 install pywinrm>=0.3.0",
      "pip3 install --ignore-installed pywinrm>=0.3.0",
      "python3 -m pip install --upgrade pip",
      "pip3 install ansible",
      "ansible --version",
    ]
    connection {
      host     = self.default_ip_address
      type     = "ssh"
      user     = "root"
      password = var.vsphere_vm_password
    }
  }
}