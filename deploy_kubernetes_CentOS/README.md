# Deploy Kubernetes Cluster with Terraform on vSphere 

## Description
Automated deployment of Kubernetes consisting of a Master and configurable Node Servers on CentOS based Virtual Machines

## Requirements
 - CentOS Template prepared and ready for deployment form vCenter - see example configuration http://everything-virtual.com/2016/05/06/creating-a-centos-7-2-vmware-gold-template/

## Configuration
All variables are configured in the terraform.tfvars file and passed through to the TF configuration files.

- vCenter Details

    vsphere_vcenter = ""
    vsphere_user = ""
    vsphere_password = ""

- VM Specifications

    vsphere_datacenter = ""
    vsphere_vm_folder = ""
    vsphere_vm_name = "" <This will be your master>
    vsphere_vm_resource_pool =""
    vsphere_vm_template = "
    vsphere_cluster = ""
    vsphere_vcpu_number = "2" <Reccomended>
    vsphere_memory_size = "8192" <Reccomended>
    vsphere_datastore = ""
    vsphere_port_group = "T
    vsphere_ipv4_address = ""
    vsphere_ipv4_netmask = ""
    vsphere_ipv4_gateway = ""
    vsphere_dns_servers = ""
    vsphere_domain = ""
    vsphere_time_zone = ""

 - Kubernetes Node Details

    vsphere_vm_name_k8n1 = ""
    vsphere_vm_name_k8n2 = ""
    vsphere_vm_name_k8n3 = ""
    vsphere_ipv4_address_k8n1 = ""
    vsphere_ipv4_address_k8n2 = ""
    vsphere_ipv4_address_k8n3 = ""
