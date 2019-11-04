# Deploy Ansible Control Server with Terraform on vSphere 

## Description
Quick and nasty automated deployment of Anisble consisting of a Contol Server on CentOS based Virtual Machine
(Related Blog Post - https://anthonyspiteri.net/?p=8928&preview=true)

## Requirements
 - CentOS Template prepared and ready for deployment form vCenter - see example configuration http://everything-virtual.com/2016/05/06/creating-a-centos-7-2-vmware-gold-template/
 
The Terraform templates included in this repository requires Terraform to be available locally on the machine running the templates.  Before you begin, please verify that you have the following information:

1. Download [Terraform](https://releases.hashicorp.com/terraform/) (tested version 0.12.07) binary to your workstation.
2. Terraform vSphere Provider
3. Gather the VMware credentials required to communicate to vCenter
4. Update the variable values in the `terraform.tfvars`file.
5. Update the variable values in the `main.tfvars`file.

#### Version 1.0
> Deploys VM from CentOS Template and installs Anisble along with some added packages and modules

## Execution

Ensure all configuration variables are set as per below.

    ./terraform init
    ./terraform plan
    
## Configuration
All variables are configured in the terraform.tfvars file and passed through to the TF configuration files.

### vCenter connection

    vsphere_vcenter = "vc03.aperaturelabs.biz"
    vsphere_user = "administrator@vsphere.local"
    vsphere_password = "PASSWORD"
    vsphere_unverified_ssl = "true"

### VM specifications

The following variables can be adjusted dependant on installation vSphere platform.

    vsphere_datacenter = "VC03"
    vsphere_vm_folder = "TPM03-AS"
    vsphere_vm_name = "TPM03-ANSIBLE-01"
    vsphere_vm_resource_pool ="TPM03-AS"
    vsphere_vm_template = "TPM03-AS/TPM03-CENTOS7-TEMPLATE"
    vsphere_cluster = "MEGA-03"
    vsphere_vcpu_number = "2"
    vsphere_memory_size = "8192"
    vsphere_datastore = "vsanDatastore"
    vsphere_port_group = "TPM03-730"
    vsphere_ipv4_address = "10.0.30.196"
    vsphere_ipv4_netmask = "24
    vsphere_ipv4_gateway = "10.0.30.1"
    vsphere_dns_servers = "10.0.0.2"
    vsphere_domain = "aperaturelabs.biz"
    vsphere_time_zone = "UTC"
    vsphere_vm_password ="Veeam1!"

## To Do

 - [ ] Work out how the hell to actually use Anisible
