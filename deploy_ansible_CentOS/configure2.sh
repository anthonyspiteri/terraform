#!/usr/bin/env bash

#Basic package install

yum install -y git vim bind-utils
yum install -y krb5-devel krb5-libs krb5-workstation

#PIP and come advanced modules

yum install -y python-requests-kerberos
python -m pip install --upgrade pip
pip install pyvmomi
pip install pywinrm

pip install "pywinrm>=0.3.0"
pip install --ignore-installed "pywinrm>=0.3.0"

python -m pip install --upgrade pip
pip install ansible

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