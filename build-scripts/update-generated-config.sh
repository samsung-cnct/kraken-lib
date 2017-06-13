#!/bin/sh
#  this script will update the generated config to have all necessary values set
#  expects first argument to be config file
#  expects second argument to be cluster name

set -x

cluster_name=`echo $2 | tr -cd '[[:alnum:]]-' | tr '[:upper:]' '[:lower:]'`

#  new style config
sed -i -e "s/- name:[[:space:]]*$/- name: ${cluster_name}/" $1

# move regions and AZs to us-east-2. note that this is the CNCT CI region for
# API rate limit purposes.
sed -i -e "s/us-east-1/us-east-2/g" $1
