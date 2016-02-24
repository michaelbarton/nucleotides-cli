import os
import nose.tools             as nose
import helper.application     as app_helper
import helper.db              as db_helper
import nucleotides.api_client as api

def test_fetch_task_from_valid_url():
    db_helper.reset_database()
    response = api.fetch_task("1", app_helper.test_application_state())
    nose.assert_in("id", response)
    nose.assert_equal(response["id"], 1)

@nose.raises(IOError)
def test_fetch_task_from_invalid_url():
    app = app_helper.test_application_state()
    app["api"] = "localhost:98765"
    response = api.fetch_task("1", app)
