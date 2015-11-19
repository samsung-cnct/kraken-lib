resource "coreosbox_vagrant" "coreos_version_info" {
  channel = "${var.coreos_update_channel}"
  hypervisor = "virtualbox"
  version = "${var.coreos_version}"
}

resource "template_file" "etcd_cloudinit" {
  filename = "${path.module}/templates/etcd.yaml.tpl"
  vars {
    ansible_playbook_command = "${var.ansible_playbook_command}"
    ansible_playbook_file = "${var.ansible_playbook_file}"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
    kubernetes_binaries_uri = "${var.kubernetes_binaries_uri}"
    logentries_token = "${var.logentries_token}"
    logentries_url = "${var.logentries_url}"
    kraken_repo = "${var.kraken_repo.repo}"
    kraken_branch = "${var.kraken_repo.branch}"
    kraken_commit = "${var.kraken_repo.commit_sha}"
    ansible_docker_image = "${var.ansible_docker_image}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/rendered/etcd.yaml\n${self.rendered}\nEOF"
  }
}

resource "template_file" "master_cloudinit" {
  filename = "${path.module}/templates/master.yaml.tpl"
  vars {
    ansible_playbook_command = "${var.ansible_playbook_command}"
    ansible_playbook_file = "${var.ansible_playbook_file}"
    cluster_name = "local"
    dns_domain = "${var.dns_domain}"
    dns_ip = "${var.dns_ip}"
    dockercfg_base64 = "${var.dockercfg_base64}"
    etcd_private_ip = "${var.ip_base}.101"
    hyperkube_deployment_mode = "${var.hyperkube_deployment_mode}"
    hyperkube_image = "${var.hyperkube_image}"
    interface_name = "eth1"
    kraken_services_branch = "${var.kraken_services_branch}"
    kraken_services_dirs = "${var.kraken_services_dirs}"
    kraken_services_repo = "${var.kraken_services_repo}"
    kubernetes_api_version = "${var.kubernetes_api_version}"
    kubernetes_binaries_uri = "${var.kubernetes_binaries_uri}"
    logentries_token = "${var.logentries_token}"
    logentries_url = "${var.logentries_url}"
    short_name = "master"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
    kraken_repo = "${var.kraken_repo.repo}"
    kraken_branch = "${var.kraken_repo.branch}"
    kraken_commit = "${var.kraken_repo.commit_sha}"
    ansible_docker_image = "${var.ansible_docker_image}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/rendered/master.yaml\n${self.rendered}\nEOF"
  }
}

resource "template_file" "apiserver_cloudinit" {
  filename = "${path.module}/templates/apiserver.yaml.tpl"
  vars {
    ansible_playbook_command = "${var.ansible_playbook_command}"
    ansible_playbook_file = "${var.ansible_playbook_file}"
    dns_domain = "${var.dns_domain}"
    dns_ip = "${var.dns_ip}"
    dockercfg_base64 = "${var.dockercfg_base64}"
    etcd_private_ip = "${var.ip_base}.101"
    hyperkube_deployment_mode = "${var.hyperkube_deployment_mode}"
    hyperkube_image = "${var.hyperkube_image}"
    interface_name = "eth1"
    kraken_services_branch = "${var.kraken_services_branch}"
    kraken_services_dirs = "${var.kraken_services_dirs}"
    kraken_services_repo = "${var.kraken_services_repo}"
    kubernetes_api_version = "${var.kubernetes_api_version}"
    kubernetes_binaries_uri = "${var.kubernetes_binaries_uri}"
    logentries_token = "${var.logentries_token}"
    logentries_url = "${var.logentries_url}"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
    kraken_repo = "${var.kraken_repo.repo}"
    kraken_branch = "${var.kraken_repo.branch}"
    kraken_commit = "${var.kraken_repo.commit_sha}"
    ansible_docker_image = "${var.ansible_docker_image}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/rendered/apiserver.yaml\n${self.rendered}\nEOF"
  }
}

resource "template_file" "node_cloudinit" {
  filename = "${path.module}/templates/node.yaml.tpl"
  vars {    
    ansible_playbook_command = "${var.ansible_playbook_command}"
    ansible_playbook_file = "${var.ansible_playbook_file}"
    dns_domain = "${var.dns_domain}"
    dns_ip = "${var.dns_ip}"
    dockercfg_base64 = "${var.dockercfg_base64}"
    hyperkube_deployment_mode = "${var.hyperkube_deployment_mode}"
    hyperkube_image = "${var.hyperkube_image}"
    interface_name = "eth1"
    etcd_private_ip = "${var.ip_base}.101"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
    kubernetes_api_version = "${var.kubernetes_api_version}"
    kubernetes_binaries_uri = "${var.kubernetes_binaries_uri}"
    logentries_token = "${var.logentries_token}"
    logentries_url = "${var.logentries_url}"
    kraken_repo = "${var.kraken_repo.repo}"
    kraken_branch = "${var.kraken_repo.branch}"
    kraken_commit = "${var.kraken_repo.commit_sha}"
    ansible_docker_image = "${var.ansible_docker_image}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/rendered/node.yaml\n${self.rendered}\nEOF"
  }
}

