Feature: Fetching input data files for benchmarking

  Background:
    Given a clean set of benchmarks

  Scenario: Fetching input data from given a nucleotides task ID
    Given the nucleotides directory is available on the path
    When I run the bash command:
      """
      AWS_ACCESS_KEY_ID=$(bundle exec ../plumbing/fetch_credential access_key) \
      AWS_SECRET_ACCESS_KEY=$(bundle exec ../plumbing/fetch_credential secret_key) \
      AWS_DEFAULT_REGION='us-west-1' \
      NUCLEOTIDES_API=${DOCKER_HOST} \
        nucleotides fetch-data --task-id=1
      """
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides-task/1/metadata.json" should exist
    And the file "nucleotides-task/1/metadata.json" should be a valid JSON document
    And the JSON should have the following:
      | id              | 1                                                                  |
      | complete        | false                                                              |
      | benchmark       | "453e406dcee4d18174d4ff623f52dcd8"                                 |
      | type            | "produce"                                                          |
      | image/task      | "default"                                                          |
      | image/name      | "bioboxes/ray"                                                     |
      | image/type      | "short_read_assembler"                                             |
      | image/sha256    | "digest_2"                                                         |
      | inputs/0/url    | "s3://nucleotides-testing/short-read-assembler/reads.fq.gz"        |
      | inputs/0/sha256 | "11948b41d44931c6a25cabe58b138a4fc7ecc1ac628c40dcf1ad006e558fb533" |
      | inputs/0/type   | "short_read_fastq"                                                 |
    And the file "nucleotides-task/1/inputs/0/reads.fq.gz" should exist
