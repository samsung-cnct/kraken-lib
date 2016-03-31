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

mkdir -p "/kraken_data/${KRAKEN_CLUSTER_NAME}/group_vars"

max_retries=${TERRAFORM_RETRIES}
time until terraform apply \
  -input=false \
  -state=/kraken_data/${KRAKEN_CLUSTER_NAME}/terraform.tfstate \
  -var-file=/opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}/${KRAKEN_CLUSTER_NAME}/terraform.tfvars \
  -var "cluster_name=${KRAKEN_CLUSTER_NAME}" \
  -var "kubeconfig=/kraken_data/${KRAKEN_CLUSTER_NAME}/kube_config" \
  /opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}
do
  if [ ${max_retries} -gt 0 ]; then
    max_retries=$((max_retries-1))
    echo "terraform apply failed with return code $?, retrying..."
    sleep 5
  else
    break
  fi
done

cp /opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}/rendered/hosts /kraken_data/${KRAKEN_CLUSTER_NAME}/hosts
cp /opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}/rendered/group_vars/cluster /kraken_data/${KRAKEN_CLUSTER_NAME}/group_vars/cluster
cp /opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}/rendered/group_vars/all /kraken_data/${KRAKEN_CLUSTER_NAME}/group_vars/all
cp /root/.ssh/config_${KRAKEN_CLUSTER_NAME} /kraken_data/${KRAKEN_CLUSTER_NAME}/ssh_config
