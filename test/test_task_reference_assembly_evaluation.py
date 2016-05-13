import os.path, docker
import nose.tools         as nose
import helper.application as app_helper
import helper.file        as file_helper
import helper.image       as image_helper

import nucleotides.command.post_data                  as post
import nucleotides.command.run_image                  as run
import nucleotides.task.reference_assembly_evaluation as task

from nose.plugins.attrib import attr


def test_create_container():
    app = app_helper.mock_reference_evaluator_state()
    cnt = run.create_container(app)
    assert "Id" in cnt
    image_helper.clean_up_container(cnt["Id"])

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


def test_create_event_request_with_non_numeric_quast_values():
    app = app_helper.mock_reference_evaluator_state(outputs = True)

    import fileinput
    for line in fileinput.input(app['path'] + '/outputs/assembly_metrics/outputs.csv', inplace = True):
        if 'NGA50' in line:
            print line.replace("25079", "-"),

    event = post.create_event_request(app, post.create_output_file_metadata(app))
    nose.assert_in("nga50", event["metrics"])
    nose.assert_equal(event["metrics"]["nga50"], 0.0)
