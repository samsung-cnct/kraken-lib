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

# shut down cluster
kraken_container_name="kraken_cluster_${KRAKEN_CLUSTER_NAME}"
if docker inspect ${kraken_container_name} &> /dev/null; then
  run_command "docker rm -f ${kraken_container_name}"
fi

if ! docker inspect kraken_data &> /dev/null; then
  warn "No terraform state available. Cluster is either not running, \
    or kraken_data container has been removed."
  exit 0;
fi

run_command "docker run -d --name ${kraken_container_name} --volumes-from kraken_data \
  samsung_ag/kraken bash -c \"/opt/kraken/terraform-down.sh --clustertype ${KRAKEN_CLUSTER_TYPE} \
  --clustername ${KRAKEN_CLUSTER_NAME}\""

follow ${kraken_container_name}

kraken_error_code=$(docker inspect -f {{.State.ExitCode}} ${kraken_container_name})
if [ ${kraken_error_code} -eq 0 ]; then
  inf "Exiting with ${kraken_error_code}"
else
  error "Exiting with ${kraken_error_code}"
fi

exit ${kraken_error_code}