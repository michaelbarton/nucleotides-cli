import os.path
import nose.tools as nose
import helper

import nucleotides.util              as util
import nucleotides.command.run_image as image
import biobox_cli.util.misc          as bbx_util

def test_docstring_parse():
    nose.assert_equal(util.parse(image.__doc__, ["run-image", "1"]),
            {'<task>': '1', 'run-image': True})

def test_create_biobox_args():
    app  = helper.test_existing_application_state()
    args = image.create_biobox_args(app)
    nose.assert_equal("run", args[0])
    nose.assert_equal("short_read_assembler", args[1])
    nose.assert_equal("bioboxes/velvet", args[2])
    nose.assert_equal("--input={}/inputs/short_read_fastq/dummy.reads.fq.gz".format(app["path"]), args[3])
    nose.assert_equal("--output={}/tmp/contig_fasta".format(app["path"]), args[4])
    nose.assert_equal("--task=default", args[5])
    nose.assert_equal("--no-rm", args[6])

def test_copy_output_files():
    app  = helper.test_existing_application_state()
    path = os.path.join(app['path'], 'tmp', 'contig_fasta')
    bbx_util.mkdir_p(os.path.dirname(path))
    with open(path, 'w') as f:
        f.write('contents')

    image.copy_output_files(app)
    nose.assert_true(os.path.isfile(app["path"] + "/outputs/contig_fasta/d1b2a59fbe"))
