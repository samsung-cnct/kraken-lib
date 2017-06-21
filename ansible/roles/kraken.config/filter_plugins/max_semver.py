import semver


def max_semver(data):
    ver = max([semver.parse(x[1:]) for x in data])
    string = semver.format_version(ver['major'], ver['minor'], ver['patch'],
                                   ver['prerelease'], ver['build'])
    return 'v' + string


class FilterModule(object):
    ''' Select the highest "v"-prefixed version string '''
    def filters(self):
        return {
            'max_semver': max_semver
        }
