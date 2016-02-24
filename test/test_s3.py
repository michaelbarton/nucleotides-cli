import tempfile, os.path, boto3

import nose.tools     as nose
import nucleotides.s3 as s3

def assert_s3_file_exists(bucket_name, path):
    bucket = boto3.resource('s3').Bucket(bucket_name)
    objs = list(bucket.objects.filter(Prefix=path))
    if not (len(objs) > 0 and objs[0].key == path):
        nose.assert_true(False, "File not found: s3://{}/{}".format(bucket_name, path))

def delete_s3_file(bucket_name, key):
    boto3.client('s3').delete_object(Bucket=bucket_name, Key=key)

def test_fetch_file():
    src = "s3://nucleotides-testing/short-read-assembler/reference.fa"
    dst = os.path.join(tempfile.mkdtemp(), 'reference.fa')
    s3.fetch_file(src, dst)
    nose.assert_true(os.path.isfile(dst))

def test_post_file():
    import time
    f_name = "nucleotides_client_testing-{}".format(int(round(time.time() * 1000)))
    bucket = "nucleotides-testing"
    dst = "s3://{}/{}".format(bucket, f_name)
    src = tempfile.mkstemp()[1]
    s3.post_file(src, dst)
    assert_s3_file_exists(bucket, f_name)
    delete_s3_file(bucket, f_name)
