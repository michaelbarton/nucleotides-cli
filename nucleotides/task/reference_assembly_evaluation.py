import os, funcy
import ruamel.yaml          as yaml
import boltons.fileutils    as fu
import biobox.image.volume  as vol

import nucleotides.util               as util
import nucleotides.filesystem         as fs
import nucleotides.command.run_image  as run

OUTPUTS = {'assembly_metrics': [0]}

def is_quast(app):
    return run.image_name(app) == "bioboxes/quast"


def is_quast_output(app):
    # The 'combined_quast_output/report.tsv' file is not listed in the biobox YAML
    return fs.get_biobox_yaml_value(app, [0]) == "combined_quast_output/report.html"


def before_container_hook(app):
    if is_quast(app):
        fu.mkdir_p(fs.get_task_dir_path(app, 'tmp/assembly_metrics'))


def biobox_args(app):
    contigs    = fs.get_task_path_file_without_name(app, 'inputs/contig_fasta')
    references = fs.get_task_dir_path(app, 'inputs/reference_fasta')
    return [{"fasta"     : [{"id" : 0 , "value" : contigs,    "type": "contig"}]},
            {"fasta_dir" : [{"id" : 1 , "value" : references, "type": "references"}]}]


def output_file_paths(app):
    if is_quast_output(app):
        return {'assembly_metrics' : 'report.tsv'}
    else:
        f = funcy.partial(fs.get_biobox_yaml_value, app)
        return funcy.walk_values(f, OUTPUTS)


def successful_event_outputs():
    return set(["assembly_metrics"])


def parse_quast_value(x):
    if x == "-":
        return 0
    else:
        return float(x)


def collect_metrics(app):
    mapping_file = os.path.join('mappings', 'quast.yml')
    mapping = yaml.safe_load(util.get_asset_file_contents(mapping_file))

    path = fs.get_task_path_file_without_name(app, 'outputs/assembly_metrics')
    with open(path, 'r') as f:
        raw_metrics = map(lambda x: x.split("\t"), f.read().strip().split("\n"))

    return dict(map(lambda (x,y): (mapping[x], parse_quast_value(y)),
        filter(lambda (x,_): x in mapping, raw_metrics)))
