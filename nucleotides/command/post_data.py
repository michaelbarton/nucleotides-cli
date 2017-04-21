"""\
Functions for creating file metadata and posting benchmarking event data to the
nucleotides API.
"""

import os, glob
import nucleotides.util                as util
import nucleotides.api_client          as api
import nucleotides.s3                  as s3
import nucleotides.metrics             as met
import nucleotides.task.task_interface as interface
import nucleotides.command.run_image   as run_image

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


def create_event_request(app, output_files):
    """
    Given a list of output file metadata dictionaries, creates the JSON body that
    should be posted to the nucleotides event API.
    """
    def remove_loc(d):
        d.pop("location")
        return d

    task = run_image.image_type(app)

    created_file_types = map(lambda x: x['type'], output_files)
    required_files_were_created = task.successful_event_output_files().issubset(created_file_types)
    metrics = task.collect_metrics(app) if required_files_were_created else {}

    expected_metrics  = met.get_expected_keys_from_mapping_file(task.metric_mapping_file(app))
    metrics_are_valid = met.are_metrics_complete(app, expected_metrics, metrics.keys())

    metrics       = metrics if metrics_are_valid else {}
    is_successful = required_files_were_created and metrics_are_valid

    return {"task"    : app["task"]["id"],
            "success" : is_successful,
            "files"   : map(remove_loc, output_files),
            "metrics" : metrics}


def post(app):
    """
    Fetches list of output files, uploads each to S3 and posts event status to
    the nucleotides API.
    """
    output_files = list_outputs(app)
    map(partial(upload_output_file, app), output_files)
    request_body = create_event_request(app, output_files)
    api.post_event(request_body, app)


def run(task, args):
    app = util.application_state(task)
    app["s3-upload"] = util.get_environment_variable("NUCLEOTIDES_S3_URL")
    app['logger'].info("Uploading all event data for task {}".format(task))
    post(app)
    app['logger'].info("Finished upload files for task {}".format(task))
