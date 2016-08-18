import os.path, docker, funcy
import nose.tools         as nose
import biobox.util        as docker
import biobox.container   as container
import helper.application as app_helper
import helper.file        as file_helper
import helper.image       as image_helper

import nucleotides.filesystem                as fs
import nucleotides.task.short_read_assembler as task
import nucleotides.command.run_image         as run
import nucleotides.command.post_data         as post

from nose.plugins.attrib import attr


def test_create_container():
    app = app_helper.mock_short_read_assembler_state(reads = True)
    cnt = run.create_container(app)
    assert "Id" in cnt
    image_helper.clean_up_container(cnt["Id"])

@attr('slow')
def test_run_container():
    app = app_helper.mock_short_read_assembler_state(reads = True)
    id_ = run.create_container(app)['Id']
    docker.client().start(id_)
    docker.client().wait(id_)
    nose.assert_equal(container.did_exit_succcessfully(id_), True)
    image_helper.clean_up_container(id_)

def test_list_input_files():
    app  = app_helper.mock_short_read_assembler_state(intermediates = True)
    args = fs.get_output_biobox_file_arguments(app)
    paths = task.output_files()
    for (file_type, path) in paths:
        location = os.path.join(app['path'], 'tmp', funcy.get_in(args, path + ['value']))
        nose.assert_true(os.path.isfile(location))

def test_copy_output_files():
    app = app_helper.mock_short_read_assembler_state(intermediates = True)
    run.copy_output_files(app)
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_log/log.txt'))
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/contig_fasta/7e9f760161'))


@attr('slow')
def test_complete_run_through():
    app = app_helper.mock_short_read_assembler_state(reads = True)
    run.execute_image(app)
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/contig_fasta/7e9f760161'))
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_runtime_metrics/metrics.json'))
    file_helper.assert_is_file(fs.get_task_file_path(app, 'outputs/container_log/log.txt'))
