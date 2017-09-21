#!/bin/bash -
#title          :computed_kubectl.sh
#description    :Calls a version of kubectl whose version is computed by ansible from the provided config, passing along the remaining arguments
#author         :Samsung SDSRA
#====================================================================
set -o errexit
set -o nounset
set -o pipefail

my_dir=$(dirname "${BASH_SOURCE}")

VERSIONFILE=$(mktemp /tmp/computed_kubectl.XXXXXX)
rm ${VERSIONFILE}

trap '{ rm -f -- "${VERSIONFILE}"; }' INT TERM HUP EXIT
# Call separate script to hide our args from lib/common.sh
if [[ -z ${2+x} ]]; then
    ${my_dir}/max_k8s_version.sh ${VERSIONFILE} --config $1
else
    ${my_dir}/max_k8s_version.sh ${VERSIONFILE} --config $1 --verbose $2
fi
shift

K8S_VERSION=$(cat ${VERSIONFILE} | cut -d . -f 1-2)
rm ${VERSIONFILE}
/opt/cnct/kubernetes/${K8S_VERSION}/bin/kubectl $@
