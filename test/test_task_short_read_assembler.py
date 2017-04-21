import os.path, docker, funcy
import nose.tools         as nose
import biobox.util        as docker
import biobox.container   as container
import helper.application as app_helper
import helper.file        as file_helper
import helper.image       as image_helper

import nucleotides.filesystem                as fs
import nucleotides.command.run_image         as run
import nucleotides.command.post_data         as post

from nucleotides.task.short_read_assembler import ShortReadAssemblerTask as task

from nose.plugins.attrib import attr


def test_create_container():
    app = app_helper.setup_app_state('sra', 'inputs')
    cnt = run.create_container(app)
    assert "Id" in cnt
    image_helper.clean_up_container(cnt["Id"])


def test_run_container():
    app = app_helper.setup_app_state('sra', 'inputs')
    id_ = run.create_container(app)['Id']
    docker.client().start(id_)
    docker.client().wait(id_)
    nose.assert_equal(container.did_exit_succcessfully(id_), True)
    image_helper.clean_up_container(id_)


def test_output_file_paths():
    app = app_helper.setup_app_state('sra', 'intermediates')
    paths = task().output_file_paths(app)
    for (_, f) in paths.items():
        location = fs.get_task_file_path(app, "tmp/" + f)
        nose.assert_true(os.path.isfile(location))

def test_copy_output_files():
    app = app_helper.setup_app_state('sra', 'intermediates')
    run.copy_output_files(app)
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_log/e0e8af3790'))
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/contig_fasta/de3d9f6d31'))


def test_complete_run_through():
    app = app_helper.setup_app_state('sra', 'inputs')
    image_helper.execute_image(app)

    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/contig_fasta/01eb7cec61'))
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_runtime_metrics/metrics.json.gz'))
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_log/1099992390'))


############################################
#
# Posting results
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
        "task" : 4,
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
    nose.assert_equal(event, {"task" : 4, "success" : False, "files" : [], "metrics" : {}})
