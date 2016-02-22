"""
nucleotides run-image - Execute Docker image for benchmarking

Usage:
    nucleotides run-image <task>
"""

import os
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
            "--output={}".format(get_output_file_path('contigs.fa', app)),
            "--task={}".format(app["task"]["image"]["task"])]

def execute_image(app):
    None

def run(args):
    opts = util.parse(__doc__, args)
    task = opts["<task>"]
    execute_image(util.application_state(task))
