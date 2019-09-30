# vCenter connection
vsphere_vcenter = "vc03.aperaturelabs.biz"
vsphere_user = "administrator@vsphere.local"
vsphere_password = "PASSWORD"
vsphere_unverified_ssl = "true"

# AD Credentials
vsphere_ad_domain = "aperaturelabs.biz"
vsphere_ad_username ="APLABS\\service.veeam"
vsphere_ad_password = "password$12"

# VM specifications
vsphere_datacenter = "VC03"
vsphere_vm_folder = "TPM03-AS"
vsphere_vm_name = "VBR-PROXY-"
vsphere_vm_resource_pool ="TPM03-AS"
vsphere_vm_template = "TPM03-AS/WIN2K19-TEST"
vsphere_vm_firmware = "efi"
vsphere_cluster = "MEGA-03"
vsphere_vcpu_number = "4"
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

# Proxy Configuration 
vsphere_proxy_number = "3"
vsphere_ipv4_address_proxy_network = "10.0.30."
vsphere_ipv4_address_proxy_host ="210"
