#!/bin/bash
set -x

KUBE_DENSITY_KUBECONFIG=${KUBE_DENSITY_KUBECONFIG:-"$HOME/.kube/config"}
KUBE_ROOT=${KUBE_ROOT:-"$GOPATH/src/k8s.io/kubernetes"}
KUBE_DENSITY_NUM_NODES=${KUBE_DENSITY_NUM_NODES:-"10"} # TODO: needed? autodetect?
KUBE_DENSITY_OUTPUT_DIR=${KUBE_DENSITY_OUTPUT_DIR:-"$(pwd)/output/density"}
KUBE_DENSITY_PROM_PUSH_GATEWAY=""
KUBE_DENSITY_DELETE_NAMESPACE=${KUBE_DENSITY_DELETE_NAMEPACE:-true}
# TODO: external build-or-download script instead
KUBE_DENSITY_REBUILD_TESTS=${KUBE_DENSITY_REBUILD_TESTS:-false}
KUBE_SSH_KEY=${KUBE_SSH_KEY:-"${AWS_SSH_KEY}"}

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

if ${KUBE_DENSITY_REBUILD_TESTS}; then
  echo
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

  export AWS_SSH_KEY="${KUBE_SSH_KEY}"

  e2e_test_args=()
  # standard args
  e2e_test_args+=("--repo-root=${KUBE_ROOT}")
  e2e_test_args+=("--kubeconfig=${KUBE_DENSITY_KUBECONFIG}")
  e2e_test_args+=("--report-dir=${KUBE_DENSITY_OUTPUT_DIR}")
  e2e_test_args+=("--e2e-output-dir=${KUBE_DENSITY_OUTPUT_DIR}")
  e2e_test_args+=("--prefix=e2e")

  # TODO: (for which branches) are these necessary?
  e2e_test_args+=("--num-nodes=${KUBE_DENSITY_NUM_NODES}")

  # Provider specific args are currently required for SSH access. Note that
  # https://github.com/kubernetes/kubernetes/issues/20919 suggests that we
  # would like to fix kubernetes so that --provider is no longer necessary.
  e2e_test_args+=("--provider=aws")
  e2e_test_args+=("--gce-zone=us-west-2")
  e2e_test_args+=("--cluster-tag=kraken-node")

  if [[ ${KUBE_DENSITY_BRANCH} == "conformance-test-v1" ]]; then
    echo "additional e2e test args for ${KUBE_DENSITY_BRANCH} branch"
  elif [[ ${KUBE_DENSITY_BRANCH} == "release-1.0" ]]; then
    echo "additional e2e test args for ${KUBE_DENSITY_BRANCH} branch"
  elif [[ ${KUBE_DENSITY_BRANCH} == "release-1.1" ]]; then
    echo "additional e2e test args for ${KUBE_DENSITY_BRANCH} branch"
  elif [[ ${KUBE_DENSITY_BRANCH} == "master" ]]; then
    echo "additional e2e test args for ${KUBE_DENSITY_BRANCH} branch"
    e2e_test_args+=("--delete-namespace=${KUBE_DENSITY_DELETE_NAMESPACE}")
  fi

  if [[ -n "${KUBE_DENSITY_PROM_PUSH_GATEWAY}" ]]; then
    e2e_test_args+=("--prom-push-gateway=${KUBE_DENSITY_PROM_PUSH_GATEWAY}")
  fi

  # ginkgo args
  e2e_test_args+=("--ginkgo.noColor=true")
  e2e_test_args+=("--ginkgo.v=true")

  # ginkgo args for density
  e2e_test_args+=("--ginkgo.focus=should allow starting ${KUBE_DENSITY_PODS_PER_NODE} pods per node")
  e2e_test_args+=("--ginkgo.skip=(^Density)")

  # Add path for things like running kubectl binary.
  export PATH=$(dirname "${e2e_test}"):"${PATH}"

  "${ginkgo}" "${e2e_test}" -- \
    "${e2e_test_args[@]:+${e2e_test_args[@]}}" \
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
