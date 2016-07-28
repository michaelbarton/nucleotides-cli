from setuptools import setup, find_packages
from nucleotides.version import __version__

def requirements():
    import pkg_resources, os
    reqs = pkg_resources.resource_string(__name__, os.path.join('requirements', 'default.txt')).strip()
    packages = filter(lambda x: 'git://' not in x, reqs.splitlines())
    packages.append("biobox-cli")
    return packages

setup(
    name                 = 'nucleotides-client',
    version              = __version__,
    description          = 'CLI to benchmark biobox Docker containers and collect metrics',
    author               = 'Michael Barton',
    author_email         = 'mail@nucleotid.es',
    url                  = 'http://nucleotid.es',
    scripts              = ['bin/nucleotides'],
    install_requires     = requirements(),
    packages             = find_packages(),

    classifiers = [
        'Natural Language :: English',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.6',
        'Topic :: Scientific/Engineering :: Bio-Informatics',
        'Intended Audience :: Science/Research',
        'Operating System :: POSIX'
    ],
)
