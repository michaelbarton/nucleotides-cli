import os.path, shutil

import biobox_cli.util.misc          as bbx_util
import nucleotides.util              as util
import nucleotides.command.run_image as image

def create_biobox_args(app):
    return ["run",
            app["task"]["image"]["type"],
            app["task"]["image"]["name"],
            "--input={}".format(image.get_input_file_path('short_read_fastq', app)),
            "--output={}".format(image.get_output_file_path('contig_fasta', app)),
            "--task={}".format(app["task"]["image"]["task"]),
            "--no-rm"]

def copy_output_files(app):
    src = os.path.join(app['path'], 'tmp', 'contig_fasta')
    dst = os.path.join(app['path'], 'outputs', 'contig_fasta', util.sha_digest(src)[:10])
    bbx_util.mkdir_p(os.path.dirname(dst))
    shutil.copy(src, dst)
