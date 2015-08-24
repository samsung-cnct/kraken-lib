variable "node_count" {
  default = "3"
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

variable "coreos_release" {
  default = "773.1.0"
  description = "Core OS release"
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
variable "node_cpus" {
  default = "1"
  description = "Number of cpus for node vm"
}
variable "node_mem" {
  default = "1024"
  description = "megs of RAM for node VM"
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
variable "hyperkube_image" {
  default = "gcr.io/google_containers/hyperkube:v1.0.3"
  description = "docker image to launch hyperkube"
}
variable "kubernetes_version" {
  default = "1.0.3"
  description = "Kubernetes version, numbers only"
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
variable "vagrant_private_key" {
  default = "~/.vagrant.d/insecure_private_key"
  description = "Location of private key for vagrant to use"
}




