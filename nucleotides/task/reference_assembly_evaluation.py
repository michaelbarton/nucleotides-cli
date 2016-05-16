import boltons.fileutils    as fu
import biobox.image.volume  as vol
import biobox.util          as util

import biobox_cli.biobox_type.assembler_benchmark as image

import nucleotides.filesystem         as fs
import nucleotides.command.run_image  as run

def before_container_hook(app):
    fu.mkdir_p(fs.get_tmp_file_path('assembly_metrics', app))

def create_container(app):
    """
    This function is a hack to get around the biobox/quast custom biobox.yaml
    format. When the biobox/quast biobox.yaml is standardised, this method should
    be removed and the biobox.image.create_container function used instead.
    """
    args = {
            '--input-fasta' : fs.get_input_file_path('contig_fasta', app),
            '--input-ref'   : fs.get_input_dir_path('reference_fasta', app)}
    volumes = image.Assembler_Benchmark().prepare_volumes(args, fs.get_tmp_dir_path(app))
    docker_args = {
            'volumes'     : map(vol.get_host_path, volumes),
            'host_config' : util.client().create_host_config(binds=volumes)}
    return util.client().create_container(
            run.image_version(app),
            run.image_task(app),
            **docker_args)



def biobox_args(app):
    contigs    = fs.get_input_file_path('contig_fasta', app)
    references = fs.get_input_dir_path('reference_fasta', app)
    return [
            {"fasta"     : [{"id" : 0 , "value" : contigs,    "type": "contig"}]},
            {"fasta_dir" : [{"id" : 1 , "value" : references, "type": "contig"}]}]


def successful_event_outputs():
    return set(["assembly_metrics"])

def copy_output_files(app):
    fs.copy_tmp_file_to_outputs(app, 'assembly_metrics/combined_quast_output/report.tsv', 'assembly_metrics')

def parse_quast_value(x):
    if x == "-":
        return 0
    else:
        return float(x)

def collect_metrics(app):
    import pkg_resources, yaml, os
    mapping_path = os.path.join('..', 'mappings', 'quast.yml')
    mapping = yaml.safe_load(pkg_resources.resource_string(__name__, mapping_path))

    path = fs.get_output_file_path('assembly_metrics', app)
    with open(os.path.join(path, os.listdir(path)[0]), 'r') as f:
        raw_metrics = map(lambda x: x.split("\t"), f.read().strip().split("\n"))

    return dict(map(lambda (x,y): (mapping[x], parse_quast_value(y)),
        filter(lambda (x,_): x in mapping, raw_metrics)))
