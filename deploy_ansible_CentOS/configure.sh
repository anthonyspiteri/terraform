#!/usr/bin/env bash

yum -y update
yum -y install yum-utils
yum -y groupinstall development
yum -y install https://centos7.iuscommunity.org/ius-release.rpm
yum -y install python36u
yum -y install python36u-pip
yum -y install python36u-devel

echo 'alias python=python3.6' >> ~/.bashrc

systemctl reboot