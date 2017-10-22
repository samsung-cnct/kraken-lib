#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Copyright © 2016 Samsung CNCT
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DOCUMENTATION = '''  
---
module: compatibility
short_description: Verifies whether a given kraken config file contains any
known incompatibilities. This module assumes the config has already passed
jsonschema validation.
'''

EXAMPLES = '''
- name: Load configuration file
  include_vars:
    file: "{{ config_filename }}"
    name: config

- name: Check if configuration file is incompatible
  compatibility:
    config: config
  register: compatibility

- name: Fail if configuration file is incompatible
  fail:
    msg: >-
         One or more incompatibilities were found in {{ config_filename }}.
         They were {{ compatibility.result.explainations }}
  when:
    - compatibility.result.incompatible

'''

from ansible.module_utils.basic import *
from ansible import errors

try:
    import yaml
    from semver import parse_version_info
except ImportError as e:
    raise errors.AnsibleModuleError(e)

REGISTERED_CHECKS = []

# All checks decorated by @register_check will be run by check_compatibility().
def register_check(check):
    REGISTERED_CHECKS.append(check)
    return check

def get_version(version):
    '''Return the VersionInfo for the version string, but strip the leading
    character if it is a v, since that's not strictly semver.
    '''
    if version[0] == 'v':
        version = version[1:]
    version_info = parse_version_info(version)
    return version_info

def get_versioned_fabric(fabric_config, version):
    '''If the kind of fabricConfig is `versionedFabric`, return the config
    specified by the version. Otherwise return the fabric_config.
    '''
    if fabric_config['kind'] == 'versionedFabric':
        version_key = 'v{}.{}'.format(version.major,
                                      version.minor)
        if version_key in fabric_config['kubeVersion']['versions']:
            return fabric_config['kubeVersion']['versions'][version_key]
        else:
            return fabric_config['default']
    else:
        return fabric_config

@register_check
def check_k8s_calico_mismatch(config):
    '''Due to an incompatiblity created by kraken-lib commit 02448b6, kraken
    nodepools running kubernetes 1.7 must use calico version v2.6.1. See
    https://goo.gl/uJR4c9 for more information.
    '''
    incompatible, explainations = False, []

    required_k8s_version = get_version('v1.7.0')
    required_calico_node_version = get_version('v2.6.1')
    template = ('Kubernetes v1.7 clusters using Calico require the calicoNode '
                'container to be at v2.6.1. The (cluster, nodepool) '
                '({cluster}, {nodepool}) does not meet this requirement. '
                'Please update the fabricConfig for the cluster named '
                '{cluster} so that the calicoNode container is v2.6.1.'
                )

    clusters = config['deployment']['clusters']
    for cluster in clusters:
        if cluster['providerConfig']['provider'] != 'aws':
            continue

        if cluster['fabricConfig']['type'] != 'canal':
            continue

        nodepools = cluster['nodePools']
        for nodepool in nodepools:
            if 'kubeConfig' not in nodepool:
                continue

            k8s_version = get_version(nodepool['kubeConfig']['version'])
            if ((k8s_version.major, k8s_version.minor) !=
                (required_k8s_version.major, required_k8s_version.minor)):
                continue

            fabric_config = get_versioned_fabric(cluster['fabricConfig'],
                                                 k8s_version)
            containers = fabric_config['options']['containers']
            calico_node_version = get_version(containers['calicoNode']['version'])
            if calico_node_version != required_calico_node_version:
                incompatible = True
                explaination = template.format(cluster=cluster['name'],
                                               nodepool=nodepool['name'])
                explainations.append(explaination)

    return incompatible, explainations

def check_compatibility(config):
    '''Calls each check function with a config and collects any
    incompatibilities returned.
    '''
    result = { 'incompatible': False,
               'explainations': [] }

    for check in REGISTERED_CHECKS:
        incompatible, explainations = check(config)
        if incompatible:
            result['incompatible'] = True
            result['explainations'] = result['explainations'] + explainations

    return result

def load_documents(config=None, config_filename=None, **kwargs):
    '''Accepts a config as either a python object or a file containing
    YAML or JSON, and returns a python object.
    '''
    if config_filename:
        with open(config_filename, 'r') as config_file:
            config = yaml.load(config_file)

    return config

def main():
    module = AnsibleModule(
        argument_spec={
            'config': { 'required': False, 'type': 'dict' },
            'config_filename': { 'required': False, 'type': 'str' },
        },
        mutually_exclusive=[
            [ 'config', 'config_filename' ],
        ],
        required_one_of=[
            [ 'config', 'config_filename' ],
        ],
        supports_check_mode=True
    )

    config = load_documents(**module.params)
    result = check_compatibility(config)

    if result['incompatible']:
        msg = 'There are incompatibles in the kraken config.'
        module.exit_json(changed=False, msg=msg, result=result)
    else:
        msg = "The kraken config appears to be compatible."
        module.exit_json(changed=False, msg=msg, result=result)

if __name__ == '__main__':  
    main()
