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


def list_outputs(app):
    """
    Creates metadata dictionaries for all produced output files.
    """
    return map(functools.partial(output_file_metadata, app["s3-upload"]),
               sorted(glob.glob(app["path"] + "/outputs/*/*")))


def upload_output_file(f):
    """
    Uploads file to s3 location specified in the dictionary
    """
    s3.post_file(f["location"], f["url"])



def create_event_request(app, outputs):
    """
    Given a list of output file metadata dictionaries, creates the JSON body that
    should be posted to the nucleotides event API.
    """
    def remove_loc(d):
        d.pop("location")
        return d

    task = util.select_task(app["task"]["image"]["type"])
    created_files = map(lambda x: x['type'], outputs)

    return {
        "task"    : app["task"]["id"],
        "success" : task.successful_event_outputs().issubset(created_files),
        "files"   : map(remove_loc, outputs),
        "metrics" : task.collect_metrics(app) }


def post(app):
    """
    Fetches list of output files, uploads each to S3 and posts event status to
    the nucleotides API.
    """
    outputs = list_outputs(app)
    map(upload_output_file, outputs)
    api.post_event(create_event_request(app, outputs), app)


def run(task):
    app = util.application_state(task)
    app["s3-upload"] = util.get_environment_variable("NUCLEOTIDES_S3_URL")
    post(app)
