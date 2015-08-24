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

  # ssh
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # http
  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # https
  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # etcd
  ingress {
    from_port = 4001
    to_port = 4001
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # cadvisor (TODO: does this have to be world open)
  ingress {
    from_port = 4194
    to_port = 4194
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # cadvisor (TODO: does this have to be world open)
  ingress {
    from_port = 8094
    to_port = 8094
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ???
  ingress {
    from_port = 6443
    to_port = 6443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ???
  ingress {
    from_port = 8000
    to_port = 8999
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # icmp (intra-group)
  ingress {
    self = true
    from_port = 0
    to_port = 0
    protocol = "-1"
  }

  # icmp (with the default group)
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_vpc.vpc.default_security_group_id}"]
  }

  # kubelet nodeport range
  ingress {
    from_port = "${var.kraken_port_low}"
    to_port = "${var.kraken_port_high}"
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # icmp (outbound)
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Security group for ${var.aws_user_prefix} ${var.aws_cluster_prefix} cluster"
  }
}

resource "template_file" "etcd_cloudinit" {
  filename = "${path.module}/templates/etcd.yaml.tpl"
  vars {
    format_docker_storage_mnt = "${lookup(var.format_docker_storage_mnt, var.aws_storage_type.etcd)}"
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
    device_name = "${var.aws_storage_path.ebs}"
    volume_size = "${var.aws_volume_size.etcd}"
  }
  ephemeral_block_device {
    device_name = "${var.aws_storage_path.ephemeral}"
    virtual_name = "ephemeral0"
  }
  user_data = "${template_file.etcd_cloudinit.rendered}"
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_etcd"
    ShortName = "etcd"
    StorageType = "${var.aws_storage_type.etcd}"
  }
}

resource "template_file" "master_cloudinit" {
  filename = "${path.module}/templates/master.yaml.tpl"
  vars {
    etcd_private_ip = "${aws_instance.kubernetes_etcd.private_ip}"
    format_docker_storage_mnt = "${lookup(var.format_docker_storage_mnt, var.aws_storage_type.etcd)}"
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
    device_name = "${var.aws_storage_path.ebs}"
    volume_size = "${var.aws_volume_size.master}"
  }
  ephemeral_block_device {
    device_name = "${var.aws_storage_path.ephemeral}"
    virtual_name = "ephemeral0"
  }
  user_data = "${template_file.master_cloudinit.rendered}"
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_master"
    ShortName = "master"
    StorageType = "${var.aws_storage_type.master}"
  }
}

resource "template_file" "node_cloudinit_typed" {
  filename = "${path.module}/templates/node.yaml.tpl"
  count = "${length(split(",", var.aws_node_type.special))}"
  vars {
    etcd_private_ip = "${aws_instance.kubernetes_etcd.private_ip}"
    format_docker_storage_mnt = "${lookup(var.format_docker_storage_mnt, element(split(",", var.aws_storage_type.special_nodes), count.index))}"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
  }
}

resource "aws_instance" "kubernetes_node_typed" {
  depends_on = ["aws_instance.kubernetes_etcd"]
  count = "${length(split(",", var.aws_node_type.special))}"
  ami = "${lookup(var.coreos_ami, var.aws_region)}"
  instance_type = "${element(split(",", var.aws_node_type.special), count.index)}"
  key_name = "${aws_key_pair.keypair.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.vpc_secgroup.id}" ]
  subnet_id = "${aws_subnet.vpc_subnet.id}"
  associate_public_ip_address = true
  ebs_block_device {
    device_name = "${var.aws_storage_path.ebs}"
    volume_size = "${element(split(",", var.aws_volume_size.special_nodes), count.index)}"
  }
  ephemeral_block_device {
    device_name = "${var.aws_storage_path.ephemeral}"
    virtual_name = "ephemeral0"
  }
  user_data = "${element(template_file.node_cloudinit_typed.*.rendered, count.index)}"
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_node-${format("%03d", count.index+1)}"
    ShortName = "${format("node-%03d", count.index+1)}"
    StorageType = "${element(split(",", var.aws_storage_type.special_nodes), count.index)}"
  }
}

resource "template_file" "node_cloudinit" {
  filename = "${path.module}/templates/node.yaml.tpl"
  vars {
    etcd_private_ip = "${aws_instance.kubernetes_etcd.private_ip}"
    format_docker_storage_mnt = "${lookup(var.format_docker_storage_mnt, var.aws_storage_type.other_nodes)}"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
  }
}

resource "aws_instance" "kubernetes_node" {
  depends_on = ["aws_instance.kubernetes_etcd"]
  count = "${var.node_count - length(split(",", var.aws_node_type.special))}"
  ami = "${lookup(var.coreos_ami, var.aws_region)}"
  instance_type = "${var.aws_node_type.other}"
  key_name = "${aws_key_pair.keypair.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.vpc_secgroup.id}" ]
  subnet_id = "${aws_subnet.vpc_subnet.id}"
  associate_public_ip_address = true
  ebs_block_device {
    device_name = "${var.aws_storage_path.ebs}"
    volume_size = "${var.aws_volume_size.other_nodes}"
  }
  ephemeral_block_device {
    device_name = "${var.aws_storage_path.ephemeral}"
    virtual_name = "ephemeral0"
  }
  user_data = "${template_file.node_cloudinit.rendered}"
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_node-${format("%03d", count.index+length(split(",", var.aws_node_type.special))+1)}"
    ShortName = "${format("node-%03d", count.index+length(split(",", var.aws_node_type.special))+1)}"
    StorageType = "${var.aws_storage_type.other_nodes}"
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
  records = ["${aws_instance.kubernetes_node_typed.0.public_ip}"]
}

resource "template_file" "ansible_inventory" {
  depends_on = ["aws_route53_record.proxy_record", "aws_route53_record.master_record"]
  filename = "${path.module}/templates/ansible.inventory.tpl"
  vars {
    ansible_ssh_private_key_file = "${var.aws_local_private_key}"
    master_public_ip = "${aws_instance.kubernetes_master.public_ip}"
    master_short_name = "${aws_instance.kubernetes_master.tags.ShortName}"
    etcd_public_ip = "${aws_instance.kubernetes_etcd.public_ip}"
    etcd_short_name = "${aws_instance.kubernetes_etcd.tags.ShortName}"
    nodes_inventory_info = "${join("\n", concat(formatlist("%v ansible_ssh_host=%v", aws_instance.kubernetes_node_typed.*.tags.ShortName, aws_instance.kubernetes_node_typed.*.public_ip), formatlist("%v ansible_ssh_host=%v", aws_instance.kubernetes_node.*.tags.ShortName, aws_instance.kubernetes_node.*.public_ip)))}"
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
    hyperkube_image = "${var.hyperkube_image}"
    kubernetes_version = "${var.kubernetes_version}"
    kubernetes_api_version = "${var.kubernetes_api_version}"
    kube_apiserver_v = "${var.kube_apiserver_v}"
    kube_scheduler_v = "${var.kube_scheduler_v}"
    kube_controller_manager_v = "${var.kube_controller_manager_v}"
    kubelet_v = "${var.kubelet_v}"
    kube_proxy_v = "${var.kube_proxy_v}"
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
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${path.module}/rendered/ansible.inventory ${path.module}/../../ansible/iaas_provision.yaml"
  }
}
