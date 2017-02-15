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

# setup a sigint trap
trap control_c SIGINT

DISPLAY_SKIPPED_HOSTS=0 ansible-playbook ${VERBOSE} -i ansible/inventory/localhost ansible/up.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=up" --tags "${KRAKEN_TAGS}" || show_post_cluster_error

show_post_cluster
