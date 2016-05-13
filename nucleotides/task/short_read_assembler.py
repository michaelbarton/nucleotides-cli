import os.path, shutil, funcy

import nucleotides.metrics     as met
import nucleotides.filesystem  as fs

def biobox_args(app):
    path = fs.get_input_file_path('short_read_fastq', app)
    return [{"fastq" : [
        {"id" : 0 , "value" : path, "type": "paired"}]}]

def copy_output_files(app):
    fs.copy_tmp_file_to_outputs(app, 'contig_fasta', 'contig_fasta')

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
