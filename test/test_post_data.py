import os
import nose.tools         as nose
import boltons.fileutils  as fu
import helper.application as app_helper
import helper.file        as file_helper
import helper.s3          as s3_helper

import nucleotides.util              as util
import nucleotides.filesystem        as fs
import nucleotides.command.post_data as post

from nose.plugins.attrib import attr

def test_list_outputs():
    app = app_helper.setup_app_state('sra', 'outputs')
    app["s3-upload"] = "s3://url/"
    outputs = post.list_outputs(app)
    nose.assert_equal(len(outputs), 3)
    nose.assert_in({
        "type"     : "contig_fasta",
        "location" : fs.get_task_path_file_without_name(app, "outputs/contig_fasta"),
        "sha256"   : "de3d9f6d31285985139aedd9e3f4b4ad04dadb4274c3c0ce28261a8e8e542a0f",
        "url"      : "s3://url/de/de3d9f6d31285985139aedd9e3f4b4ad04dadb4274c3c0ce28261a8e8e542a0f"},
        outputs)


def test_upload_output_file():
    app  = app_helper.setup_app_state('sra', 'task')
    url  = "s3://nucleotides-testing/upload/"
    path = file_helper.create_benchmark_file(app, '/outputs/contig_fasta/d1b2a59fbe', 'contents')
    post.upload_output_file(app, post.output_file_metadata(url, path))
    expected_path = "upload/d1/d1b2a59fbea7e20077af9f91b27e95e865061b270be03ff539ab3b73587882e8"
    s3_helper.assert_s3_file_exists("nucleotides-testing", expected_path)
    s3_helper.delete_s3_file("nucleotides-testing", expected_path)
