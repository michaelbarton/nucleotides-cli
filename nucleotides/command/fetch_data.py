"""
nucleotides fetch-data - Download all data necessary to perform a benchmarking task

Usage:
    nucleotides fetch-data <task>
"""

import nucleotides.util        as util
import nucleotides.api_client  as api

def create_metadata_file(app_state):
    import json
    with open(app_state['path'] + "/metadata.json", "w") as f:
        f.write(json.dumps(app_state['task']))

def create_benchmark_dir(task, app_state):
    app_state['task'] = api.fetch_task(task, app_state)
    create_metadata_file(app_state)

def run(args):
    opts = util.parse(__doc__, args)
    task = opts["<task>"]
    create_benchmark_dir(task, util.application_state(task))
