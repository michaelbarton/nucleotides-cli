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

    # GAET step files and metrics
    And the JSON should have the following:
       | tasks/2/events/0/files/0/type | "assembly_metrics"          |
       | tasks/2/events/0/files/1/type | "container_log"             |
       | tasks/2/events/0/files/2/type | "container_runtime_metrics" |
    And the JSON should have the following:
       | tasks/2/events/0/metrics/comparison.gene_type_distance.cds.n_symmetric_difference |
       | tasks/2/events/0/metrics/assembly.minimum_gene_set.single_copy                    |

    And the directory "nucleotides/1" should not exist
    And the directory "nucleotides/2" should not exist
    And the directory "nucleotides/3" should not exist


  Scenario: Executing a reference assembly task when the input contig file is empty
    # An contig fasta file with a single too-short contig is posted to the API as
    # the output of a short read assembly task. The corresponding reference assembly
    # evaluation tasks should then complete without error and mark their tasks as
    # unsuccessful
    Given I copy the example data files:
      | tasks/short_read_assembler.json        | nucleotides/4/metadata.json                      |
      | generated_files/cgroup_metrics.json.gz | nucleotides/4/outputs/container_runtime_metrics/metrics.json.gz |
    And I copy the example data files to their SHA256 named versions:
      | generated_files/one_short_contig.fa    | nucleotides/4/outputs/contig_fasta/              |
      | generated_files/log.txt                | nucleotides/4/outputs/container_log/             |
    And I run `nucleotides post-data 4`
    When I run `nucleotides all 5`
    When I run `nucleotides all 6`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And I get the url "/benchmarks/4f57d0ecf9622a0bd8a6e3f79c71a09d"
    And the JSON should have the following:
      | tasks/0/complete | true  |
      | tasks/0/success  | true  |
      | tasks/1/complete | true  |
      | tasks/1/success  | false |
      | tasks/2/complete | true  |
      | tasks/2/success  | false |
      | complete         | true  |
      | success          | false |
