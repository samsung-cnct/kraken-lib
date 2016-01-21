#!/bin/bash -
#title           :kraken-up.sh
#description     :use docker-machine to bring up a kraken cluster manager instance.
#author          :Samsung SDSRA
#==============================================================================
set -o errexit
set -o nounset
set -o pipefail

# kraken root folder
KRAKEN_ROOT=$(dirname "${BASH_SOURCE}")/..
source "${KRAKEN_ROOT}/bin/utils.sh"

# now build the docker container
kraken_container_name="kraken_cluster_${KRAKEN_CLUSTER_NAME}"
if docker inspect ${kraken_container_name} &> /dev/null; then
  is_running=$(docker inspect -f '{{ .State.Running }}' ${kraken_container_name})
  if [ ${is_running} == "true" ];  then
    error "Cluster build already running:\n Run\n  \
      'docker logs --follow ${kraken_container_name}'\n to see logs."
    exit 1
  fi

  run_command "docker rm -f ${kraken_container_name}"
fi

# run cluster up
run_command "docker build -t samsung_ag/kraken -f '${KRAKEN_ROOT}/bin/build/Dockerfile' '${KRAKEN_ROOT}'"
run_command "docker run -d --name ${kraken_container_name} -v /var/run:/ansible --volumes-from kraken_data samsung_ag/kraken \
  bash -c \"/opt/kraken/terraform-up.sh --clustertype ${KRAKEN_CLUSTER_TYPE} --clustername ${KRAKEN_CLUSTER_NAME}\""

follow ${kraken_container_name}

kraken_error_code=$(docker inspect -f {{.State.ExitCode}} ${kraken_container_name})
if [ ${kraken_error_code} -eq 0 ]; then
  inf "Exiting with ${kraken_error_code}"
else
  error "Exiting with ${kraken_error_code}"
fi

exit ${kraken_error_code}