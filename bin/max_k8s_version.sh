#!/bin/bash -
#title           :max_k8s_version.sh
#description     :Writes the maximum k8s version found to a specified file
#author          :Samsung SDSRA
#==============================================================================
set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")

# first argument is the output file, shift to next argument when this is read.
# fail if not found.
OUTFILE=$1
if [ -z ${OUTFILE} ]; then 
  echo "must specify a file to save the max version to"
  exit 1
fi
shift

source "${my_dir}/../lib/kraken_arguments.sh"

# setup a sigint trap
trap control_c SIGINT
LOCAL_KEV="kraken_action=max_k8s_version version_outfile=${OUTFILE}"

function runcmd(){
    echo "$(ansible-playbook ${K2_VERBOSE} \
        -i ansible/inventory/localhost \
        ansible/max_k8s_version.yaml \
        --extra-vars "${KRAKEN_EXTRA_VARS}${LOCAL_KEV}" \
        || echo "max_version failed")"
}

if [[ -n $K2_VERBOSE ]]; then
    runcmd
else
    runcmd > /dev/null
fi


