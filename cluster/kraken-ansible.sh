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

source "${KRAKEN_ROOT}/cluster/utils.sh"

while [[ $# > 1 ]]
do
key="$1"

case $key in
    --dmname)
    KRAKEN_DOCKER_MACHINE_NAME="$2"
    shift
    ;;
    *)
      # unknown option
    ;;
esac
shift # past argument or value
done

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

is_running=$(docker inspect -f '{{ .State.Running }}' kraken_cluster)
if [ ${is_running} == "true" ];  then
  error "Cluster build is currently running:\n Run\n  'docker logs --follow kraken_cluster'\n to see logs."
  exit 1
fi

mkdir -p "clusters/${KRAKEN_DOCKER_MACHINE_NAME}"
docker cp kraken_data:/kraken_data/ansible.inventory "clusters/${KRAKEN_DOCKER_MACHINE_NAME}/ansible.inventory"
docker cp kraken_cluster:/root/.ssh/id_rsa "clusters/${KRAKEN_DOCKER_MACHINE_NAME}/id_rsa"
docker cp kraken_cluster:/root/.ssh/id_rsa.pub "clusters/${KRAKEN_DOCKER_MACHINE_NAME}/id_rsa.pub"

inf "Parameters for ansible:\n   --inventory-file clusters/${KRAKEN_DOCKER_MACHINE_NAME}/ansible.inventory\n   --private-key clusters/${KRAKEN_DOCKER_MACHINE_NAME}/id_rsa"