import os.path, shutil

import biobox_cli.util.misc          as bbx_util
import nucleotides.util              as util
import nucleotides.command.run_image as image

def setup(app):
    None

def create_biobox_args(app):
    return ["run",
            app["task"]["image"]["type"],
            app["task"]["image"]["name"],
            "--input={}".format(image.get_input_file_path('short_read_fastq', app)),
            "--output={}".format(image.get_output_file_path('contig_fasta', app)),
            "--task={}".format(app["task"]["image"]["task"]),
            "--no-rm"]

def copy_output_files(app):
    image.copy_tmp_file_to_outputs(app, 'contig_fasta', 'contig_fasta')
