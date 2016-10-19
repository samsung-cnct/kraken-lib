import yaml, copy, json
from ansible import errors

def expand_config(config_data):
  try:
    all_data = copy.deepcopy(config_data)
    top_level_categories = all_data.keys()

    # iterate over all data, looking for dictionaries
    # expand each dictionary when found
    for key, value in all_data.items():
      if isinstance(value, dict):
        expand_object(value, top_level_categories, all_data)
      elif isinstance(value, list):
        for item in value:
          expand_object(item, top_level_categories, all_data)
      else:
        continue
    return all_data
  except Exception, e:
    raise errors.AnsibleFilterError(
            'expand_config plugin error: {0}, config_data={1}'.format(
              str(e),
              str(config_data)))

# expand dictionary recursively - go over its keys, see if any one of them is a string value key
# that matches a top level category
# if it does - look up a value under one of the top category arrays with a matching 'name'
# if it does not - move on
def expand_object(object_to_expand, top_level_categories, all_data):
  if not isinstance(object_to_expand, dict):
    return

  for key, value in object_to_expand.items():
    if isinstance(value, basestring):
      key_lookup(key, value, object_to_expand, top_level_categories, all_data)
    elif isinstance(value, dict):
      expand_object(object_to_expand[key], top_level_categories, all_data)
    elif isinstance(value, list):
      for item in value:
        expand_object(item, top_level_categories, all_data)

def key_lookup(key, value, object_to_expand, top_level_categories, all_data):
  if key in top_level_categories:
    object_to_expand[key] = get_named_section(key, value, all_data)
    if isinstance(object_to_expand[key], dict):
      expand_object(object_to_expand[key], top_level_categories, all_data)
    elif isinstance(object_to_expand[key], list):
      for item in object_to_expand[key]:
        expand_object(item, top_level_categories, all_data)


def get_named_section(key, value, all_data):
  # get key'ed value from all data
  top_level_category = all_data[key]
  if isinstance(top_level_category, list):
    named_sections = filter(lambda x: x['name'] == value, top_level_category)
    return named_sections[0] if len(named_sections) > 0 else None
  else:
    return value

class FilterModule(object):
  ''' Expand Kraken configuration file '''
  def filters(self):
    return {
      'expand_config': expand_config
    }