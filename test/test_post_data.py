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
    app = app_helper.mock_short_read_assembler_state(outputs = True)
    app["s3-upload"] = "s3://url/"
    outputs = post.list_outputs(app)
    nose.assert_equal(len(outputs), 3)
    nose.assert_in({
        "type"     : "contig_fasta",
        "location" : fs.get_task_path_file_without_name(app, "outputs/contig_fasta"),
        "sha256"   : "7e9f760161e13ffdd4f81fdfec2222ccd3c568f4abcbcadcb10487d43b2a0092",
        "url"      : "s3://url/7e/7e9f760161e13ffdd4f81fdfec2222ccd3c568f4abcbcadcb10487d43b2a0092"},
        outputs)


def test_upload_output_file():
    app  = app_helper.mock_short_read_assembler_state()
    url  = "s3://nucleotides-testing/upload/"
    path = file_helper.create_benchmark_file(app, '/outputs/contig_fasta/d1b2a59fbe', 'contents')
    post.upload_output_file(post.output_file_metadata(url, path))
    expected_path = "upload/d1/d1b2a59fbea7e20077af9f91b27e95e865061b270be03ff539ab3b73587882e8"
    s3_helper.assert_s3_file_exists("nucleotides-testing", expected_path)
    s3_helper.delete_s3_file("nucleotides-testing", expected_path)


############################################
#
# Short read assembler
#
############################################

def test_short_read_assembler_successful_event():
    app = app_helper.mock_short_read_assembler_state(outputs = True)
    outputs = [{
        "type"     : "contig_fasta",
        "location" : "/local/path",
        "sha256"   : "digest_1",
        "url"      : "s3://url/dir/file"}]
    event = post.create_event_request(app, outputs)
    nose.assert_equal({
        "task" : 5,
        "success" : True,
        "metrics" : {'max_cpu_usage': 53545596799.0, 'max_memory_usage': 183865344.0, 'total_wall_clock_time_in_seconds': 15},
        "files" : [
            {"url"    : "s3://url/dir/file",
             "sha256" : "digest_1",
             "type"   : "contig_fasta"}]}, event)


def test_short_read_assembler_unsuccessful_event():
    app = app_helper.mock_short_read_assembler_state(outputs = False)
    outputs = []
    event = post.create_event_request(app, outputs)
    nose.assert_equal(event, {"task" : 5, "success" : False, "files" : [], "metrics" : {}})
