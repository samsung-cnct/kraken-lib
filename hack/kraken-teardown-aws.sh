#!/bin/bash
#
#
# This script generates a series of commands for removal of clusters. 
#
#   Goal: provide a means of tearing down Kraken clusters *without* access to
#     the configuration files that generated them. 
# 
#   Means:
#     Requires a cluster name specified as command line argument.
#     Queries AWS API, based on the `KubernetesCluster` tag whereever possible.
#     Generates DELETE (equivalent) API calls in the correct order, to remove
#       the cluster from AWS.
#     Should tolerate partially removed clusters in some cases, insofar as 
#       querying their associated elements will simply produce empty sets.
#
#   Limitations:
#     The identification of IAM roles to delete is predicated upon their 
#       reference within the ASG Launch Configurations. If not found, they will 
#       not be removed.
#     The actual DELETE effects are masked by `echo` statements below.
#       The intent is to provide an easy way to validate the operations before execution.
#       To actually execute deletion, simply pipe its output into another bash process.
# 
# See also:
# https://github.com/samsung-cnct/docs/blob/master/cnct/common-tools/Manual%20Deletion%20of%20kraken%20Cluster%20Resources.md
# This script intends to obviate the need for the documentation above. :)

# Exit when a command fails, and when referenced variables are unset.
set -o errexit
set -o pipefail
set -o nounset


AWS_REGION=${AWS_REGION:-us-east-2}
AWS_COMMON_ARGS="--region=${AWS_REGION} --output=text"
VERBOSE=${VERBOSE:-0}

test "${DEBUG:-0}" -gt 0 && set -x

usage(){
cat <<EOF
  Usage: $0 -c CLUSTER_NAME

  Query AWS API to identify resources related to Kubernetes clusters, identified
  primarily by the "KubernetesCluster" tag having the value CLUSTER_NAME, to be 

  This script generates a series of AWS CLI commands, which should be directly
  executable to tear down the specified Kubernetes cluster, in the correct 
  order.

  To actually execute the teardown, simply pipe this script's output into 
  another bash instance, like so:

    $0 -c CLUSTER_NAME | bash
    
EOF
}

info() {
  [ "${VERBOSE}" -gt 0 ] && echo "# $@" >&2 || return 0
}

fail(){
  echo "[FAIL] $2" >&2
  return $1
}

delete_asg () {
  info "Deleting ASG: $1"  
  echo aws ${AWS_COMMON_ARGS} autoscaling delete-auto-scaling-group --auto-scaling-group-name "$1"
}

delete_launchconfig () {
  info "Deleting Launch Configuration: $1"
  echo aws ${AWS_COMMON_ARGS} autoscaling delete-launch-configuration --launch-configuration-name "$1"
}

delete_keypair () {
  info "Deleting Key Pair: $1"
  echo aws ${AWS_COMMON_ARGS} ec2 delete-key-pair --key-name "$1"
}

