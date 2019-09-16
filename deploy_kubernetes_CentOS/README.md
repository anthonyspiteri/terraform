
# Deploy Kubernetes Cluster with Terraform on vSphere 

## Description
Automated deployment of Kubernetes consisting of a Master and configurable Node Servers on CentOS based Virtual Machines

## Requirements
 - CentOS Template prepared and ready for deployment form vCenter - see example configuration http://everything-virtual.com/2016/05/06/creating-a-centos-7-2-vmware-gold-template/

#### Version 2.0
> Added support for Update 4 PowerShell command to mananage new Cloud Credentials

> Added Scale Out Backup Repository Support with option for Capacity Tier

> Merged BR-Condigure-Veeam code into main PowerShell and config.json (https://github.com/anthonyspiteri/powershell/tree/master/BR-Configure-Veeam)

> Added better logic for processing Backup Repository selection for Default Job Creation

## Getting Started

    EXAMPLE - PS C:\>deploy_veeam_sddc_release.ps1 -Runall
    EXAMPLE - PS C:\>deploy_veeam_sddc_release.ps1 -Runall -LocalLinuxRepoDeploy
    EXAMPLE - PS C:\>deploy_veeam_sddc_release.ps1 -RunVBRConfigure -NoLinuxRepo
    EXAMPLE - PS C:\>deploy_veeam_sddc_release.ps1 -ClearVBRConfig
    EXAMPLE - PS C:\>deploy_veeam_sddc_release.ps1 -RunVBRConfigure -ConfigureSOBR -NoCapacityTier

The Terraform templates included in this repository requires Terraform to be available locally on the machine running the templates.  Before you begin, please verify that you have the following information:

1. Download [Terraform](https://www.terraform.io/downloads.html) (minimum tested version 0.11.8) binary to your workstation.
2. Gather the VMware credentials required to communicate to vCenter
3. Update the variable values in the newly created `terraform.tfvars` file.


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
