# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

MASTER_YAML = File.join(File.dirname(__FILE__), "master.yaml")
NODE_YAML = File.join(File.dirname(__FILE__), "node.yaml")

# Define parameters for cluster
# node_instances is the number of worker or minion nodes in
# ADDITION to the node-master
# Adjust these params according to the resources available on your
# machine
$node_instances = 3
$update_channel = "alpha"
$enable_serial_logging = false
$vm_master_memory = 512
$vm_master_cpus = 1
$vm_node_memory = 1024
$vm_node_cpus = 1

Vagrant.configure("2") do |config|
  # Yes we are still using vagrant old insecure key. So don't expose these instances outside
  # your box.
  # YOU HAVE BEEN WARNED.
  config.ssh.insert_key = false

  config.vm.box = "coreos-%s" % $update_channel
  config.vm.box_version = "= 598.0.0"
  config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % $update_channel

  config.vm.provider :virtualbox do |v|
    # Do not use VirtualBox guest tools or additions.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end


  config.vm.define vm_master_name = "node-master" do |config|
    config.vm.hostname = vm_master_name

    if $enable_serial_logging
      logdir = File.join(File.dirname(__FILE__), "log")
      FileUtils.mkdir_p(logdir)

      serialFile = File.join(logdir, "%s-serial.txt" % vm_master_name)
      FileUtils.touch(serialFile)

      config.vm.provider :virtualbox do |vb, override|
        vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
        vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
      end
    end

    if $expose_docker_tcp
      config.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), auto_correct: true
    end

    config.vm.provider :virtualbox do |vb|
      vb.gui = $vm_gui
      vb.memory = $vm_master_memory
      vb.cpus = $vm_master_cpus
    end

    # Enable file sharing between host machine and guest and run local startup scrip.
    config.vm.synced_folder ".", "/vagrant", disabled: false
    system('. local_startup.sh')

    ip = "172.16.1.101"
    config.vm.network :private_network, ip: ip

    if File.exist?(MASTER_YAML)
      config.vm.provision :file, :source => "#{MASTER_YAML}", :destination => "/tmp/vagrantfile-user-data"
      config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
    end
  end

  (1..$node_instances).each do |i|
    config.vm.define vm_node_name = "node-%02d" % i do |config|
      config.vm.hostname = vm_node_name
      # Create
      if $enable_serial_logging
        logdir = File.join(File.dirname(__FILE__), "log")
        FileUtils.mkdir_p(logdir)

        serialFile = File.join(logdir, "%s-serial.txt" % vm_node_name)
        FileUtils.touch(serialFile)

        config.vm.provider :virtualbox do |vb, override|
          vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
          vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
        end
      end

      if $expose_docker_tcp
        config.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), auto_correct: true
      end

      config.vm.provider :vmware_fusion do |vb|
        vb.gui = $vm_gui
      end

      config.vm.provider :virtualbox do |vb|
        vb.gui = $vm_gui
        vb.memory = $vm_node_memory
        vb.cpus = $vm_node_cpus
      end

      ip = "172.16.1.#{i+101}"
      config.vm.network :private_network, ip: ip

      # Uncomment below to enable NFS for sharing the host machine into the coreos-vagrant VM.
      #config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']
      config.vm.synced_folder ".", "/vagrant", disabled: true

      if File.exist?(NODE_YAML)
        config.vm.provision :file, :source => "#{NODE_YAML}", :destination => "/tmp/vagrantfile-user-data"
        config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
      end
    end
  end
end
