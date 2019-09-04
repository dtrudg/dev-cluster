#!/bin/bash

################################################
# Install Lustre Kernel Modules and Setup client
################################################

# Setup repo
cat >/etc/yum.repos.d/lustre-repo.repo <<\__EOF
[lustre-server]
name=lustre-server
baseurl=https://downloads.whamcloud.com/public/lustre/latest-release/el7/server
# exclude=*debuginfo*
gpgcheck=0

[lustre-client]
name=lustre-client
baseurl=https://downloads.whamcloud.com/public/lustre/latest-release/el7/client
# exclude=*debuginfo*
gpgcheck=0

[e2fsprogs-wc]
name=e2fsprogs-wc
baseurl=https://downloads.whamcloud.com/public/e2fsprogs/latest/el7
# exclude=*debuginfo*
gpgcheck=0
__EOF

# Install client modules
yum -y --nogpgcheck --enablerepo=lustre-client install \
    kmod-lustre-client \
    lustre-client

modprobe lustre
modprobe lnet

# Setup our lnet network
if ! lnetctl ping master; then
    lnetctl net add --net tcp0 --if eth1
    lnetctl export > /etc/lnet.conf
fi

# Setup mounts & mount them
mkdir -p /lustre
if ! grep -q "lustre" /etc/fstab; then
    echo "master@tcp0:/lustre1        /lustre         lustre  defaults,_netdev 0 0" >> /etc/fstab
fi

if ! mountpoint -q /lustre; then
    mount /lustre
fi

