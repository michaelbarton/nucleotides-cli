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

def create_application_state(task):
    path = os.path.join("nucleotides", task)
    bbx_util.mkdir_p(path)
    return {'api'    : os.environ["NUCLEOTIDES_API"],
            'logger' : log.create_logger(os.path.join(path, "benchmark.log")),
            'path'   : path}

def get_task_metadata(task, app_state):
    import nucleotides.api_client as api
    import json
    metadata_json = os.path.join(app_state['path'], 'metadata.json')
    if os.path.isfile(metadata_json):
        with open(metadata_json, 'r') as f:
            metadata = json.loads(f.read())
    else:
        metadata = api.fetch_task(task, app_state)
        with open(metadata_json, "w") as f:
            f.write(json.dumps(metadata))
    return metadata

def application_state(task):
    app = create_application_state(task)
    app['task'] = get_task_metadata(task, app)
    return app
