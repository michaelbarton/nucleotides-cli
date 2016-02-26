import os, tempfile
import biobox_cli.util.misc as bbx_util

def create_benchmark_file(app, path, contents = ''):
    loc = os.path.join(app["path"] + path)
    bbx_util.mkdir_p(os.path.dirname(loc))
    with open(loc, 'w+') as f:
        f.write(contents)
    return loc

def test_dir():
    path = os.path.join(os.path.dirname(os.path.realpath(__file__)), '..', '..', 'tmp', 'tests')
    bbx_util.mkdir_p(path)
    return tempfile.mkdtemp(dir = path)
