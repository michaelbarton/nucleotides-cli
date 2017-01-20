import os.path
import nose.tools         as nose
import helper.application as app_helper
import helper.file        as file_helper
import helper.image       as image_helper
import biobox.util        as docker
import biobox.container   as container

import nucleotides.filesystem                         as fs
import nucleotides.command.post_data                  as post
import nucleotides.command.run_image                  as run
import nucleotides.task.reference_assembly_evaluation as task

from nose.plugins.attrib import attr


def test_create_container():
    app = app_helper.setup_app_state('quast', 'inputs')
    cnt = run.create_container(app)
    assert "Id" in cnt
    image_helper.clean_up_container(cnt["Id"])


def test_run_container():
    app = app_helper.setup_app_state('quast', 'inputs')
    id_ = run.create_container(app)['Id']
    docker.client().start(id_)
    docker.client().wait(id_)
    nose.assert_equal(container.did_exit_succcessfully(id_), True)
    image_helper.clean_up_container(id_)


#################################################
#
# QUAST specific tests
#
#################################################


def test_quast_complete_run_through():
    app = app_helper.setup_app_state('quast', 'inputs')
    image_helper.execute_image(app)
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/assembly_metrics/684281f282'))
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_log/86bbc499b0'))


def test_create_event_request_with_a_successful_quast_event():
    app = app_helper.setup_app_state('quast', 'outputs')
    event = post.create_event_request(app, post.list_outputs(app))
    nose.assert_equal(event["task"], 6)
    nose.assert_equal(event["success"], True)
    nose.assert_equal(event["files"][0]["type"], "assembly_metrics")
    nose.assert_in("ng50", event["metrics"])
    nose.assert_in("lga75", event["metrics"])
    nose.assert_equal(event["metrics"]["lga75"], 16.0)
    nose.assert_equal(event["metrics"]["ng50"], 25079.0)


def test_create_event_request_with_non_numeric_quast_values():
    app = app_helper.setup_app_state('quast', 'outputs')

    import fileinput
    for line in fileinput.input(app['path'] + '/outputs/assembly_metrics/67ba437ffa', inplace = True):
        if 'NGA50' in line:
            print line.replace("25079", "-"),

    event = post.create_event_request(app, post.list_outputs(app))
    nose.assert_in("nga50", event["metrics"])
    nose.assert_equal(event["metrics"]["nga50"], 0.0)


#################################################
#
# GAET specific tests
#
#################################################


def test_gaet_complete_run_through():
    app = app_helper.setup_app_state('gaet', 'inputs')
    image_helper.execute_image(app)
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/assembly_metrics/d70c163200'))
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_log/1661337965'))

def test_create_event_request_with_a_successful_gaet_event():
    app = app_helper.setup_app_state('gaet', 'outputs')
    event = post.create_event_request(app, post.list_outputs(app))
    nose.assert_equal(event["task"], 6)
    nose.assert_equal(event["success"], True)
    nose.assert_equal(event["files"][0]["type"], "assembly_metrics")
    nose.assert_in("assembly.size_metrics.all.n50", event["metrics"])
    nose.assert_equal(event["metrics"]["assembly.size_metrics.all.n50"], 777.0)
    nose.assert_equal(event["metrics"]["comparison.gene_set_agreement.trna"], 1.0)
