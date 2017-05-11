import os, tempfile
import boltons.fileutils  as fu
import nose.tools         as nose

def create_benchmark_file(app, path, contents = ''):
    loc = os.path.join(app["path"] + path)
    fu.mkdir_p(os.path.dirname(loc))
    with open(loc, 'w+') as f:
        f.write(contents)
    return loc

def test_dir():
    path = os.path.join(os.path.dirname(os.path.realpath(__file__)), '..', '..', 'tmp', 'tests')
    fu.mkdir_p(path)
    return tempfile.mkdtemp(dir = path)


def assert_is_dir(path):
    nose.assert_true(os.path.isdir(path), "Dir not found: {}".format(path))


def assert_is_file(path):
    nose.assert_true(os.path.isfile(path), "File should exist: {}".format(path))
    nose.assert_true(os.stat(path).st_size != 0, "File should not be empty: {}".format(path))


def assert_is_not_file(path):
    nose.assert_false(os.path.isfile(path), "File should not exist: {}".format(path))


def assert_is_empty_directory(path):
    nose.assert_equal(os.listdir(path), [])
