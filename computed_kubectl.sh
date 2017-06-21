#!/bin/bash -
#title          :computed_kubectl
#description    :Calls a version of kubectl whose version is computed by ansible from the provided config, passing along the remaining arguments
#author         :Samsung SDSRA
#====================================================================
set -o errexit
set -o nounset
set -o pipefail

my_dir=$(dirname "${BASH_SOURCE}")
VERSIONFILE=$(mktemp /tmp/$0.XXXXXX)
rm ${VERSIONFILE}
trap '{ rm -f -- "${VERSIONFILE}"; }' INT TERM HUP EXIT
# Call separate script to hide our args from lib/common.sh
${my_dir}/max_k8s_version.sh ${VERSIONFILE} -c $1
shift
K8S_VERSION=$(cat ${VERSIONFILE} | cut -d . -f 1-2)
rm ${VERSIONFILE}
/opt/cnct/kubernetes/${K8S_VERSION}/bin/kubectl $@
