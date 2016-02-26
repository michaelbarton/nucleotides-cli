import os
import nose.tools         as nose
import helper.application as app_helper
import helper.file        as file_helper
import helper.s3          as s3_helper

import nucleotides.util              as util
import nucleotides.command.post_data as post

def test_docstring_parse():
    nose.assert_equal(
        util.parse(post.__doc__, ["post-data", "1", "--s3-upload=loc"]),
        {'<task>': '1', 'post-data': True, "--s3-upload" : "loc"})

def test_create_output_file_metadata():
    app  = app_helper.mock_application_state()
    app["s3-upload"] = "s3://url/"
    path = file_helper.create_benchmark_file(app, "/outputs/contig_fasta/d1b2a59fbe", 'contents')
    nose.assert_equal(post.create_output_file_metadata(app), [{
        "type"     : "contig_fasta",
        "location" : path,
        "sha256"   : "d1b2a59fbea7e20077af9f91b27e95e865061b270be03ff539ab3b73587882e8",
        "url"      : "s3://url/d1/d1b2a59fbea7e20077af9f91b27e95e865061b270be03ff539ab3b73587882e8"}])

def test_upload_output_file():
    app  = app_helper.mock_application_state()
    url  = "s3://nucleotides-testing/upload/"
    path = file_helper.create_benchmark_file(app, '/outputs/contig_fasta/d1b2a59fbe', 'contents')
    post.upload_output_file(post.output_file_metadata(url, path))
    expected_path = "upload/d1/d1b2a59fbea7e20077af9f91b27e95e865061b270be03ff539ab3b73587882e8"
    s3_helper.assert_s3_file_exists("nucleotides-testing", expected_path)
    s3_helper.delete_s3_file("nucleotides-testing", expected_path)

def test_create_event_request_with_a_successful_event():
    app = app_helper.mock_application_state()
    outputs = [{
        "type"     : "contig_fasta",
        "location" : "/local/path",
        "sha256"   : "digest_1",
        "url"      : "s3://url/dir/file"}]
    event = post.create_event_request(app, outputs)
    nose.assert_equal(event, {
        "task" : 1,
        "success" : True,
        "files" : [
            {"url"    : "s3://url/dir/file",
             "sha256" : "digest_1",
             "type"   : "contig_fasta"}]})

def test_create_event_request_with_an_unsuccessful_event():
    app = app_helper.mock_application_state()
    outputs = []
    event = post.create_event_request(app, outputs)
    nose.assert_equal(event, {"task" : 1, "success" : False, "files" : []})
