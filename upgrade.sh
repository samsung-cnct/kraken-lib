#!/bin/bash -
#title           :upgrade.sh
#description     :upgrade kubernetes version after running up.sh with new version declared
#author          :Samsung SDSRA
#==============================================================================
set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/lib/common.sh"

# setup a sigint trap
trap control_c SIGINT

DISPLAY_SKIPPED_HOSTS=0 ansible-playbook ${K2_VERBOSE} -i ansible/inventory/localhost ansible/upgrade.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=upgrade" --tags "${KRAKEN_TAGS}" || show_upgrade_error

show_upgrade
