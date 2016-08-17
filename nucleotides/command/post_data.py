"""\
Functions for creating file metadata and posting benchmarking event data to the
nucleotides API.
"""

import os, functools, glob
import nucleotides.util       as util
import nucleotides.api_client as api
import nucleotides.s3         as s3

def s3_file_url(s3_path, digest):
    """
    Returns the s3 for a given file based on the file's sha256 digest.
    """
    return os.path.join(s3_path, digest[0:2], digest)


def file_type(path):
    """
    Returns the file type based on the parent directory name.
    """
    return os.path.dirname(path).split("/")[-1]


def output_file_metadata(s3_path, path):
    """
    Returns metadata dictionary containing the required fields to submit a file to
    the nucleotides benchmarking event API.
    """
    import nucleotides.filesystem
    digest = nucleotides.filesystem.sha_digest(path)
    return {
        "location" : path,
        "type"     : file_type(path),
        "sha256"   : digest,
        "url"      : s3_file_url(s3_path, digest)}


def upload_output_file(f):
    s3.post_file(f["location"], f["url"])

def create_output_file_metadata(app):
    return map(functools.partial(output_file_metadata, app["s3-upload"]),
               glob.glob(app["path"] + "/outputs/*/*"))

def list_outputs(app):
    return map(lambda x: x.split("/")[-2], glob.glob(app["path"] + "/outputs/*/*"))

def create_event_request(app, outputs):
    def remove_loc(d):
        d.pop("location")
        return d

    task = util.select_task(app["task"]["image"]["type"])

    return {
        "task"    : app["task"]["id"],
        "success" : task.successful_event_outputs().issubset(list_outputs(app)),
        "files"   : map(remove_loc, outputs),
        "metrics" : task.collect_metrics(app) }

def post(app):
    outputs = create_output_file_metadata(app)
    map(upload_output_file, outputs)
    api.post_event(create_event_request(app, outputs), app)

def run(task):
    app = util.application_state(task)
    app["s3-upload"] = util.get_environment_variable("NUCLEOTIDES_S3_URL")
    post(app)
