Feature: Use the `all` sub-command to execute all steps in benchmarking with realistic data

  Background:
    Given a clean set of benchmarks
    And no files in the S3 directory "s3://nucleotides-testing/uploads/"
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |

  Scenario: A complete run through of an assembler benchmark
    Given the default aruba exit timeout is 900 seconds
    When I run `nucleotides all 1`
    And I run `nucleotides all 2`
    And I run `nucleotides all 3`
    And I get the url "/benchmarks/2f221a18eb86380369570b2ed147d8b4"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the JSON should have the following:
      | complete | true |
      | success  | true |

    # Assembly step URLs and digests
    And the JSON should have the following:
      | tasks/0/events/0/metrics/total_cpu_usage_in_seconds  |
      | tasks/0/events/0/files/0/url                         |
      | tasks/0/events/0/files/0/sha256                      |

    # Assembly step files and metrics
    And the JSON should have the following:
      | tasks/0/events/0/files/0/type  | "container_log"             |
      | tasks/0/events/0/files/1/type  | "container_runtime_metrics" |
      | tasks/0/events/0/files/2/type  | "contig_fasta"              |

    # QUAST step files and metrics
    And the JSON should have the following:
      | tasks/1/events/0/files/0/type  | "assembly_metrics"          |
      | tasks/1/events/0/files/1/type  | "container_log"             |
      | tasks/1/events/0/files/2/type  | "container_runtime_metrics" |
      | tasks/1/events/0/metrics/nga50 | 6456.0                      |
    And the directory "nucleotides/1" should not exist
    And the directory "nucleotides/2" should not exist
    And the directory "nucleotides/3" should not exist
