# Deploy Kubernetes Cluster with Terraform on vSphere 

## Description
Automated deployment of Kubernetes consisting of a Master and configurable Node Servers on CentOS based Virtual Machines

## Requirements
 - CentOS Template prepared and ready for deployment form vCenter - see example configuration http://everything-virtual.com/2016/05/06/creating-a-centos-7-2-vmware-gold-template/

#### Version 2.0
> Added ability to deploy Kubernetes Nodes dynamically via terraform apply and also via declared variable

> Split configuration scripts up to allow use of variables for dynamic deployment leveraging remote-exec for file and inline commands

## Execution

Ensure all configuration variables are set as per below.

    ./terraform init
    ./terraform plan
 
Can be applied with or without number of nodes variable. If not specified will use node count declared in terraform.tfvars otherwise specified count with apply will take precedence.
 
    ./terraform apply
    ./terraform apply --var 'vsphere_k8_nodes=3' --auto-approve
    
After deployment you need to use the kubeadm join command to join the nodes to the cluster. The required command will be outputed via the remote-exec script as shown below

![enter image description here](https://snipboard.io/L9Zqpa.jpg)

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

The following variables can be adjusted dependant on installation vSphere platform. The one var to look out for is the K8 Pod Network, which is used during the setup of Kubernetes.

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

The varibales below dictate the number of nodes (if the var is not specified during the apply), the name of the nodes and then the first three octects of the IP Subnet and then the starting host address of nodes. The names and IP addresses of nodes are incremented based on the number of nodes being deployed.

    vsphere_k8_nodes = "1"
    vsphere_vm_name_k8n1 = "TPM03-K8-NODE-T"
    vsphere_ipv4_address_k8n1_network = "10.0.30."
    vsphere_ipv4_address_k8n1_host ="197"

## To Do

 - [ ] Update Outputs to reflect Node IPs
 - [ ] Automate kubeadm join commands
 - [ ] Remove Node from Cluster automatically
 - [ ] Install Kubernetes Dashboard
