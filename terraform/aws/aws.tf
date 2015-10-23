provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
  max_retries = "${var.max_retries}"
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

resource "coreos_ami" "latest_ami" {
  channel = "${var.coreos_update_channel}"
  type = "hvm"
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "b" {
  bucket = "${var.aws_kraken_s3_bucket}-${var.aws_user_prefix}-${var.aws_cluster_prefix}"
  acl = "public-read"
  policy = "{\"Version\": \"2012-10-17\", \"Statement\": [ { \"Sid\": \"Stmt1442424671241\", \"Action\": [ \"s3:GetObject\" ], \"Effect\": \"Allow\", \"Resource\": \"arn:aws:s3:::${var.aws_kraken_s3_bucket}-${var.aws_user_prefix}-${var.aws_cluster_prefix}/*\", \"Principal\": \"*\" } ] }"
}
resource "execute_command" "kube-cert-gen" {
  command = "${path.module}/../../generate-cert/make-cert-tokens.sh ${aws_instance.kubernetes_master.private_ip} ${var.dns_ip} ${path.module}/kube-cert"
  destroy_command = "rm -rf ${path.module}/kube-cert"
  # kube-certs.tgz
  #
  # ca.crt
  # known_tokens.csv
  # kube-proxy/kubeconfig
  # kubecfg.crt - not used yet
  # kubecfg.key - not used yet
  # kubelet/kubeconfig
  # server.cert
  # server.key
}
resource "aws_s3_bucket_object" "kube-certs-archive" {
  depends_on = ["aws_s3_bucket.b", "execute_command.kube-cert-gen"] # explicit dependency
  bucket = "${var.aws_kraken_s3_bucket}-${var.aws_user_prefix}-${var.aws_cluster_prefix}"
  key = "kube-certs.tgz"
  source = "${path.module}/kube-cert/kube-certs.tgz"
}

resource "template_file" "etcd_cloudinit" {
  filename = "${path.module}/templates/etcd.yaml.tpl"
  vars {
    ansible_playbook_command = "${var.ansible_playbook_command}"
    ansible_playbook_file = "${var.ansible_playbook_file}"
    format_docker_storage_mnt = "${lookup(var.format_docker_storage_mnt, var.aws_storage_type_etcd)}"
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
}
resource "aws_instance" "kubernetes_etcd" {
  depends_on = ["aws_internet_gateway.vpc_gateway"] # explicit dependency
  ami = "${coreos_ami.latest_ami.ami}"
  instance_type = "${var.aws_etcd_type}"
  key_name = "${aws_key_pair.keypair.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.vpc_secgroup.id}" ]
  subnet_id = "${aws_subnet.vpc_subnet.id}"
  associate_public_ip_address = true
  ebs_block_device {
    device_name = "${var.aws_storage_path.ebs}"
    volume_size = "${var.aws_volume_size_etcd}"
    volume_type = "${var.aws_volume_type_etcd}"
  }
  ephemeral_block_device {
    device_name = "${var.aws_storage_path.ephemeral}"
    virtual_name = "ephemeral0"
  }
  user_data = "${template_file.etcd_cloudinit.rendered}"
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_etcd"
    ShortName = "etcd"
    StorageType = "${var.aws_storage_type_etcd}"
  }
}

