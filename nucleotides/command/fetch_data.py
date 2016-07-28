import os.path

import boltons.fileutils       as fu
import nucleotides.util        as util
import nucleotides.api_client  as api
import nucleotides.s3          as s3

EXTENSION_MAPPING = {
        'short_read_fastq' : '.fq.gz',
        'reference_fasta'  : '.fa.gz',
        'contig_fasta'     : '.fa' }

def destination_path(path, f):
    filename = os.path.basename(f['url']) + EXTENSION_MAPPING[f['type']]
    return os.path.join(path, 'inputs', f['type'], filename)

def which_download_file(f):
    return f['type'] in EXTENSION_MAPPING.keys()

def create_input_files(app):
    for f in filter(which_download_file, app['task']['inputs']):
        dst = destination_path(app['path'], f)
        fu.mkdir_p(os.path.dirname(dst))
        s3.fetch_file(f['url'], dst)

def run(task):
    create_input_files(util.application_state(task))
