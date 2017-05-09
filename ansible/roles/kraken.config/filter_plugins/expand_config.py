import copy, os
from ansible import errors 

def expand_config(config_data):
  try:
    all_data = copy.deepcopy(expand_envs(config_data))
    return all_data
  except Exception, e:
    raise errors.AnsibleFilterError(
            'expand_config plugin error: {0}, config_data={1}'.format(
              str(e),
              str(config_data)))

def expand_envs(obj):
  if isinstance(obj, dict):
    return { key: expand_envs(val) for key, val in obj.items()}
  if isinstance(obj, list):
    return [ expand_envs(item) for item in obj ]
  if isinstance(obj, basestring):
    return os.path.expandvars(obj)
  return obj

class FilterModule(object):
  ''' Expand Kraken configuration file '''
  def filters(self):
    return {
      'expand_config': expand_config
    }
