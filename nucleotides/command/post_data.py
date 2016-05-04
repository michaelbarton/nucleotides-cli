import os, functools, glob
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
