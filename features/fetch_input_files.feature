Feature: Fetching input data files for benchmarking

  Background:
    Given a clean set of benchmarks

  Scenario: Fetching input data from given a nucleotides task ID
    Given the nucleotides directory is available on the path
    When I run the bash command:
      """
      NUCLEOTIDES_API=${DOCKER_HOST} nucleotides fetch-data 1
      """
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/1/metadata.json" should exist
    And the file "nucleotides/1/metadata.json" should be a valid JSON document
    And the JSON should have the following:
      | id              | 1                                                                  |
      | complete        | false                                                              |
      | benchmark       | "453e406dcee4d18174d4ff623f52dcd8"                                 |
      | type            | "produce"                                                          |
      | image/task      | "default"                                                          |
      | image/name      | "bioboxes/ray"                                                     |
      | image/type      | "short_read_assembler"                                             |
      | image/sha256    | "digest_2"                                                         |
      | inputs/0/url    | "s3://nucleotides-testing/short-read-assembler/dummy.reads.fq.gz"  |
      | inputs/0/sha256 | "24b5b01b08482053d7d13acd514e359fb0b726f1e8ae36aa194b6ddc07335298" |
      | inputs/0/type   | "short_read_fastq"                                                 |
    And the file "nucleotides/1/inputs/0/dummy.reads.fq.gz" should exist
