#!/bin/bash -
#title           :terraform-up.sh
#description     :run terraform with parameters. This is intended to be executed inside a docker container.
#author          :Samsung SDSRA
#==============================================================================

set -o errexit
set -o nounset
set -o pipefail

source "/opt/kraken/docker-utils.sh"

if [ -z ${KRAKEN_CLUSTER_TYPE+x} ]; then
  error "--clustertype not specified."
  exit 1
fi

if [ -z ${KRAKEN_CLUSTER_NAME+x} ]; then
  error "--clustername not specified."
  exit 1
fi

mkdir -p "/kraken_data/${KRAKEN_CLUSTER_NAME}"
terraform apply \
  -input=false \
  -state=/kraken_data/${KRAKEN_CLUSTER_NAME}/terraform.tfstate \
  -var-file=/opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}/${KRAKEN_CLUSTER_NAME}/terraform.tfvars \
  -var "cluster_name=${KRAKEN_CLUSTER_NAME}" \
  -var "kubeconfig=/kraken_data/kube_config" \
  /opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}

cp /opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}/rendered/ansible.inventory /kraken_data/${KRAKEN_CLUSTER_NAME}/ansible.inventory
cp /root/.ssh/config_${KRAKEN_CLUSTER_NAME} /kraken_data/${KRAKEN_CLUSTER_NAME}/ssh_config