resource "template_file" "apiserver_cloudinit" {
  filename = "${path.module}/templates/apiserver.yaml.tpl"
  depends_on = ["aws_s3_bucket.b"] # need the returned data
  vars {
    ansible_playbook_command = "${var.ansible_playbook_command}"
    ansible_playbook_file = "${var.ansible_playbook_file}"
    cluster_name = "aws"
    dns_domain = "${var.dns_domain}"
    dns_ip = "${var.dns_ip}"
    dockercfg_base64 = "${var.dockercfg_base64}"
    etcd_private_ip = "${aws_instance.kubernetes_etcd.private_ip}"
    etcd_public_ip = "${aws_instance.kubernetes_etcd.public_ip}"
    hyperkube_deployment_mode = "${var.hyperkube_deployment_mode}"
    hyperkube_image = "${var.hyperkube_image}"
    interface_name = "eth0"
    kraken_services_branch = "${var.kraken_services_branch}"
    kraken_services_dirs = "${var.kraken_services_dirs}"
    kraken_services_repo = "${var.kraken_services_repo}"
    kubernetes_api_version = "${var.kubernetes_api_version}"
    kubernetes_binaries_uri = "${var.kubernetes_binaries_uri}"
    logentries_token = "${var.logentries_token}"
    logentries_url = "${var.logentries_url}"
    format_docker_storage_mnt = "${lookup(var.format_docker_storage_mnt, var.aws_storage_type_master)}"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
    kraken_repo = "${var.kraken_repo.repo}"
    kraken_branch = "${var.kraken_repo.branch}"
    kraken_commit = "${var.kraken_repo.commit_sha}"
    kraken_kube_cert_base_url = "https://s3-${aws_s3_bucket.b.region}.amazonaws.com/${aws_s3_bucket.b.id}"
    ansible_docker_image = "${var.ansible_docker_image}"
  }
}
resource "aws_instance" "kubernetes_apiserver" {
  depends_on = ["aws_instance.kubernetes_etcd"]
  count = "${var.apiserver_count}"
  ami = "${coreos_ami.latest_ami.ami}"
  instance_type = "${var.aws_apiserver_type}"
  key_name = "${aws_key_pair.keypair.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.vpc_secgroup.id}" ]
  subnet_id = "${aws_subnet.vpc_subnet.id}"
  associate_public_ip_address = true
  ebs_block_device {
    device_name = "${var.aws_storage_path.ebs}"
    volume_size = "${var.aws_volume_size_apiserver}"
    volume_type = "${var.aws_volume_type_apiserver}"
  }
  ephemeral_block_device {
    device_name = "${var.aws_storage_path.ephemeral}"
    virtual_name = "ephemeral0"
  }
  user_data = "${template_file.apiserver_cloudinit.rendered}"
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_apiserver-${format("%03d", count.index+1)}"
    ShortName = "${format("apiserver-%03d", count.index+1)}"
    StorageType = "${var.aws_storage_type_apiserver}"
  }
}

resource "template_file" "master_cloudinit" {
  filename = "${path.module}/templates/master.yaml.tpl"
  depends_on = ["aws_s3_bucket.b"] # need the returned data
  vars {
    ansible_playbook_command = "${var.ansible_playbook_command}"
    ansible_playbook_file = "${var.ansible_playbook_file}"
    cluster_master_record = "http://${var.aws_user_prefix}-master.${var.aws_cluster_domain}:8080"
    cluster_name = "aws"
    dns_domain = "${var.dns_domain}"
    dns_ip = "${var.dns_ip}"
    dockercfg_base64 = "${var.dockercfg_base64}"
    etcd_private_ip = "${aws_instance.kubernetes_etcd.private_ip}"
    etcd_public_ip = "${aws_instance.kubernetes_etcd.public_ip}"
    hyperkube_deployment_mode = "${var.hyperkube_deployment_mode}"
    hyperkube_image = "${var.hyperkube_image}"
    interface_name = "eth0"
    kraken_services_branch = "${var.kraken_services_branch}"
    kraken_services_dirs = "${var.kraken_services_dirs}"
    kraken_services_repo = "${var.kraken_services_repo}"
    kubernetes_api_version = "${var.kubernetes_api_version}"
    kubernetes_binaries_uri = "${var.kubernetes_binaries_uri}"
    logentries_token = "${var.logentries_token}"
    logentries_url = "${var.logentries_url}"
    short_name = "master"
    cluster_proxy_record = "${var.aws_user_prefix}-proxy.${var.aws_cluster_domain}"
    format_docker_storage_mnt = "${lookup(var.format_docker_storage_mnt, var.aws_storage_type_master)}"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
    kraken_repo = "${var.kraken_repo.repo}"
    kraken_branch = "${var.kraken_repo.branch}"
    apiserver_nginx_pool = "${join(" ", concat(formatlist("server %v:8080;", aws_instance.kubernetes_apiserver.*.private_ip)))}"
    kraken_commit = "${var.kraken_repo.commit_sha}"
    kraken_kube_cert_base_url = "https://s3-${aws_s3_bucket.b.region}.amazonaws.com/${aws_s3_bucket.b.id}"
    ansible_docker_image = "${var.ansible_docker_image}"
  }
}
resource "aws_instance" "kubernetes_master" {
  depends_on = ["aws_instance.kubernetes_apiserver"]
  ami = "${coreos_ami.latest_ami.ami}"
  instance_type = "${var.aws_master_type}"
  key_name = "${aws_key_pair.keypair.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.vpc_secgroup.id}" ]
  subnet_id = "${aws_subnet.vpc_subnet.id}"
  associate_public_ip_address = true
  ebs_block_device {
    device_name = "${var.aws_storage_path.ebs}"
    volume_size = "${var.aws_volume_size_master}"
    volume_type = "${var.aws_volume_type_master}"
  }
  ephemeral_block_device {
    device_name = "${var.aws_storage_path.ephemeral}"
    virtual_name = "ephemeral0"
  }
  user_data = "${template_file.master_cloudinit.rendered}"
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_master"
    ShortName = "master"
    StorageType = "${var.aws_storage_type_master}"
  }
}

