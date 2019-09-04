#!/bin/bash

##############################################
# Basic OS Setup
##############################################

# Host resolution
if ! grep -q "master" /etc/hosts; then
    echo "10.0.4.100 master" >> /etc/hosts
    echo "10.0.4.101 compute01" >> /etc/hosts
    echo "10.0.4.102 compute02" >> /etc/hosts
fi

# Disable selinux and firewall
setenforce 0
cat >/etc/selinux/config<<__EOF
SELINUX=disabled
SELINUXTYPE=targeted
__EOF
systemctl disable firewalld
systemctl stop firewalld
