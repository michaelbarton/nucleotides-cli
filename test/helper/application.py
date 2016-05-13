import os

import boltons.fileutils     as fu
import helper.file           as file_helper
import nucleotides.log       as log

def mock_app():
    path = file_helper.test_dir()
    app = {'api'    : os.environ["NUCLEOTIDES_API"],
           'logger' : log.create_logger(os.path.join(path, "benchmark.log")),
           'path'   : path}
    return app

def mock_short_read_assembler_state(task = True, dummy_reads = False, reads = False, outputs = False):
    import json, shutil
    app = mock_app()

    if task:
        shutil.copy('data/short_read_assembler.json', app['path'] + '/metadata.json')
        with open(app['path'] + '/metadata.json', 'r') as f:
            app["task"] = json.loads(f.read())

    if dummy_reads:
        fu.mkdir_p(app['path'] + '/inputs/short_read_fastq/')
        shutil.copy('tmp/data/dummy.reads.fq.gz', app['path'] + '/inputs/short_read_fastq/')

    if reads:
        fu.mkdir_p(app['path'] + '/inputs/short_read_fastq/')
        shutil.copy('tmp/data/reads.fq.gz', app['path'] + '/inputs/short_read_fastq/')

    if outputs:
        fu.mkdir_p(app['path'] + '/outputs/contig_fasta/')
        shutil.copy('tmp/data/contigs.fa', app['path'] + '/outputs/contig_fasta/contigs')
        fu.mkdir_p(app['path'] + '/outputs/container_runtime_metrics/')
        shutil.copy('tmp/data/container_runtime.json', app['path'] + '/outputs/container_runtime_metrics/metrics.json')

    return app

def mock_reference_evaluator_state(outputs = False):
    import json, shutil
    app = mock_app()

    shutil.copy('data/reference_assembly_evaluation.json', app['path'] + '/metadata.json')
    with open(app['path'] + '/metadata.json', 'r') as f:
        app["task"] = json.loads(f.read())

    app["s3-upload"] = "s3://"

    fu.mkdir_p(app['path'] + '/inputs/reference_fasta/')
    shutil.copy('tmp/data/reference.fa', app['path'] + '/inputs/reference_fasta/6bac51cc35.fa')

    fu.mkdir_p(app['path'] + '/inputs/contig_fasta/')
    shutil.copy('tmp/data/contigs.fa', app['path'] + '/inputs/contig_fasta/7e9f760161.fa')

    if outputs:
        fu.mkdir_p(app['path'] + '/outputs/assembly_metrics/')
        shutil.copy('tmp/data/assembly_metrics.tsv', app['path'] + '/outputs/assembly_metrics/outputs.csv')
        fu.mkdir_p(app['path'] + '/outputs/container_runtime_metrics/')
        shutil.copy('tmp/data/container_runtime.json', app['path'] + '/outputs/container_runtime_metrics/metrics.json')

    return app
