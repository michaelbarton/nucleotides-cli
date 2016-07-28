import os.path, shutil, json

import ruamel.yaml        as yaml
import boltons.fileutils  as fu
import nucleotides.util   as util

# http://stackoverflow.com/a/4213255/91144
def sha_digest(filename):
    import hashlib
    sha = hashlib.sha256()
    with open(filename,'rb') as f:
        for chunk in iter(lambda: f.read(sha.block_size), b''):
            sha.update(chunk)
    return sha.hexdigest()

def get_input_dir_path(name, app):
    return os.path.join(app['path'], 'inputs', name)

def get_input_file_path(name, app):
    path = get_input_dir_path(name, app)
    return os.path.join(path, os.listdir(path)[0])


def get_tmp_dir_path(app):
    dir_ = os.path.join(app['path'], 'tmp')
    fu.mkdir_p(dir_)
    return dir_

def get_tmp_file_path(name, app):
    return os.path.join(get_tmp_dir_path(app), name)

def get_output_biobox_file_arguments(app):
    with open(get_tmp_file_path('biobox.yaml', app)) as f:
        return yaml.load(f.read())['arguments']


def get_output_file_path(name, app):
    dir_ = os.path.join(app['path'], 'outputs')
    return os.path.join(dir_, name)

def copy_tmp_file_to_outputs(app, src_file, dst_dir):
    src = os.path.join(app['path'], 'tmp', src_file)
    dst = os.path.join(app['path'], 'outputs', dst_dir, sha_digest(src)[:10])
    fu.mkdir_p(os.path.dirname(dst))
    shutil.copy(src, dst)

def create_runtime_metric_file(app, metrics):
    dst = os.path.join(app['path'], 'outputs', 'container_runtime_metrics', 'metrics.json')
    fu.mkdir_p(os.path.dirname(dst))
    with open(dst, 'w') as f:
        f.write(json.dumps(metrics))
