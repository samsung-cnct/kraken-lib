resource "coreosbox_vagrant" "coreos_version_info" {
  channel    = "${var.coreos_update_channel}"
  hypervisor = "virtualbox"
  version    = "${var.coreos_version}"
}

resource "template_file" "etcd_cloudinit" {
  template = "${path.module}/templates/etcd.yaml.tpl"

  vars {
    ansible_docker_image = "${var.ansible_docker_image}"
    ansible_playbook_command = "${var.ansible_playbook_command}"
    ansible_playbook_file = "${var.ansible_playbook_file}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
    coreos_update_channel = "${var.coreos_update_channel}"
    kraken_branch = "${var.kraken_repo.branch}"
    kraken_commit = "${var.kraken_repo.commit_sha}"
    kraken_local_dir ="${var.kraken_local_dir}"
    kraken_repo = "${var.kraken_repo.repo}"
    kubernetes_binaries_uri = "${var.kubernetes_binaries_uri}"
    logentries_token = "${var.logentries_token}"
    logentries_url = "${var.logentries_url}"
    sysdigcloud_access_key    = "${var.sysdigcloud_access_key}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/rendered/etcd.yaml\n${self.rendered}\nEOF"
  }
}

resource "template_file" "master_cloudinit" {
  template = "${path.module}/templates/master.yaml.tpl"

  vars {
    access_port                 = "${var.access_port}"
    access_scheme               = "${var.access_scheme}"
    ansible_docker_image        = "${var.ansible_docker_image}"
    ansible_playbook_command    = "${var.ansible_playbook_command}"
    ansible_playbook_file       = "${var.ansible_playbook_file}"
    cluster_name                = "${var.cluster_name}"
    cluster_passwd              = "${var.cluster_passwd}"
    cluster_user                = "${var.local_user_prefix}"
    command_passwd              = "${var.command_passwd}"
    coreos_reboot_strategy      = "${var.coreos_reboot_strategy}"
    coreos_update_channel       = "${var.coreos_update_channel}"
    dns_domain                  = "${var.dns_domain}"
    dns_ip                      = "${var.dns_ip}"
    dockercfg_base64            = "${var.dockercfg_base64}"
    etcd_private_ip             = "${var.ip_base}.101"
    hyperkube_deployment_mode   = "${var.hyperkube_deployment_mode}"
    hyperkube_image             = "${var.hyperkube_image}"
    interface_name              = "eth1"
    kraken_branch               = "${var.kraken_repo.branch}"
    kraken_commit               = "${var.kraken_repo.commit_sha}"
    kraken_local_dir            = "${var.kraken_local_dir}"
    kraken_repo                 = "${var.kraken_repo.repo}"
    kraken_services_branch      = "${var.kraken_services_branch}"
    kraken_services_dirs        = "${var.kraken_services_dirs}"
    kraken_services_repo        = "${var.kraken_services_repo}"
    kubernetes_api_version      = "${var.kubernetes_api_version}"
    kubernetes_binaries_uri     = "${var.kubernetes_binaries_uri}"
    kubernetes_cert_dir         = "${var.kubernetes_cert_dir}"
    logentries_token            = "${var.logentries_token}"
    logentries_url              = "${var.logentries_url}"
    short_name                  = "master"
    sysdigcloud_access_key      = "${var.sysdigcloud_access_key}"
    thirdparty_scheduler        = "${var.thirdparty_scheduler}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/rendered/master.yaml\n${self.rendered}\nEOF"
  }
}

resource "template_file" "apiserver_cloudinit" {
  template = "${path.module}/templates/apiserver.yaml.tpl"

  vars {
    access_port                 = "${var.access_port}"
    access_scheme               = "${var.access_scheme}"
    ansible_docker_image        = "${var.ansible_docker_image}"
    ansible_playbook_command    = "${var.ansible_playbook_command}"
    ansible_playbook_file       = "${var.ansible_playbook_file}"
    cluster_name                = "${var.cluster_name}"
    cluster_passwd              = "${var.cluster_passwd}"
    cluster_user                = "${var.local_user_prefix}"
    coreos_reboot_strategy      = "${var.coreos_reboot_strategy}"
    coreos_update_channel       = "${var.coreos_update_channel}"
    dns_domain                  = "${var.dns_domain}"
    dns_ip                      = "${var.dns_ip}"
    dockercfg_base64            = "${var.dockercfg_base64}"
    etcd_private_ip             = "${var.ip_base}.101"
    hyperkube_deployment_mode   = "${var.hyperkube_deployment_mode}"
    hyperkube_image             = "${var.hyperkube_image}"
    interface_name              = "eth1"
    kraken_branch               = "${var.kraken_repo.branch}"
    kraken_commit               = "${var.kraken_repo.commit_sha}"
    kraken_local_dir            = "${var.kraken_local_dir}"
    kraken_repo                 = "${var.kraken_repo.repo}"
    kraken_services_branch      = "${var.kraken_services_branch}"
    kraken_services_dirs        = "${var.kraken_services_dirs}"
    kraken_services_repo        = "${var.kraken_services_repo}"
    kubernetes_api_version      = "${var.kubernetes_api_version}"
    kubernetes_binaries_uri     = "${var.kubernetes_binaries_uri}"
    kubernetes_cert_dir         = "${var.kubernetes_cert_dir}"
    logentries_token            = "${var.logentries_token}"
    logentries_url              = "${var.logentries_url}"
    sysdigcloud_access_key      = "${var.sysdigcloud_access_key}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/rendered/apiserver.yaml\n${self.rendered}\nEOF"
  }
}

