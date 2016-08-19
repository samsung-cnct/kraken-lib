import StringIO
import gzip

def gz(content_to_compress):
 	out = StringIO.StringIO()
	with gzip.GzipFile(fileobj=out, mode="w") as f:
		f.write(content_to_compress)
	return out.getvalue()

class FilterModule(object):
  def filters(self):
    return { 'gz': gz }