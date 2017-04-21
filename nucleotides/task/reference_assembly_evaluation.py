import os, funcy, csv
import ruamel.yaml         as yaml
import boltons.fileutils   as fu
import biobox.image.volume as vol

import nucleotides.util               as util
import nucleotides.metrics            as metrics
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


class ReferenceAssemblyEvaluationTask(TaskInterface):

    def before_container_hook(self, app):
        if is_quast(app):
            fu.mkdir_p(fs.get_task_dir_path(app, 'tmp/assembly_metrics'))


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


    def collect_metrics(self, app):
        path = fs.get_task_path_file_without_name(app, 'outputs/assembly_metrics')
        with open(path, 'r') as f:
            raw_metrics = list(csv.reader(f, delimiter = '\t'))

        if is_quast_output(app):
            mapping_file = os.path.join('mappings', 'quast.yml')
            mapping      = yaml.safe_load(util.get_asset_file_contents(mapping_file))
            return metrics.parse_metrics(dict(raw_metrics), mapping)
        else:
            return dict(map(lambda (k, v): [k, float(v)], raw_metrics))


    def successful_event_output_files(self):
        return set(["assembly_metrics"])


    def metric_mapping_file(self, app):
        return {'bioboxes/quast' : 'quast',
                'bioboxes/gaet'  : 'gaet'
                }[run.image_name(app)]
