import boto3
import nose.tools as nose

def assert_s3_file_exists(bucket_name, path):
    bucket = boto3.resource('s3').Bucket(bucket_name)
    objs = list(bucket.objects.filter(Prefix=path))
    if not (len(objs) > 0 and objs[0].key == path):
        nose.assert_true(False, "File not found: s3://{}/{}".format(bucket_name, path))

def delete_s3_file(bucket_name, key):
    boto3.client('s3').delete_object(Bucket=bucket_name, Key=key)

