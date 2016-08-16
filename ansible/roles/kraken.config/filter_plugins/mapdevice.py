def mapdevice(device_name):
  s = list(device_name)
  if device_name.startswith("s"):
    s[0] = 'x'
    s.insert(1, 'v')
  return "".join(s)

class FilterModule(object):
     def filters(self):
         return { 'mapdevice': mapdevice }