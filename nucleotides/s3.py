def s3():
    import boto3, boto3.s3.transfer
    return boto3.s3.transfer.S3Transfer(boto3.client('s3'))

def parse_s3_url(url):
    import urlparse
    location = urlparse.urlparse(url)
    _, key = location.path.split('/', 1)
    bucket = location.netloc
    return [bucket, key]

def fetch_file(src, dst):
    bucket, key = parse_s3_url(src)
    s3().download_file(bucket, key, dst)

def post_file(src, dst):
    bucket, key = parse_s3_url(dst)
    s3().upload_file(src, bucket, key)
