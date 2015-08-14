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

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False KRAKEN_IP_BASE=${var.ip_base} KRAKEN_COREOS_CHANNEL=${var.coreos_update_channel} KRAKEN_COREOS_RELEASE=${var.coreos_release} KRAKEN_NUMBER_NODES=${var.node_count} VAGRANT_CWD=${path.module} VAGRANT_DOTFILE_PATH=${path.module} KRAKEN_ETCD_CPUS=${var.etcd_cpus} KRAKEN_ETCD_MEM=${var.etcd_mem} KRAKEN_MASTER_CPUS=${var.master_cpus} KRAKEN_MASTER_MEM=${var.master_mem} KRAKEN_NODE_CPUS=${var.node_cpus} KRAKEN_NODE_MEM=${var.node_mem} vagrant destroy --force"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False KRAKEN_IP_BASE=${var.ip_base} KRAKEN_COREOS_CHANNEL=${var.coreos_update_channel} KRAKEN_COREOS_RELEASE=${var.coreos_release} KRAKEN_NUMBER_NODES=${var.node_count} VAGRANT_CWD=${path.module} VAGRANT_DOTFILE_PATH=${path.module} KRAKEN_ETCD_CPUS=${var.etcd_cpus} KRAKEN_ETCD_MEM=${var.etcd_mem} KRAKEN_MASTER_CPUS=${var.master_cpus} KRAKEN_MASTER_MEM=${var.master_mem} KRAKEN_NODE_CPUS=${var.node_cpus} KRAKEN_NODE_MEM=${var.node_mem} vagrant up"
  } 
}
