"""\
Module for interacting with the filesystem relative to the current nucleotides task
directory. Each nucleotides benchmarking task takes place in a directory named for
the nucleotides task ID. This module functions to simplify getting the location of
where input files can be found, and where output files should be created.
"""
import os.path, json

import ruamel.yaml        as yaml
import boltons.fileutils  as fu
import nucleotides.util   as util

#########################################
#
# Paths with the nucleotides task directory
#
#########################################

def get_input_dir_path(name, app):
    """
    Return the input directory path for the given nucleotides task.
    """
    return os.path.join(app['path'], 'inputs', name)


def get_input_file_path(name, app):
    """
    Return the path for a specific file defined in given nucleotides task.
    """
    path = get_input_dir_path(name, app)
    return os.path.join(path, os.listdir(path)[0])


def get_meta_dir_path(app):
    """
    Return the path to the metadata directory for the given nucleotides task.
    Creates the directory if it does not already exist.
    """
    dir_ = os.path.join(app['path'], 'meta')
    fu.mkdir_p(dir_)
    return dir_


def get_meta_file_path(name, app):
    """
    Return the path to the given file within the metadata directory for the given
    nucleotides task. Creates the temporary directory if it does not already exist.
    """
    return os.path.join(get_meta_dir_path(app), name)


def get_tmp_dir_path(app):
    """
    Return the path to the temporary directory for the given nucleotides task.
    Creates the directory if it does not already exist.
    """
    dir_ = os.path.join(app['path'], 'tmp')
    fu.mkdir_p(dir_)
    return dir_


def get_tmp_file_path(name, app):
    """
    Return the path to the given file within the temporary directory for the given
    nucleotides task. Creates the temporary directory if it does not already exist.
    """
    return os.path.join(get_tmp_dir_path(app), name)


def get_output_file_path(name, app):
    """
    Return the path for the given file name within the nucleotides task.
    """
    dir_ = os.path.join(app['path'], 'outputs')
    return os.path.join(dir_, name)


def get_output_biobox_file_arguments(app):
    """
    Return the contents of the biobox.yaml file generated by the Docker container.
    """
    with open(get_tmp_file_path('biobox.yaml', app)) as f:
        return yaml.load(f.read())['arguments']

#########################################
#
# Misc file operations
#
#########################################

# http://stackoverflow.com/a/4213255/91144
def sha_digest(filename):
    """
    Returns the sha256sum for a given file path.
    """
    import hashlib
    sha = hashlib.sha256()
    with open(filename,'rb') as f:
        for chunk in iter(lambda: f.read(sha.block_size), b''):
            sha.update(chunk)
    return sha.hexdigest()


def copy_file(src, dst):
    """
    Copies src to dst creating the destination directory if necessary.
    """
    import shutil
    fu.mkdir_p(os.path.dirname(dst))
    shutil.copy(src, dst)


def copy_tmp_file_to_outputs(app, src_file, dst_dir):
    """
    Copies a Docker container generated file from temporary directory to the output
    directory. The name of the file will be the 10-character truncated sha256sum of
    the file.
    """
    src = os.path.join(app['path'], 'tmp', src_file)
    dst = os.path.join(app['path'], 'outputs', dst_dir, sha_digest(src)[:10])
    copy_file(src, dst)


def create_runtime_metric_file(app, metrics):
    """
    Parses the raw cgroup data collected from the Docker container into a new file
    containing a JSON dictionary of nucleotides metrics suitable for upload to the
    nuclotides API.
    """
    dst = get_output_file_path('container_runtime_metrics/log.txt', app)
    fu.mkdir_p(os.path.dirname(dst))
    with open(dst, 'w') as f:
        f.write(json.dumps(metrics))
