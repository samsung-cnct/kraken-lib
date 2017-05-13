#!/bin/sh
#  this script will update the generated config to have all necessary values set
#  expects first argument to be config file
#  expects second argument to be cluster name

set -x

cluster_name=`echo $2 | tr -cd '[[:alnum:]]-' | tr '[:upper:]' '[:lower:]'`

#  old style configs (can be removed after k2recon is merged)
sed -i -e "s/cluster:/cluster: ${cluster_name}/" $1

#  new style config
sed -i -e "s/- name:[[:space:]]*$/- name: ${cluster_name}/" $1