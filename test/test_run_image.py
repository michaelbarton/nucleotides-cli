import os.path
import nose.tools as nose
import helper

import nucleotides.util              as util
import nucleotides.command.run_image as image

def test_docstring_parse():
    nose.assert_equal(util.parse(image.__doc__, ["run-image", "1"]),
            {'<task>': '1', 'run-image': True})
