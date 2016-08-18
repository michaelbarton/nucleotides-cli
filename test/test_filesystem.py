import nose.tools             as nose
import helper.application     as app_helper
import nucleotides.filesystem as fs

from nose.plugins.attrib import attr

def test_get_output_biobox_file_arguments():
    app = app_helper.mock_short_read_assembler_state(intermediates = True)
    args = fs.get_output_biobox_file_arguments(app)
    nose.assert_in('fasta', args[0])
