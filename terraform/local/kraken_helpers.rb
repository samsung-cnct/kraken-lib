# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'fileutils'
require 'ipaddr'
require 'erb'
require 'ostruct'
require 'yaml'

VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version ">= 1.7.2"

def install_plugins
  plugins_yaml = File.join(File.dirname(__FILE__), 'plugins.yaml')
  install_plugins_from_file(plugins_yaml)
end

def install_plugins_from_file(plugins_yaml)
  abort "#{plugins_yaml} does not exist" unless File.exist?(plugins_yaml)

  required_plugins = YAML.load_file(plugins_yaml)
  required_plugins['plugins'].each do |plugin|
    need_restart = false
    unless Vagrant.has_plugin? plugin['name'], plugin['version']
      system "vagrant plugin install #{plugin['name']} --plugin-version #{plugin['version']}"
      need_restart = true
    end
    exec "vagrant #{ARGV.join(' ')}" if need_restart
  end
end

def coreos_release
  ENV['KRAKEN_COREOS_RELEASE']
end

def coreos_url
  "http://#{ENV['KRAKEN_COREOS_CHANNEL']}.release.core-os.net/amd64-usr"
end

def coreos_boxname
  "coreos-#{ENV['KRAKEN_COREOS_CHANNEL']}"
end

def get_num_apiservers
  ENV['KRAKEN_NUMBER_APISERVERS'].to_i
end

def get_num_nodes
  ENV['KRAKEN_NUMBER_NODES'].to_i
end

def get_num_vms
  get_num_nodes + get_num_apiservers + 2 # 2 represents the etcd and master vms
end  

def enable_serial_logging
  ENV['KRAKEN_SERIAL_LOGGING'] || false
end

def base_ip_address
    network = "#{ENV['KRAKEN_IP_BASE']}.0/24"
    IPAddr.new(network).to_s.chomp("0")
end

def build_coreos_userdata(host_number)
  user_data = nil
  subtotal = 2 + get_num_apiservers
  total = get_num_vms
  case host_number
  when 1
    user_data = { name: 'etcd', data: File.join(__dir__, 'rendered', 'etcd.yaml'), cpus: ENV['KRAKEN_ETCD_CPUS'], mem: ENV['KRAKEN_ETCD_MEM']}
  when 2
    user_data = { name: 'master', data: File.join(__dir__, 'rendered', 'master.yaml'), cpus: ENV['KRAKEN_MASTER_CPUS'], mem: ENV['KRAKEN_MASTER_MEM']  }
  when (3)..subtotal
    user_data = { name: "apiserver-%03d" % (host_number - 2), data: File.join(__dir__, 'rendered', 'apiserver.yaml'), cpus: ENV['KRAKEN_APISERVER_CPUS'], mem: ENV['KRAKEN_APISERVER_MEM']  }
  else
    user_data = { name: "node-%03d" % (host_number - (2 + get_num_apiservers)), data: File.join(__dir__, 'rendered', 'node.yaml'), cpus: ENV['KRAKEN_NODE_CPUS'], mem: ENV['KRAKEN_NODE_MEM'] }
  end

  user_data
end

def final_node_ip
  number_of_nodes = get_num_vms
  base_ip_address + "#{(get_num_vms + 100)}"
end

def render(templatepath, destinationpath, variables)
  if File.file?(templatepath)
    template = File.open(templatepath, "rb").read
    content = ERB.new(template).result(OpenStruct.new(variables).instance_eval { binding })
    outputpath = destinationpath.end_with?('/') ? "#{destinationpath}/#{File.basename(templatepath, '.erb')}" : destinationpath
    FileUtils.mkdir_p(File.dirname(outputpath))
    File.open(outputpath, "wb") { |f| f.write(content) }
  end
end