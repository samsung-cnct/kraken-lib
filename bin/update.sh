#!/bin/bash -
#title           :update.sh
#description     :update kubernetes version on AWS after changing config file to new version
#author          :Samsung SDSRA
#==============================================================================
# k2-crash-app is taking over the EXIT in common.sh functions called in the trap
# leaving this commented out in case we missed an edge case
# set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/../lib/kraken_arguments.sh"

# if [ -z $UPDATE_NODEPOOLS ]; then
#   error "--nodepools flag must be used"
#   exit 1
# fi
# setup a sigint trap
trap control_c SIGINT

# capture logs for crash app
LOG_FILE=$"/tmp/crash-logs"

# exit trap for crash app
trap crash_test_update EXIT

K2_CRASH_APP=$(which k2-crash-application)  
if [ $? -ne 0 ];then  
	DISPLAY_SKIPPED_HOSTS=0 ansible-playbook ${K2_VERBOSE} -i ansible/inventory/localhost ansible/update.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=update" || show_update_error
else
	DISPLAY_SKIPPED_HOSTS=0 ansible-playbook ${K2_VERBOSE} -i ansible/inventory/localhost ansible/update.yaml --extra-vars "${KRAKEN_EXTRA_VARS}kraken_action=update" | tee $LOG_FILE
fi