resource "execute_command" "command" {
  depends_on = ["template_file.node_cloudinit", "template_file.master_cloudinit", "template_file.etcd_cloudinit", "template_file.apiserver_cloudinit"]
  command = "echo Running vagrant ..."
  destroy_command = "KRAKEN_IP_BASE=${var.ip_base} KRAKEN_COREOS_CHANNEL=${var.coreos_update_channel} KRAKEN_COREOS_RELEASE=${coreosbox_vagrant.coreos_version_info.version_out} KRAKEN_NUMBER_APISERVERS=${var.apiserver_count} KRAKEN_NUMBER_NODES=${var.node_count} VAGRANT_CWD=${path.module} VAGRANT_DOTFILE_PATH=${path.module} KRAKEN_ETCD_CPUS=${var.etcd_cpus} KRAKEN_ETCD_MEM=${var.etcd_mem} KRAKEN_MASTER_CPUS=${var.master_cpus} KRAKEN_MASTER_MEM=${var.master_mem} KRAKEN_APISERVER_CPUS=${var.apiserver_cpus} KRAKEN_APISERVER_MEM=${var.apiserver_mem} KRAKEN_NODE_CPUS=${var.node_cpus} KRAKEN_NODE_MEM=${var.node_mem} KRAKEN_KRAKEN_SERVICES_REPO=${var.kraken_services_repo} KRAKEN_NODE_MEMEN_KRAKEN_SERVICES_BRANCH=${var.kraken_services_branch} KRAKEN_DNS_DOMAIN=${var.dns_domain} KRAKEN_DNS_IP=${var.dns_ip} KRAKEN_DOCKERCFG_BASE64='${var.dockercfg_base64}' KRAKEN_HYPERKUBE_DEPLOYMENT_MODE=${var.hyperkube_deployment_mode} KRAKEN_HYPERKUBE_IMAGE=${var.hyperkube_image} KRAKEN_KUBERNETES_BINARIES_URI=${var.kubernetes_binaries_uri} KRAKEN_KUBERNETES_API_VERSION=${var.kubernetes_api_version} KRAKEN_KRAKEN_SERVICES_DIRS='${var.kraken_services_dirs}' KRAKEN_LOGENTRIES_TOKEN=${var.logentries_token} KRAKEN_LOGENTRIES_URL=${var.logentries_url} KRAKEN_VAGRANT_PRIVATE_KEY=${var.vagrant_private_key} KRAKEN_INTERFACE_NAME=eth1 vagrant destroy --force"

  provisioner "local-exec" {
    command = "KRAKEN_IP_BASE=${var.ip_base} KRAKEN_COREOS_CHANNEL=${var.coreos_update_channel} KRAKEN_COREOS_RELEASE=${coreosbox_vagrant.coreos_version_info.version_out} KRAKEN_NUMBER_APISERVERS=${var.apiserver_count} KRAKEN_NUMBER_NODES=${var.node_count} VAGRANT_CWD=${path.module} VAGRANT_DOTFILE_PATH=${path.module} KRAKEN_ETCD_CPUS=${var.etcd_cpus} KRAKEN_ETCD_MEM=${var.etcd_mem} KRAKEN_MASTER_CPUS=${var.master_cpus} KRAKEN_MASTER_MEM=${var.master_mem} KRAKEN_APISERVER_CPUS=${var.apiserver_cpus} KRAKEN_APISERVER_MEM=${var.apiserver_mem} KRAKEN_NODE_CPUS=${var.node_cpus} KRAKEN_NODE_MEM=${var.node_mem} KRAKEN_KRAKEN_SERVICES_REPO=${var.kraken_services_repo} KRAKEN_KRAKEN_SERVICES_BRANCH=${var.kraken_services_branch} KRAKEN_DNS_DOMAIN=${var.dns_domain} KRAKEN_DNS_IP=${var.dns_ip} KRAKEN_DOCKERCFG_BASE64='${var.dockercfg_base64}' KRAKEN_HYPERKUBE_DEPLOYMENT_MODE=${var.hyperkube_deployment_mode} KRAKEN_HYPERKUBE_IMAGE=${var.hyperkube_image} KRAKEN_KUBERNETES_BINARIES_URI=${var.kubernetes_binaries_uri} KRAKEN_KUBERNETES_API_VERSION=${var.kubernetes_api_version} KRAKEN_KRAKEN_SERVICES_DIRS='${var.kraken_services_dirs}' KRAKEN_LOGENTRIES_TOKEN=${var.logentries_token} KRAKEN_LOGENTRIES_URL=${var.logentries_url} KRAKEN_VAGRANT_PRIVATE_KEY=${var.vagrant_private_key} KRAKEN_INTERFACE_NAME=eth1 vagrant up"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i 'localhost,' --connection=local ${path.module}/../../ansible/localhost_pre_provision.yaml --extra-vars 'cluster_name=${var.cluster_name} cluster_master_record=http://${var.ip_base}.102:8080'"
  }
}
