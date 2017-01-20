import os
import helper.application as app_helper
import helper.file        as file_helper
import nose.tools         as nose
import nucleotides.main   as main
import nucleotides.util   as util

from nose.plugins.attrib import attr

def test_get_task_metadata_with_no_metadata_json():
    app = app_helper.setup_app_state('sra')
    metadata = util.get_task_metadata("1", app)
    nose.assert_in("id", metadata)
    file_helper.assert_is_file(app["path"] + "/metadata.json")

def test_get_task_metadata_with_existing_metadata_json():
    import json, shutil
    app = app_helper.setup_app_state('sra')
    shutil.copy('example_data/tasks/short_read_assembler.json', app['path'] + '/metadata.json')
    app["api"] = None # Ensure data is not collected from the API
    metadata = util.get_task_metadata("1", app)
    nose.assert_in("id", metadata)


def test_parse_args_with_no_polling_interval_provided():
    args = ["run_image", "5"]
    parsed = util.parse(main.__doc__, args, True)
    nose.assert_in("--polling", parsed)
    nose.assert_equal(parsed["--polling"], '15')


def test_parse_args_with_polling_interval_provided():
    args = ["--polling=1", "run_image", "5"]
    parsed = util.parse(main.__doc__, args, True)
    nose.assert_in("--polling", parsed)
    nose.assert_equal(parsed["--polling"], '1')
