#!/bin/bash -
#title          :computed_kubectl.sh
#description    :Calls a version of kubectl whose version is computed by ansible from the provided config, passing along the remaining arguments
#author         :Samsung SDSRA
#====================================================================
set -o errexit
set -o nounset
set -o pipefail

my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/../lib/common.sh"

VERSIONFILE=$(mktemp /tmp/computed_kubectl.XXXXXX)

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -c|--config)
    KRAKEN_CONFIG="$2"
    shift 2
    ;;
    -v|--verbose)
    VERBOSE=true
    shift 1
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

if [ ${#POSITIONAL[@]} -eq 0 ]; then
    POSITIONAL=("")
fi

set -- "${POSITIONAL[@]}" # restore positional parameters

if [ -z ${KRAKEN_CONFIG+x} ]; then
    error "please enter valid config file"
    exit 1
fi

trap '{ rm -f -- "${VERSIONFILE}"; }' INT TERM HUP EXIT

# Call separate script to hide our args from lib/common.sh
if [[ "${VERBOSE}" == true  ]]; then
    ${my_dir}/max_k8s_version.sh ${VERSIONFILE} --config ${KRAKEN_CONFIG} --verbose "-vvv"
else
    ${my_dir}/max_k8s_version.sh ${VERSIONFILE} --config ${KRAKEN_CONFIG}
fi

K8S_VERSION=$(cat ${VERSIONFILE} | cut -d . -f 1-2)
rm ${VERSIONFILE}
/opt/cnct/kubernetes/${K8S_VERSION}/bin/kubectl $@
