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

from nose.plugins.attrib import attr


def test_create_container():
    app = app_helper.setup_app_state('quast', 'execute')
    cnt = run.create_container(app)
    assert "Id" in cnt
    image_helper.clean_up_container(cnt["Id"])


def test_run_container():
    app = app_helper.setup_app_state('quast', 'execute')
    id_ = run.create_container(app)['Id']
    docker.client().start(id_)
    docker.client().wait(id_)
    nose.assert_equal(container.did_exit_succcessfully(id_), True)
    image_helper.clean_up_container(id_)


def test_execution_with_empty_contig_file():
    app = app_helper.setup_app_state('quast', 'execute')
    input_contigs = fs.get_task_file_path(app, "inputs/contig_fasta/de3d9f6d31.fa")
    open(input_contigs, "w").truncate()

    image_helper.execute_image(app)
    file_helper.assert_is_empty_directory(fs.get_task_file_path(app, 'outputs/assembly_metrics/'))
    file_helper.assert_is_empty_directory(fs.get_task_file_path(app, 'outputs/container_log/'))


#################################################
#
# QUAST specific tests
#
#################################################

def test_quast_complete_run_through():
    app = app_helper.setup_app_state('quast', 'execute')
    image_helper.execute_image(app)
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/assembly_metrics/684281f282'))
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_log/86bbc499b0'))


def test_create_event_request_with_a_successful_quast_event():
    app = app_helper.setup_app_state('quast', 'outputs')
    event = post.create_event_request(app, post.list_outputs(app))
    nose.assert_equal(event["task"], 6)
    nose.assert_equal(event["success"], True)
    nose.assert_equal(event["files"][0]["type"], "assembly_metrics")
    nose.assert_in("total_aligned_length", event["metrics"])
    nose.assert_in("lga75", event["metrics"])
    nose.assert_equal(event["metrics"]["lga75"], 70.0)
    nose.assert_equal(event["metrics"]["total_aligned_length"], 679979.0)


def test_assembly_benchmark_unsuccessful_event():
    app = app_helper.setup_app_state('quast', 'task') # No tmp/biobox.yaml
    event = post.create_event_request(app, post.list_outputs(app))
    nose.assert_equal(event, {"task" : 6, "success" : False, "files" : [], "metrics" : {}})


def test_create_event_request_with_non_numeric_quast_values():
    app = app_helper.setup_app_state('quast', 'outputs')

    import fileinput
    for line in fileinput.input(app['path'] + '/outputs/assembly_metrics/67ba437ffa', inplace = True):
        if 'NGA50' in line:
            print line.replace("6456", "-"),
        else:
            print line.replace("\n", "")

    event = post.create_event_request(app, post.list_outputs(app))
    nose.assert_equal(event["success"], True)
    nose.assert_in("nga50", event["metrics"])
    nose.assert_equal(event["metrics"]["nga50"], 0.0)


def test_create_event_request_with_missing_alignment_values():
    app = app_helper.setup_app_state('quast', 'missing_alignment')
    event = post.create_event_request(app, post.list_outputs(app))
    nose.assert_equal(event["success"], False)
    nose.assert_equal(event["metrics"], {})


def test_create_event_request_with_missing_contiguity_metrics():
    app = app_helper.setup_app_state('quast', 'missing_g75_values')
    event = post.create_event_request(app, post.list_outputs(app))
    nose.assert_equal(event["success"], True)
    nose.assert_in("nga50", event["metrics"])
    nose.assert_equal(event["metrics"]["nga50"], 17378.0)
    nose.assert_equal(event["metrics"]["nga75"], 0.0)

#################################################
#
# GAET specific tests
#
#################################################


def test_gaet_complete_run_through():
    app = app_helper.setup_app_state('gaet', 'execute')
    image_helper.execute_image(app)
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/assembly_metrics/d70c163200'))
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_log/1661337965'))

def test_create_event_request_with_a_successful_gaet_event():
    app = app_helper.setup_app_state('gaet', 'outputs')
    event = post.create_event_request(app, post.list_outputs(app))
    nose.assert_equal(event["task"], 6)
    nose.assert_equal(event["success"], True)
    nose.assert_equal(event["files"][0]["type"], "assembly_metrics")

    nose.assert_in("comparison.gene_type_distance.cds.n_symmetric_difference", event["metrics"])
    nose.assert_equal(event["metrics"]["comparison.gene_type_distance.cds.n_symmetric_difference"], 7.0)

    nose.assert_in("assembly.minimum_gene_set.single_copy", event["metrics"])
    nose.assert_equal(event["metrics"]["assembly.minimum_gene_set.single_copy"], 0.0)