resource "template_file" "node_cloudinit_special" {
  filename = "${path.module}/templates/node.yaml.tpl"
  depends_on = ["aws_s3_bucket.b"] # need the returned data
  count = "${var.special_node_count}"
  vars {
    ansible_playbook_command = "${var.ansible_playbook_command}"
    ansible_playbook_file = "${var.ansible_playbook_file}"
    cluster_master_record = "http://${var.aws_user_prefix}-master.${var.aws_cluster_domain}:8080"
    cluster_name = "aws"
    dns_domain = "${var.dns_domain}"
    dns_ip = "${var.dns_ip}"
    dockercfg_base64 = "${var.dockercfg_base64}"
    etcd_private_ip = "${aws_instance.kubernetes_etcd.private_ip}"
    etcd_public_ip = "${aws_instance.kubernetes_etcd.public_ip}"
    hyperkube_deployment_mode = "${var.hyperkube_deployment_mode}"
    hyperkube_image = "${var.hyperkube_image}"
    interface_name = "eth0"
    kraken_services_branch = "${var.kraken_services_branch}"
    kraken_services_dirs = "${var.kraken_services_dirs}"
    kraken_services_repo = "${var.kraken_services_repo}"
    kubernetes_api_version = "${var.kubernetes_api_version}"
    kubernetes_binaries_uri = "${var.kubernetes_binaries_uri}"
    logentries_token = "${var.logentries_token}"
    logentries_url = "${var.logentries_url}"
    master_private_ip = "${aws_instance.kubernetes_master.private_ip}"
    master_public_ip = "${aws_instance.kubernetes_master.public_ip}"
    cluster_proxy_record = "${var.aws_user_prefix}-proxy.${var.aws_cluster_domain}"
    format_docker_storage_mnt = "${lookup(var.format_docker_storage_mnt, element(split(",", var.aws_storage_type_special), count.index))}"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
    short_name = "node-${format("%03d", count.index+1)}"
    kraken_repo = "${var.kraken_repo.repo}"
    kraken_branch = "${var.kraken_repo.branch}"
    kraken_commit = "${var.kraken_repo.commit_sha}"
    kraken_kube_cert_base_url = "https://s3-${aws_s3_bucket.b.region}.amazonaws.com/${aws_s3_bucket.b.id}"
    ansible_docker_image = "${var.ansible_docker_image}"
  }
}
resource "aws_instance" "kubernetes_node_special" {
  count = "${var.special_node_count}"
  ami = "${coreos_ami.latest_ami.ami}"
  instance_type = "${element(split(",", var.aws_special_node_type), count.index)}"
  key_name = "${aws_key_pair.keypair.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.vpc_secgroup.id}" ]
  subnet_id = "${aws_subnet.vpc_subnet.id}"
  associate_public_ip_address = true
  ebs_block_device {
    device_name = "${var.aws_storage_path.ebs}"
    volume_size = "${element(split(",", var.aws_volume_size_special), count.index)}"
    volume_type = "${element(split(",", var.aws_volume_type_special), count.index)}"
  }
  ephemeral_block_device {
    device_name = "${var.aws_storage_path.ephemeral}"
    virtual_name = "ephemeral0"
  }
  user_data = "${element(template_file.node_cloudinit_special.*.rendered, count.index)}"
  tags {
    Name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_node-${format("%03d", count.index+1)}"
    ShortName = "${format("node-%03d", count.index+1)}"
    StorageType = "${element(split(",", var.aws_storage_type_special), count.index)}"
  }
}

