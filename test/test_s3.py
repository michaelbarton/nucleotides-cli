import tempfile, os.path

import nose.tools     as nose
import helper.s3      as s3_helper
import helper.file    as file_helper
import nucleotides.s3 as s3

def test_fetch_file():
    src = "s3://nucleotides-testing/short-read-assembler/reference.fa"
    dst = os.path.join(tempfile.mkdtemp(), 'reference.fa')
    s3.fetch_file(src, dst)
    file_helper.assert_is_file(dst)

def test_post_file():
    import time
    f_name = "nucleotides_client_testing-{}".format(int(round(time.time() * 1000)))
    bucket = "nucleotides-testing"
    dst = "s3://{}/{}".format(bucket, f_name)
    src = tempfile.mkstemp()[1]
    s3.post_file(src, dst)
    s3_helper.assert_s3_file_exists(bucket, f_name)
    s3_helper.delete_s3_file(bucket, f_name)
