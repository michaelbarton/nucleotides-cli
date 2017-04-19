"""\
Functions for creating file metadata and posting benchmarking event data to the
nucleotides API.
"""

import os, glob
import nucleotides.util                as util
import nucleotides.api_client          as api
import nucleotides.s3                  as s3
import nucleotides.task.task_interface as interface

from functools import partial


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


def list_outputs(app):
    """
    Creates metadata dictionaries for all produced output files.
    """
    return map(partial(output_file_metadata, app["s3-upload"]),
               sorted(glob.glob(app["path"] + "/outputs/*/*")))


def upload_output_file(app, f):
    """
    Uploads file to s3 location specified in the dictionary
    """
    app['logger'].debug("Posting file '{}' to S3 '{}'".format(f["location"], f["url"]))
    s3.post_file(f["location"], f["url"])



def create_event_request(app, outputs):
    """
    Given a list of output file metadata dictionaries, creates the JSON body that
    should be posted to the nucleotides event API.
    """
    def remove_loc(d):
        d.pop("location")
        return d

    task = interface.select_task(app["task"]["image"]["type"])()
    created_files = map(lambda x: x['type'], outputs)
    is_succesful  = task.successful_event_outputs().issubset(created_files)
    metrics       = task.collect_metrics(app) if is_succesful else {}

    return {
        "task"    : app["task"]["id"],
        "success" : is_succesful,
        "files"   : map(remove_loc, outputs),
        "metrics" : metrics}


def post(app):
    """
    Fetches list of output files, uploads each to S3 and posts event status to
    the nucleotides API.
    """
    outputs = list_outputs(app)
    map(partial(upload_output_file, app), outputs)
    api.post_event(create_event_request(app, outputs), app)


def run(task, args):
    app = util.application_state(task)
    app["s3-upload"] = util.get_environment_variable("NUCLEOTIDES_S3_URL")
    app['logger'].info("Uploading all event data for task {}".format(task))
    post(app)
    app['logger'].info("Finished upload files for task {}".format(task))
