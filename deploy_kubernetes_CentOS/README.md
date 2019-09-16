
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


### vCenter connection

    vsphere_vcenter = "vc03.aperaturelabs.biz"
    vsphere_user = "administrator@vsphere.local"
    vsphere_password = "PASSWORD"
    vsphere_unverified_ssl = "true"

### VM specifications

    vsphere_datacenter = "VC03"
    vsphere_vm_folder = "TPM03-AS"
    vsphere_vm_name = "TPM03-K8-MASTER-T"
    vsphere_vm_resource_pool ="TPM03-AS"
    vsphere_vm_template = "TPM03-AS/TPM03-CENTOS7-TEMPLATE"
    vsphere_cluster = "MEGA-03"
    vsphere_vcpu_number = "2"
    vsphere_memory_size = "8192"
    vsphere_datastore = "vsanDatastore"
    vsphere_port_group = "TPM03-730"
    vsphere_ipv4_address = "10.0.30.196"
    vsphere_ipv4_netmask = "24"
    vsphere_k8pod_network = "10.0.30.0/24"
    vsphere_ipv4_gateway = "10.0.30.1"
    vsphere_dns_servers = "10.0.0.2"
    vsphere_domain = "aperaturelabs.biz"
    vsphere_time_zone = "UTC"
    vsphere_vm_password ="Veeam1!"

### K8 NODES

    vsphere_k8_nodes = "1"
    vsphere_vm_name_k8n1 = "TPM03-K8-NODE-T"
    vsphere_ipv4_address_k8n1_network = "10.0.30."
    vsphere_ipv4_address_k8n1_host ="197"
