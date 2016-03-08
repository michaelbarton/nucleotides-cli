"""
nucleotides run-image - Execute Docker image for benchmarking

Usage:
    nucleotides run-image <task>
"""

import os, shutil, json
import nucleotides.util       as util
import biobox_cli.command.run as image_runner
import biobox_cli.util.misc   as bbx_util

def get_input_dir_path(name, app):
    return os.path.join(app['path'], 'inputs', name)

def get_input_file_path(name, app):
    path = get_input_dir_path(name, app)
    return os.path.join(path, os.listdir(path)[0])

def get_tmp_file_path(name, app):
    dir_ = os.path.join(app['path'], 'tmp')
    bbx_util.mkdir_p(dir_)
    return os.path.join(dir_, name)

def get_output_file_path(name, app):
    dir_ = os.path.join(app['path'], 'outputs')
    return os.path.join(dir_, name)

def copy_tmp_file_to_outputs(app, src_file, dst_dir):
    src = os.path.join(app['path'], 'tmp', src_file)
    dst = os.path.join(app['path'], 'outputs', dst_dir, util.sha_digest(src)[:10])
    bbx_util.mkdir_p(os.path.dirname(dst))
    shutil.copy(src, dst)

def create_runtime_metric_file(app, metrics):
    dst = os.path.join(app['path'], 'outputs', 'container_runtime_metrics', 'metrics.json')
    bbx_util.mkdir_p(os.path.dirname(dst))
    with open(dst, 'w') as f:
        f.write(json.dumps(metrics))

def collect_metrics(name, container):
    import docker, docker.utils, time
    time.sleep(1)
    client = docker.Client(**docker.utils.kwargs_from_env(assert_hostname = False))
    id_ = filter(lambda x: x['Image'] == name, client.containers())[0]['Id']
    stats = []
    while container.isAlive():
        stats.append(next(client.stats(id_)))
        time.sleep(15)
    return map(json.loads, stats)

def execute_image(app):
    from threading import Thread
    from functools import partial

    task = util.select_task(app["task"]["image"]["type"])
    task.setup(app)

    container = Thread(target = partial(image_runner.run, task.create_biobox_args(app)))
    container.start()

    image = app["task"]["image"]["name"]
    metrics = collect_metrics(image, container)
    create_runtime_metric_file(app, metrics)
    task.copy_output_files(app)

def run(args):
    opts = util.parse(__doc__, args)
    task = opts["<task>"]
    execute_image(util.application_state(task))
