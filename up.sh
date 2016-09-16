#!/bin/bash -
#title           :up.sh
#description     :bring up a kraken cluster
#author          :Samsung SDSRA
#==============================================================================
set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/bin/utils.sh"

ansible-playbook -i ansible/inventory/localhost ansible/up.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=up" --tags "${KRAKEN_TAGS}"