delete_instances () {
  [ $# -gt 0 ] || return 0
  info "Terminating Instances: $@"
  echo aws ${AWS_COMMON_ARGS} ec2 terminate-instances  --instance-ids "$@" 
}

delete_elb (){ 
  info "Deleting LoadBalancer: $1"
  echo aws ${AWS_COMMON_ARGS} elb delete-load-balancer --load-balancer-name "$1"
}

delete_vpc () {
  info "Deleting VPC: $1"
  echo aws ${AWS_COMMON_ARGS} ec2 delete-vpc --vpc-id "$1"
}

delete_eni () {
  info "Deleting Network Interface: $1"
  echo aws ${AWS_COMMON_ARGS} ec2 delete-network-interface  \
    --network-interface-id "$1"
}

delete_iam_profile () {
  info "Deleting IAM Profile: $1"
  echo aws iam delete-instance-profile --instance-profile-name "$1"
}

delete_iam_role () {
  info "Deleting IAM Role: $1"
  echo aws iam delete-role --role-name "$1"
}

delete_route53_zone () {
  info "Deleting Route53 zone: $1"
  echo aws route53 delete-hosted-zone --id "$1"
}

describe_cluster_instances () {
  aws ${AWS_COMMON_ARGS} ec2 describe-instances \
    --filter "Name=tag:KubernetesCluster, Values=$1" \
      "Name=instance-state-name, Values=running,stopped,pending,shutting-down" \
    --query="Reservations[*].Instances[*].{a:InstanceId, b:Tags[?Key=='Name']|[0].Value}"
}

describe_launchconfig () {
  aws ${AWS_COMMON_ARGS} autoscaling describe-launch-configurations \
    --launch-configuration-name "$1" \
    --query "LaunchConfigurations[*].{a:LaunchConfigurationName, b:KeyName, c:IamInstanceProfile}"
}

describe_asg () {
  # Produce fields in specific order: GroupName, ARN
  # Columns are ordered alphabetically to their aliases (a and b, here)
  [ $# -gt 0 ] || return 0
  aws ${AWS_COMMON_ARGS} autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "${@}" \
    --query 'AutoScalingGroups[*].{a:AutoScalingGroupName, b:AutoScalingGroupARN, c:LaunchConfigurationName}' 
}

list_elb_all () {
  aws ${AWS_COMMON_ARGS} elb describe-load-balancers \
    --query="LoadBalancerDescriptions[*].{a:LoadBalancerName}"
}

list_elb_cluster_tags () {
  [ $# -gt 0 ] || return 0

  print_exec=''
  test "${DEBUG:-0}" -eq 1 && print_exec="-t"

  # This is a pagination hack. LOL.
  echo "${@}" | tr -s ' ' '\n' | xargs ${print_exec} -n 20 -J % \
    aws ${AWS_COMMON_ARGS} elb describe-tags \
    --load-balancer-names % \
    --query="TagDescriptions[*].{a:LoadBalancerName, b:Tags[?Key=='KubernetesCluster']|[0].Value}"
}

list_elb_by_cluster_tag (){ 
  list_elb_cluster_tags $(list_elb_all) | awk "{ if(\$2 == \"$1\"){ print \$1 } }"
}

list_asg_by_cluster_tag () {
  aws ${AWS_COMMON_ARGS} autoscaling describe-tags \
    --filters "Name=Key, Values=KubernetesCluster" "Name=Value, Values=$1" \
    --query "Tags[*].{a:Value, b:ResourceId, c:ResourceType}" \
      | awk "{ if(\$3 == \"auto-scaling-group\") { print \$2 } }"
}

list_eni_by_vpc_id () {
  aws ${AWS_COMMON_ARGS} ec2 describe-network-interfaces \
    --filter="Name=vpc-id, Values=$1" \
    --query="NetworkInterfaces[].{a:NetworkInterfaceId, b:SubnetId, c:VpcId, d:Status}"
}

list_vpc_by_cluster_tag () {
  aws ${AWS_COMMON_ARGS} ec2 describe-vpcs \
    --filter "Name=tag:KubernetesCluster, Values=$1" \
    --query="Vpcs[*].{a:VpcId, b:Tags[?Key=='Name']|[0].Value}"
}

list_iam_roles_for_profile () {
  aws ${AWS_COMMON_ARGS} iam get-instance-profile  --instance-profile-name "$1" \
    --query "InstanceProfile.{a:Roles[*]|[0].RoleName, b:InstanceProfileName}"
}

list_route53_zones_by_name () {
  aws ${AWS_COMMON_ARGS} route53 list-hosted-zones \
    --query="HostedZones[*].{b:Id, a:Name}" --max-items=10000  \
      | awk "{ if(\$1 == \"$1\") { print \$2 }}"
}


# Removes various resources from AWS in the proper order.
delete_cluster_artifacts () {
  # Expects first argument to be the cluster name.
  [ -z "$1" ] && fail 1 "Please specify a cluster name."

  local roles_to_delete keys_to_delete

  roles_to_delete=`mktemp /tmp/delete_roles.XXXXX`
  keys_to_delete=`mktemp /tmp/delete_keys.XXXXX`

  # Iterate through autoscaling groups for this cluster.
  while read asgname; do
    while read asgname arn lcn; do
        # Remove the autoscaling group
        delete_asg ${asgname}
        
        while read lcn kpn iamprofile; do
          # Queue keypair for deletion (if exists)
          echo "${kpn}" >> ${keys_to_delete}
          
          # Queue IAM role  for deletion (if exists)
          echo "${iamprofile}" >> ${roles_to_delete}

          # Remove launch configuration
          delete_launchconfig ${lcn}
        done < <([ -n "${lcn}" ] && describe_launchconfig ${lcn})

    done < <(describe_asg ${asgname})
  done < <(list_asg_by_cluster_tag "$1")
  
  while read kpn; do
    delete_keypair ${kpn}
  done < <(sort ${keys_to_delete} | uniq)

  # Remove remaining EC2 instances
  delete_instances `describe_cluster_instances ${1} | awk '{ print $1 }'`

  # Remove associated load balancers
  while read elb; do
    delete_elb ${elb}
  done < <(list_elb_by_cluster_tag "$1")


  # Remove associated VPC
  while read vpcid vpcName; do

    # Remove associated network interfaces
    while read eni sni _ status; do
      delete_eni ${eni}
    done < <(list_eni_by_vpc_id "${vpcid}")
  
    delete_vpc ${vpcid}
  done < <(list_vpc_by_cluster_tag "$1")

  # Remove associated IAM roles
  while read iamprofile; do
    while read role profile; do
      delete_iam_profile ${profile}
      delete_iam_role ${role}
    done < <(list_iam_roles_for_profile ${iamprofile})
  done < <(sort ${roles_to_delete} | uniq)

  # Remove zones associated with the cluster
  while read zone; do
    delete_route53_zone ${zone}
  done < <(list_route53_zones_by_name "$1.internal.")

  rm  ${roles_to_delete} ${keys_to_delete}
}




main () {
  local CLUSTER_NAME=""

  while builtin getopts ":c:h" OPT "${@}"; do
    case "$OPT" in
      c) CLUSTER_NAME="${OPTARG}" ;;
      h) usage; exit 0 ;;
      \?) fail 1 "-$OPTARG is an invalid option";;
      :) fail 2 "-$OPTARG is missing the required parameter";;
    esac
  done

  if [ -n "${CLUSTER_NAME}" ]; then
    delete_cluster_artifacts "${CLUSTER_NAME}"
  else
    usage
    exit 1
  fi 
}


main "${@:-NONE}"
