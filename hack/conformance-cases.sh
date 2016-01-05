#!/bin/sh

my_dir=$(dirname "${BASH_SOURCE}")
kraken_root="${my_dir}/.."
pushd ${kraken_root} > /dev/null

for branch in master release-1.1 release-1.0 conformance-test-v1; do
  mkdir -p cases
  rm -rf ./output
  KUBE_CONFORMANCE_REBUILD_TESTS=true ./hack/conformance.sh $branch
  cat ./output/conformance/junit_01.xml |\
    xmllint --xpath '//testcase[not(skipped)]/@name' - |\
    sed -e$'s/ name=/\\\n/g' |\
    sed -e 's/^"//;s/"$//' |\
    sort > cases/conformance-cases-$branch.txt
done

popd > /dev/null
