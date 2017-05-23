from distutils.version import StrictVersion

def latest_helm(data):
    # Find out all the versions
    file_info = data['files']
    versions = []
    for item in file_info:
        path = item['path']
        version_number = path.split('/')[4][1:]
        versions.append(version_number)

    max_version = versions[0]

    for version in versions:
        if StrictVersion(max_version) < StrictVersion(version):
            max_version = version

    return max_version

class FilterModule(object):
    ''' Returns the latest version of helm available in the filesystem '''
    def filters(self):
        return {
            'latest_helm': latest_helm
        }
