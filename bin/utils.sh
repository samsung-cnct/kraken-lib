#!/bin/bash -
#title           :utils.sh
#description     :utils
#author          :Samsung SDSRA
#==============================================================================

my_dir=$(dirname "${BASH_SOURCE}")

# set KRAKEN_ROOT to absolute path for use in other scripts
readonly KRAKEN_ROOT=$(cd "${my_dir}/.."; pwd)
KRAKEN_VERBOSE=${KRAKEN_VERBOSE:-false}

function warn {
  echo -e "\033[1;33mWARNING: $1\033[0m"
}

function error {
  echo -e "\033[0;31mERROR: $1\033[0m"
}

function inf {
  echo -e "\033[0;32m$1\033[0m"
}


function run_command {
  inf "Running:\n $1"
  eval $1
}


while [[ $# > 1 ]]
do
key="$1"

case $key in
  --config)
  KRAKEN_CONFIG="$2"
  shift
  ;;
  --output)
  KRAKEN_BASE="$2"
  shift
  ;;
  --tags)
  KRAKEN_TAGS="$2"
  shift
  ;;
  *)
    # unknown option
  ;;
esac
shift # past argument or value
done

if [ -z ${KRAKEN_CONFIG+x} ]; then
  warn "--config not specified. Using ~/.kraken/config.yml as location"
  KRAKEN_CONFIG="~/.kraken/config.yml"
fi

if [ -z ${KRAKEN_BASE+x} ]; then
  warn "--output not specified. Using ~/.kraken as location"
  KRAKEN_BASE="~/.kraken"
fi

if [ -z ${KRAKEN_TAGS+x} ]; then
  KRAKEN_TAGS="all" 
fi

KRAKEN_EXTRA_VARS="config_path=${KRAKEN_CONFIG} config_base=${KRAKEN_BASE} "