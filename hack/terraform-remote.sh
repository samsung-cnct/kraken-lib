#!/bin/bash

AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-"us-west-2"}

if [[ $# < 3 ]]; then
  echo "Usage: $0 cloud cluster_name verb [args...]"
  echo "  eg: $0 aws kubernetes_conformance apply" 
  echo "  eg: $0 local my_cluster destroy" 
  exit 1
fi

cloud=$1
cluster_name=$2
verb=$3
shift 3

# terraform remote doesn't let us explicitly specify state files, so change the cwd instead
my_dir=$(dirname "${BASH_SOURCE}")
pushd $my_dir/../terraform/$cloud

terraform remote config \
  -backend=S3 \
  -backend-config="bucket=pipelet-clusters" \
  -backend-config="key=$cluster_name/terraform.tfstate" \
  -pull=true

case $verb in
  apply|plan)
    # terraform doesn't provide a first-class way to represent rendered template contents 
    # as a resource (see https://github.com/hashicorp/terraform/issues/2342), so we explicitly
    # taint before running apply so terraform will re-render the template
    terraform taint template_file.ansible_inventory
    time terraform $verb -input=false $@
    ;;
  destroy)
    time terraform destroy -input=false -force=true $@
    ;;
  *)
    echo "unrecognized verb: $verb" >2
    ;;
esac

terraform remote push

popd
