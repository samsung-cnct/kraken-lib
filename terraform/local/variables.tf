variable "apiserver_count" {
  default = "1"
  description = "How many apiservers to run in a pool"
}
variable "node_count" {
  default = "2"
  description = "How many nodes (not counting master and etcd to bring up)"
}
variable "coreos_update_channel" {
  default = "alpha"
  description = "Core OS update channel. Alpha, beta, stable or some custom value"
}

variable "coreos_reboot_strategy" {
  default = "off"
  description = "Core OS reboot strategy."
}

variable "ip_base" {
  default = "172.16.1"
  description = "IP addresses will be assigned from ip_base.103 to ip_base.102 + number of nodes"
}

variable "etcd_cpus" {
  default = "1"
  description = "Number of cpus for etcd vm"
}
variable "etcd_mem" {
  default = "1024"
  description = "megs of RAM for etcd VM"
}
variable "master_cpus" {
  default = "1"
  description = "Number of cpus for master vm"
}
variable "master_mem" {
  default = "1024"
  description = "megs of RAM for master VM"
}
variable "apiserver_cpus" {
  default = "1"
  description = "Number of cpus for master vm"
}
variable "apiserver_mem" {
  default = "1024"
  description = "megs of RAM for master VM"
}
variable "node_cpus" {
  default = "1"
  description = "Number of cpus for node vm"
}
variable "node_mem" {
  default = "1024"
  description = "megs of RAM for node VM"
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
  default = "gcr.io/google_containers/hyperkube:v1.0.6"
  description = "image to use when running with hyperkube_deploy_mode 'docker'"
}
variable "kubernetes_binaries_uri" {
  default = "https://storage.googleapis.com/kubernetes-release/release/v1.0.6/bin/linux/amd64"
  description = "url to fetch hyperkube, kubectl binaries from in hyperkube_deploy_mode 'binary'"
}
variable "kubernetes_api_version" {
  default = "v1"
  description = "Kubernetes api version"
}
variable "ansible_forks" {
  default = "5"
  description = "number of parallel processes to use for ansible-playbook run"
}
variable "kraken_services_dirs" {
  default = "heapster influxdb-grafana kube-ui loadtest prometheus"
  description = "Kraken services folders under kraken repo to deploy kubernetes services from."
}
variable "kraken_services_repo" {
  default = "git://github.com/samsung-ag/kraken-services"
  description = "Kraken services git repo"
}
variable "kraken_services_branch" {
  default = "master"
  description = "Kraken services repo branch"
}
variable "logentries_token" {
  default = ""
  description = "Logentries.com token"
}
variable "logentries_url" {
  default = "api.logentries.com:20000"
  description = "Logentries.com API url"
}
variable "vagrant_private_key" {
  default = "~/.vagrant.d/insecure_private_key"
  description = "Location of private key for vagrant to use"
}




