import os
import helper.application as app_helper
import helper.file        as file_helper
import nose.tools         as nose
import nucleotides.main   as main
import nucleotides.util   as util

def test_parse_args():
    nose.assert_equal(util.parse(main.__doc__, ["fetch-data", "1"]),
            {'<task>': "1", '<command>': 'fetch-data', '<args>' : []})

def test_get_task_metadata_with_no_metadata_json():
    app = app_helper.mock_application_state(task = False)
    metadata = util.get_task_metadata("1", app)
    nose.assert_in("id", metadata)
    file_helper.assert_is_file(app["path"] + "/metadata.json")

def test_get_task_metadata_with_existing_metadata_json():
    import json
    app = app_helper.mock_application_state(task = False)
    with open(app['path'] + '/metadata.json', 'w') as f:
        f.write(json.dumps(app_helper.sample_benchmark_task()))
    app["api"] = None # Ensure data is not collected from the API
    metadata = util.get_task_metadata("1", app)
    nose.assert_in("id", metadata)
