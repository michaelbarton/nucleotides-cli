from setuptools import setup, find_packages
from nucleotides.version import __version__

setup(
    name                 = 'nucleotides-client',
    version              = __version__,
    description          = 'CLI to benchmark biobox Docker containers and collect metrics',
    author               = 'Michael Barton',
    author_email         = 'mail@nucleotid.es',
    url                  = 'http://nucleotid.es',
    scripts              = ['bin/nucleotides'],
    install_requires     = [
        "boto3==1.2.3",
        "docopt==0.6.2",
        "biobox-cli"],
    dependency_links=[
        "git+ssh://github.com/bioboxes/command-line-interface.git@c686ff8#egg=biobox-cli"
    ],

    packages             = find_packages(),
    include_package_data = True,

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
