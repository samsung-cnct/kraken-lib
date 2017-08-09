#!/bin/bash -
#title           :up.sh
#description     :bring up a kraken cluster
#author          :Samsung SDSRA
#==============================================================================
# k2-crash-app is taking over the EXIT in common.sh functions called in the trap
# leaving this commented out in case we missed an edge case
# set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/../lib/common.sh"

# setup a sigint trap
trap control_c SIGINT

# capture logs for crash app
LOG_FILE=$"/tmp/crash-logs"

# exit trap for crash app
trap crash_test_up EXIT

K2_CRASH_APP=$(which k2-crash-application)  
if [ $? -ne 0 ];then  
	DISPLAY_SKIPPED_HOSTS=0 ansible-playbook ${K2_VERBOSE} -i ansible/inventory/localhost ansible/up.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=up" --tags "${KRAKEN_TAGS}"
else
	DISPLAY_SKIPPED_HOSTS=0 ansible-playbook ${K2_VERBOSE} -i ansible/inventory/localhost ansible/up.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=up" --tags "${KRAKEN_TAGS}" | tee $LOG_FILE
fi