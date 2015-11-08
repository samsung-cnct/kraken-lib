#!/bin/bash
set -e
set -u
set -x

if [[ $# < 1 ]]; then
  echo "Deletes all Active namespaces matchting regex, and waits for their termination"
  echo "Usage: $0 namespace_regex
  echo "eg: $0 density
  exit 
fi

regex="$1"
poll_delay_secs=5

# Delete all Active namespaces that match the regex
for ns in $(kubectl get namespaces | grep ${regex} | grep Active | awk '{print $1}'); do
  kubectl delete namespace $ns;
done

# The namepace is going to sit around in Terminating state until k8s has removed all resources
# therein, including pods, rcs, events, etc.
while (kubectl get namespaces | grep ${regex}); do
  sleep ${poll_delay_secs};
  date -u
done
