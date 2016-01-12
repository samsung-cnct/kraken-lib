#!/bin/bash

AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-"us-west-2"}
KUBE_ROOT=${KUBE_ROOT:-"${GOPATH}/src/k8s.io/kubernetes"}
KUBE_BUILD_ID=${KUBE_BUILD_ID:-"sha"}
KUBE_BUILD_CLEAN=${KUBE_BUILD_CLEAN:-"true"}

# enter kubernetes dir
pushd "${KUBE_ROOT}" > /dev/null

# use sha of HEAD for build id by default
if [[ "${KUBE_BUILD_ID}" == "sha" ]]; then
  KUBE_BUILD_ID=$(git log -n1 --format='%h')
fi

if [[ "${KUBE_BUILD_CLEAN}" == "true" ]]; then
  # contents of build/make-clean.sh without the clean_images call;
  # we'll assume something else is responsible for reaping on this docker host
  source "${KUBE_ROOT}/build/common.sh"
  kube::build::verify_prereqs
  kube::build::clean_output
fi

# we only care about linux/amd64 as a platform
build/run.sh hack/build-go.sh

# push binaries up to s3
for kube_binary in kubectl hyperkube; do
  s3_path="sundry-automata/hyperkube/${KUBE_BUILD_ID}/${kube_binary}"
  aws s3 cp \
    --acl public-read \
    "${KUBE_ROOT}/_output/dockerized/bin/linux/amd64/${kube_binary}" \
    "s3://${s3_path}"
  echo "pushed: https://s3-${AWS_DEFAULT_REGION}.amazonaws.com/${s3_path}"
done

# go back to wherever we were before kubernetes dir
popd > /dev/null
