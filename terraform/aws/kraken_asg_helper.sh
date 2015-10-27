#!/bin/bash -
#title           :kraken_asg_helper.sh
#description     :This script will wait for the count of kubernetes cluster nodes to reach some number,and then query a given AWS Autoscaling Group
#                 And append the public ips of all nodes in the group into a file
#author          :Samsung SDSRA
#==============================================================================

while [[ $# > 1 ]]
do
key="$1"

case $key in
    -c|--cluster)
    CLUSTER="$2"
    shift # past argument
    ;;
    -l|--limit)
    NODE_LIMIT="$2"
    shift # past argument
    ;;
    -n|--name)
    ASG_NAME="$2"
    shift # past argument
    ;;
    -o|--output)
    OUTPUT_FILE="$2"
    shift # past argument
    ;;
    -s|--singlewait)
    SLEEP_TIME="$2"
    shift # past argument
    ;;
    -t|--totalwaits)
    TOTAL_WAITS="$2"
    shift # past argument
    ;;
    -r|--retries)
    RETRIES="$2"
    shift # past argument
    ;;
    -e|--etcd)
    ETCD_IP="$2"
    shift # past argument
    ;;
    -p|--port)
    ETCD_PORT="$2"
    shift # past argument
    ;;
    -o|--offset)
    NUMBERING_OFFSET="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

echo "Cluster type is ${CLUSTER}"
echo "Waiting for ${NODE_LIMIT} kubectl nodes"
echo "Autoscaling group name is ${ASG_NAME}"
echo "Will append public IPs to ${OUTPUT_FILE}"
echo "Waiting for ${SLEEP_TIME} between each check"
echo "$((SLEEP_TIME*TOTAL_WAITS)) seconds total single wait on kubectl health"
echo "$((SLEEP_TIME*TOTAL_WAITS*RETRIES)) seconds total wait time on kubectl health"
echo "Host numbering offset is ${NUMBERING_OFFSET}"
echo "ETCD ip address is ${ETCD_IP}"
echo "ETCD ip port number is ${ETCD_PORT}"

control_c()
{
  echo "Interrupted. Will try to generate local ansible inventory anyway."
  generate_configs
  exit 1
}

generate_configs()
{
  ec2_ips=$(aws --output text \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
    ec2 describe-instances --instance-ids \
    $(aws --output text --query "AutoScalingGroups[0].Instances[*].InstanceId" autoscaling describe-auto-scaling-groups --auto-scaling-group-names "${ASG_NAME}"))

  current_node=$((NUMBERING_OFFSET+1))
  output="\n[nodes]\n"
  for ec2_ip in $ec2_ips; do
    output="${output}$(printf 'node-%03d' ${current_node}) ansible_ssh_host=${ec2_ip}\n"
    current_node=$((current_node+1))
  done

  script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

  echo Writing ${OUTPUT_FILE}
  echo -e $output >> ${OUTPUT_FILE}

  # for the scenario of docker container buit from windows host:
  chmod -x ${OUTPUT_FILE}

  # run ansible
  echo "Running ansible-playbook -i ${OUTPUT_FILE} ${script_dir}/../../ansible/localhost_post_provision.yaml ..."
  ansible-playbook -i ${OUTPUT_FILE} ${script_dir}/../../ansible/localhost_post_provision.yaml
}

