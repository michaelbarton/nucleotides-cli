import os, shutil
import nose.tools as nose

import nucleotides.command.fetch_data as fetch
import nucleotides.util               as util

os.environ["NUCLEOTIDES_API"] = os.environ["DOCKER_HOST"]

def test_docstring_parse():
    nose.assert_equal(util.parse(fetch.__doc__, ["fetch-data", "1"]),
            {'<task>': '1', 'fetch-data': True})

def test_create_benchmark_dir():
    fetch.create_benchmark_dir("1")
    exists = os.path.isfile("nucleotides-task/1/metadata.json")
    shutil.rmtree("nucleotides-task")
    nose.assert_true(exists)
