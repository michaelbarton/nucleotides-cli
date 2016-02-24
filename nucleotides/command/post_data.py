"""
nucleotides post-data - Post collected benchmark metrics back to nucleotides API

Usage:
    nucleotides post-data <task> [--s3-upload=<url>]

Options:
    task                 The current task number
    --s3-upload=<url>    S3 location to upload generated files to.
"""

import os, functools
import nucleotides.util as util
import nucleotides.s3   as s3

def output_file_metadata(s3_path, path):
    digest = util.sha_digest(path)
    return {
        "location" : path,
        "type"     : os.path.dirname(path).split("/")[-1],
        "sha256"   : digest,
        "s3_url"   : os.path.join(s3_path, digest[0:2], digest)}

def upload_output_file(f):
    s3.post_file(f["location"], f["s3_url"])

def create_output_file_metadata(app):
    import glob
    return map(functools.partial(output_file_metadata, app["s3-upload"]),
               glob.glob(app["path"] + "/outputs/*/*"))

def post(app):
    outputs = create_output_file_metadata(app)
    map(upload_output_file, outputs)

def run(args):
    opts = util.parse(__doc__, args)
    task = opts["<task>"]
    app = util.create_application_state(task)
    app["s3-upload"] = opts["--s3-upload"]
    post(app)
