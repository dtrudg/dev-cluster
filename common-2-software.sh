#!/bin/bash

#########################################
# Useful software to have on the cluster
#########################################

# Utilities
yum -y install vim-enhanced htop iftop

# Development
yum -y groupinstall "Development Tools"
sudo yum install -y git golang openssl-devel libuuid-devel \
     libseccomp-devel squashfs-tools cryptsetup

# EPEL Singularity
yum -y install singularity

# OpenMPI
yum -y install openmpi3
