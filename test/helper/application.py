import os, shutil, json

import boltons.fileutils     as fu
import helper.file           as file_helper
import nucleotides.log       as log

def mock_app():
    path = file_helper.test_dir()
    app = {'api'    : os.environ["NUCLEOTIDES_API"],
           'logger' : log.create_logger(os.path.join(path, "benchmark.log")),
           'path'   : path}
    return app

def copy_to_directory(src_file, dst_dir, app):
    dir_ = os.path.join(app['path'], dst_dir)
    fu.mkdir_p(dir_)
    shutil.copy(src_file, dir_)

def copy_to_file(src_file, dst_file, app):
    file_ = os.path.join(app['path'], dst_file)
    dir_  = os.path.dirname(file_)
    fu.mkdir_p(dir_)
    shutil.copy(src_file, file_)

def mock_short_read_assembler_state(task = True, dummy_reads = False, reads = False, intermediates = False, outputs = False):
    app = mock_app()

    if task:
        shutil.copy('data/short_read_assembler.json', app['path'] + '/metadata.json')
        with open(app['path'] + '/metadata.json', 'r') as f:
            app["task"] = json.loads(f.read())

    if dummy_reads:
        copy_to_directory('tmp/data/dummy.reads.fq.gz', 'inputs/short_read_fastq', app)

    if reads:
        copy_to_directory('tmp/data/11948b41d44931c6a25cabe58b138a4fc7ecc1ac628c40dcf1ad006e558fb533', 'inputs/short_read_fastq', app)

    if intermediates:
        copy_to_file('data/log.txt', 'meta/log.txt', app)
        copy_to_file('data/sra_biobox.yaml', 'tmp/biobox.yaml', app)
        copy_to_directory('tmp/data/contigs.fa', 'tmp', app)

    if outputs:
        copy_to_directory('tmp/data/contigs.fa',   'outputs/contig_fasta', app)
        copy_to_directory('data/log.txt',          'outputs/container_log', app)
        copy_to_directory('tmp/data/metrics.json', 'outputs/container_runtime_metrics', app)

    return app

def mock_reference_evaluator_state(inputs = True, intermediates = False, outputs = False):
    import json, shutil
    app = mock_app()

    shutil.copy('data/reference_assembly_evaluation.json', app['path'] + '/metadata.json')
    with open(app['path'] + '/metadata.json', 'r') as f:
        app["task"] = json.loads(f.read())

    app["s3-upload"] = "s3://"

    if inputs:
        copy_to_file('tmp/data/6bac51cc35ee2d11782e7e31ea1bfd7247de2bfcdec205798a27c820b2810414', 'inputs/reference_fasta/6bac51cc35.fa.gz', app)
        copy_to_file('tmp/data/contigs.fa', 'inputs/contig_fasta/7e9f760161.fa', app)

    if intermediates:
        copy_to_file('tmp/data/assembly_metrics.tsv', 'tmp/combined_quast_output/report.tsv', app)
        copy_to_file('data/quast_biobox.yaml', 'tmp/biobox.yaml', app)

    if outputs:
        copy_to_file('tmp/data/assembly_metrics.tsv', 'outputs/assembly_metrics/outputs.csv', app)
        copy_to_directory('tmp/data/metrics.json', 'outputs/container_runtime_metrics', app)

    return app
