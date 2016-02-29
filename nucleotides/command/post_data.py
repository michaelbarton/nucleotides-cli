"""
nucleotides post-data - Post collected benchmark metrics back to nucleotides API

Usage:
    nucleotides post-data <task> [--s3-upload=<url>]

Options:
    task                 The current task number
    --s3-upload=<url>    S3 location to upload generated files to.
"""

import os, functools
import nucleotides.util       as util
import nucleotides.api_client as api
import nucleotides.s3         as s3

def output_file_metadata(s3_path, path):
    digest = util.sha_digest(path)
    return {
        "location" : path,
        "type"     : os.path.dirname(path).split("/")[-1],
        "sha256"   : digest,
        "url"      : os.path.join(s3_path, digest[0:2], digest)}

def upload_output_file(f):
    s3.post_file(f["location"], f["url"])

def create_output_file_metadata(app):
    import glob
    return map(functools.partial(output_file_metadata, app["s3-upload"]),
               glob.glob(app["path"] + "/outputs/*/*"))

def event_successful(outputs):
    return "contig_fasta" in map(lambda x: x["type"], outputs)

def parse_runtime_metrics(metrics):

    def map_f(a):
        return {"max_resident_set_size" : a["memory_stats"]["stats"]["rss"],
                "max_cpu_usage"         : a["cpu_stats"]["cpu_usage"]["total_usage"]}

    # http://stackoverflow.com/a/25658642/91144
    def red_f(a, b):
        return {key:max(value,b[key]) for key, value in a.iteritems() }

    return reduce(red_f, map(map_f, metrics), {"max_cpu_usage" : 0, "max_resident_set_size" : 0})

def create_event_request(app, outputs):

    def remove_loc(d):
        d.pop("location")
        return d

    return {
        "task"    : app["task"]["id"],
        "success" : event_successful(outputs),
        "files"   : map(remove_loc, outputs)}

def post(app):
    outputs = create_output_file_metadata(app)
    map(upload_output_file, outputs)
    api.post_event(create_event_request(app, outputs), app)

def run(args):
    opts = util.parse(__doc__, args)
    task = opts["<task>"]
    app = util.application_state(task)
    app["s3-upload"] = opts["--s3-upload"]
    post(app)
