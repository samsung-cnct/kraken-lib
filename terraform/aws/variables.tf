# Listing required vairables first
variable "aws_access_key" {
  description = "AWS key id"
}
variable "aws_secret_key" {
  description = "AWS secret key"
}
variable "aws_user_prefix" {
  description = "AWS resource prefix - all resources with names will be identified as <aws_user_prefix>_<aws_cluster_prefix>_<name>"
}

# variables with defaults
variable "max_retries" {
  default = "100"
  description = "Max number of API call retries before failure"
}
variable "aws_cluster_prefix" {
  default = "kubernetes"
  description = "AWS cluster prefix - all resources with names will be identified as <aws_user_prefix>_<aws_cluster_prefix>_<name>"
}
variable "aws_region" {
  default = "us-west-2"
  description = "AWS region"
}
variable "aws_zone_id" {
  default = "ZX7O08V47RE60"
  description = "Route53 hosted zone id"
}
variable "node_count" {
  default = "3"
  description = "How many nodes (not counting master and etcd to bring up)"
}
variable "aws_master_type" {
  default = "m3.xlarge"
  description = "Kubernetes master instance type"
}
variable "aws_etcd_type" {
  default = "m3.xlarge"
  description = "Kubernetes etcd instance type"
}
variable "aws_node_type" {
  description = "Types of nodes. Special - type per node, starting with node 1. Other - all other nodes not covered in special. Special count must be < node_count."
  default = {
    "special" = "m3.xlarge"
    "other" = "m3.medium"
  }
}
variable "aws_storage_type" {
  description = "Storage types for nodes. ebs or ephemeral. special_nodes is a list of types, must be < node_count. Must be same length as special node type list."
  default = {
    "master" = "ebs"
    "etcd" = "ebs"
    "special_nodes" = "ebs"
    "other_nodes" = "ebs"
  }
}
variable "aws_volume_size" {
  default = {
    "master" = "30"
    "etcd" = "30"
    "special_nodes" = "30"
    "other_nodes" = "30"
  }
  description = "Size of EBS volume attached to each AWS instance in gigabytes. special_nodes is a list of sizes, must be < node_count. Must be same length as special node type list."
}
variable "aws_volume_type" {
  default = {
    "master" = "gp2"
    "etcd" = "gp2"
    "special_nodes" = "gp2"
    "other_nodes" = "gp2"
  }
  description = "Type of EBS volume attached to each AWS instance. special_nodes is a list of types, must be < node_count. Must be same length as special node type list."
}
variable "aws_storage_path" {
  default =  {
    "ebs" = "/dev/sdf"
    "ephemeral" = "/dev/sdb"
  }
  description = "Storage device path"
}
variable "format_docker_storage_mnt" {
  default =  {
    "ebs" = "/dev/xvdf"
    "ephemeral" = "/dev/xvdb"
  }
  description = "Mount point for EBS drive to move /var/docker to"
}
variable "kraken_port_low" {
  default = "30000"
  description = "Low port range for kraken kubernetes services"
}
variable "kraken_port_high" {
  default = "32767"
  description = "High port range for kraken kubernetes services"
}
variable "aws_local_public_key" {
  default = "~/.ssh/id_rsa.pub"
  description = "Location of public key material to import into the <aws_user_prefix>_<aws_cluster_prefix>_keypair"
}
variable "aws_local_private_key" {
  default = "~/.ssh/id_rsa"
  description = "Location of private key material"
}
variable "aws_cluster_domain" {
  default = "kubeme.io"
  description = "Location of public key material to import into the <aws_user_prefix>_<aws_cluster_prefix>_keypair"
}
variable "coreos_update_channel" {
  default = "beta"
  description = "Core OS update channel. Alpha, beta, stable or some custom value"
}
variable "coreos_reboot_strategy" {
  default = "off"
  description = "Core OS reboot strategy"
}
variable "kraken_services_repo" {
  default = "git://github.com/samsung-ag/kraken-services"
  description = "Kraken services git repo"
}
variable "kraken_services_branch" {
  default = "stable"
  description = "Kraken services repo branch"
}
variable "dns_domain" {
  default = "kubernetes.local"
  description = "Kubenretes DNS domain"
}
variable "dns_ip" {
  default = "10.100.0.10"
  description = "Kubernetes DNS ip"
}
variable "dockercfg_base64" {
  default = ""
  description = "Docker base64-encoded configuration string"
}
variable "hyperkube_deployment_mode" {
  default = "binary"
  description = "Run inside 'docker' or run on host as 'binary'"
}
variable "hyperkube_image" {
  default = "gcr.io/google_containers/hyperkube:v1.0.3"
  description = "image to use when running with hyperkube_deploy_mode 'docker'"
}
variable "kubernetes_binaries_uri" {
  default = "https://storage.googleapis.com/kubernetes-release/release/v1.0.3/bin/linux/amd64"
  description = "url to fetch hyperkube, kubectl binaries from in hyperkube_deploy_mode 'binary'"
}
variable "kubernetes_api_version" {
  default = "v1"
  description = "Kubernetes api version"
}
variable "kube_apiserver_v" {
  default = "2"
  description = "kubernetes apiserver verbosity"
}
variable "kube_controller_manager_v" {
  default = "2"
  description = "kubernetes controller manager verbosity"
}
variable "kube_scheduler_v" {
  default = "2"
  description = "kubernetes scheduler verbosity"
}
variable "kubelet_v" {
  default = "2"
  description = "kubernetes kubelet verbosity"
}
variable "kube_proxy_v" {
  default = "2"
  description = "kubernetes proxy verbosity"
}
variable "ansible_forks" {
  default = "5"
  description = "number of parallel processes to use for ansible-playbook run"
}
variable "kraken_services_dirs" {
  default = "heapster influxdb-grafana kube-ui loadtest prometheus"
  description = "Kraken services folders under kraken repo to deploy kubernetes services from."
}
variable "logentries_token" {
  default = ""
  description = "Logentries.com token"
}
variable "logentries_url" {
  default = "api.logentries.com:20000"
  description = "Logentries.com API url"
}



