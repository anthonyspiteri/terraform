#!/usr/bin/env bash

systemctl stop firewalld
systemctl disable firewalld

swapoff -a
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

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

yum install -y docker kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet

cat << EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
 
sysctl --system

kubeadm init --pod-network-cidr=10.0.30.0/24

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get pods --all-namespaces

export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"

#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml

kubectl get pods --all-namespaces
kubectl get nodes
