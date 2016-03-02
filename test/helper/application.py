import os
import helper.file           as file_helper
import biobox_cli.util.misc  as bbx_util
import nucleotides.log       as log

def mock_app():
    path = file_helper.test_dir()
    app = {'api'    : os.environ["NUCLEOTIDES_API"],
           'logger' : log.create_logger(os.path.join(path, "benchmark.log")),
           'path'   : path}
    return app

def mock_short_read_assembler_state(task = True, dummy_reads = False, reads = False):
    import json, shutil
    app = mock_app()

    if task:
        shutil.copy('data/short_read_assembler.json', app['path'] + '/metadata.json')
        with open(app['path'] + '/metadata.json', 'r') as f:
            app["task"] = json.loads(f.read())

    if dummy_reads:
        bbx_util.mkdir_p(app['path'] + '/inputs/short_read_fastq/')
        shutil.copy('tmp/data/dummy.reads.fq.gz', app['path'] + '/inputs/short_read_fastq/')

    if reads:
        bbx_util.mkdir_p(app['path'] + '/inputs/short_read_fastq/')
        shutil.copy('tmp/data/reads.fq.gz', app['path'] + '/inputs/short_read_fastq/')

    return app

def mock_reference_evaluator_state():
    import json, shutil
    app = mock_app()

    shutil.copy('data/reference_assembly_evaluation.json', app['path'] + '/metadata.json')

    bbx_util.mkdir_p(app['path'] + '/inputs/reference_fasta/')
    shutil.copy('tmp/data/reference.fa', app['path'] + '/inputs/reference_fasta/6bac51cc35.fa')

    bbx_util.mkdir_p(app['path'] + '/inputs/contig_fasta/')
    shutil.copy('tmp/data/contigs.fa', app['path'] + '/inputs/contig_fasta/7e9f760161.fa')

    return app
