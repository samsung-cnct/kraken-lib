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
source "${my_dir}/lib/common.sh"

# capture logs for crash app
log_file=$"/k2-crash-app/logs"

# exit trap for crash app
trap crash_test EXIT

ansible-playbook ${K2_VERBOSE} -i ansible/inventory/localhost ansible/down.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=down" --tags "${KRAKEN_TAGS}" | tee $log_file
