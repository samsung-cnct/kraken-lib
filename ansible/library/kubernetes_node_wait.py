#!/usr/bin/python

from datetime import timedelta, datetime
from ansible.module_utils.basic import AnsibleModule

try:
    from kubernetes import client, config, watch
    HAS_LIB = True
except ImportError as err:
    HAS_LIB = False

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': 'preview',
    'supported_by': 'community'
}

DOCUMENTATION = '''
---
module: kubernetes_node_wait

short_description: Wait for kubernetes node(s) to have required state

version_added: "2.4"

description:
    - "Wait for the configured number of nodes that match the labels to be in the specified state."

options:
    - kubeconfig:
        description:
            - "The full path to your kubeconfig."
        required: false
    - count:
        description:
            - "The number of nodes required to meet the criteria."
        required: true
    - labels:
        description:
            - "A list of labels to match nodes against."
        required: false
    - state:
        description:
            - "The desired state of the node. Defaults to 'Ready'.
        required: false
    - timeout:
        description:
            - "The length of time to wait for the desired state. Defaults to 5m"
        required: false
'''

EXAMPLES = '''
# Wait for 3 arm64 nodes to be ready
- name: Wait for 3 arm64 nodes to be ready
  kubernetes_node_wait:
    count: 3
    labels:
      - 'beta.kubernetes.io/arch=arm64'
'''

RETURN = '''
nodes:
    description: The list of node names found that matched the filter
    type: list
initial_nodes:
    description: The number of nodes when this wait started
    type: int
'''


def run_module():
    '''
    This is the module that is run.
    '''
    # define the available arguments/parameters that a user can pass to
    # the module
    module_args = dict(
        kubeconfig=dict(type='str', required=False, default=None),
        count=dict(type='int', required=True),
        labels=dict(type='list', required=False, default=[]),
        state=dict(type='str', required=False, default='Ready'),
        timeout=dict(type='str', required=False, default='5m'),
    )

    # seed the result dict in the object
    result = dict(
        changed=False,
        nodes=[],
        initial_nodes=0
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    if not HAS_LIB:
        module.fail_json(
            msg="Cannot import kubernetes module. Please ensure it's installed.")

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        return result

    config.load_kube_config(module.params['kubeconfig'])

    kubeapiv1 = client.CoreV1Api()
    watchobj = watch.Watch()

    stop_at = datetime.utcnow() + \
        convert_to_timedelta(module.params['timeout'])

    for event in watchobj.stream(
            kubeapiv1.list_node,
            label_selector=",".join(module.params['labels']),
            _request_timeout=convert_from_timedelta(stop_at - datetime.utcnow())):
        if is_ready(event['object'], module.params['state']
                   ) and event['object'].metadata.name not in result['nodes']:
            if event['type'] == 'ADDED':
                result['initial_nodes'] += 1
            result['nodes'].append(event['object'].metadata.name)
        if len(result['nodes']) >= module.params['count']:
            watchobj.stop()
        if datetime.utcnow() > stop_at:
            module.fail_json(msg="Timed out waiting for {count} nodes to be {state}".format(
                count=module.params['count'], state=module.params['state']))

    if len(result['nodes']) > result['initial_nodes']:
        result['changed'] = True

    module.exit_json(**result)


def is_ready(node_obj, nodestate):
    """
    return true if *node_obj* has an active condition that is in the desired state of *nodestate*
    """
    for condition in node_obj.status.conditions:
        if (condition.status == "True") and (condition.type == nodestate):
            return True
    return False


def convert_to_timedelta(time_val):
    """
    Given a *time_val* (string) such as '5d', returns a timedelta object
    representing the given value (e.g. timedelta(days=5)).  Accepts the
    following '<num><char>' formats:

    =========   ======= ===================
    Character   Meaning Example
    =========   ======= ===================
    s           Seconds '60s' -> 60 Seconds
    m           Minutes '5m'  -> 5 Minutes
    h           Hours   '24h' -> 24 Hours
    d           Days    '7d'  -> 7 Days
    =========   ======= ===================

    Examples::

        >>> convert_to_timedelta('7d')
        datetime.timedelta(7)
        >>> convert_to_timedelta('24h')
        datetime.timedelta(1)
        >>> convert_to_timedelta('60m')
        datetime.timedelta(0, 3600)
        >>> convert_to_timedelta('120s')
        datetime.timedelta(0, 120)
    """
    num = int(time_val[:-1])
    if time_val.endswith('s'):
        return timedelta(seconds=num)
    elif time_val.endswith('m'):
        return timedelta(minutes=num)
    elif time_val.endswith('h'):
        return timedelta(hours=num)
    elif time_val.endswith('d'):
        return timedelta(days=num)


def convert_from_timedelta(timedelta_val):
    """
    given a *timedelta_val* (datetime.timedelta), return a string representing the
    inverse of convert_to_timedelta, eg. "5m".
    """
    if timedelta_val.days:
        return "{days}d".format(days=timedelta_val.days)
    if timedelta_val.seconds:
        return "{seconds}s".format(seconds=timedelta_val.seconds)


def main():
    '''
    Main
    '''
    run_module()


if __name__ == '__main__':
    main()