wait_for_asg()
{
  local asg_instance_limit=($(aws --output text --query "AutoScalingGroups[0].DesiredCapacity" \
          autoscaling describe-auto-scaling-groups --auto-scaling-group-name "${ASG_NAME}"))
  local asg_instances=($(aws --output text --query "AutoScalingGroups[0].Instances[?LifecycleState=='InService'].InstanceId" \
          autoscaling describe-auto-scaling-groups --auto-scaling-group-name "${ASG_NAME}"))
  local autoscaling_wait=60

  while [ ${#asg_instances[@]} -lt ${asg_instance_limit} ]
  do
    echo "${#asg_instances[@]} instances out of ${asg_instance_limit}"
    sleep ${autoscaling_wait}
    asg_instances=($(aws --output text --query "AutoScalingGroups[0].Instances[*].InstanceId" \
      autoscaling describe-auto-scaling-groups --auto-scaling-group-name "${ASG_NAME}"))
  done

  echo "Reached ${asg_instance_limit} nodes in ${ASG_NAME}."
}

nudge_asg_nodes()
{
  local proceed_terminate=true
  local ip_index=0
  local max_slice=200

  local fleet_array=($(fleetctl --endpoint=http://${ETCD_IP}:${ETCD_PORT} list-machines | grep node | awk '{ print $2 }'))
  if [ ${#fleet_array[@]} -eq 0 ]; then
    echo "Unexpected - No fleet nodes returned. Fleetctl error?"
    proceed_terminate=false
  fi

  local kube_array=($(kubectl --cluster=${CLUSTER} get nodes | tail -n +2 | awk '{ print $1 }'))
  if [ ${#fleet_array[@]} -eq 0 ]; then
    echo "Unexpected - No kubectl nodes returned. Fleetctl error?"
    proceed_terminate=false
  fi

  local delta=($(echo ${fleet_array[@]} ${kube_array[@]} | tr ' ' '\n' | sort | uniq -u))
  if [ ${#delta[@]} -eq 0 ]; then
      echo "Unexpected - kubectl not reporting all nodes and yet no nodes are in delta between fleet and kubectl."
      proceed_terminate=false
  fi

  # describe/terminate instances in chunks of max 200 (aws limitation of 200 filter values)
  while [ ${ip_index} -lt ${#delta[@]} ] && [ "${proceed_terminate}" = true ]
  do
    delta_slice=(${delta[@]:$index:$max_slice})
    private_ips=$( IFS=$','; echo "${delta_slice[*]}" )
    echo -e "Fleet nodes not yet present in kubernetes cluster:\n${private_ips}"

    ec2_instances=($(aws --output text \
        --query "Reservations[*].Instances[*].[InstanceId]" \
        ec2 describe-instances --filters "Name=private-ip-address,Values=${private_ips}" --instance-ids \
        $(aws --output text --query "AutoScalingGroups[0].Instances[*].InstanceId" \
            autoscaling describe-auto-scaling-groups --auto-scaling-group-names "${ASG_NAME}")))

    echo -e "Instances to be terminated:\n${ec2_instances[*]}"
    aws --output text ec2 terminate-instances --instance-ids ${ec2_instances[*]}

    ip_index=$(($ip_index + $max_slice))
  done
}

# setup a sigint trap
trap control_c SIGINT

# first lets wait for the autoscaling group to fill out.
echo "Starting wait on ${ASG_NAME} autoscaling group to become healthy."
wait_for_asg

# get a count of nodes from kubectl
echo "Starting wait on ${NODE_LIMIT} provisioned kubernetes nodes."
kube_node_count=$(kubectl --cluster=${CLUSTER} get nodes | tail -n +2 | wc -l | xargs)
max_loops=$((TOTAL_WAITS-1))
max_retries=$((RETRIES-1))

# overall success
success=1

while [ ${kube_node_count} -lt ${NODE_LIMIT} ]
do
  if [ ${max_loops} -ge 0 ]; then
    echo "${kube_node_count} kubernetes nodes out of ${NODE_LIMIT}"
    sleep ${SLEEP_TIME}
    kube_node_count=$(kubectl --cluster=${CLUSTER} get nodes | tail -n +2 | wc -l | xargs)
    max_loops=$((max_loops-1))
  elif [ ${max_retries} -ge 0 ]; then
    echo "Waited for $((SLEEP_TIME*TOTAL_WAITS)). Will attempt to detect and restart failed autoscaling group nodes."
    nudge_asg_nodes

    # give the nudge a chance to work
    sleep 10

    echo "Starting wait on ${ASG_NAME} autoscaling group to become healthy again."
    wait_for_asg

    # reset max loops and decrement retries
    max_loops=$((TOTAL_WAITS-1))
    max_retries=$((max_retries-1))
  else
    success=0
    echo "Maximum wait of $((SLEEP_TIME*TOTAL_WAITS)) seconds reached."
    break
  fi
done

# generate all post-wait configurations
generate_configs

if (( success )); then
  echo "Success!"
else
  echo "Failure!"
fi

exit $((!$success))