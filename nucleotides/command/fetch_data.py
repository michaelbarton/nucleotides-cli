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

def create_input_files(app_state):
    for index, input_ in enumerate(app_state['task']['inputs']):
        dst_dir = os.path.join(app_state['path'], 'inputs', str(index))
        bbx_util.mkdir_p(dst_dir)

        dst     = os.path.join(dst_dir, os.path.basename(input_['url']))
        src     = input_['url']
        s3.fetch_file(src, dst)

def run(args):
    opts = util.parse(__doc__, args)
    task = opts["<task>"]
    create_input_files(util.application_state(task))
