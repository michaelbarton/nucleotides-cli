import helper.application            as app_helper
import helper.file                   as file_helper
import nucleotides.command.run_image as run
import nucleotides.filesystem        as fs

from nose.plugins.attrib import attr

@attr('slow')
def test_failing_image_with_no_outputs():
    image = {
        "name"   : "bioboxes/crash-test-biobox",
        "sha256" : "eaf1ab35314712db9d3fff0d265613629fe628ed9b058a9a4fe94424184f8c41",
        "task"   : "exit-1",
        "type"   : "short_read_assembler"
    }
    app  = app_helper.mock_short_read_assembler_state(reads = True)
    app["task"]["image"] = image
    app_helper.rewrite_app_task(app)
    run.execute_image(app)
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_runtime_metrics/metrics.json'))


@attr('slow')
def test_failing_image_with_log_output():
    image = {
        "name"   : "bioboxes/crash-test-biobox",
        "sha256" : "eaf1ab35314712db9d3fff0d265613629fe628ed9b058a9a4fe94424184f8c41",
        "task"   : "exit-1-with-log",
        "type"   : "short_read_assembler"
    }
    app  = app_helper.mock_short_read_assembler_state(reads = True)
    app["task"]["image"] = image
    app_helper.rewrite_app_task(app)
    run.execute_image(app)
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_runtime_metrics/metrics.json'))
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_log/log.txt'))
