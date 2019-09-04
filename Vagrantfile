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
  config.vm.define "master" do |mds01|
    mds01.vm.box = "centos/7"
    # installing lustre kernel removes virtualbox guest additions
    mds01.vm.synced_folder ".", "/vagrant", disabled: true
    mds01.vm.network "private_network", ip: "10.0.4.1", nic_type: "virtio"
    mds01.vm.provider "virtualbox" do |v|
      v.memory = 2048  # lustre is greedy and segfaults with small RAM
      v.cpus = 2
      v.customize ['modifyvm', :id, '--nictype1', 'virtio']
    end
    mds01.vm.provider "virtualbox" do |vb|
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
    config.vm.probision "shell", inline: "hostnamectl set-hostname master"
    config.vm.provision "shell", path: "common-1-initial.sh"
    config.vm.provision "shell", path: "common-2-lustre_kernel.sh"
    config.vm.provision :reload
    config.vm.provision "shell", path: "master-1-lustre_fs.sh"
    config.vm.provision "shell", path: "master-2-nfs_fs.sh"
    config.vm.provision "shell", path: "master-3-slurm_master.sh"

  end

  # # Compute node 1
  # config.vm.define "compute01" do |centos7|
  #   centos7.vm.box = "centos/7"
  #   centos7.vm.network "private_network", ip: "10.0.4.2", nic_type: "virtio"
  #   centos7.vm.provider "virtualbox" do |v|
  #     v.memory = 1024
  #     v.cpus = 1
  #     v.customize ['modifyvm', :id, '--nictype1', 'virtio']
  #   end
  #  config.vm.probision "shell", inline: "hostnamectl set-hostname compute01"
  #  config.vm.provision "shell", path: "common-1-initial.sh"
  #  config.vm.provision "shell", path: "common-2-lustre_kernel.sh"
  #  config.vm.provision "shell", path: "compute-1-lustre_client.sh"
  #  config.vm.provision "shell", path: "compute-2-slurm_client.sh"
  # end

  # # Compute node 2
  # config.vm.define "compute02" do |centos7|
  #   centos7.vm.box = "centos/7"
  #   centos7.vm.network "private_network", ip: "10.0.4.2", nic_type: "virtio"
  #   centos7.vm.provider "virtualbox" do |v|
  #     v.memory = 1024
  #     v.cpus = 1
  #     v.customize ['modifyvm', :id, '--nictype1', 'virtio']
  #   end
  # end

end
