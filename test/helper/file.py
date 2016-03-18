import os, tempfile
import biobox_cli.util.misc as bbx_util
import nose.tools as nose

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

def assert_is_dir(path):
    nose.assert_true(os.path.isdir(path), "Dir not found: {}".format(path))

def assert_is_file(path):
    nose.assert_true(os.path.isfile(path), "File not found: {}".format(path))
    nose.assert_true(os.stat(path).st_size != 0, "File is empty: {}".format(path))
