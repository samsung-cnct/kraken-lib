variable "node_count" {
  default = "3"
  description = "How many nodes (not counting master and etcd to bring up)"
}

module "local" {
  source = "../modules/local"
  node_count = "${var.node_count}"
}

