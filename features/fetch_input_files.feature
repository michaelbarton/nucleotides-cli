Feature: Fetching input data files for benchmarking

  Background:
    Given a clean set of benchmarks
    And no files in the S3 directory "s3://nucleotides-testing/uploads/"

  Scenario: Fetching input data from given a nucleotides task ID
    Given the nucleotides directory is available on the path
    When I run the bash command:
      """
      nucleotides fetch-data 3
      """
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/3/metadata.json" should exist
    And the file "nucleotides/3/metadata.json" should be a valid JSON document
    And the JSON should have the following:
      | id              | 3                                                                  |
      | complete        | false                                                              |
      | benchmark       | "4f57d0ecf9622a0bd8a6e3f79c71a09d"                                 |
      | type            | "produce"                                                          |
      | image/task      | "careful"                                                          |
      | image/name      | "bioboxes/velvet"                                                  |
      | image/type      | "short_read_assembler"                                             |
      | image/sha256    | "6611675a6d3755515592aa71932bd4ea4c26bccad34fae7a3ec1198ddcccddad" |
      | inputs/0/url    | "s3://nucleotides-testing/short-read-assembler/dummy.reads.fq.gz"        |
      | inputs/0/sha256 | "11948b41d44931c6a25cabe58b138a4fc7ecc1ac628c40dcf1ad006e558fb533" |
      | inputs/0/type   | "short_read_fastq"                                                 |
    And the file "nucleotides/3/inputs/short_read_fastq/dummy.reads.fq.gz" should exist
