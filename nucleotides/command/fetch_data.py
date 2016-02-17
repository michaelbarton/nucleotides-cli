"""
nucleotides fetch-data - Download all data necessary to perform a benchmarking task

Usage:
    nucleotides fetch-data <task>
"""

import nucleotides.util        as util
import nucleotides.api_client  as api
import biobox_cli.util.misc    as bbx_util

def run(args):
    opts = util.parse(__doc__, args)
    create_metadata_file(opts["<task>"])

def create_metadata_file(metadata):
    import json
    path = "nucleotides-task/{}".format(metadata["id"])
    bbx_util.mkdir_p(path)
    with open(path + "/metadata.json", "w") as f:
        f.write(json.dumps(metadata))

def create_benchmark_dir(id_):
    metadata = api.fetch_task(id_)
    create_metadata_file(metadata)
