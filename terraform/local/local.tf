resource "coreosver_version" "coreos_version_info" {
    channel = "${var.coreos_update_channel}"
}

resource "template_file" "etcd_cloudinit" {
  filename = "${path.module}/templates/etcd.yaml.tpl"
  vars {
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/rendered/etcd.yaml\n${self.rendered}\nEOF"
  }
}

resource "template_file" "master_cloudinit" {
  filename = "${path.module}/templates/master.yaml.tpl"
  vars {
    etcd_private_ip = "${var.ip_base}.101"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/rendered/master.yaml\n${self.rendered}\nEOF"
  }
}

resource "template_file" "apiserver_cloudinit" {
  filename = "${path.module}/templates/apiserver.yaml.tpl"
  vars {
    etcd_private_ip = "${var.ip_base}.101"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/rendered/apiserver.yaml\n${self.rendered}\nEOF"
  }
}

resource "template_file" "node_cloudinit" {
  filename = "${path.module}/templates/node.yaml.tpl"
  vars {
    etcd_private_ip = "${var.ip_base}.101"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/rendered/node.yaml\n${self.rendered}\nEOF"
  }
}

resource "execute_command" "command" {
  depends_on = ["template_file.node_cloudinit", "template_file.master_cloudinit", "template_file.etcd_cloudinit", "template_file.apiserver_cloudinit"]
  command = "echo Running vagrant ..."
  destroy_command = "ANSIBLE_FORKS=${var.ansible_forks} ANSIBLE_SSH_PIPELINING=True ANSIBLE_SSH_RETRIES=3 ANSIBLE_HOST_KEY_CHECKING=False KRAKEN_IP_BASE=${var.ip_base} KRAKEN_COREOS_CHANNEL=${var.coreos_update_channel} KRAKEN_COREOS_RELEASE=${coreosver_version.coreos_version_info.version} KRAKEN_NUMBER_APISERVERS=${var.apiserver_count} KRAKEN_NUMBER_NODES=${var.node_count} VAGRANT_CWD=${path.module} VAGRANT_DOTFILE_PATH=${path.module} KRAKEN_ETCD_CPUS=${var.etcd_cpus} KRAKEN_ETCD_MEM=${var.etcd_mem} KRAKEN_MASTER_CPUS=${var.master_cpus} KRAKEN_MASTER_MEM=${var.master_mem} KRAKEN_APISERVER_CPUS=${var.apiserver_cpus} KRAKEN_APISERVER_MEM=${var.apiserver_mem} KRAKEN_NODE_CPUS=${var.node_cpus} KRAKEN_NODE_MEM=${var.node_mem} KRAKEN_KRAKEN_SERVICES_REPO=${var.kraken_services_repo} KRAKEN_NODE_MEMEN_KRAKEN_SERVICES_BRANCH=${var.kraken_services_branch} KRAKEN_DNS_DOMAIN=${var.dns_domain} KRAKEN_DNS_IP=${var.dns_ip} KRAKEN_DOCKERCFG_BASE64='${var.dockercfg_base64}' KRAKEN_HYPERKUBE_DEPLOYMENT_MODE=${var.hyperkube_deployment_mode} KRAKEN_HYPERKUBE_IMAGE=${var.hyperkube_image} KRAKEN_KUBERNETES_BINARIES_URI=${var.kubernetes_binaries_uri} KRAKEN_KUBERNETES_API_VERSION=${var.kubernetes_api_version} KRAKEN_KRAKEN_SERVICES_DIRS='${var.kraken_services_dirs}' KRAKEN_LOGENTRIES_TOKEN=${var.logentries_token} KRAKEN_LOGENTRIES_URL=${var.logentries_url} KRAKEN_VAGRANT_PRIVATE_KEY=${var.vagrant_private_key} KRAKEN_INTERFACE_NAME=eth1 vagrant destroy --force"

  provisioner "local-exec" {
    command = "ANSIBLE_FORKS=${var.ansible_forks} ANSIBLE_SSH_PIPELINING=True ANSIBLE_SSH_RETRIES=3 ANSIBLE_HOST_KEY_CHECKING=False KRAKEN_IP_BASE=${var.ip_base} KRAKEN_COREOS_CHANNEL=${var.coreos_update_channel} KRAKEN_COREOS_RELEASE=${coreosver_version.coreos_version_info.version} KRAKEN_NUMBER_APISERVERS=${var.apiserver_count} KRAKEN_NUMBER_NODES=${var.node_count} VAGRANT_CWD=${path.module} VAGRANT_DOTFILE_PATH=${path.module} KRAKEN_ETCD_CPUS=${var.etcd_cpus} KRAKEN_ETCD_MEM=${var.etcd_mem} KRAKEN_MASTER_CPUS=${var.master_cpus} KRAKEN_MASTER_MEM=${var.master_mem} KRAKEN_APISERVER_CPUS=${var.apiserver_cpus} KRAKEN_APISERVER_MEM=${var.apiserver_mem} KRAKEN_NODE_CPUS=${var.node_cpus} KRAKEN_NODE_MEM=${var.node_mem} KRAKEN_KRAKEN_SERVICES_REPO=${var.kraken_services_repo} KRAKEN_KRAKEN_SERVICES_BRANCH=${var.kraken_services_branch} KRAKEN_DNS_DOMAIN=${var.dns_domain} KRAKEN_DNS_IP=${var.dns_ip} KRAKEN_DOCKERCFG_BASE64='${var.dockercfg_base64}' KRAKEN_HYPERKUBE_DEPLOYMENT_MODE=${var.hyperkube_deployment_mode} KRAKEN_HYPERKUBE_IMAGE=${var.hyperkube_image} KRAKEN_KUBERNETES_BINARIES_URI=${var.kubernetes_binaries_uri} KRAKEN_KUBERNETES_API_VERSION=${var.kubernetes_api_version} KRAKEN_KRAKEN_SERVICES_DIRS='${var.kraken_services_dirs}' KRAKEN_LOGENTRIES_TOKEN=${var.logentries_token} KRAKEN_LOGENTRIES_URL=${var.logentries_url} KRAKEN_VAGRANT_PRIVATE_KEY=${var.vagrant_private_key} KRAKEN_INTERFACE_NAME=eth1 vagrant up"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/rendered/ansible.inventory ${path.module}/../../ansible/localhost_provision.yaml"
  }
}
