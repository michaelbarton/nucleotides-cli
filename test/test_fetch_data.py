import nose.tools as nose

import nucleotides.command.fetch_data as fetch
import nucleotides.util               as util

def test_docstring_parse():
    nose.assert_equal(util.parse(fetch.__doc__, ["fetch-data", "1"]),
            {'<task>': '1', 'fetch-data': True})
