#!/bin/bash -
#title           :kraken-up.sh
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
