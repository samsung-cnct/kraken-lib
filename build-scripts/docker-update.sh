#!/bin/sh
#  this script will update the checked in dockerfile to use a passed in parameter
#  for the tag on the source image
#  expects first argument to be source tag
#  expects second argument to be Dockerfile to update

set -x

source_tag=$1
dockerfile=$2

if [ -n ${source_tag} && -n ${dockerfile} ] ; then
  sed -i -e "s/latest/${1}/" ${2}
else 
  echo "missing parameters, make no changes"
fi