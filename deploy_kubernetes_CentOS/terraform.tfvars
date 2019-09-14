# vCenter connection
vsphere_vcenter = "vc03.aperaturelabs.biz"
vsphere_user = "administrator@vsphere.local"
vsphere_password = "PASSWORD"
vsphere_unverified_ssl = "true"

# VM specifications
vsphere_datacenter = "VC03"
vsphere_vm_folder = "TPM03-AS"
vsphere_vm_name = "TPM03-K8-MASTER1"
vsphere_vm_resource_pool ="TPM03-AS"
vsphere_vm_template = "TPM03-AS/TPM03-CENTOS7-TEMPLATE"
vsphere_cluster = "MEGA-03"
vsphere_vcpu_number = "2"
vsphere_memory_size = "8192"
vsphere_datastore = "vsanDatastore"
vsphere_port_group = "TPM03-730"
vsphere_ipv4_address = "10.0.30.191"
vsphere_ipv4_netmask = "24"
vsphere_k8pod_network = "10.0.30.0/24"
vsphere_ipv4_gateway = "10.0.30.1"
vsphere_dns_servers = "10.0.0.2"
vsphere_domain = "aperaturelabs.biz"
vsphere_time_zone = "UTC"
vsphere_vm_password ="Veeam1!"

# K8 NODES 
vsphere_vm_name_k8n1 = "TPM03-K8-NODE1"
vsphere_vm_name_k8n2 = "TPM03-K8-NODE2"
vsphere_vm_name_k8n3 = "TPM03-K8-NODE3"

vsphere_ipv4_address_k8n1 = "10.0.30.192"
vsphere_ipv4_address_k8n2 = "10.0.30.193"
vsphere_ipv4_address_k8n3 = "10.0.30.194"