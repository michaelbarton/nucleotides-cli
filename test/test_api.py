import os
import nose.tools as nose

import helper
import nucleotides.api_client as api


def test_fetch_task_from_valid_url():
    response = api.fetch_task(os.environ["DOCKER_HOST"], "1")
    nose.assert_in("id", response)
    nose.assert_equal(response["id"], 1)

@nose.raises(IOError)
def test_fetch_task_from_invalid_url():
    response = api.fetch_task("example.com", "1")
