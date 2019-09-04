#!/bin/bash

################################################
# Install Lustre Kernel Modules and Setup client
################################################

# Install modules into the now running lustre kernel
yum --nogpgcheck --enablerepo=lustre-client-2.10.0 install \
    kmod-lustre-client \
    lustre-client

# Setup our lnet network
if ! lnetctl ping master; then
    lnetctl net add --net tcp0 --if eth1
    lnetctl export > /etc/lnet.conf
fi

# Setup mounts & mount them
mkdir -p /lustre
if ! grep -q "lustre" /etc/fstab; then
    echo "master@tcp01:/lustre1        /lustre         lustre  defaults_netdev 0 0" >> /etc/fstab
fi

if ! mountpoint -q /lustre; then
    mount /lustre
fi

