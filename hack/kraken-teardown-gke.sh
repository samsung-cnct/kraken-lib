#!/bin/sh

# This script generates a series of commands for removal of clusters.
#
#   Goal: provide a means of tearing down GKE Kraken clusters *without* access
#     to the configuration files that generated them.
# 
#   Means: 
#     Requires a deployment name, GCP zone and project as CLI arguments.
#     Queries GCP API, interrogating the deployment for associated clusters.
#     Generates DELETE (equivalent) API calls in the correct order, to remove
#       the cluster fform GKE/GCP.
#     Should tolerate partially removed clusters, in which the deployment exists
#       but the cluster has already been deleted.
#
#   Limitations:
#     The script currently masks DELETE operations with `echo`; this is intentional.
#       The intent is to provide an easy way to validate the operations before execution.
#       To actually execute deletion, simply pipe its output into another bash process.
#
#


# Exit when a command fails, and when referenced variables are unset.
set -o errexit
set -o pipefail
set -o nounset

test "${DEBUG:-0}" -gt 0 && set -x

usage(){
cat <<EOF
  Usage: $0 -c DEPLOYMENT_NAME -z GCP_ZONE -p GCP_PROJECT

  - GCP_ZONE defaults to "us-east1-b"
  - GCP_PROJECT can be specified by name, rather than ID number

  Query Google Cloud API to identify resources related to Kubernetes clusters, 
  identified primarily by the associated deployment.

  This script generates a series of gcloud CLI commands, which should be directly
  executable to tear down the specified Kubernetes cluster, in the correct 
  order.

  To actually execute the teardown, simply pipe this script's output into 
  another bash instance, like so:

    $0 -c DEPLOYMENTNAME -z GCP_ZONE -p GCP_PROJECT | bash

EOF
}

info() {
  [ "${VERBOSE}" -gt 0 ] && echo "# $@" >&2 || return 0
}

fail(){
  echo "[FAIL] $2" >&2
  return $1
}

delete_deployment () {
    echo gcloud deployemnt-manager deployments delete "$1" \
        --project "${2}" --zone "${3}"
}

delete_cluster () {
    echo gcloud container clusters delete "$1" \
        --project "${2}" --zone "${3}"
}

list_deployments_by_name () {
    filter_arg=""
    [ $# -gt 0 ] && filter_arg="--filter=name=${1}"
    gcloud deployment-manager deployments list \
        --project "${2}" ${filter_arg} \
        --format="value(name,operation.status,manifest)"
}

list_clusters_by_deployment () {
    gcloud deployment-manager deployments describe "$1" \
        --project "${2}" \
        --format="value(resources[].name, resources[].type)" \
        | awk '{ if($2 == "container.v1.cluster") { print $1 } }'
}

describe_deployed_cluster () {
    # This is allowed to fail, because deployments may specify clusters have
    # have ALREADY been deleted
    gcloud container clusters describe "$1" \
        --zone="${3}" --project="${2}" \
        --format="value(name,status,zone)" 2>/dev/null || true
}


delete_cluster_artifacts () {

    local clusters_to_kill
    local zone="$2"
    local project="$3"

    clusters_to_kill=`mktemp /tmp/gkeclusters_delete.XXXXX`

    while read dname status manifest; do

        while read cname; do
            describe_deployed_cluster "${cname}" "${project}" "$zone" \
                | grep RUNNING >> ${clusters_to_kill} \
                || true
        done < <(list_clusters_by_deployment "${dname}" "${project}" "$zone")

        delete_deployment "${dname}" "$project" "$zone"
        
    done < <(list_deployments_by_name "$1" "$project")

    while read cname status zone; do
        delete_cluster "${cname}" "${project}" "${zone}"
    done < <(sort ${clusters_to_kill} | uniq)


    rm ${clusters_to_kill}
}


main () {
    local DEPLOYMENT_NAME=""
    local GCP_PROJECT=""
    local GCP_ZONE="us-east1-b"

    while builtin getopts ":c:z:p:h" OPT "${@}"; do
        case "$OPT" in
            c) DEPLOYMENT_NAME="${OPTARG}";;
            z) GCP_ZONE="${OPTARG}";;
            p) GCP_PROJECT="${OPTARG}";;
            h) usage ; exit 0 ;;
            \?) fail 1 "-$OPTARG is an invalid option";;
            :) fail 2 "-$OPTARG is missing the required parameter";;
        esac
    done

    if [ -n "${DEPLOYMENT_NAME}" -a -n "${GCP_PROJECT}" ]; then
        delete_cluster_artifacts "${DEPLOYMENT_NAME}" "${GCP_ZONE}" "${GCP_PROJECT}"
    else
        usage
        exit 1
    fi

}



main "${@:-NONE}"
