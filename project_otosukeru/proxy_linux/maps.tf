variable "vpshere_linux_distro" {
  description = "Select the Linux Distro"
}

variable "remote_exec" {
  default = {
    ubuntu = "sudo ufw allow from any to any port 2500 proto tcp"
    centos = "firewall-cmd --zone=public --add-port=2500/tcp --permanent; firewall-cmd --reload"
  }
}
variable "linux_template" {
  default = {
    ubuntu = "TPM03-AS/TPM03-UBUNTU-ROOT"
    centos = "TPM03-AS/TPM03-CENTOS7-TEMPLATE"
  }
}
variable "linux_password" {
  default = {
    ubuntu = "password$12"
    centos = "Veeam1!"
  }
}