import os.path, shutil, funcy

import nucleotides.metrics    as met
import nucleotides.filesystem as fs

from nucleotides.task.task_interface import TaskInterface

OUTPUT_PATH = {'contig_fasta' : [0, 'fasta', 0]}

class ShortReadAssemblerTask(TaskInterface):

    def biobox_args(self, app):
        path = fs.get_task_path_file_without_name(app, 'inputs/short_read_fastq')
        return [{"fastq" : [
            {"id" : 0 , "value" : path, "type": "paired"}]}]


    def output_file_paths(self, app):
        f = funcy.partial(fs.get_biobox_yaml_value, app)
        return funcy.walk_values(f, OUTPUT_PATH)


    def collect_metrics(self, app):
        import json, gzip
        path = fs.get_task_file_path(app, "outputs/container_runtime_metrics/metrics.json.gz")
        if os.path.isfile(path):
            with gzip.open(path) as f:
                return met.parse_runtime_metrics(json.loads(f.read()))
        else:
            return {}

    def successful_event_output_files(self):
        return set(["contig_fasta"])

    def metric_mapping_file(self, app):
        return 'cgroup_runtime_metrics'
