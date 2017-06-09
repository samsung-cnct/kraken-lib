# from plugins/filter/json_query.py

from ansible.errors import AnsibleError
from ansible.plugins.lookup import LookupBase
from ansible.parsing.yaml.objects import AnsibleUnicode
from ansible.utils.listify import listify_lookup_plugin_terms
from jinja2.runtime import StrictUndefined

def is_empty(data):
    if isinstance(data, dict):
        return data == {}
    if isinstance(data, AnsibleUnicode):
        return data.strip() == ""
    if isinstance(data, StrictUndefined):
        return True
    if data is None:
        return True
    return False

class FilterModule(object):
    ''' Query filter '''
    def filters(self):
        return {
            'is_empty': is_empty
        }
