set -x

#  prep the local container with the test files
#  fetch the test files
KUBERNETES_RELEASE_VERSION=$1
platform=linux
arch=amd64
cache_dir="${3}/${KUBERNETES_RELEASE_VERSION}"
mkdir -p "${cache_dir}"
gsutil -mq cp "gs://kubernetes-release/release/${KUBERNETES_RELEASE_VERSION}/kubernetes.tar.gz" ${cache_dir}
gsutil -mq cp "gs://kubernetes-release/release/${KUBERNETES_RELEASE_VERSION}/kubernetes-test.tar.gz" ${cache_dir}
gsutil -mq cp "gs://kubernetes-release/release/${KUBERNETES_RELEASE_VERSION}/kubernetes-client-${platform}-${arch}.tar.gz" ${cache_dir}

#  unpack the test files
target_dir="${3}/kubernetes"
mkdir -p "${target_dir}"
tar --strip-components 1 -C "${target_dir}" -xzf "${cache_dir}/kubernetes.tar.gz"
tar --strip-components 1 -C "${target_dir}" -xzf "${cache_dir}/kubernetes-test.tar.gz"
tar --strip-components 3 -C "${target_dir}/platforms/${platform}/${arch}" -xzf "${cache_dir}/kubernetes-client-${platform}-${arch}.tar.gz"

# setup output dir
OUTPUT_DIR="${PWD}/output"
mkdir -p "${OUTPUT_DIR}/artifacts"

# setup gopath
export GOPATH="${PWD}/go"
mkdir -p "${GOPATH}"

## run
K2_CLUSTER_NAME=`echo $2 | tr -cd '[[:alnum:]]-' | tr '[:upper:]' '[:lower:]'`
export KUBE_CONFORMANCE_KUBECONFIG=${PWD}/cluster/aws/${K2_CLUSTER_NAME}/admin.kubeconfig
export KUBE_CONFORMANCE_OUTPUT_DIR=${OUTPUT_DIR}/artifacts

# TODO: unclear what part of k8s scripts require USER to be set
KUBERNETES_PROVIDER=aws USER=jenkins ${PWD}/hack/parallel-conformance.sh ${target_dir}
conformance_result=$?

# clean up scratch space
rm -rf $3/*

exit ${conformance_result}
