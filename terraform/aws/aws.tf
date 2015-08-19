provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = false
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_vpc"
  }
}

resource "aws_vpc_dhcp_options" "vpc_dhcp" {
  domain_name = "${var.aws_region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_dhcp"
  }
}

resource "aws_vpc_dhcp_options_association" "vpc_dhcp_association" {
    vpc_id = "${aws_vpc.vpc.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.vpc_dhcp.id}"
}

resource "aws_internet_gateway" "vpc_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_gateway"
  }
}

resource "aws_route_table" "vpc_rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc_gateway.id}"
  }
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_rt"
  }
}

resource "aws_network_acl" "vpc_acl" {
  vpc_id = "${aws_vpc.vpc.id}"
  egress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  ingress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_acl"
  }
}

resource "aws_key_pair" "keypair" {
  key_name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_key"
  public_key = "${file(var.aws_local_public_key)}"
}

resource "aws_subnet" "vpc_subnet" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.0.0/16"
  map_public_ip_on_launch = true
  tags {
      Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_subnet"
  }
}

resource "aws_route_table_association" "vpc_rt_association" {
    subnet_id = "${aws_subnet.vpc_subnet.id}"
    route_table_id = "${aws_route_table.vpc_rt.id}"
}

resource "aws_main_route_table_association" "a" {
    vpc_id = "${aws_vpc.vpc.id}"
    route_table_id = "${aws_route_table.vpc_rt.id}"
}

resource "aws_security_group" "vpc_secgroup" {
  name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_secgroup"
  description = "Security group for ${var.aws_user_prefix} ${var.aws_cluster_prefix} cluster"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 4001
    to_port = 4001
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 4194
    to_port = 4194
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 6443
    to_port = 6443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8000
    to_port = 8999
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    self = true
    from_port = 0
    to_port = 0
    protocol = "-1"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_vpc.vpc.default_security_group_id}"]
  }

  # kraken services
  ingress {
    from_port = "${var.kraken_port_low}"
    to_port = "${var.kraken_port_high}"
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Pipelet security group"
  }
}

resource "template_file" "etcd_cloudinit" {
  filename = "${path.module}/templates/etcd.yaml.tpl"
  vars {
    format_docker_storage_mnt = "${var.format_docker_storage_mnt}"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
  }
}
resource "aws_instance" "kubernetes_etcd" {
  ami = "${lookup(var.coreos_ami, var.aws_region)}"
  instance_type = "${var.aws_etcd_type}"
  key_name = "${aws_key_pair.keypair.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.vpc_secgroup.id}" ]
  subnet_id = "${aws_subnet.vpc_subnet.id}"
  associate_public_ip_address = true
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = "${var.aws_volume_size}"
  }
  user_data = "${template_file.etcd_cloudinit.rendered}"
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_etcd"
  }
}

resource "template_file" "master_cloudinit" {
  filename = "${path.module}/templates/master.yaml.tpl"
  vars {
    etcd_private_ip = "${aws_instance.kubernetes_etcd.private_ip}"
    format_docker_storage_mnt = "${var.format_docker_storage_mnt}"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
  }
}
resource "aws_instance" "kubernetes_master" {
  ami = "${lookup(var.coreos_ami, var.aws_region)}"
  instance_type = "${var.aws_master_type}"
  key_name = "${aws_key_pair.keypair.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.vpc_secgroup.id}" ]
  subnet_id = "${aws_subnet.vpc_subnet.id}"
  associate_public_ip_address = true
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = "${var.aws_volume_size}"
  }
  user_data = "${template_file.master_cloudinit.rendered}"
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_master"
  }
}

resource "template_file" "node_cloudinit" {
  filename = "${path.module}/templates/node.yaml.tpl"
  vars {
    etcd_private_ip = "${aws_instance.kubernetes_etcd.private_ip}"
    format_docker_storage_mnt = "${var.format_docker_storage_mnt}"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
  }
}
resource "aws_instance" "kubernetes_node" {
  depends_on = ["aws_instance.kubernetes_etcd"]
  count = "${var.node_count}"
  ami = "${lookup(var.coreos_ami, var.aws_region)}"
  instance_type = "${var.aws_node_type}"
  key_name = "${aws_key_pair.keypair.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.vpc_secgroup.id}" ]
  subnet_id = "${aws_subnet.vpc_subnet.id}"
  associate_public_ip_address = true
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = "${var.aws_volume_size}"
  }
  user_data = "${template_file.node_cloudinit.rendered}"
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_node-${count.index+1}"
  }
}

resource "aws_route53_record" "master_record" {
  depends_on = ["aws_instance.kubernetes_master"]
  zone_id = "${var.aws_zone_id}"
  name = "${var.aws_user_prefix}-master.${var.aws_cluster_domain}"
  type = "A"
  ttl = "30"
  records = ["${aws_instance.kubernetes_master.public_ip}"]
}

resource "aws_route53_record" "proxy_record" {
  depends_on = ["aws_instance.kubernetes_master"]
  zone_id = "${var.aws_zone_id}"
  name = "${var.aws_user_prefix}-proxy.${var.aws_cluster_domain}"
  type = "A"
  ttl = "30"
  records = ["${aws_instance.kubernetes_node.0.public_ip}"]
}

resource "template_file" "ansible_inventory" {
  depends_on = ["aws_route53_record.proxy_record", "aws_route53_record.master_record"]
  filename = "${path.module}/templates/ansible.inventory.tpl"
  vars {
    master_public_ip = "${aws_instance.kubernetes_master.public_ip}"
    etcd_public_ip = "${aws_instance.kubernetes_etcd.public_ip}"
    node_public_ips = "${join("\n", aws_instance.kubernetes_node.*.public_ip)}"
    master_private_ip = "${aws_instance.kubernetes_master.private_ip}"
    etcd_private_ip = "${aws_instance.kubernetes_etcd.private_ip}"
    node_01_private_ip = "${aws_instance.kubernetes_node.0.private_ip}"
    node_01_public_ip = "${aws_instance.kubernetes_node.0.public_ip}"
    cluster_name = "aws"
    cluster_master_record = "http://${var.aws_user_prefix}-master.${var.aws_cluster_domain}:8080"
    kraken_services_repo = "${var.kraken_services_repo}"
    kraken_services_branch = "${var.kraken_services_branch}"
    dns_domain = "${var.dns_domain}"
    dns_ip = "${var.dns_ip}"
    dockercfg_base64 = "${var.dockercfg_base64}"
    kubernetes_version = "${var.kubernetes_version}"
    kubernetes_api_version = "${var.kubernetes_api_version}"
    kubernetes_verbosity = "${var.kubernetes_verbosity}"
    kraken_services_dirs = "${var.kraken_services_dirs}"
    logentries_token = "${var.logentries_token}"
    logentries_url = "${var.logentries_url}"
    interface_name = "eth0"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/rendered/ansible.inventory\n${self.rendered}\nEOF"
  }

  provisioner "local-exec" {
    command = "ansible-galaxy install defunctzombie.coreos-bootstrap --ignore-errors"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${path.module}/rendered/ansible.inventory ${path.module}/../../ansible/setup-python.yaml"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${path.module}/rendered/ansible.inventory ${path.module}/../../ansible/setup-kubernetes.yaml"
  }
}