resource "template_file" "node_cloudinit" {
  template = "${path.module}/templates/node.yaml.tpl"
  vars {
    access_port                 = "${var.access_port}"
    access_scheme               = "${var.access_scheme}"
    ansible_docker_image        = "${var.ansible_docker_image}"
    ansible_playbook_command    = "${var.ansible_playbook_command}"
    ansible_playbook_file       = "${var.ansible_playbook_file}"
    cluster_name                = "${var.cluster_name}"
    cluster_passwd              = "${var.cluster_passwd}"
    cluster_user                = "${var.local_user_prefix}"
    coreos_reboot_strategy      = "${var.coreos_reboot_strategy}"
    coreos_update_channel       = "${var.coreos_update_channel}"
    dns_domain                  = "${var.dns_domain}"
    dns_ip                      = "${var.dns_ip}"
    dockercfg_base64            = "${var.dockercfg_base64}"
    etcd_private_ip             = "${var.ip_base}.101"
    hyperkube_deployment_mode   = "${var.hyperkube_deployment_mode}"
    hyperkube_image             = "${var.hyperkube_image}"
    interface_name              = "eth1"
    kraken_branch               = "${var.kraken_repo.branch}"
    kraken_commit               = "${var.kraken_repo.commit_sha}"
    kraken_local_dir            = "${var.kraken_local_dir}"
    kraken_repo                 = "${var.kraken_repo.repo}"
    kraken_services_branch      = "${var.kraken_services_branch}"
    kraken_services_dirs        = "${var.kraken_services_dirs}"
    kraken_services_repo        = "${var.kraken_services_repo}"
    kubernetes_api_version      = "${var.kubernetes_api_version}"
    kubernetes_binaries_uri     = "${var.kubernetes_binaries_uri}"
    kubernetes_cert_dir         = "${var.kubernetes_cert_dir}"
    logentries_token            = "${var.logentries_token}"
    logentries_url              = "${var.logentries_url}"
    sysdigcloud_access_key      = "${var.sysdigcloud_access_key}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/rendered/node.yaml\n${self.rendered}\nEOF"
  }
}

