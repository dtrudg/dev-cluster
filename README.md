# dev-cluster

This is a Vagrant environment that provides a minimal virtual HPC cluster with
some commonly encountered filesystems and tools:

  - [X] CentOS 7 Base
  - [ ] 1 master node, 2 compute nodes
  - [ ] NFS exported from master to compute nodes
  - [ ] Lustre exported from master to compute nodes
  - [ ] Slurm 19.05.2 installed and configured
  - [ ] Singularity 3.4.0 installed on all nodes
  
  
Caveats:

  * The lustre setup is very simple. There are 1 each of MGS/MDT/OST and they
    are all running on the master VM.
  * The lustre and NFS volumes are 8GB each. You may wish to increase their size.
  * The master VM is allocated 2GB RAM and 2 CPU by default. You will want to
    increase this if you have the capacity.
  * The compute node VMs are allocated 1GB RAM and 1 CPU by default. You will
    want to increase this if you have the capacity.
    
