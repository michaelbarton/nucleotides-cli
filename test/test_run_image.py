import helper.application            as app_helper
import helper.image                  as image_helper
import helper.file                   as file_helper
import nucleotides.command.run_image as run
import nucleotides.filesystem        as fs

from nose.plugins.attrib import attr

def test_failing_image_with_no_outputs():
    image = {
        "name"   : "bioboxes/crash-test-biobox",
        "sha256" : "eaf1ab35314712db9d3fff0d265613629fe628ed9b058a9a4fe94424184f8c41",
        "task"   : "exit-1",
        "type"   : "short_read_assembler"
    }
    app  = app_helper.setup_app_state('sra', 'inputs')
    app["task"]["image"] = image
    app_helper.rewrite_app_task(app)
    image_helper.execute_image(app)
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_runtime_metrics/metrics.json.gz'))


def test_failing_image_with_log_output():
    image = {
        "name"   : "bioboxes/crash-test-biobox",
        "sha256" : "eaf1ab35314712db9d3fff0d265613629fe628ed9b058a9a4fe94424184f8c41",
        "task"   : "exit-1-with-log",
        "type"   : "short_read_assembler"
    }
    app  = app_helper.setup_app_state('sra', 'inputs')
    app["task"]["image"] = image
    app_helper.rewrite_app_task(app)
    image_helper.execute_image(app)
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_runtime_metrics/metrics.json.gz'))
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_log/1d4dba8a3c'))