resource "template_file" "node_cloudinit" {
  filename = "${path.module}/templates/node.yaml.tpl"
  depends_on = ["aws_s3_bucket.b"] # need the returned data
  vars {
    ansible_playbook_command = "${var.ansible_playbook_command}"
    ansible_playbook_file = "${var.ansible_playbook_file}"
    cluster_master_record = "http://${var.aws_user_prefix}-master.${var.aws_cluster_domain}:8080"
    cluster_name = "aws"
    dns_domain = "${var.dns_domain}"
    dns_ip = "${var.dns_ip}"
    dockercfg_base64 = "${var.dockercfg_base64}"
    etcd_private_ip = "${aws_instance.kubernetes_etcd.private_ip}"
    etcd_public_ip = "${aws_instance.kubernetes_etcd.public_ip}"
    hyperkube_deployment_mode = "${var.hyperkube_deployment_mode}"
    hyperkube_image = "${var.hyperkube_image}"
    interface_name = "eth0"
    kraken_services_branch = "${var.kraken_services_branch}"
    kraken_services_dirs = "${var.kraken_services_dirs}"
    kraken_services_repo = "${var.kraken_services_repo}"
    kubernetes_api_version = "${var.kubernetes_api_version}"
    kubernetes_binaries_uri = "${var.kubernetes_binaries_uri}"
    logentries_token = "${var.logentries_token}"
    logentries_url = "${var.logentries_url}"
    master_private_ip = "${aws_instance.kubernetes_master.private_ip}"
    master_public_ip = "${aws_instance.kubernetes_master.public_ip}"
    cluster_proxy_record = "${var.aws_user_prefix}-proxy.${var.aws_cluster_domain}"
    format_docker_storage_mnt = "${lookup(var.format_docker_storage_mnt, var.aws_storage_type)}"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
    short_name = "autoscaled"
    kraken_repo = "${var.kraken_repo.repo}"
    kraken_branch = "${var.kraken_repo.branch}"
    kraken_commit = "${var.kraken_repo.commit_sha}"
    kraken_kube_cert_base_url = "https://s3-${aws_s3_bucket.b.region}.amazonaws.com/${aws_s3_bucket.b.id}"
    ansible_docker_image = "${var.ansible_docker_image}"
  }
}
resource "aws_launch_configuration" "kubernetes_node" {
  image_id = "${coreos_ami.latest_ami.ami}"
  instance_type = "${var.aws_node_type}"
  key_name = "${aws_key_pair.keypair.key_name}"
  security_groups  = [ "${aws_security_group.vpc_secgroup.id}" ]
  associate_public_ip_address = true
  user_data = "${template_file.node_cloudinit.rendered}"
  ebs_block_device {
    device_name = "${var.aws_storage_path.ebs}"
    volume_size = "${var.aws_volume_size}"
    volume_type = "${var.aws_volume_type}"
  }
  ephemeral_block_device {
    device_name = "${var.aws_storage_path.ephemeral}"
    virtual_name = "ephemeral0"
  }
}
resource "aws_autoscaling_group" "kubernetes_nodes" {
  name = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_nodes"
  max_size = "${var.node_count}"
  min_size = "${var.node_count}"
  desired_capacity = "${var.node_count}"
  force_delete = true
  wait_for_capacity_timeout = "0"
  health_check_grace_period = "30"
  default_cooldown = "10"
  vpc_zone_identifier = ["${aws_subnet.vpc_subnet.id}"]
  launch_configuration = "${aws_launch_configuration.kubernetes_node.name}"
  health_check_type = "EC2"
  tag {
    key = "StorageType"
    value = "${var.aws_storage_type}"
    propagate_at_launch = true
  }
  tag {
    key = "Name"
    value = "${var.aws_user_prefix}_${var.aws_cluster_prefix}_node-autoscaled"
    propagate_at_launch = true
  }
  tag {
    key = "ShortName"
    value = "node-autoscaled"
    propagate_at_launch = true
  }
}

resource "aws_route53_record" "master_record" {
  zone_id = "${var.aws_zone_id}"
  name = "${var.aws_user_prefix}-master.${var.aws_cluster_domain}"
  type = "A"
  ttl = "30"
  records = ["${aws_instance.kubernetes_master.public_ip}"]
}
resource "aws_route53_record" "proxy_record" {
  zone_id = "${var.aws_zone_id}"
  name = "${var.aws_user_prefix}-proxy.${var.aws_cluster_domain}"
  type = "A"
  ttl = "30"
  records = ["${aws_instance.kubernetes_node_special.0.public_ip}"]
}


