#!/bin/bash -
#title           :utils.sh
#description     :utils
#author          :Samsung SDSRA
#==============================================================================

function warn {
  echo -e "\033[1;33mWARNING: $1\033[0m"
}

function error {
  echo -e "\033[0;31mERROR: $1\033[0m"
}

function inf {
  echo -e "\033[0;32m$1\033[0m"
}

while [[ $# > 1 ]]
do
key="$1"

case $key in
    --clustertype)
    KRAKEN_CLUSTER_TYPE="$2"
    shift
    ;;
    --dmopts)
    KRAKEN_DOCKER_MACHINE_OPTIONS="$2"
    shift
    ;;
    --dmname)
    KRAKEN_DOCKER_MACHINE_NAME="$2"
    shift
    ;;
    *)
      # unknown option
    ;;
esac
shift # past argument or value
done