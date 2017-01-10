import os.path
import nose.tools             as nose
import helper.application     as app_helper
import nucleotides.filesystem as fs

from nose.plugins.attrib import attr

def test_get_output_biobox_file_contents():
    app = app_helper.mock_short_read_assembler_state(intermediates = True)
    args = fs.get_output_biobox_file_contents(app)
    nose.assert_in('fasta', args[0])


def test_copy_container_output_files_with_no_files():
    app = app_helper.mock_short_read_assembler_state(intermediates = False)
    input_files = {'container_log' : 'meta/log.txt', 'assembly_metrics' : 'combined_quast_output/report.tsv'}
    fs.copy_container_output_files(app, input_files)
    # Should do nothing if files don't exist


def test_copy_container_output_files_with_intermediates():
    app = app_helper.mock_reference_evaluator_state(intermediates = True)
    input_files = {'container_log' : 'meta/log.txt', 'assembly_metrics' : 'combined_quast_output/report.tsv'}
    output_files = ['assembly_metrics/67ba437ffa', 'container_log/e0e8af3790']

    fs.copy_container_output_files(app, input_files)
    for f in output_files:
        loc = fs.get_task_file_path(app, "outputs/" + f)
        assert os.path.isfile(loc), "Output file should be copied: {}".format(loc)
