#!/bin/bash

##############################################
# Setup lustre filesystems 
##############################################

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

# Dependencies for DKMS or manual builds if we want to use a different
# lustre version
yum -y install epel-release
yum -y install \
  asciidoc audit-libs-devel automake bc \
  binutils-devel bison device-mapper-devel elfutils-devel \
  elfutils-libelf-devel expect flex gcc gcc-c++ git \
  glib2 glib2-devel hmaccalc keyutils-libs-devel krb5-devel ksh \
  libattr-devel libblkid-devel libselinux-devel libtool \
  libuuid-devel libyaml-devel lsscsi make ncurses-devel \
  net-snmp-devel net-tools newt-devel numactl-devel \
  parted patchutils pciutils-devel perl-ExtUtils-Embed \
  pesign python-devel redhat-rpm-config rpm-build systemd-devel \
  tcl tcl-devel tk tk-devel wget xmlto yum-utils zlib-devel

# Install lustre e2fsprogs
yum -y --nogpgcheck --disablerepo=* --enablerepo=e2fsprogs-wc \
    install e2fsprogs

# Install lustre kernel
yum -y --nogpgcheck --disablerepo=base,extras,updates \
    --enablerepo=lustre-server install \
    kernel \
    kernel-devel \
    kernel-headers \
    kernel-tools \
    kernel-tools-libs \
    kernel-tools-libs-devel


