import yaml, copy, json
from ansible import errors

def expected_nodes(config_data, readiness_type, readiness_value):
  total_nodes = 0
  for node in config_data['nodePools']:
    if 'etcdConfig' not in node:
      total_nodes += node['count']

  if readiness_type == 'exact':
    return total_nodes
  elif readiness_type == 'percent':
    return int(round(percentage(readiness_value, total_nodes)))
  elif readiness_type == 'delta':
    return int(total_nodes) - int(readiness_value)
  else:
    raise errors.AnsibleFilterError(
            'expected_nodes plugin error: {0} is not a recognized readiness type'.format(
              readiness_type))

def percentage(percent, whole):
  return (int(percent) * int(whole)) / 100.0

class FilterModule(object):
  ''' Derive acceptable number of nodes from kraken config and readiness values '''
  def filters(self):
    return {
      'expected_nodes': expected_nodes
    }