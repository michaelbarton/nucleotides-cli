import os.path
import nose.tools         as nose
import helper.db          as db_helper
import helper.application as app_helper
import helper.file        as file_helper

import nucleotides.util               as util
import nucleotides.command.fetch_data as fetch

from nose.plugins.attrib import attr

@attr('slow')
def test_fetch_short_read_assembler_input_files():
    db_helper.reset_database()
    app = app_helper.mock_short_read_assembler_state()
    fetch.create_input_files(app)
    file_helper.assert_is_file(app["path"] + "/inputs/short_read_fastq/24b5b01b08482053d7d13acd514e359fb0b726f1e8ae36aa194b6ddc07335298.fq.gz")


@attr('slow')
def test_fetch_reference_assembler_input_files():
    db_helper.reset_database()
    app = app_helper.mock_reference_evaluator_state(inputs = False)
    fetch.create_input_files(app)
    file_helper.assert_is_file(app["path"] + "/inputs/reference_fasta/6bac51cc35ee2d11782e7e31ea1bfd7247de2bfcdec205798a27c820b2810414.fa.gz")
    file_helper.assert_is_file(app["path"] + "/inputs/contig_fasta/7e9f760161e13ffdd4f81fdfec2222ccd3c568f4abcbcadcb10487d43b2a0092.fa")
