#!/bin/bash -
#title           :down.sh
#description     :bring down a kraken cluster
#author          :Samsung SDSRA
#==============================================================================
set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/bin/utils.sh"

ansible-playbook ${VERBOSE} -i ansible/inventory/localhost ansible/down.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=down" --tags "${KRAKEN_TAGS}"
