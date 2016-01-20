Feature: Fetching input data files for benchmarking

  Scenario: Fetching input data from given a nucleotides task ID
    Given the ncle directory is available on the path
    When I run the bash command:
      """
      AWS_ACCESS_KEY=$(../plumbing/fetch_credential access_key) \
      AWS_SECRET_KEY=$(../plumbing/fetch_credential secret_key) \
      AWS_REGION='us-west-1' \
      NUCLEOTIDES_API=${DOCKER_HOST} \
        nucleotides fetch-data --task-id=1
      """
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides-task/1/input/reads.fq.gz" should exist
    And the file "nucleotides-task/1/metadata.json" should contain:
      """
      {
      "id": 1,
      "task_type": "produce",
      "image_task": "careful",
      "image_sha256": "6611675a6d3755515592aa71932bd4ea4c26bccad34fae7a3ec1198ddcccddad",
      "image_name": "bioboxes/velvet",
      "image_type": "short_read_assembler",
      "input_url": "s3://nucleotid-es/test-data/0001/0001/2000000/1/reads.fq.gz",
      "input_md5": "eaa5305f8d0debbce934975c3ec6c14b"
      }