resource "execute_command" "command" {
  depends_on      = ["template_file.node_cloudinit", "template_file.master_cloudinit", "template_file.etcd_cloudinit", "template_file.apiserver_cloudinit"]
  command         = "echo Running vagrant ..."

  destroy_command = "KRAKEN_IP_BASE=${var.ip_base} KRAKEN_COREOS_CHANNEL=${var.coreos_update_channel} KRAKEN_COREOS_RELEASE=${coreosbox_vagrant.coreos_version_info.version_out} KRAKEN_NUMBER_APISERVERS=${var.apiserver_count} KRAKEN_NUMBER_NODES=${var.node_count} VAGRANT_CWD=${path.module} VAGRANT_DOTFILE_PATH=${path.module} KRAKEN_ETCD_CPUS=${var.etcd_cpus} KRAKEN_ETCD_MEM=${var.etcd_mem} KRAKEN_MASTER_CPUS=${var.master_cpus} KRAKEN_MASTER_MEM=${var.master_mem} KRAKEN_APISERVER_CPUS=${var.apiserver_cpus} KRAKEN_APISERVER_MEM=${var.apiserver_mem} KRAKEN_NODE_CPUS=${var.node_cpus} KRAKEN_NODE_MEM=${var.node_mem} KRAKEN_KRAKEN_SERVICES_REPO=${var.kraken_services_repo} KRAKEN_NODE_MEMEN_KRAKEN_SERVICES_BRANCH=${var.kraken_services_branch} KRAKEN_THIRDPARTY_SCHEDULER=${var.thirdparty_scheduler} KRAKEN_DNS_DOMAIN=${var.dns_domain} KRAKEN_DNS_IP=${var.dns_ip} KRAKEN_DOCKERCFG_BASE64='${var.dockercfg_base64}' KRAKEN_HYPERKUBE_DEPLOYMENT_MODE=${var.hyperkube_deployment_mode} KRAKEN_HYPERKUBE_IMAGE=${var.hyperkube_image} KRAKEN_KUBERNETES_BINARIES_URI=${var.kubernetes_binaries_uri} KRAKEN_KUBERNETES_API_VERSION=${var.kubernetes_api_version} KRAKEN_KRAKEN_SERVICES_DIRS='${var.kraken_services_dirs}' KRAKEN_LOGENTRIES_TOKEN=${var.logentries_token} KRAKEN_LOGENTRIES_URL=${var.logentries_url} KRAKEN_VAGRANT_PRIVATE_KEY=${var.vagrant_private_key} KRAKEN_INTERFACE_NAME=eth1 KRAKEN_CLUSTER_USER=${var.local_user_prefix} KRAKEN_CLUSTER_PASSWD=${var.cluster_passwd} KRAKEN_CLUSTER_NAME=${var.cluster_name} KRAKEN_ACCESS_SCHEME=${var.access_scheme} KRAKEN_ACCESS_PORT=${var.access_port} KRAKEN_KRAKEN_LOCAL_DIR=${var.kraken_local_dir} KRAKEN_KUBERNETES_CERT_DIR=${var.kubernetes_cert_dir} KRAKEN_COMMAND_PASSWD=${var.command_passwd} SYSDIGCLOUD_ACCESS_KEY=${var.sysdigcloud_access_key} vagrant destroy --force"

  provisioner "local-exec" {
    command = "KRAKEN_IP_BASE=${var.ip_base} KRAKEN_COREOS_CHANNEL=${var.coreos_update_channel} KRAKEN_COREOS_RELEASE=${coreosbox_vagrant.coreos_version_info.version_out} KRAKEN_NUMBER_APISERVERS=${var.apiserver_count} KRAKEN_NUMBER_NODES=${var.node_count} VAGRANT_CWD=${path.module} VAGRANT_DOTFILE_PATH=${path.module} KRAKEN_ETCD_CPUS=${var.etcd_cpus} KRAKEN_ETCD_MEM=${var.etcd_mem} KRAKEN_MASTER_CPUS=${var.master_cpus} KRAKEN_MASTER_MEM=${var.master_mem} KRAKEN_APISERVER_CPUS=${var.apiserver_cpus} KRAKEN_APISERVER_MEM=${var.apiserver_mem} KRAKEN_NODE_CPUS=${var.node_cpus} KRAKEN_NODE_MEM=${var.node_mem} KRAKEN_KRAKEN_SERVICES_REPO=${var.kraken_services_repo} KRAKEN_KRAKEN_SERVICES_BRANCH=${var.kraken_services_branch} KRAKEN_THIRDPARTY_SCHEDULER=${var.thirdparty_scheduler} KRAKEN_DNS_DOMAIN=${var.dns_domain} KRAKEN_DNS_IP=${var.dns_ip} KRAKEN_DOCKERCFG_BASE64='${var.dockercfg_base64}' KRAKEN_HYPERKUBE_DEPLOYMENT_MODE=${var.hyperkube_deployment_mode} KRAKEN_HYPERKUBE_IMAGE=${var.hyperkube_image} KRAKEN_KUBERNETES_BINARIES_URI=${var.kubernetes_binaries_uri} KRAKEN_KUBERNETES_API_VERSION=${var.kubernetes_api_version} KRAKEN_KRAKEN_SERVICES_DIRS='${var.kraken_services_dirs}' KRAKEN_LOGENTRIES_TOKEN=${var.logentries_token} KRAKEN_LOGENTRIES_URL=${var.logentries_url} KRAKEN_VAGRANT_PRIVATE_KEY=${var.vagrant_private_key} KRAKEN_INTERFACE_NAME=eth1 KRAKEN_CLUSTER_USER=${var.local_user_prefix} KRAKEN_CLUSTER_PASSWD=${var.cluster_passwd} KRAKEN_CLUSTER_NAME=${var.cluster_name} KRAKEN_ACCESS_SCHEME=${var.access_scheme} KRAKEN_ACCESS_PORT=${var.access_port} KRAKEN_KRAKEN_LOCAL_DIR=${var.kraken_local_dir} KRAKEN_KUBERNETES_CERT_DIR=${var.kubernetes_cert_dir} KRAKEN_COMMAND_PASSWD=${var.command_passwd} SYSDIGCLOUD_ACCESS_KEY=${var.sysdigcloud_access_key} vagrant up"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${path.module}/rendered/hosts' --connection=local ${path.module}/../../ansible/generate_local_kubeconfig.yaml"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${path.module}/rendered/hosts' --connection=local ${path.module}/../../ansible/generate_local_ssh_config.yaml"
  }
}
