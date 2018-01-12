#!/bin/bash
#  this script will update the generated config to have all necessary values set
#  expects first argument to be config file
#  expects second argument to be cluster name

set -x

cluster_name=`echo $2 | tr -cd '[[:alnum:]]-' | tr '[:upper:]' '[:lower:]'`

# k8s version mappings
declare -A kubeStanza
kubeStanza[v1.9]="*defaultKube19"
kubeStanza[v1.8]="*defaultKube18"
kubeStanza[v1.7]="*defaultKube17"

declare -A etcdStanza
etcdStanza["v1.9"]="*etcd19AndLater"
etcdStanza["v1.8"]="*etcd18AndEarlier"
etcdStanza["v1.7"]="*etcd18AndEarlier"

declare -A etcdEventsStanza
etcdEventsStanza["v1.9"]="*etcdEvents19AndLater"
etcdEventsStanza["v1.8"]="*etcdEvents18AndEarlier"
etcdEventsStanza["v1.7"]="*etcdEvents18AndEarlier"

#  cluster name
sed -i -e "s/- name:[[:space:]]*$/- name: ${cluster_name}/" $1

# move regions and AZs to us-east-2. note that this is the CNCT CI region for
# API rate limit purposes.
sed -i -e "s/us-east-1/us-east-2/g" $1

#  k8s version munging
sed -i -e "s/kubeConfig: *defaultKube/kubeConfig: ${kubeStanza[$3]}/" $1

#  etcd -> k8s version mapping
sed -i -e "s/*etcdDefault/${etcdStanza[$3]}/" $1
sed -i -e "s/*etcdEventsDefault/${etcdEventsStanza[$3]}/" $1