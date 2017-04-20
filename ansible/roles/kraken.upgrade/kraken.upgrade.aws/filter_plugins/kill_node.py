
from kubernetes import client, config
import time
import kubernetes.client
from kubernetes.client.rest import ApiException
import boto3
import subprocess

class FilterModule(object):
    ''' Delete and Terminate Node '''
    def filters(self):
        return {
            'delete_and_terminate_node_filter': self.delete_and_terminate_node_filter,
        }

    def delete_node(self, node_name, config_path):
        config.load_kube_config(config_file=config_path)
        api_instance = kubernetes.client.CoreV1Api()
        name = node_name
        body = kubernetes.client.V1DeleteOptions()
        grace_period_seconds = 56
        orphan_dependents = True

        try:
            api_response = api_instance.delete_node(name, body, grace_period_seconds=grace_period_seconds, orphan_dependents=orphan_dependents)
        except ApiException as e:
            print("Exception when calling CoreV1Api->delete_node: %s\n" % e)
            raise

    def terminate_node(self, instance_id, aws_region):
        ids = [instance_id]
        try:
            ec2 = boto3.resource('ec2', region_name=aws_region)
        except Exception as e:
            print "Unexpected error: %s" % e
            raise
        try:
            ec2.instances.filter(InstanceIds=ids).terminate()
        except Exception as e:
            print "Unexpected error: %s" % e
            raise

    def current_node_count(self, config_path):
        config.load_kube_config(config_file=config_path)
        api_instance = kubernetes.client.CoreV1Api()
        label_selector = 'nodepool=masterNodes'
        timeout_seconds = 30

        try:
            time.sleep(10)
            api_response = api_instance.list_node(label_selector=label_selector, timeout_seconds=timeout_seconds)
            count = len(api_response.items)
            return count

        except ApiException as e:
            print("Exception when calling CoreV1Api->list_node: %s\n" % e)

    # delete and terminate node, then wait until node recreates itself by running a check on current node count versus expected node count
    # update this so that it tries to do each part, and breaks if any part fails with a good error message
    def delete_and_terminate_node_filter(self, node_name, instance_id, expected_count, kubeconfig, aws_region):
        try:
            self.terminate_node(instance_id, aws_region)
            print "Terminating instance: " + instance_id
        except Exception:
            return False
        try:
            self.delete_node(node_name, kubeconfig)
            print "Deleting node: " + node_name
        except Exception:
            return False

        current_count = int(self.current_node_count(kubeconfig))
        print "Available Nodes: %s/%s" % (current_count, expected_count)
        while current_count != int(expected_count):
            print "Pausing for node creation"
            time.sleep(60)
            current_count = int(self.current_node_count(kubeconfig))
            print "Available Nodes: %s/%s" % (current_count, expected_count)
        print "Node has been upgraded."
        return True
