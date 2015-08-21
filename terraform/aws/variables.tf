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
variable "coreos_ami" {
  description = "CoreOS AMI defaults"
  default = {
    "ap-northeest-1" = "ami-f2338ff2"
    "ap-southeast-1" = "ami-b6d8d4e4"
    "ap-southeast-2" = "ami-8f88c8b5"
    "eu-central-1" = "ami-bececaa3"
    "eu-west-1" = "ami-0e104179"
    "sa-east-1" = "ami-11e9600c"
    "us-east-1" = "ami-3d73d356"
    "us-gov-west-1" = "ami-c75033e4"
    "us-west-1" = "ami-1db04f59"
    "us-west-2" = "ami-85ada4b5"
  }
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
  default = "m3.large"
  description = "Kubernetes etcd instance type"
}

variable "aws_node_type_file" {
  default = "default_typefile"
  description = "location of a file with comma-separated list of node types from 1 to n"
}

variable "aws_node_type" {
  description = "Types of nodes. Special - type per node, starting with node 1. Other - all other nodes not covered in special. Special count must be < node_count."
  default = {
    "special" = "m3.xlarge,m3.medium"
    "other" = "m3.medium"
  }
}

variable "aws_volume_size" {
  default = "300"
  description = "Size of EBS volume attached to each AWS instance in gigabytes"
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
variable "format_docker_storage_mnt" {
  default = "/dev/xvdf"
  description = "Mount point for EBS drive to move /var/docker to"
}
variable "coreos_update_channel" {
  default = "alpha"
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
variable "kubernetes_version" {
  default = "1.0.3"
  description = "Kubernetes version, numbers only"
}
variable "kubernetes_api_version" {
  default = "v1"
  description = "Kubernetes api version"
}
variable "kubernetes_verbosity" {
  default = "2"
  description = "Kubernetes log verbosity"
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



