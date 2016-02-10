#!/bin/bash -
#title           :kraken-ssh.sh
#description     :ssh to a remotely managed cluster node
#author          :Samsung SDSRA
#==============================================================================

set -o errexit
set -o nounset
set -o pipefail

# kraken root folder
KRAKEN_ROOT=$(dirname "${BASH_SOURCE}")/..

source "${KRAKEN_ROOT}/bin/utils.sh"

kraken_container_name="kraken_cluster_${KRAKEN_CLUSTER_NAME}"
is_running=$(docker inspect -f '{{ .State.Running }}' ${kraken_container_name})
if [ ${is_running} == "true" ];  then
  error "Cluster build is currently running:\n Run\n  \
    'docker logs --follow ${kraken_container_name}'\n to see logs."
  exit 1
fi

mkdir -p "${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}"
docker cp \
  kraken_data:/kraken_data/${KRAKEN_CLUSTER_NAME}/ssh_config \
  "${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}/"
docker cp \
  kraken_data:/kraken_data/${KRAKEN_CLUSTER_NAME}/ansible.inventory \
  "${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}/"
docker cp \
  kraken_data:/kraken_data/${KRAKEN_CLUSTER_NAME}/terraform.tfstate \
  "${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}/"
docker cp \
  ${kraken_container_name}:/opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}/${KRAKEN_CLUSTER_NAME}/terraform.tfvars \
  "${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}/"
docker cp \
  kraken_data:/kraken_data/${KRAKEN_CLUSTER_NAME}/kube_config \
  "${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}/"
docker cp \
  ${kraken_container_name}:/root/.ssh/id_rsa \
  "${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}/"
docker cp \
  ${kraken_container_name}:/root/.ssh/id_rsa.pub \
  "${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}/"

inf "Parameters for ssh:\n   \
  ssh -F ${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}/ssh_config -i \
  ${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}/id_rsa <node-name>\n"
inf "Alternatively: \n"
inf "   eval \$(docker-machine env ${KRAKEN_DOCKER_MACHINE_NAME})\n   \
  docker run -it --volumes-from kraken_data samsung_ag/kraken ssh -F \
  /kraken_data/${KRAKEN_CLUSTER_NAME}/ssh_config <other ssh options> <node-name>"

inf "\n\nParameters for ansible:\n   \
  --inventory-file ${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}/ansible.inventory\n   \
  --private-key ${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}/id_rsa"

inf "\n\nParameters for terraform:\n   \
  -state=${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}/terraform.tfstate\n   \
  -var-file=${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}/terraform.tfvars\n   \
  -var 'cluster_name=${KRAKEN_CLUSTER_NAME}'"

inf "\n\nTo control your cluster use:\n  \
  kubectl --kubeconfig=${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}/kube_config \
  --cluster=${KRAKEN_CLUSTER_NAME} <kubectl commands>"