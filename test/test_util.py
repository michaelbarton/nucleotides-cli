import os
import helper.application as app_helper
import helper.file        as file_helper
import nose.tools         as nose
import nucleotides.main   as main
import nucleotides.util   as util

def test_get_task_metadata_with_no_metadata_json():
    app = app_helper.mock_short_read_assembler_state(task = False)
    metadata = util.get_task_metadata("1", app)
    nose.assert_in("id", metadata)
    file_helper.assert_is_file(app["path"] + "/metadata.json")

def test_get_task_metadata_with_existing_metadata_json():
    import json, shutil
    app = app_helper.mock_short_read_assembler_state(task = False)
    shutil.copy('example_data/tasks/short_read_assembler.json', app['path'] + '/metadata.json')
    app["api"] = None # Ensure data is not collected from the API
    metadata = util.get_task_metadata("1", app)
    nose.assert_in("id", metadata)
