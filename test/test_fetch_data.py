import os.path
import nose.tools         as nose
import helper.db          as db_helper
import helper.application as app_helper

import nucleotides.util               as util
import nucleotides.command.fetch_data as fetch

def test_docstring_parse():
    nose.assert_equal(util.parse(fetch.__doc__, ["fetch-data", "1"]),
            {'<task>': '1', 'fetch-data': True})

def test_fetch_input_files():
    db_helper.reset_database()
    app = app_helper.test_application_state()
    app['task'] = app_helper.sample_benchmark_task()
    fetch.create_input_files(app)
    nose.assert_true(os.path.isfile(app["path"] + "/inputs/0/dummy.reads.fq.gz"))
