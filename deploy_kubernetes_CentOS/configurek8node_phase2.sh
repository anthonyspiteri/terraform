#!/usr/bin/env bash

systemctl enable --now kubelet

yum install -y docker

systemctl enable docker && systemctl start docker
 
sysctl --system

echo '1' > /proc/sys/net/ipv4/ip_forward
echo "1" > /proc/sys/net/bridge/bridge-nf-call-iptables