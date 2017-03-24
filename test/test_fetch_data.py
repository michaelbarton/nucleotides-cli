import os.path
import nose.tools         as nose
import helper.db          as db_helper
import helper.application as app_helper
import helper.file        as file_helper

import nucleotides.util               as util
import nucleotides.command.fetch_data as fetch

from nose.plugins.attrib import attr

def test_fetch_short_read_assembler_input_files():
    db_helper.reset_database()
    app  = app_helper.setup_app_state('sra', 'task')
    fetch.create_input_files(app)
    file_helper.assert_is_file(app["path"] + "/inputs/short_read_fastq/24b5b01b08482053d7d13acd514e359fb0b726f1e8ae36aa194b6ddc07335298.fq.gz")


@attr('wip')
def test_fetch_reference_assembler_input_files():
    db_helper.reset_database()
    app = app_helper.setup_app_state('quast', 'task')
    fetch.create_input_files(app)
    file_helper.assert_is_file(app["path"] + "/inputs/reference_fasta/6bac51cc35ee2d11782e7e31ea1bfd7247de2bfcdec205798a27c820b2810414.fa.gz")
    file_helper.assert_is_file(app["path"] + "/inputs/contig_fasta/57601ff10b7faf7fcf53a7268e3615db58088db34eb8e8bf31cb475c24381451.fa")

def test_fetch_reference_assembler_input_files_with_short_contigs():
    db_helper.reset_database()
    app = app_helper.setup_app_state('quast_short_contigs', 'task')
    fetch.create_input_files(app)

    # If the short contig are filtered as part of the download process, the input
    # file should have the same SHA256 as the contig.fa without the short contigs.
    file_helper.assert_is_file(app["path"] + "/inputs/contig_fasta/de3d9f6d31285985139aedd9e3f4b4ad04dadb4274c3c0ce28261a8e8e542a0f.fa")
    file_helper.assert_is_not_file(app["path"] + "/inputs/contig_fasta/1ff29bcb6940b7d629d2d070fd67b23604e3459c9fd0167cdb6d1dcb26966c87.fa")
    file_helper.assert_is_not_file(app["path"] + "/inputs/contig_fasta/1ff29bcb6940b7d629d2d070fd67b23604e3459c9fd0167cdb6d1dcb26966c87.fa.fai")
