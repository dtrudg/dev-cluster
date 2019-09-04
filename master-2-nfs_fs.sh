#!/bin/bash

#####################################################
# Setup NFS server
#####################################################

# Format the volume for the nfs server
mkfs.ext4 /dev/sdb

# Mount locally
mkdir -p /nfsdata
echo "/dev/sdb        /nfsdata        ext4       defaults     0  2" >> /etc/fstab
mount /nfsdata

# Allow unrestricted perms
chmod 777 /nfsdata

# Install & start NFS services
yum install -y nfs-utils
systemctl start nfs-server rpcbind
systemctl enable nfs-server rpcbind

# Export over NFS
echo "/nfsdata 10.0.4.0/24(rw,sync,no_root_squash)" > /etc/exports
exportfs -r

