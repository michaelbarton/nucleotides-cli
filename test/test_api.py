import os
import nose.tools as nose

import helper
import nucleotides.api_client as api

os.environ["NUCLEOTIDES_API"] = os.environ["DOCKER_HOST"]

def test_fetch_task():
    response = api.fetch_task("1")
    nose.assert_in("id", response)
    nose.assert_equal(response["id"], 1)
