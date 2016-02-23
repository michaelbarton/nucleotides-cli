import nose.tools as nose
import helper

import nucleotides.util              as util
import nucleotides.command.post_data as post

def test_docstring_parse():
    nose.assert_equal(util.parse(post.__doc__, ["post-data", "1"]),
            {'<task>': '1', 'post-data': True})
