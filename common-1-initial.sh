#!/bin/bash

##############################################
# Basic OS Setup
##############################################

# Host resolution
echo "10.0.4.1 master" >> /etc/hosts
echo "10.0.4.2 compute01" >> /etc/hosts
echo "10.0.4.3 compute02" >> /etc/hosts

# Disable selinux and firewall
setenforce 0
cat >/etc/selinux/config<<__EOF
SELINUX=disabled
SELINUXTYPE=targeted
__EOF
systemctl disable firewalld
systemctl stop firewalld
