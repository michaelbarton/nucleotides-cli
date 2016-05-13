import os.path, shutil, funcy

import biobox.image.availability as avail
import biobox.image.execute      as image
import nucleotides.metrics       as met
import nucleotides.filesystem    as fs

def image_uuid(app):
    return \
            funcy.get_in(app, ["task", "image", "name"]) + \
            "@sha256:" + \
            funcy.get_in(app, ["task", "image", "sha256"])

def image_task(app):
    return funcy.get_in(app, ["task", "image", "task"])

def image_args(app):
    path = fs.get_input_file_path('short_read_fastq', app)
    return [{"fastq" : [
        {"id" : 0 , "value" : path, "type": "paired"}]}]

def create_container(app):
    avail.get_image(image_uuid(app))
    return image.create_container(
            image_uuid(app),
            image_args(app),
            fs.get_tmp_dir_path(app),
            image_task(app))

def collect_metrics(app):
    import json
    path = app['path'] + "/outputs/container_runtime_metrics/metrics.json"
    if os.path.isfile(path):
        with open(path) as f:
            return met.parse_runtime_metrics(json.loads(f.read()))
    else:
        return {}

def successful_event_outputs():
    return set(["contig_fasta"])

def create_biobox_args(app):
    return ["run",
            app["task"]["image"]["type"],
            app["task"]["image"]["name"],
            "--input={}".format(image.get_input_file_path('short_read_fastq', app)),
            "--output={}".format(image.get_tmp_file_path('contig_fasta', app)),
            "--task={}".format(app["task"]["image"]["task"]),
            "--no-rm"]

def copy_output_files(app):
    fs.copy_tmp_file_to_outputs(app, 'contig_fasta', 'contig_fasta')
