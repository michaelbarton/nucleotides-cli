import pkg_resources, os

def get_version():
    path = os.path.join('..', 'VERSION')
    return pkg_resources.resource_string(__name__, path).strip()

__version__ = get_version()
