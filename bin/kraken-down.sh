#!/bin/bash -
#title           :kraken-down.sh
#description     :use docker-machine to bring down a kraken cluster manager instance.
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

if [ -z ${KRAKEN_CLUSTER_TYPE+x} ]; then
  warn "--clustertype not specified. Assuming 'aws'"
  KRAKEN_CLUSTER_TYPE="aws"
fi

if [ -z ${KRAKEN_CLUSTER_NAME+x} ]; then
  warn "--clustername not specified. Assuming '${KRAKEN_CLUSTER_TYPE}'"
  KRAKEN_CLUSTER_NAME=$KRAKEN_CLUSTER_TYPE
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

# shut down cluster
kraken_container_name="kraken_cluster_${KRAKEN_CLUSTER_NAME}"
if docker inspect ${kraken_container_name} &> /dev/null; then
  inf "Removing old kraken_cluster container:\n   'docker rm -f ${kraken_container_name}'"
  docker rm -f ${kraken_container_name} &> /dev/null
fi

if ! docker inspect kraken_data &> /dev/null; then
  warn "No terraform state available. Cluster is either not running, or kraken_data container has been removed."
  exit 0;
fi

inf "Tearing down kraken cluster:\n  'docker run -d --name ${kraken_container_name} --volumes-from kraken_data samsung_ag/kraken \
  /opt/kraken/terraform-down.sh --clustertype ${KRAKEN_CLUSTER_TYPE} --clustername ${KRAKEN_CLUSTER_NAME}'"

docker run -d --name ${kraken_container_name} --volumes-from kraken_data \
  samsung_ag/kraken bash -c "/opt/kraken/terraform-down.sh --clustertype ${KRAKEN_CLUSTER_TYPE} --clustername ${KRAKEN_CLUSTER_NAME}"

inf "Following docker logs now. Ctrl-C to cancel."
docker logs --follow ${kraken_container_name}

kraken_error_code=$(docker inspect -f {{.State.ExitCode}} ${kraken_container_name})
if [ ${kraken_error_code} -eq 0 ]; then
  inf "Exiting with ${kraken_error_code}"
else
  error "Exiting with ${kraken_error_code}"
fi

exit ${kraken_error_code}