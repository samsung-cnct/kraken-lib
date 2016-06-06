#!/bin/bash
set -x

KUBE_CONFORMANCE_KUBECONFIG=${KUBE_CONFORMANCE_KUBECONFIG:-"$HOME/.kube/config"}
KUBE_CONFORMANCE_OUTPUT_DIR=${KUBE_CONFORMANCE_OUTPUT_DIR:-"$(pwd)/output/conformance"}

if [[ $# < 1 ]]; then
  echo "Usage: $0 conformance_branch"
  echo "Switches to given directory assumed to contain kubernetes binaries and runs all non-[Serial] [Conformance] tests (in parallel)"
  echo "  eg: $0 ~/sandbox/kubernetes-1.2.0/"
  exit 1
fi

KUBE_ROOT=$1

pushd "${KUBE_ROOT}"

echo "Conformance test run start date: $(date -u)"
echo "Conformance test dir: ${KUBE_ROOT}"
echo "Conformance test kubeconfig: ${KUBE_CONFORMANCE_KUBECONFIG}"

function run_hack_e2e_go() {
  # XXX: e2e-internal scripts assume KUBERNETES_PROVIDER=gce,
  #      which assumes gcloud is present and configured; instead
  #      set a provider that has fewer dependencies
  export KUBERNETES_PROVIDER=aws

  # XXX: e2e-internal scripts require USER to be set
  export USER=${USER:-$(whoami)}

  # avoid provider-specific e2e setup
  export KUBERNETES_CONFORMANCE_TEST="y"

  # specify which cluster to talk to, and what credentials to use
  export KUBECONFIG=${KUBE_CONFORMANCE_KUBECONFIG}

  common_test_args=()
  common_test_args+=("--ginkgo.v=true")
  common_test_args+=("--ginkgo.noColor=true")

  test_args=()
  test_args+=("--ginkgo.focus=\[Conformance\]")
  test_args+=("--ginkgo.skip=\[Serial\]")
  test_args+=("--e2e-output-dir=${KUBE_CONFORMANCE_OUTPUT_DIR}/parallel")
  test_args+=("--report-dir=${KUBE_CONFORMANCE_OUTPUT_DIR}/parallel")

  # run everything that we can in parallel
  GINKGO_PARALLEL=y go run hack/e2e.go --v --test --test_args="${common_test_args[*]} ${test_args[*]}" --check_version_skew=false
}

echo
echo "Running conformance tests..."
run_hack_e2e_go
conformance_result=$?

popd

echo
echo "Conformance test run stop date: $(date -u)"
exit $conformance_result
