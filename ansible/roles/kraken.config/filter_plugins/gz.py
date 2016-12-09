import StringIO
import gzip

def gz(content_to_compress):
 	out = StringIO.StringIO()
	with gzip.GzipFile(fileobj=out, mode="w", mtime=1481236323.771718) as f:  # parameter to mtime is chosen at random but should be same for every call
		f.write(content_to_compress)
	return out.getvalue()

class FilterModule(object):
  def filters(self):
    return { 'gz': gz }
