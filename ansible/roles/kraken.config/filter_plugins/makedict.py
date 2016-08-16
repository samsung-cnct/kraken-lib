class FilterModule(object):
     def filters(self):
         return { 'makedict': lambda _val, _list: { k: _val for k in _list }  }