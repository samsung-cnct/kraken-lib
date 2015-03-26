echo "Applying local environment settings"
# Setup environment variables
export ETCDCTL_PEERS=http://172.16.1.101:4001
export PATH=/opt/kubernetes/platforms/darwin/amd64:$PATH
export FLEETCTL_ENDPOINT=http://172.16.1.101:4001
export KUBERNETES_MASTER=http://172.16.1.101:8080

# Create AWS paths
