#!/bin/bash

function usage
{
  echo "Control kraken vagrantfiles"
  echo ""
  echo "Usage:"
  echo "   ./kraken.sh [cluster] [vagrant commands]"
  echo ""
  echo "examples:"
  echo "  ./kraken.sh local up"
  echo "  ./kraken.sh aws destroy"
  echo ""
}

if [ "$#" -lt 2 ]; then
    usage
fi

cluster_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/$1" 

echo "Running: KRAKEN_CLUSTER=$1 VAGRANT_DOTFILE_PATH='$cluster_folder' vagrant ${@:2}"
KRAKEN_CLUSTER=$1 VAGRANT_DOTFILE_PATH="$cluster_folder" vagrant "${@:2}"