resource "template_file" "ansible_inventory" {
  filename = "${path.module}/templates/ansible.inventory.tpl"
  depends_on = ["aws_s3_bucket.b"] # need the returned data
  vars {
    kraken_kube_cert_base_url = "https://s3-${aws_s3_bucket.b.region}.amazonaws.com/${aws_s3_bucket.b.id}"
    ansible_ssh_private_key_file = "${var.aws_local_private_key}"
    etcd_public_ip = "${aws_instance.kubernetes_etcd.public_ip}"
    master_public_ip = "${aws_instance.kubernetes_master.public_ip}"
    cluster_name = "aws"
    cluster_master_record = "http://${var.aws_user_prefix}-master.${var.aws_cluster_domain}:8080"
    nodes_inventory_info = "${join("\n", formatlist("%v ansible_ssh_host=%v", aws_instance.kubernetes_node_special.*.tags.ShortName, aws_instance.kubernetes_node_special.*.public_ip))}"
    dns_domain = "${var.dns_domain}"
    dns_ip = "${var.dns_ip}"
    dockercfg_base64 = "${var.dockercfg_base64}"
    etcd_private_ip = "${aws_instance.kubernetes_etcd.private_ip}"
    etcd_public_ip = "${aws_instance.kubernetes_etcd.public_ip}"
    hyperkube_deployment_mode = "${var.hyperkube_deployment_mode}"
    hyperkube_image = "${var.hyperkube_image}"
    interface_name = "eth0"
    kraken_services_branch = "${var.kraken_services_branch}"
    kraken_services_dirs = "${var.kraken_services_dirs}"
    kraken_services_repo = "${var.kraken_services_repo}"
    kubernetes_api_version = "${var.kubernetes_api_version}"
    kubernetes_binaries_uri = "${var.kubernetes_binaries_uri}"
    logentries_token = "${var.logentries_token}"
    logentries_url = "${var.logentries_url}"
    master_private_ip = "${aws_instance.kubernetes_master.private_ip}"
    master_public_ip = "${aws_instance.kubernetes_master.public_ip}"
    apiservers_inventory_info = "${join("\n", concat(formatlist("%v ansible_ssh_host=%v", aws_instance.kubernetes_apiserver.*.tags.ShortName, aws_instance.kubernetes_apiserver.*.public_ip)))}"
    cluster_proxy_record = "${var.aws_user_prefix}-proxy.${var.aws_cluster_domain}"
    format_docker_storage_mnt = "${lookup(var.format_docker_storage_mnt, var.aws_storage_type)}"
    coreos_update_channel = "${var.coreos_update_channel}"
    coreos_reboot_strategy = "${var.coreos_reboot_strategy}"
    apiserver_nginx_pool = "${join(" ", concat(formatlist("server %v:8080;", aws_instance.kubernetes_apiserver.*.private_ip)))}"
  }

  provisioner "local-exec" {
    command = "cat << 'EOF' > ${path.module}/rendered/ansible.inventory\n${self.rendered}\nEOF"
  }

  # a special trick to run against localhost without using inventory
  provisioner "local-exec" {
    command = "ansible-playbook -i 'localhost,' --connection=local ${path.module}/../../ansible/localhost_pre_provision.yaml --extra-vars 'cluster_name=aws cluster_master_record=http://${var.aws_user_prefix}-master.${var.aws_cluster_domain}:8080'"
  }

  provisioner "local-exec" {
    command = "AWS_ACCESS_KEY_ID=${var.aws_access_key} AWS_SECRET_ACCESS_KEY=${var.aws_secret_key} AWS_DEFAULT_REGION=${var.aws_region} ${path.module}/kraken_asg_helper.sh --cluster aws --limit ${var.node_count + var.special_node_count} --name ${var.aws_user_prefix}_${var.aws_cluster_prefix}_nodes --output ${path.module}/rendered/ansible.inventory --singlewait ${var.asg_wait_single} --totalwaits ${var.asg_wait_total} --offset ${var.special_node_count} --retries ${var.asg_retries} --etcd ${aws_instance.kubernetes_etcd.public_ip} --port 4001"
  }
}
