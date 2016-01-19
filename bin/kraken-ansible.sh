#!/bin/bash -
#title           :kraken-ansible.sh
#description     :get the remote ansible inventory and ssh keys
#author          :Samsung SDSRA
#==============================================================================

set -o errexit
set -o nounset
set -o pipefail

# kraken root folder
KRAKEN_ROOT=$(dirname "${BASH_SOURCE}")/..

source "${KRAKEN_ROOT}/bin/utils.sh"

if [ "${KRAKEN_NATIVE_DOCKER}" = false ]; then 
  if [ -z ${KRAKEN_DOCKER_MACHINE_NAME+x} ]; then
    error "--dmname not specified. Docker Machine name is required."
    exit 1
  fi
fi

if [ -z ${KRAKEN_CLUSTER_NAME+x} ]; then
  error "--clustername not specified. Cluster name is required."
  exit 1
fi

if [ "${KRAKEN_NATIVE_DOCKER}" = false ]; then 
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

mkdir -p "clusters/${KRAKEN_DOCKER_MACHINE_NAME}/${KRAKEN_CLUSTER_NAME}"
docker cp kraken_data:/kraken_data/${KRAKEN_CLUSTER_NAME}/ansible.inventory "clusters/${KRAKEN_DOCKER_MACHINE_NAME}/${KRAKEN_CLUSTER_NAME}/ansible.inventory"
docker cp ${kraken_container_name}:/root/.ssh/id_rsa "clusters/${KRAKEN_DOCKER_MACHINE_NAME}/id_rsa"
docker cp ${kraken_container_name}:/root/.ssh/id_rsa.pub "clusters/${KRAKEN_DOCKER_MACHINE_NAME}/id_rsa.pub"

inf "Parameters for ansible:\n   --inventory-file clusters/${KRAKEN_DOCKER_MACHINE_NAME}/${KRAKEN_CLUSTER_NAME}/ansible.inventory\n   --private-key clusters/${KRAKEN_DOCKER_MACHINE_NAME}/id_rsa"