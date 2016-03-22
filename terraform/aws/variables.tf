# Listing required vairables first
variable "cluster_name" {
  description = "Name of the cluster, useed in kubernetes config as the --cluster"
}

variable "aws_access_key" {
  description = "AWS key id"
}

variable "aws_secret_key" {
  description = "AWS secret key"
}

variable "aws_user_prefix" {
  description = "AWS resource prefix - all resources with names will be identified as <aws_user_prefix>_<cluster_name>_resource. Also used in kubectl --user"
}

variable "sysdigcloud_access_key" {
  description = "Sysdig Cloud Access Key"
  default = ""
}

# variables with defaults
variable "kubeconfig" {
  description = "Location of kubeconfig file used during kubectl invocations"
  default     = "~/.kube/config"
}

variable "max_retries" {
  default     = "100"
  description = "Max number of API call retries before failure"
}

variable "aws_region" {
  default     = "us-west-2"
  description = "AWS region"
}

variable "aws_region_azs" {
  default = {
    "us-west-2" = "us-west-2a,us-west-2b,us-west-2c"
    "us-east-1" = "us-east-1b,us-east-1c,us-east-1d"
  }

  description = "Availability zones by region"
}

variable "aws_zone_id" {
  default     = "ZX7O08V47RE60"
  description = "Route53 hosted zone id"
}

variable "special_node_count" {
  default     = "1"
  description = "How many nodes (not counting master, etcd and special nodes to bring up). At least 1."
}

variable "node_count" {
  default     = "3"
  description = "How many nodes (not counting master, etcd and special nodes to bring up)"
}

variable "apiserver_count" {
  default     = "1"
  description = "How many apiservers to include in the apiserver pool"
}

variable "aws_master_type" {
  default     = "m3.xlarge"
  description = "Kubernetes master instance type"
}

variable "aws_etcd_type" {
  default     = "m3.xlarge"
  description = "Kubernetes etcd instance type"
}

variable "aws_apiserver_type" {
  default     = "m3.large"
  description = "Kubernetes apiserver instance type"
}

variable "aws_special_node_type" {
  description = "Types of nodes. Type per node, comma separated, starting with node 1. Number of must be = special_node_count."
  default     = "m3.xlarge"
}

variable "aws_node_type" {
  description = "Types of nodes, other than special nodes"
  default     = "t2.micro"
}

variable "aws_storage_type_master" {
  description = "Primary volume type for master"
  default     = "ebs"
}

variable "aws_storage_type_apiserver" {
  description = "Primary volume type for master"
  default     = "ebs"
}

variable "aws_storage_type_etcd" {
  description = "Primary volume type for master"
  default     = "ebs"
}

variable "aws_storage_type_special_docker" {
  description = "Primary volume type for special nodes for /var/lib/docker. Comma-sperated list. Count must = special_node_count"
  default     = "ebs"
}

variable "aws_storage_type_special_kubelet" {
  description = "Primary volume type for special nodes for /var/lib/kubelet. Comma-sperated list. Count must = special_node_count"
  default     = "ebs"
}

variable "aws_storage_type_node_docker" {
  description = "Primary volume type for nodes for /var/lib/docker"
  default     = "ebs"
}

variable "aws_storage_type_node_kubelet" {
  description = "Primary volume type for nodes for /var/lib/kubelet"
  default     = "ebs"
}

variable "aws_volume_size_master" {
  default     = "10"
  description = "Size of EBS volume attached to master instance in gigabytes."
}

variable "aws_volume_size_apiserver" {
  default     = "10"
  description = "Size of EBS volume attached to master instance in gigabytes."
}

variable "aws_volume_size_etcd" {
  default     = "10"
  description = "Size of EBS volume attached to etcd instance in gigabytes."
}

variable "aws_volume_size_special_docker" {
  default     = "10"
  description = "Sizes of EBS volume attached to special nodes for /var/lib/docker. Comma-sperated list. Count must = special_node_count."
}

variable "aws_volume_size_special_kubelet" {
  default     = "10"
  description = "Sizes of EBS volume attached to special nodes for /var/lib/kubelet. Comma-sperated list. Count must = special_node_count."
}

variable "aws_volume_size_node_docker" {
  default     = "10"
  description = "Size of EBS volume attached to nodes for /var/lib/docker in gigabytes."
}

variable "aws_volume_size_node_kubelet" {
  default     = "10"
  description = "Size of EBS volume attached to nodes for /var/lib/kubelet in gigabytes"
}

variable "aws_volume_type_master" {
  default     = "gp2"
  description = "Type of EBS volume attached to master AWS instance. "
}

variable "aws_volume_type_apiserver" {
  default     = "gp2"
  description = "Type of EBS volume attached to master AWS instance. "
}

variable "aws_volume_type_etcd" {
  default     = "gp2"
  description = "Type of EBS volume attached to etcd AWS instance. "
}

variable "aws_volume_type_special_docker" {
  default     = "gp2"
  description = "Type of EBS volume attached special nodes for /var/lib/docker. Comma-sperated list. Count must = special_node_count."
}

variable "aws_volume_type_special_kubelet" {
  default     = "gp2"
  description = "Type of EBS volume attached special nodes for /var/lib/kubelet. Comma-sperated list. Count must = special_node_count."
}

