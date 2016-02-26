import os.path, docker
import nose.tools as nose
import helper.application as app_helper
import helper.file        as file_helper

import nucleotides.util              as util
import nucleotides.command.run_image as image
import biobox_cli.util.misc          as bbx_util

from nose.plugins.attrib import attr

def test_docstring_parse():
    nose.assert_equal(util.parse(image.__doc__, ["run-image", "1"]),
            {'<task>': '1', 'run-image': True})

def test_create_biobox_args():
    app  = app_helper.mock_application_state(dummy_reads = True)
    args = image.create_biobox_args(app)
    nose.assert_equal("run", args[0])
    nose.assert_equal("short_read_assembler", args[1])
    nose.assert_equal("bioboxes/velvet", args[2])
    nose.assert_equal("--input={}/inputs/short_read_fastq/dummy.reads.fq.gz".format(app["path"]), args[3])
    nose.assert_equal("--output={}/tmp/contig_fasta".format(app["path"]), args[4])
    nose.assert_equal("--task=default", args[5])
    nose.assert_equal("--no-rm", args[6])

def test_copy_output_files():
    app  = app_helper.mock_application_state()
    file_helper.create_benchmark_file(app, "/tmp/contig_fasta", 'contents')
    image.copy_output_files(app)
    file_helper.assert_is_file(app["path"] + "/outputs/contig_fasta/d1b2a59fbe")

@attr('slow')
def test_execute_image():
    import json, shutil
    app = app_helper.mock_application_state(reads = True)
    os.environ['TMPDIR'] = file_helper.test_dir()
    image.execute_image(app)
    file_helper.assert_is_file(app["path"] + "/tmp/contig_fasta")
