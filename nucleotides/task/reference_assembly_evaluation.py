import os
import ruamel.yaml          as yaml
import boltons.fileutils    as fu
import biobox.image.volume  as vol

import nucleotides.util               as util
import nucleotides.filesystem         as fs
import nucleotides.command.run_image  as run

def before_container_hook(app):
    fu.mkdir_p(fs.get_tmp_file_path('assembly_metrics', app))

def biobox_args(app):
    contigs    = fs.get_input_file_path('contig_fasta', app)
    references = fs.get_input_dir_path('reference_fasta', app)
    return [{"fasta"     : [{"id" : 0 , "value" : contigs,    "type": "contig"}]},
            {"fasta_dir" : [{"id" : 1 , "value" : references, "type": "references"}]}]


def successful_event_outputs():
    return set(["assembly_metrics"])

def copy_output_files(app):
    fs.copy_tmp_file_to_outputs(app, 'combined_quast_output/report.tsv', 'assembly_metrics')

def parse_quast_value(x):
    if x == "-":
        return 0
    else:
        return float(x)


def collect_metrics(app):
    path = os.path.join('mappings', 'quast.yml')
    mapping = yaml.safe_load(util.get_asset_file_contents(path))

    path = fs.get_output_file_path('assembly_metrics', app)
    with open(os.path.join(path, os.listdir(path)[0]), 'r') as f:
        raw_metrics = map(lambda x: x.split("\t"), f.read().strip().split("\n"))

    return dict(map(lambda (x,y): (mapping[x], parse_quast_value(y)),
        filter(lambda (x,_): x in mapping, raw_metrics)))
