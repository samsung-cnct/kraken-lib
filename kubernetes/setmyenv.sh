#!/bin/bash
#
# setup kubectl for our Kraken clusters
#
# As long as the --kubeconfig arg points to the correct .kubeconfig file
# things will work.  NOTE: This is also to avoid the inconsistencies
# that can happen by depending on default locations for the .kubeconfig file.
#
# e.g.   what we want:
#alias kubectl='/opt/kubernetes/platforms/darwin/amd64/kubectl --kubeconfig="/Users/mikel_nelson/dev/cloud/kraken/kubernetes/.kubeconfig"'
#
echo "--------------------------------------------"
echo "  Attempting to set a kubectl alias"
echo "  for Kraken."
echo "" 
echo " NOTE: You must 'source' this file"
echo "       so the alias will stick."
echo ""
echo " \$source ./setmyenv.sh"
echo "   or"
echo " \$. ./setmyenv.sh"
echo ""
unset CDPATH
echo "Locating Kraken Project kubectl and .kubeconfig..."
SCRIPTPATH="$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )"
cd ${SCRIPTPATH}
KUBECONFIG=`find ${SCRIPTPATH} -type f -name ".kubeconfig" -print | egrep 'kubernetes'`
if [ $? -ne 0 ];then
    echo "Could not find Kraken .kubeconfig in ${SCRIPTPATH}"
    exit 1
else
    echo "found: $KUBECONFIG"
fi
KUBECTL=`find /opt/kubernetes/platforms/darwin/amd64 -type f -name "kubectl" -print | egrep '.*'`
if [ $? -ne 0 ];then
    echo "Could not find kubectl. Make sure you have /opt/kubernetes/platforms/darwin/amd64/kubectl defined."
    exit 2
else
    echo "found: $KUBECTL"
fi
echo "Setting alias for kubectl with the kraken .kubeconfig file"
alias kubectl="${KUBECTL} --kubeconfig=${KUBECONFIG}"
echo `alias kubectl`
echo "--------------------------------------------"
echo "  Switching back to the starting directory:"
#
# switch back to where we started
cd -
