Feature: Fetching input data files for benchmarking

  Background:
    Given a clean set of benchmarks

  Scenario: Fetching input data from given a nucleotides task ID
    Given the nucleotides directory is available on the path
    When I run the bash command:
      """
      nucleotides fetch-data 9
      """
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/9/metadata.json" should exist
    And the file "nucleotides/9/metadata.json" should be a valid JSON document
    And the JSON should have the following:
      | id              | 9                                                                  |
      | complete        | false                                                              |
      | benchmark       | "4f57d0ecf9622a0bd8a6e3f79c71a09d"                                 |
      | type            | "produce"                                                          |
      | image/task      | "careful"                                                          |
      | image/name      | "bioboxes/velvet"                                                  |
      | image/type      | "short_read_assembler"                                             |
      | image/sha256    | "digest_1"                                                         |
      | inputs/0/url    | "s3://nucleotides-testing/short-read-assembler/dummy.reads.fq.gz"  |
      | inputs/0/sha256 | "24b5b01b08482053d7d13acd514e359fb0b726f1e8ae36aa194b6ddc07335298" |
      | inputs/0/type   | "short_read_fastq"                                                 |
    And the file "nucleotides/9/inputs/short_read_fastq/dummy.reads.fq.gz" should exist
