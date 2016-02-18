import tempfile, os.path

import nose.tools     as nose
import nucleotides.s3 as s3

def test_fetch_file():
    src = "s3://nucleotides-testing/short-read-assembler/reference.fa"
    dst = os.path.join(tempfile.mkdtemp(), 'reference.fa')
    s3.fetch_file(src, dst)
    nose.assert_true(os.path.isfile(dst))
