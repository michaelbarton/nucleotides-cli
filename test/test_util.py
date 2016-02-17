import nose.tools       as nose
import nucleotides.main as main
import nucleotides.util as util

def test_parse_args():
    nose.assert_equal(util.parse(main.__doc__, ["fetch-data", "--task-id=1"]),
            {'<args>': ['--task-id=1'], '<command>': 'fetch-data'})

