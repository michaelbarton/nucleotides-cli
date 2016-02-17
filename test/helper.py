import os, tempfile
import nucleotides.log as log

def test_application_state():
    path = tempfile.mkdtemp()
    return {'api'    : os.environ["DOCKER_HOST"],
            'logger' : log.create_logger(os.path.join(path, "benchmark.log")),
            'path'   : path}

