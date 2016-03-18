import os.path, docker
import nose.tools         as nose
import helper.application as app_helper
import helper.file        as file_helper

import nucleotides.command.post_data                  as post
import nucleotides.task.reference_assembly_evaluation as task

def test_create_biobox_args():
    app  = app_helper.mock_reference_evaluator_state()
    args = task.create_biobox_args(app)
    nose.assert_equal("run", args[0])
    nose.assert_equal("assembler_benchmark", args[1])
    nose.assert_equal("bioboxes/quast", args[2])
    nose.assert_equal("--input-fasta={}/inputs/contig_fasta/7e9f760161.fa".format(app["path"]), args[3])
    nose.assert_equal("--input-ref={}/inputs/reference_fasta".format(app["path"]), args[4])
    nose.assert_equal("--output={}/tmp/assembly_metrics".format(app["path"]), args[5])
    nose.assert_equal("--task=default", args[6])
    nose.assert_equal("--no-rm", args[7])

def test_copy_output_files():
    app = app_helper.mock_reference_evaluator_state()
    file_helper.create_benchmark_file(app, "/tmp/assembly_metrics/combined_quast_output/report.tsv", 'contents')
    task.copy_output_files(app)
    file_helper.assert_is_file(app["path"] + "/outputs/assembly_metrics/d1b2a59fbe")

def test_create_event_request_with_a_successful_event():
    app = app_helper.mock_reference_evaluator_state(outputs = True)
    event = post.create_event_request(app, post.create_output_file_metadata(app))
    nose.assert_equal(event["task"], 6)
    nose.assert_equal(event["success"], True)
    nose.assert_equal(event["files"][0]["type"], "assembly_metrics")
    nose.assert_in("ng50", event["metrics"])
    nose.assert_in("lga75", event["metrics"])
    nose.assert_equal(event["metrics"]["lga75"], 16.0)
    nose.assert_equal(event["metrics"]["ng50"], 25079.0)
