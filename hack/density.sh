#!/bin/bash
set -x

KUBE_DENSITY_KUBECONFIG=${KUBE_DENSITY_KUBECONFIG:-"$HOME/.kube/config"}
KUBE_ROOT=${KUBE_ROOT:-"$GOPATH/src/k8s.io/kubernetes"}
KUBE_DENSITY_NUM_NODES=${KUBE_DENSITY_NUM_NODES:-"10"} # TODO: needed? autodetect?
KUBE_DENSITY_OUTPUT_DIR=${KUBE_DENSITY_OUTPUT_DIR:-"$(pwd)/output/density"}

REBUILD_TESTS=${REBUILD_TESTS:-true}

if [[ $# < 2 ]]; then
  echo "Usage: $0 density_branch pods_per_node"
  echo "Runs kubernetes density tests from the given branch"
  echo "  eg: $0 release-1.1 3"
  exit 1
fi

KUBE_DENSITY_BRANCH=$1
KUBE_DENSITY_PODS_PER_NODE=$2


pushd "${KUBE_ROOT}"
# XXX: this is destructive, bad idea to use with repo under active development
git checkout -f ${KUBE_DENSITY_BRANCH}
KUBE_CONFORMANCE_SHA=$(git rev-parse HEAD)

echo
echo "Density test run start date: $(date -u)"
echo "Density test branch: ${KUBE_DENSITY_BRANCH}"
echo "Density test SHA: ${KUBE_DENSITY_SHA}"
echo "Density test cluster size: ${KUBE_DENSITY_NUM_NODES}"
echo "Density test kubeconfig: ${KUBE_DENSITY_KUBECONFIG}"

if $REBUILD_TESTS; then
  echo
  # TODO: build just the density tests for our platform instead of a whole release?
  echo "Building density tests..."
  build/make-clean.sh
  build/run.sh hack/build-cross.sh
fi

function hack_ginkgo_e2e() {
  # use glue from k8s for now
  source "${KUBE_ROOT}/cluster/common.sh"
  source "${KUBE_ROOT}/hack/lib/init.sh"
  kube::golang::setup_env
  ginkgo=$(kube::util::find-binary "ginkgo")
  e2e_test=$(kube::util::find-binary "e2e.test")

  mkdir -p ${KUBE_DENSITY_OUTPUT_DIR}

  e2e_test_args=()
  # standard args
  e2e_test_args+=("--repo-root=${KUBE_ROOT}")
  e2e_test_args+=("--kubeconfig=${KUBE_DENSITY_KUBECONFIG}")
  e2e_test_args+=("--e2e-output-dir=${KUBE_DENSITY_OUTPUT_DIR}")
  e2e_test_args+=("--prefix=e2e")

  # TODO: (for which branches) are these necessary?
  e2e_test_args+=("--num-nodes=${KUBE_DENSITY_NUM_NODES}")
  # TODO: conditionally add --prom-push-gateway
  # TODO: conditionally add --delete-namespace=false

  # ginkgo args
  e2e_test_args+=("--ginkgo.noColor=true")
  e2e_test_args+=("--ginkgo.v=true")

  # ginkgo args for density
  e2e_test_args+=("--ginkgo.focus='should allow starting ${KUBE_DENSITY_PODS_PER_NODE} pods per node'")
  e2e_test_args+=("--ginkgo.skip='(^Density)'")

  # Add path for things like running kubectl binary.
  export PATH=$(dirname "${e2e_test}"):"${PATH}"

  "${ginkgo}" "${e2e_test}" -- \
    ${e2e_test_args[@]:+${e2e_test_args[@]}} \
    "${@:-}"
}

echo
echo "Running density tests..."
hack_ginkgo_e2e
density_result=$?

# restore the previous HEAD
git checkout -
popd

echo
echo "Density test run stop date: $(date -u)"
exit $density_result
