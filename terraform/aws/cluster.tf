variable "aws_access_key" {
  description = "AWS key id"
}
variable "aws_secret_key" {
  description = "AWS secret key"
}
variable "aws_user_prefix" {
  description = "AWS resource prefix - all resources with names will be identified as <aws_user_prefix>_<aws_cluster_prefix>_<name>"
}

variable "node_count" {
  default = "3"
  description = "How many nodes (not counting master and etcd to bring up)"
}

variable "aws_local_public_key" {
  default = "~/.ssh/id_rsa.pub"
  description = "Location of public key material to import into the <aws_user_prefix>_<aws_cluster_prefix>_keypair"
}

module "aws" {
  source = "../modules/aws"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_user_prefix = "${var.aws_user_prefix}"
  aws_local_public_key = "${var.aws_local_public_key}"
  node_count = "${var.node_count}"
}

resource "template_file" "ansible_inventory" {
  filename = "${path.module}/dummy"
  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/../../ansible/inventory/ansible.inventory\n${module.aws.template}\nEOF"
  }

  provisioner "local-exec" {
    command = "ansible-galaxy install defunctzombie.coreos-bootstrap --ignore-errors"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${path.module}/../../ansible/inventory/ansible.inventory ${path.module}/../../ansible/setup-python.yaml"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${path.module}/../../ansible/inventory/ansible.inventory ${path.module}/../../ansible/setup-kubernetes.yaml"
  }
}

