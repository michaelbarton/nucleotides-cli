import os, funcy, csv
import ruamel.yaml         as yaml
import boltons.fileutils   as fu
import biobox.image.volume as vol

import nucleotides.util               as util
import nucleotides.metrics            as met
import nucleotides.filesystem         as fs
import nucleotides.command.run_image  as run


from nucleotides.task.task_interface import TaskInterface

OUTPUT_PATH = {'assembly_metrics': [0]}


def is_quast(app):
    return run.image_name(app) == "bioboxes/quast"


def is_quast_output(app):
    """
    Check whether the output is from QUAST. This workaround is required because
    'combined_quast_output/report.tsv' file is not currently listed in the biobox
    YAML produced by QUAST.

    This method should be removed once all assembly evaluation bioboxes return a
    metrics field in their biobox.yaml output.
    """
    return fs.get_biobox_yaml_value(app, [0]) == "combined_quast_output/report.html"

def is_contig_file_empty(app):
    contigs = fs.get_task_path_file_without_name(app, 'inputs/contig_fasta')
    return True if os.stat(contigs).st_size == 0 else False


class ReferenceAssemblyEvaluationTask(TaskInterface):

    def before_container_hook(self, app):
        if is_quast(app):
            fu.mkdir_p(fs.get_task_dir_path(app, 'tmp/assembly_metrics'))


    def does_task_pass_pre_execution_checks(self, app):
        if is_contig_file_empty(app):
            return (False, "Aborting Docker image exection because contig file is empty")
        else:
            return (True, "")


    def biobox_args(self, app):
        contigs    = fs.get_task_path_file_without_name(app, 'inputs/contig_fasta')
        references = fs.get_task_dir_path(app, 'inputs/reference_fasta')
        return [{"fasta"     : [{"id" : 0 , "value" : contigs,    "type": "contig"}]},
                {"fasta_dir" : [{"id" : 1 , "value" : references, "type": "references"}]}]


    def output_file_paths(self, app):
        if is_quast_output(app):
            return {'assembly_metrics' : 'report.tsv'}
        else:
            f = funcy.partial(fs.get_biobox_yaml_value, app)
            return funcy.walk_values(f, OUTPUT_PATH)


    def metric_mapping_file(self, app):
        return {'bioboxes/quast' : 'quast',
                'bioboxes/gaet'  : 'gaet'
                }[run.image_name(app)]



    def collect_metrics(self, app):
        path = fs.get_task_path_file_without_name(app, 'outputs/assembly_metrics')
        with open(path, 'r') as f:
            raw_metrics = list(csv.reader(f, delimiter = '\t'))

        mapping_file = os.path.join('mappings', self.metric_mapping_file(app) + '.yml')
        mapping      = yaml.safe_load(util.get_asset_file_contents(mapping_file))
        return met.parse_metrics(app, dict(raw_metrics), mapping)


    def successful_event_output_files(self):
        return set(["assembly_metrics"])


    def are_generated_metrics_valid(self, app, metrics):
        expected_metrics  = met.get_expected_keys_from_mapping_file(self.metric_mapping_file(app))
        return met.are_metrics_complete(app, expected_metrics, metrics.keys())
