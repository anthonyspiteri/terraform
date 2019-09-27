# Project Ōtosukēru 

![enter image description here](https://sociorocketnewsen.files.wordpress.com/2017/12/gp-41.png)

## Description
The aim of this project, is to have Veeam Proxies automtically deployed and configured for ephemeral use by Veeam Backup & Replication jobs. It has the ability to deploy Veeam Backup Proxy VMs to vSphere and configures them in Veeam Backup & Replication and also the ability to remove the configuration and destory the VMs. A pre and post script can be configured within the Veeam Job and run everytime the job is executed.

There is a master PowerShell script that executes all the code as does the following:

- Connects to a Veeam Backup & Replication Server
- Gets all Backup Jobs and derives the number of VMs total being backed up
- Works out how many Veeam Proxies to deploy and sets that as a proxy count value
- Executes Terraform apply using the proxy count value
- Terraform deploys Proxies VM to vCenter, configures VM with name and static IP, and adds GustOS to domain
- PowerShell adds Proxies to Backup & Replication

- PowerShell then removed Proxies from Backup & Replication
- Destroys the Proxy VMs with Terraform

## Requirements

1. Download [Terraform](https://releases.hashicorp.com/terraform/0.11.7/) (tested version 0.11.7 - 0.12.x will not work) binary to your workstation.
2. Terraform vSphere Provider
3. Pre configured Windows or Linux Template accessible from vCenter
4. Gather the VMware credentials required to communicate to vCenter
5. Update the variable values in the 'terraform.tfvars' file.
6. Update path in 'pre.bat' and 'post.bat'

#### Version 0.3
> First pre release for testing 

## Getting Started

Ensure all configuration variables are set as per requirements and as per below.

    PARAMETER Windows - Will deploy Windows Template for Veeam Proxy VMs and configure Veeam Server
    PARAMETER Remove - Will remove configuration from Veeam Server and destroy Proxy VMs

    EXAMPLE - PS C:\>deploy_otosukeru.ps1 -Windows
    EXAMPLE - PS C:\>deploy_otosukeru.ps1 -Remove

To Create and Configure Proxies:

    ./deploy_otosukeru.ps1 -Windows

or

    ./pre.bat

To Destroy and Remove Proxies:

    ./deploy_otosukeru.ps1 -Remove

or

    ./post.bat
    
## Configuration

## config.json Breakdown
All of the variables are configured in the config.json file. Nothing is required to be changed in the main depply script.

    {
	    "Default": {
		    "Path":"c:\\Users\\anthonyspiteri\\Downloads\\Project_Otosukeru",
		    "TFOutputProxy":"c:\\Users\\anthonyspiteri\\Downloads\\PProject_Otosukeru\\proxy_ip.json"
	    },
    
    "LinuxProxy": {
		    "Username": "centos",
		    "LocalUsername":"root",
		    "LocalPassword":"Veeam1!"
		},
    
    "VBRDetails": {
		    "Server":"TPM03-VBR01.AperatureLabs.biz",
		    "Username":"APLABS\\service.veeam",
		    "Password":"password$12"
	    }
    }

## terraform.tfvars Breakdown
All variables are configured in the terraform.tfvars file and passed through to the TF configuration files.

### vCenter connection

    vsphere_vcenter = "vc03.aperaturelabs.biz"
    vsphere_user = "administrator@vsphere.local"
    vsphere_password = "PASSWORD"
    vsphere_unverified_ssl = "true"

### VM specifications

The following variables can be adjusted dependant on installation vSphere platform. The one var to look out for is the K8 Pod Network, which is used during the setup of Kubernetes.

    vsphere_datacenter = "VC03"
    vsphere_vm_folder = "TPM03-AS"
    vsphere_vm_name = "VBR-PROXY-"
    vsphere_vm_resource_pool ="TPM03-AS"
    vsphere_vm_template = "TPM03-AS/WIN2K19-TEST"
    vsphere_vm_firmware = "efi"
    vsphere_cluster = "MEGA-03"
    vsphere_vcpu_number = "2"
    vsphere_memory_size = "8192"
    vsphere_datastore = "vsanDatastore"
    vsphere_port_group = "TPM03-730"
    vsphere_ipv4_address = "10.0.30.210"
    vsphere_ipv4_netmask = "24"
    vsphere_ipv4_gateway = "10.0.30.1"
    vsphere_dns_server1 = "10.0.0.2"
    vsphere_dns_server2 = "10.0.0.3"
    vsphere_domain = "aperaturelabs.biz"
    vsphere_time_zone = "UTC"
    vsphere_vm_password ="Veeam1!"
    vsphere_tag_category ="TPM03"
    vsphere_tag_name ="TPM03-NO-BACKUP"

The varibales below dictate the number of nodes (if run outside of PowerShell Proxy Logic), the first three octects of the IP Subnet and then the starting host address of proxies. The names and IP addresses of Proxies are incremented based on the number of Proxies being deployed.

### Proxy Configuration 

    vsphere_proxy_number = "3"
    vsphere_ipv4_address_proxy_network = "10.0.30."
    vsphere_ipv4_address_proxy_host ="210"

## To Do

 - [ ] Complete option for Linux Proxy deployment and configuration (waiting for PowerShell commands in v10)
 - [ ] Add option to choose DCHP or Static IP Allocation
 - [ ] Add ability to scale Proxies outside of pre and post job scripts
 - [ ] Add error checking to ensure correct exit conditions
 - [ ] Add option to not join GuestOS to domain
 - [ ] Fix compatability issues with Terraform 0.12.x - main issue is JSON output not being correct format for PowerShell import
 - [ ] Improve basic Proxy sizing logic
