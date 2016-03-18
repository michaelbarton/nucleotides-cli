import os.path, docker
import nose.tools         as nose
import helper.application as app_helper
import helper.file        as file_helper

import nucleotides.task.short_read_assembler as task
import nucleotides.command.post_data         as post

def test_create_biobox_args():
    app  = app_helper.mock_short_read_assembler_state(dummy_reads = True)
    args = task.create_biobox_args(app)
    nose.assert_equal("run", args[0])
    nose.assert_equal("short_read_assembler", args[1])
    nose.assert_equal("bioboxes/velvet", args[2])
    nose.assert_equal("--input={}/inputs/short_read_fastq/dummy.reads.fq.gz".format(app["path"]), args[3])
    nose.assert_equal("--output={}/tmp/contig_fasta".format(app["path"]), args[4])
    nose.assert_equal("--task=default", args[5])
    nose.assert_equal("--no-rm", args[6])

def test_copy_output_files():
    app  = app_helper.mock_short_read_assembler_state()
    file_helper.create_benchmark_file(app, "/tmp/contig_fasta", 'contents')
    task.copy_output_files(app)
    file_helper.assert_is_file(app["path"] + "/outputs/contig_fasta/d1b2a59fbe")

def test_create_event_request_with_a_successful_event():
    app = app_helper.mock_short_read_assembler_state(outputs = True)
    outputs = [{
        "type"     : "contig_fasta",
        "location" : "/local/path",
        "sha256"   : "digest_1",
        "url"      : "s3://url/dir/file"}]
    event = post.create_event_request(app, outputs)
    nose.assert_equal(event, {
        "task" : 1,
        "success" : True,
        "metrics" : {'max_cpu_usage': 80, 'max_memory_usage': 20},
        "files" : [
            {"url"    : "s3://url/dir/file",
             "sha256" : "digest_1",
             "type"   : "contig_fasta"}]})

def test_create_event_request_with_an_unsuccessful_event():
    app = app_helper.mock_short_read_assembler_state(outputs = False)
    outputs = []
    event = post.create_event_request(app, outputs)
    nose.assert_equal(event, {"task" : 1, "success" : False, "files" : [], "metrics" : {}})
