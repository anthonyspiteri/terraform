#!/usr/bin/env bash

systemctl stop firewalld
systemctl disable firewalld

swapoff -a
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo sysctl net.bridge.bridge-nf-call-iptables=1

cat << EOF > /etc/hosts
10.0.30.191 TPM03-K8-MASTER1
10.0.30.192 TPM03-K8-NODE1
10.0.30.193 TPM03-K8-NODE2
10.0.30.194 TPM03-K8-NODE3
EOF

cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet

yum install -y docker

systemctl enable docker && systemctl start docker
 
sysctl --system

echo '1' > /proc/sys/net/ipv4/ip_forward
echo "1" > /proc/sys/net/bridge/bridge-nf-call-iptables