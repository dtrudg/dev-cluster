#!/bin/bash

################################################
# Install Lustre Kernel Modules and Basic Tools
################################################

# Install modules into the now running lustre kernel
yum -y --nogpgcheck --enablerepo=lustre-server install \
  kmod-lustre \
  kmod-lustre-osd-ldiskfs \
  lustre-osd-ldiskfs-mount \
  lustre \
  lustre-resource-agents

# Enable and start lustre & lnet
systemctl enable lustre
systemctl start lustre
systemctl enable lnet
systemctl start lnet

# Setup our lnet network
lnetctl net add --net tcp0 --if eth1
lnetctl export > /etc/lnet.conf

# Format the lustre volumes
mkfs.lustre --reformat --fsname=lustre1 --mgs /dev/sdc
mkfs.lustre --reformat --fsname=lustre1 --mgsnode=master@tcp0 --mdt --index=0 /dev/sdd
mkfs.lustre --reformat --mgsnode=master@tcp0 --fsname=lustre --ost --index=0 /dev/sde

# Setup mounts & mount them
mkdir -p /mgs /mdt /ost
echo "/dev/sdc        /mgs         lustre  defaults_netdev 0 0" >> /etc/fstab
echo "/dev/sdd        /mdt         lustre  defaults_netdev 0 0" >> /etc/fstab
echo "/dev/sde        /ost         lustre  defaults_netdev 0 0" >> /etc/fstab
mount /mgs
mount /mdt
mount /ost
