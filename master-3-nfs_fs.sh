#!/bin/bash

#####################################################
# Setup NFS server
#####################################################

# Format the volume for the nfs server
if ! mountpoint -q /nfsdata; then
  mkfs.ext4 /dev/sdb
fi

# Mount locally
mkdir -p /nfsdata
if ! grep 'nfsdata' /etc/fstab; then
    echo "/dev/sdb        /nfsdata        ext4       defaults     0  2" >> /etc/fstab
fi

if ! mountpoint -q /nfsdata; then
    mount /nfsdata
fi

# Allow unrestricted perms
chmod 777 /nfsdata

# Install & start NFS services
yum install -y nfs-utils
systemctl start nfs-server rpcbind
systemctl enable nfs-server rpcbind

# Export over NFS
echo "/nfsdata 10.0.4.0/24(rw,sync,no_root_squash)" > /etc/exports
exportfs -r

# Mount the filesystem to our own host
mkdir -p /nfs
if ! grep -q "master:nfsdata" /etc/fstab; then
    echo "master:/nfsdata        /nfs         nfs4  defaults,_netdev 0 0" >> /etc/fstab
fi

if ! mountpoint -q /nfs; then
    mount /nfs
fi
