#!/bin/bash

#####################################################
# Install slurm master
#####################################################

# Setup users
export MUNGEUSER=991
groupadd -g $MUNGEUSER munge
useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge
export SLURMUSER=992
groupadd -g $SLURMUSER slurm
useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm

# Install munge
yum -y install epel-release
yum -y install munge munge-libs munge-devel

# Create a munge key
echo "THIS_IS_NOT_A_VERY_SECURE_MUNGE_KEY_BUT_IT_WILL_DO" > /etc/munge/munge.key
chown munge.munge /etc/munge/munge.key

# Correct perms & enable service
chown -R munge: /etc/munge/ /var/log/munge/
chmod 0700 /etc/munge/ /var/log/munge/
systemctl enable munge
systemctl start munge

# Install Slurm deps
yum -y install openssl openssl-devel pam-devel numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel rrdtool-devel ncurses-devel man2html libibmad libibumad

# Install slurm
cd /tmp
wget https://github.com/SchedMD/slurm/archive/slurm-19-05-2-1.tar.gz
