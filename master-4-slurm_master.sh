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
chmod 400 /etc/munge/munge.key

# Correct perms & enable service
chown -R munge: /etc/munge/ /var/log/munge/
chmod 0700 /etc/munge/ /var/log/munge/
systemctl enable munge
systemctl start munge

# Install Slurm deps
yum -y install openssl openssl-devel pam-devel numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel rrdtool-devel ncurses-devel man2html libibmad libibumad rpmbuild mariadb-devel

# Install slurm
cd /tmp
wget https://download.schedmd.com/slurm/slurm-19.05.2.tar.bz2
rpmbuild -tb slurm-19.05.2.tar.bz2
yum -y install /root/rpmbuild/RPMS/x86_64/slurm*.rpm

# Copy slurm rpms to NFS for compute nodes to install
mkdir -p /nfsdata/slurm-rpms
cp /root/rpmbuild/RPMS/x86_64/slurm*.rpm /nfsdata/slurm-rpms/

# Correct perms
mkdir -p /var/spool/slurmctld
chown slurm: /var/spool/slurmctld
chmod 755 /var/spool/slurmctld
touch /var/log/slurmctld.log
chown slurm: /var/log/slurmctld.log
touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log

# Minimal slurm config
cat <<EOF >> /etc/slurm/slurm.conf
ControlMachine=master
ControlAddr=10.0.4.100
MpiDefault=none
ProctrackType=proctrack/pgid
ReturnToService=1
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmdPidFile=/var/run/slurmd.pid
SlurmdSpoolDir=/var/spool/slurmd
SlurmUser=slurm
StateSaveLocation=/var/spool/slurmctld
SwitchType=switch/none
TaskPlugin=task/none
FastSchedule=1
SchedulerType=sched/backfill
SelectType=select/linear
AccountingStorageType=accounting_storage/none
ClusterName=dev
JobAcctGatherType=jobacct_gather/none
SlurmctldLogFile=/var/log/slurmctld.log
SlurmdLogFile=/var/log/slurmd.log
#
# COMPUTE NODES
NodeName=compute01 NodeAddr=10.0.4.101 CPUs=1 State=UNKNOWN
NodeName=compute02 NodeAddr=10.0.4.102 CPUs=1 State=UNKNOWN
PartitionName=super Nodes=compute0[1-2] Default=YES MaxTime=INFINITE State=UP
EOF

# Start slurm
systemctl enable slurmctld
systemctl start slurmctld

# Check sinfo works
sinfo
