#!/bin/bash -
#title           :kraken-ssh.sh
#description     :run ansible with remotely managed kraken cluster
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

docker run -it --volumes-from kraken_data -v /var/run:/ansible samsung_ag/kraken bash -c 'cp /kraken_data/ansible.inventory /etc/ansible/hosts && cd /opt/kraken/ansible && bash'