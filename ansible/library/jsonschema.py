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
module: jsonschema
short_description: Validates a JSON document against a JSON schema
'''

EXAMPLES = '''
- name: Load configuration file
  include_vars:
    file: "{{ config_filename }}"
    name: config

- name: Validate configuration against JSON schema
  jsonschema:
    config: config
    schema_filename: "{{ schema_filename }}"
  register: validation

- name: Fail invalid configurations
  fail:
    msg: >-
         {{ config_filename }} was invalid. Exception raised was
         {{ validation.exception }}
    when:
      - validation.invalid
 
'''

from os import listdir
from os.path import isfile, join
import re

from ansible.module_utils.basic import *
from ansible import errors

try:
    import yaml
    import jsonschema
    import netaddr
except ImportError as e:
    raise errors.AnsibleModuleError(e)

_semver_regex = (r'^v?(0|[1-9]\d*)\.'
                 r'(0|[1-9]\d*)\.'
                 r'(0|[1-9]\d*)'
                 r'(-(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)?'
                 r'(\+[0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*)?$')

@jsonschema.FormatChecker.cls_checks('semver')
def validate_semver_format(entry):
    m = re.match(_semver_regex, entry)
    return m is not None    

@jsonschema.FormatChecker.cls_checks('cidr')
def _validate_cidr_format(cidr):
    try:
        netaddr.IPNetwork(cidr)
    except netaddr.AddrFormatError:
        return False
    if '/' not in cidr:
        return False
    if re.search('\s', cidr):
        return False
    return True

class ApiValidator(jsonschema.Draft4Validator):
    def __init__(self, schema, schema_uri='', subschema_dir=None):
        '''Accepts a schema, the URI of the schema, and an optional directory
        containing additional schema files. Any files in this directory with a
        .json extension will be loaded and used to resolve $refs.
        '''
        store = {}
        if subschema_dir:
            subschema_uri_prefix = os.path.dirname(schema_uri)
            for filename in os.listdir(subschema_dir):
                if filename.endswith(".json"):
                    subschema_uri = os.path.join(subschema_uri_prefix, filename)
                    subschema_filename = os.path.join(subschema_dir, filename)
                    store[subschema_uri] = json.load(open(subschema_filename, 'r'))
            resolver = jsonschema.RefResolver(schema_uri, schema, store)
        else:
            resolver = None

        format_checker = jsonschema.FormatChecker()
        super(ApiValidator, self).__init__(schema,
                                           resolver=resolver,
                                           format_checker=format_checker)

def validate_document(config, schema, subschema_dir=''):
    '''Attempts to validate config against schema. Returns a dictionary
    containing the config and schema, a boolean invalid indicating whether the
    config is invalid under the schema, and a text message description if
    there is a ValidationError or SchemaError exception.
    
    The jsonschema module which implements validation unconditionally attempts
    to load subschema with a remote URI over the network. This behavior is not
    specified by the jsonschema standard, and in fact, it is important that we
    can validate configs without requiring network access. Therefore, if the
    optional schema_dir parameter is passed, an attempt will be made to load
    any files with a json extension from this directory, and they will be
    passed to the validator to avoid a network dependency.
    '''
    result={ 'config': config,
             'schema': schema,
             'invalid': False,
             'exception': None,
    }

    if 'id' in schema:
        schema_uri = schema['id']
    else:
        schema_uri = ''

    try:
        validator = ApiValidator(schema, schema_uri, subschema_dir)
        validator.validate(config)
    except (jsonschema.ValidationError, jsonschema.SchemaError) as e:
        result['invalid'] = True
        result['exception'] = str(e)

    return result

def load_documents(config=None, config_filename=None,
                   schema=None, schema_filename=None, **kwargs):
    '''Accepts a config and schema as either python objects, or files containing
    YAML or JSON, and returns python objects.
    '''
    if config_filename:
        with open(config_filename, 'r') as config_file:
            config = yaml.load(config_file)

    if schema_filename:
        with open(schema_filename, 'r') as schema_file:
            schema = yaml.load(schema_file)

    return config, schema

def main():
    module = AnsibleModule(
        argument_spec={
            'config': { 'required': False, 'type': 'dict' },
            'config_filename': { 'required': False, 'type': 'str' },
            'schema': { 'required': False, 'type': 'dict' },
            'schema_filename': { 'required': False, 'type': 'str' },
            'subschema_dir': { 'required': False, 'type': 'str' },
        },
        mutually_exclusive=[
            [ 'config', 'config_filename' ],
            [ 'schema', 'schema_filename' ],
        ],
        required_one_of=[
            [ 'config', 'config_filename' ],
            [ 'schema', 'schema_filename' ],
        ],
        supports_check_mode=True
    )

    config, schema = load_documents(**module.params)
    if 'subschema_dir' in module.params:
        result = validate_document(config, schema, module.params['subschema_dir'])
    else:
        result = validate_document(config, schema)

    if result['invalid']:
        msg = 'The kraken config is invalid.'
    else:
        msg = "The kraken config appears to be valid."
    module.exit_json(changed=False, msg=msg, **result)

if __name__ == '__main__':  
    main()
