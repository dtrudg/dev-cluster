#!/bin/bash

################################################
# Mount NFS share from master
################################################

# Setup mounts & mount them
mkdir -p /nfs
if ! grep -q "nfs" /etc/fstab; then
    echo "master:/nfsdata        /nfs         nfs4  defaults,_netdev 0 0" >> /etc/fstab
fi

if ! mountpoint -q /nfs; then
    mount /nfs
fi

