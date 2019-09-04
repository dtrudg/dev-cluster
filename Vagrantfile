# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w( vagrant-reload )
plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

Vagrant.configure(2) do |config|
  # Master will host SLURM, NFS, and Lustre
  config.vm.define "master" do |master|
    master.vm.box = "centos/7"
    master.vm.synced_folder ".", "/vagrant", disabled: true
    master.vm.network "private_network", ip: "10.0.4.100", nic_type: "virtio"
    master.vm.provider "virtualbox" do |v|
      v.memory = 2048  # lustre is greedy and segfaults with small RAM
      v.cpus = 2
      v.customize ['modifyvm', :id, '--nictype1', 'virtio']
    end
    master.vm.provider "virtualbox" do |vb|
      # 8 GB Volume for NFS
      if !File.exist?("nfs01.vdi")
#        vb.customize ["storagectl", :id, "--name", "SATA Controller", "--add", "sata" ]
        vb.customize ["createhd", "--filename", "nfs01.vdi", "--size", 8192, "--variant", "Fixed"]
        vb.customize ["modifyhd", "nfs01.vdi", "--type", "shareable"]
      end
      vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", 1, "--device", 0, "--type", "hdd", "--medium", "nfs01.vdi"]
      # 1 GB Volume for Lustre MGT (Config)
      if !File.exist?("mgt01.vdi")
        vb.customize ["createhd", "--filename", "mgt01.vdi", "--size", 1024, "--variant", "Fixed"]
        vb.customize ["modifyhd", "mgt01.vdi", "--type", "shareable"]
      end
      vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", 2, "--device", 0, "--type", "hdd", "--medium", "mgt01.vdi"]
      # 1 GB Volume for Lustre MDT (Metadata)
      if !File.exist?("mdt01.vdi")
        vb.customize ["createhd", "--filename", "mdt01.vdi", "--size", 1024, "--variant", "Fixed"]
        vb.customize ["modifyhd", "mdt01.vdi", "--type", "shareable"]
      end
      vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", 3, "--device", 0, "--type", "hdd", "--medium", "mdt01.vdi"]
      # 8 GB Volume for lustre OST (Data)
      if !File.exist?("ost01.vdi")
        vb.customize ["createhd", "--filename", "ost01.vdi", "--size", 8192, "--variant", "Fixed"]
        vb.customize ["modifyhd", "ost01.vdi", "--type", "shareable"]
      end
      vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", 4, "--device", 0, "--type", "hdd", "--medium", "ost01.vdi"]
    end

    # Provisioning scripts
    master.vm.provision "shell", inline: "hostnamectl set-hostname master"
    master.vm.provision "shell", path: "common-1-initial.sh"
    master.vm.provision "shell", path: "common-2-software.sh"
    master.vm.provision "shell", path: "master-1-lustre_kernel.sh"
    master.vm.provision :reload
    master.vm.provision "shell", path: "master-2-lustre_fs.sh"
    master.vm.provision "shell", path: "master-3-nfs_fs.sh"
    master.vm.provision "shell", path: "master-4-slurm_master.sh"
  end

  # Compute node 1
  config.vm.define "compute01" do |compute01|
    compute01.vm.box = "centos/7"
    compute01.vm.synced_folder ".", "/vagrant", disabled: true
    compute01.vm.network "private_network", ip: "10.0.4.101", nic_type: "virtio"
    compute01.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 1
      v.customize ['modifyvm', :id, '--nictype1', 'virtio']
    end
   compute01.vm.provision "shell", inline: "hostnamectl set-hostname compute01"
   compute01.vm.provision "shell", path: "common-1-initial.sh"
   compute01.vm.provision "shell", path: "common-2-software.sh"
   compute01.vm.provision "shell", path: "compute-1-lustre_client.sh"
   compute01.vm.provision "shell", path: "compute-2-nfs_client.sh"
   compute01.vm.provision "shell", path: "compute-3-slurm_client.sh"
  end

  # Compute node 2
  config.vm.define "compute02" do |compute02|
    compute02.vm.box = "centos/7"
    compute02.vm.synced_folder ".", "/vagrant", disabled: true
    compute02.vm.network "private_network", ip: "10.0.4.102", nic_type: "virtio"
    compute02.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 1
      v.customize ['modifyvm', :id, '--nictype1', 'virtio']
    end
    compute02.vm.provision "shell", inline: "hostnamectl set-hostname compute02"
    compute02.vm.provision "shell", path: "common-1-initial.sh"
    compute02.vm.provision "shell", path: "common-2-software.sh"
    compute02.vm.provision "shell", path: "compute-1-lustre_client.sh"
    compute02.vm.provision "shell", path: "compute-2-nfs_client.sh"
    compute02.vm.provision "shell", path: "compute-3-slurm_client.sh"
  end

end
