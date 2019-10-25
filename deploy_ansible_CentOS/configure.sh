#!/usr/bin/env bash

#Basic package install

yum install -y epel-release
yum update -y
yum install -y ansible git vim

#PIP and come advanced modules

yum install -y python-pip
pip install pyvmomi
pip install pywinrm

#Upgrade PIP

pip install --upgrade pip

#Extra Stuff based on vmarkus_k

mkdir /extras/
cd /extras/
git clone https://github.com/vmware/vsphere-automation-sdk-python.git
cd vsphere-automation-sdk-python/
pip install --upgrade --force-reinstall -r requirements.txt --extra-index-url file:///extras/vsphere-automation-sdk-python/lib

cd /extras/
curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
yum install -y powershell

#Create Default Vault Password

cat << EOF > ~/.vault_pass.txt
password123
EOF

#Show some info about Anisble

ansible --version