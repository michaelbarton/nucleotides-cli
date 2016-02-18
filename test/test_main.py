import nose.tools       as nose
import nucleotides.main as main

import nucleotides.command.fetch_data

def test_command():
    nose.assert_equal(main.select_command('fetch-data'), nucleotides.command.fetch_data)
