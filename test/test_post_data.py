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


############################################
#
# Short read assembler
#
############################################

def test_short_read_assembler_successful_event():
    app  = app_helper.setup_app_state('sra', 'outputs')
    outputs = [{
        "type"     : "contig_fasta",
        "location" : "/local/path",
        "sha256"   : "digest_1",
        "url"      : "s3://url/dir/file"}]
    event = post.create_event_request(app, outputs)
    nose.assert_equal({
        "task" : 5,
        "success" : True,
        "metrics" : {
            "total_cpu_usage_in_seconds"               : 53.546,
            "total_cpu_usage_in_seconds_in_kernelmode" : 1.75,
            "total_cpu_usage_in_seconds_in_usermode"   : 11.11,
            "total_memory_usage_in_mibibytes"          : 175.348,
            "total_rss_in_mibibytes"                   : 80.543,
            "total_read_io_in_mibibytes"               : 38.641,
            "total_write_io_in_mibibytes"              : 0.0,
            "total_wall_clock_time_in_seconds"         : 0.0},
        "files" : [
            {"url"    : "s3://url/dir/file",
             "sha256" : "digest_1",
             "type"   : "contig_fasta"}]}, event)


def test_short_read_assembler_unsuccessful_event():
    app  = app_helper.setup_app_state('sra', 'task')
    outputs = []
    event = post.create_event_request(app, outputs)
    nose.assert_equal(event, {"task" : 5, "success" : False, "files" : [], "metrics" : {}})


def test_assembly_benchmark_unsuccessful_event():
    app = app_helper.setup_app_state('quast', 'task') # No tmp/biobox.yaml
    event = post.create_event_request(app, post.list_outputs(app))
    nose.assert_equal(event, {"task" : 6, "success" : False, "files" : [], "metrics" : {}})
