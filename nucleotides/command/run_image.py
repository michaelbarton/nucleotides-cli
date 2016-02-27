"""
nucleotides run-image - Execute Docker image for benchmarking

Usage:
    nucleotides run-image <task>
"""

import os, shutil, json
import nucleotides.util       as util
import biobox_cli.command.run as image_runner
import biobox_cli.util.misc   as bbx_util

def get_input_file_path(name, app):
    path = os.path.join(app['path'], 'inputs', name)
    return os.path.join(path, os.listdir(path)[0])

def get_output_file_path(name, app):
    dir_ = os.path.join(app['path'], 'tmp')
    bbx_util.mkdir_p(dir_)
    return os.path.join(dir_, name)

def create_biobox_args(app):
    return ["run",
            app["task"]["image"]["type"],
            app["task"]["image"]["name"],
            "--input={}".format(get_input_file_path('short_read_fastq', app)),
            "--output={}".format(get_output_file_path('contig_fasta', app)),
            "--task={}".format(app["task"]["image"]["task"]),
            "--no-rm"
            ]

def copy_output_files(app):
    src = os.path.join(app['path'], 'tmp', 'contig_fasta')
    dst = os.path.join(app['path'], 'outputs', 'contig_fasta', util.sha_digest(src)[:10])
    bbx_util.mkdir_p(os.path.dirname(dst))
    shutil.copy(src, dst)

def create_runtime_metric_file(app, metrics):
    dst = os.path.join(app['path'], 'outputs', 'container_runtime_metrics', 'metrics.json')
    bbx_util.mkdir_p(os.path.dirname(dst))
    with open(dst, 'w') as f:
        f.write(json.dumps(metrics))

def collect_metrics(name):
    import docker, docker.utils, time
    time.sleep(1)
    client = docker.Client(**docker.utils.kwargs_from_env(assert_hostname = False))
    container = filter(lambda x: x['Image'] == name, client.containers())[0]['Id']
    stats = []
    while client.inspect_container(container)["State"]["Status"] == "running":
        stats.append(next(client.stats(container)))
        time.sleep(15)
    return map(json.loads, stats)

def execute_image(app):
    from threading import Thread
    from functools import partial

    Thread(target = partial(image_runner.run, create_biobox_args(app))).start()

    image = app["task"]["image"]["name"]
    metrics = collect_metrics(image)
    create_runtime_metric_file(app, metrics)
    copy_output_files(app)

def run(args):
    opts = util.parse(__doc__, args)
    task = opts["<task>"]
    execute_image(util.application_state(task))
