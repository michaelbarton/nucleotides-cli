import boto3, urlparse
import boto3.s3.transfer as trn

def fetch_file(src, dst):
    s3 = trn.S3Transfer(boto3.client('s3'))
    location = urlparse.urlparse(src)
    _, file_ = location.path.split('/', 1)
    bucket   = location.netloc
    s3.download_file(bucket, file_, dst)
