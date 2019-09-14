<<<<<<< HEAD
# Deploy Kubernetes Cluster with Terraform on vSphere 

## Description
Automated deployment of Kubernetes consisting of a Master and three Node Servers on CentOS based Virtual Machines

## Requirements
 - CentOS Template prepared and ready for deplaoyment - see example configuration here
 - 

## Configuration
All variables are configured in the terraform.tfvars file and passed through to the TF configuration files. No other edits need to be made to the TF files. 

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

    There are two locations in the guest configuration scripts that need adjusting as well

  - configure.sh <modify DNS records to suit line 12 to 17 and enter in POD Network and Mast line 42>

    cat << EOF > /etc/hosts
    10.0.30.191 TPM03-K8-MASTER1
    10.0.30.192 TPM03-K8-NODE1
    10.0.30.193 TPM03-K8-NODE2
    10.0.30.194 TPM03-K8-NODE3
    EOF

    kubeadm init --pod-network-cidr=10.0.30.0/24

  - configurek8node.sh <modify DNS records to suit line 14 to 19>

    cat << EOF > /etc/hosts
    10.0.30.191 TPM03-K8-MASTER1
    10.0.30.192 TPM03-K8-NODE1
    10.0.30.193 TPM03-K8-NODE2
    10.0.30.194 TPM03-K8-NODE3
    EOF
