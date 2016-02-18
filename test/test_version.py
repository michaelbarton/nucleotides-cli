import nose.tools          as nose
import nucleotides.version as v

def test_get_version():
    nose.assert_equal(len(v.__version__.split('.')), 3)
