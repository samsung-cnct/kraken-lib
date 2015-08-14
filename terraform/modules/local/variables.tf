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




