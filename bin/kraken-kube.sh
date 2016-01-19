#!/bin/bash -
#title           :kraken-kube.sh
#description     :get the remote kubectl config
#author          :Samsung SDSRA
#==============================================================================

set -o errexit
set -o nounset
set -o pipefail

# kraken root folder
KRAKEN_ROOT=$(dirname "${BASH_SOURCE}")/..
source "${KRAKEN_ROOT}/bin/utils.sh"

if [ -z ${KRAKEN_CLUSTER_NAME+x} ]; then
  error "--clustername not specified. Cluster name is required."
  exit 1
fi

if [ "${KRAKEN_NATIVE_DOCKER}" = false ]; then 
  if [ -z ${KRAKEN_DOCKER_MACHINE_NAME+x} ]; then
    error "--dmname not specified. Docker Machine name is required."
    exit 1
  fi

  if docker-machine ls -q | grep --silent "${KRAKEN_DOCKER_MACHINE_NAME}"; then
    inf "Machine ${KRAKEN_DOCKER_MACHINE_NAME} exists."
  else
    error "Machine ${KRAKEN_DOCKER_MACHINE_NAME} does not exist."
    exit 1
  fi
  eval "$(docker-machine env ${KRAKEN_DOCKER_MACHINE_NAME})"
fi

kraken_container_name="kraken_cluster_${KRAKEN_CLUSTER_NAME}"
is_running=$(docker inspect -f '{{ .State.Running }}' ${kraken_container_name})
if [ ${is_running} == "true" ];  then
  error "Cluster build is currently running:\n Run\n  'docker logs --follow ${kraken_container_name}'\n to see logs."
  exit 1
fi

mkdir -p "clusters/${KRAKEN_DOCKER_MACHINE_NAME}"
docker cp kraken_data:/kraken_data/kube_config "clusters/${KRAKEN_DOCKER_MACHINE_NAME}/kube_config"

inf "To control your cluster use:\n  kubectl --kubeconfig=clusters/${KRAKEN_DOCKER_MACHINE_NAME}/kube_config --cluster=${KRAKEN_CLUSTER_NAME} <kubectl commands>"