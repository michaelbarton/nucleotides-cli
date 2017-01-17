Feature: Fetching input data files for benchmarking

  Background:
    Given a clean set of benchmarks
    And no files in the S3 directory "s3://nucleotides-testing/uploads/"

  Scenario: Fetching input data files for short read assembly task
    When I run `nucleotides fetch-data 1`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/1/metadata.json" should exist
    And the file "nucleotides/1/metadata.json" should be a valid JSON document
    And the file "nucleotides/1/benchmark.log" should exist
    And the JSON should have the following:
       | id              | 1                                                                                                                |
       | complete        | false                                                                                                            |
       | success         | false                                                                                                            |
       | benchmark       | "2f221a18eb86380369570b2ed147d8b4"                                                                               |
       | type            | "produce"                                                                                                        |
       | image/task      | "default"                                                                                                        |
       | image/name      | "bioboxes/tadpole"                                                                                               |
       | image/type      | "short_read_assembler"                                                                                           |
       | image/sha256    | "a8f03646039e9264265ec5e04dff5a6e88326b67c7a4178ee50057ecaaa14943"                                               |
       | inputs/0/url    | "s3://nucleotides-testing/short-read-assembler/11948b41d44931c6a25cabe58b138a4fc7ecc1ac628c40dcf1ad006e558fb533" |
       | inputs/0/sha256 | "11948b41d44931c6a25cabe58b138a4fc7ecc1ac628c40dcf1ad006e558fb533"                                               |
       | inputs/0/type   | "short_read_fastq"                                                                                               |
    And the file "nucleotides/1/inputs/short_read_fastq/11948b41d44931c6a25cabe58b138a4fc7ecc1ac628c40dcf1ad006e558fb533.fq.gz" should exist


  Scenario: Fetching input data files for assembly benchmarking task
    When I run `nucleotides fetch-data 2`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/2/inputs/reference_fasta/6bac51cc35ee2d11782e7e31ea1bfd7247de2bfcdec205798a27c820b2810414.fa.gz" should exist
    And the file "nucleotides/2/benchmark.log" should exist
