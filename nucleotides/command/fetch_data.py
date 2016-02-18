"""
nucleotides fetch-data - Download all data necessary to perform a benchmarking task

Usage:
    nucleotides fetch-data <task>
"""

import os.path

import biobox_cli.util.misc    as bbx_util
import nucleotides.util        as util
import nucleotides.api_client  as api
import nucleotides.s3          as s3

def create_metadata_file(app_state):
    import json
    with open(app_state['path'] + "/metadata.json", "w") as f:
        f.write(json.dumps(app_state['task']))

def create_input_files(app_state):
    for index, input_ in enumerate(app_state['task']['inputs']):
        dst_dir = os.path.join(app_state['path'], 'inputs', str(index))
        bbx_util.mkdir_p(dst_dir)

        dst     = os.path.join(dst_dir, os.path.basename(input_['url']))
        src     = input_['url']
        s3.fetch_file(src, dst)

def create_benchmark_dir(task, app_state):
    app_state['task'] = api.fetch_task(task, app_state)
    create_metadata_file(app_state)
    create_input_files(app_state)

def run(args):
    opts = util.parse(__doc__, args)
    task = opts["<task>"]
    create_benchmark_dir(task, util.application_state(task))
