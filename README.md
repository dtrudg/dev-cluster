# dev-cluster

This is a Vagrant environment that provides a minimal virtual HPC cluster with
some commonly encountered filesystems and tools:

  - [X] CentOS 7 Base
  - [X] 1 master node, 2 compute nodes
  - [X] NFS exported from master to compute nodes
  - [X] Lustre exported from master to compute nodes
  - [X] Slurm 19.05.2 installed and configured
  - [X] Singularity from EPEL
  - [X] Dev tools to build Singularity from source
  - [X] OpenMPI (from repos, 3.0.2-1)
 
 
## How to use:

```
# bring up the master
#
# This will fail the first time, as CentOS base image has an IDE controller
# We need a SATA controller, and there is no easy idempotent way to add one in a
# Vagrantfile such that initial and re-provisioning will succeeed.
#
vagrant up master

# Add the SATA controller we need
VBoxManage storagectl $(cat .vagrant/machines/master/virtualbox/id) --add sata --name "SATA Controller"

# Bring up the master properly now
vagrant up master

# bring up the compute nodes
vagrant up compute01 compute02

```

In this minimal cluster we can be naughty and use the master node as a login
node. For your experiments, note that currently:

 - The cluster has a common `vagrant` user across all nodes - this is the user
   you should use for Slurm jobs
 - $HOME is not mounted over NFS (yet)
 - Put anything you need across the cluster into `/nfs` or `/lustre`
 - OpenMPI is available as a module via `module load mpi/openmpi3-x86_64`


```
# login to master
$ vagrant ssh

# Run hostname across the cluster (2 nodes)
$ srun -N 2 hostname

# /nfs & /lustre are mounted across master and nodes
# Run an interactive session on a node
# Look in the shared filesystems
$ srun --pty /bin/bash
$ ls /nfs /lustre
```
  
## Caveats

  * The lustre setup is very simple. There are 1 each of MGS/MDT/OST and they
    are all running on the master VM.
  * The lustre and NFS volumes are 8GB each. You may wish to increase their size.
  * The master VM is allocated 2GB RAM and 2 CPU by default. You will want to
    increase this if you have the capacity.
  * The compute node VMs are allocated 1GB RAM and 1 CPU by default. You will
    want to increase this if you have the capacity.
    
