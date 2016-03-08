import nucleotides.command.run_image as image
import biobox_cli.util.misc          as bbx_util

def successful_event_outputs():
    return set(["assembly_metrics"])

def setup(app):
    bbx_util.mkdir_p(image.get_tmp_file_path('assembly_metrics', app))

def create_biobox_args(app):
    return ["run",
            "assembler_benchmark",
            app["task"]["image"]["name"],
            "--input-fasta={}".format(image.get_input_file_path('contig_fasta', app)),
            "--input-ref={}".format(image.get_input_dir_path('reference_fasta', app)),
            "--output={}".format(image.get_tmp_file_path('assembly_metrics', app)),
            "--task={}".format(app["task"]["image"]["task"]),
            "--no-rm"]

def copy_output_files(app):
    image.copy_tmp_file_to_outputs(app, 'assembly_metrics/combined_quast_output/report.tsv', 'assembly_metrics')

def collect_metrics(app):
    import pkg_resources, yaml, os
    mapping_path = os.path.join('..', 'mappings', 'quast.yml')
    mapping = yaml.safe_load(pkg_resources.resource_string(__name__, mapping_path))

    path = image.get_output_file_path('assembly_metrics', app)
    with open(os.path.join(path, os.listdir(path)[0]), 'r') as f:
        raw_metrics = map(lambda x: x.split("\t"), f.read().strip().split("\n"))

    return dict(map(lambda (x,y): (mapping[x], float(y)),
        filter(lambda (x,_): x in mapping, raw_metrics)))
