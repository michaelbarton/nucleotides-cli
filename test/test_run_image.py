import os.path
import nose.tools as nose
import helper

import nucleotides.util              as util
import nucleotides.command.run_image as image

def test_docstring_parse():
    nose.assert_equal(util.parse(image.__doc__, ["run-image", "1"]),
            {'<task>': '1', 'run-image': True})

def test_execute_image_with_short_reads():
    app = helper.test_existing_application_state()
    os.environ['TMPDIR'] = helper.test_dir()
    image.execute_image(app)

def test_create_biobox_args():
    app  = helper.test_existing_application_state()
    args = image.create_biobox_args(app)
    nose.assert_equal("run", args[0])
    nose.assert_equal("short_read_assembler", args[1])
    nose.assert_equal("bioboxes/velvet", args[2])
    nose.assert_equal("--input={}/inputs/short_read_fastq/dummy.reads.fq.gz".format(app["path"]), args[3])
    nose.assert_equal("--output={}/tmp/contigs.fa".format(app["path"]), args[4])
    nose.assert_equal("--task=default", args[5])