variable "aws_volume_type_node_docker" {
  default     = "gp2"
  description = "Type of EBS volume attached to node for /var/lib/docker"
}

variable "aws_volume_type_node_kubelet" {
  default     = "gp2"
  description = "Type of EBS volume attached to nodes for /var/lib/kubelet"
}

variable "aws_storage_path" {
  default = {
    "ebs"       = "/dev/sdf"
    "ephemeral" = "/dev/sdb"
  }

  description = "Storage device path"
}

variable "format_docker_storage_mnt" {
  default = {
    "ebs"       = "/dev/xvdf"
    "ephemeral" = "/dev/xvdb"
  }

  description = "Mount point for EBS drive to move /var/lib/docker to"
}

variable "format_kubelet_storage_mnt" {
  default = {
    "ebs"       = "/dev/xvdg"
    "ephemeral" = "/dev/xvdc"
  }

  description = "Mount point for EBS drive to move /var/lib/kubelet to"
}

variable "kraken_port_low" {
  default     = "30000"
  description = "Low port range for kraken kubernetes services"
}

variable "kraken_port_high" {
  default     = "32767"
  description = "High port range for kraken kubernetes services"
}

variable "aws_local_public_key" {
  default     = "~/.ssh/id_rsa.pub"
  description = "Location of public key material to import into the <aws_user_prefix>_<cluster_name>_keypair"
}

variable "aws_local_private_key" {
  default     = "~/.ssh/id_rsa"
  description = "Location of private key material"
}

variable "aws_cluster_domain" {
  default     = "kubeme.io"
  description = "Domain to use for route53 records <aws_user_prefix>-<cluster_name>-master.<aws_cluster_domain>"
}

variable "coreos_update_channel" {
  default     = "beta"
  description = "Core OS update channel. Alpha, beta, stable or some custom value"
}

variable "coreos_version" {
  default     = "current"
  description = "Core OS version. current or version number."
}

variable "coreos_reboot_strategy" {
  default     = "off"
  description = "Core OS reboot strategy"
}

variable "kraken_local_dir" {
  default = "/opt/kraken"
  description = "location of kraken files"
}

variable "kraken_repo" {
  default = {
    "repo"       = "https://github.com/Samsung-AG/kraken.git"
    "branch"     = "master"
    "commit_sha" = ""
  }

  description = "Kraken git repo"
}

variable "kraken_services_repo" {
  default     = "https://github.com/samsung-ag/kraken-services"
  description = "Kraken services git repo"
}

variable "kraken_services_branch" {
  default     = "master"
  description = "Kraken services repo branch"
}

variable "kraken_services_dirs" {
  default     = "skydns cluster-monitoring kubedash prometheus"
  description = "Kraken services folders under kraken repo to deploy kubernetes services from."
}

variable "thirdparty_scheduler" {
  default     = ""
  description = "Kraken services folder that has a third party scheduler pod"
}

variable "ansible_docker_image" {
  default     = "quay.io/samsung_ag/kraken_ansible"
  description = "Docker image to use for ansible-in-docker"
}

variable "dns_domain" {
  default     = "cluster.local"
  description = "Kubenretes DNS domain"
}

variable "dns_ip" {
  default     = "10.100.0.10"
  description = "Kubernetes DNS ip"
}

variable "dockercfg_base64" {
  default     = ""
  description = "Docker base64-encoded configuration string"
}

variable "deployment_mode" {
  default     = "binary"
  description = "Run inside 'container' or run on host as 'binary'"
}

variable "hyperkube_image" {
  default     = "gcr.io/google_containers/hyperkube:v1.1.1"
  description = "image to use when running with hyperkube_deploy_mode 'docker'"
}

variable "kubernetes_binaries_uri" {
  default     = "https://storage.googleapis.com/kubernetes-release/release/v1.1.1/bin/linux/amd64"
  description = "url to fetch hyperkube, kubectl binaries from in hyperkube_deploy_mode 'binary'"
}

variable "kubernetes_api_version" {
  default     = "v1"
  description = "Kubernetes api version"
}

variable "kubernetes_cert_dir" {
  default = "/srv/kubernetes"
  description = "Location of kubernetes cert, keys, and tokens"
}

variable "logentries_token" {
  default     = ""
  description = "Logentries.com token"
}

variable "logentries_url" {
  default     = "api.logentries.com:20000"
  description = "Logentries.com API url"
}

variable "asg_wait_single" {
  default     = "10"
  description = "Sleep for x seconds between each check of number of nodes up"
}

variable "asg_wait_total" {
  default     = "180"
  description = "Repeat up to X waits"
}

variable "asg_retries" {
  default     = "4"
  description = "Retry X waits N times"
}

variable "ansible_playbook_command" {
  default     = "ansible-playbook"
  description = "ansible-playbook invocation that will run inside ansible-docker container via cloudinit"
}

variable "ansible_playbook_file" {
  default     = "/opt/kraken/ansible/kraken.yaml"
  description = "location of playbook file run with ansible_playbook_command"
}

variable "access_scheme" {
  default     = "https"
  description = "http or https"
}

variable "access_port" {
  default     = "443"
  description = "443, 8080 etc"
}

variable "command_passwd" {
  default     = ""
  description = "password to use for command addon in kraken-services"
}

variable "cluster_passwd" {
  default     = "kraken"
  description = "password to use for basic auth on the completed cluster"
}
