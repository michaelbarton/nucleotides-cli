import os, os.path

import nucleotides.log      as log
import biobox_cli.util.misc as bbx_util

def parse(doc, argv):
    from docopt              import docopt
    from nucleotides.version import __version__
    return docopt(doc,
                  argv          = argv,
                  version       = __version__,
                  options_first = True)

def application_state(id_):
    path = os.path.join("nucleotides", id_)
    bbx_util.mkdir_p(path)
    return {'api'    : os.environ["NUCLEOTIDES_API"],
            'logger' : log.create_logger(os.path.join(path, "benchmark.log")),
            'path'   : path}
