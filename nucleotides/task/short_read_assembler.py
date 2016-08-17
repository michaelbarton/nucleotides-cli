import os.path, shutil, funcy

import nucleotides.metrics     as met
import nucleotides.filesystem  as fs

def biobox_args(app):
    path = fs.get_task_path_file_without_name(app, 'inputs/short_read_fastq')
    return [{"fastq" : [
        {"id" : 0 , "value" : path, "type": "paired"}]}]

def output_files():
    return [['contig_fasta', [0, 'fasta', 0]]]

def collect_metrics(app):
    import json
    path = fs.get_task_file_path(app, "outputs/container_runtime_metrics/metrics.json")
    if os.path.isfile(path):
        with open(path) as f:
            return met.parse_runtime_metrics(json.loads(f.read()))
    else:
        return {}

def successful_event_outputs():
    return set(["contig_fasta"])
