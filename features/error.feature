Feature: Reporting useful error messages

  Background:
    Given a clean set of benchmarks
    And no files in the S3 directory "s3://nucleotides-testing/uploads/"
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |


  Scenario Outline: Reporting errors when environment variables are not set
    Given the nucleotides directory is available on the path
    And I copy the example data files:
      | tasks/short_read_assembler.json | nucleotides/4/metadata.json |
      | generated_files/cgroup_metrics.json.gz | nucleotides/4/outputs/container_runtime_metrics/metrics.json.gz |
    And I copy the example data files to their SHA256 named versions:
      | generated_files/contigs.fa             | nucleotides/4/outputs/contig_fasta/              |
    When I run the bash command:
      """
      unset <variable> && nucleotides post-data 4
      """
    Then the stdout should not contain anything
    And the exit status should be 1
    And the stderr should contain:
      """
      Missing environment variable: <variable>
      """

    Examples:
      | variable           |
      | NUCLEOTIDES_S3_URL |
      | NUCLEOTIDES_API    |


  Scenario: Executing a short read assembly task that fails whilst producing a log
    Given the default aruba exit timeout is 180 seconds
    When I run `nucleotides all 4`
    And I get the url "/tasks/4"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the JSON should have the following:
      | complete               | true                        |
      | success                | false                       |
      | events/0/files/0/type  | "container_log"             |
      | events/0/files/1/type  | "container_runtime_metrics" |


  Scenario: Executing a short read assembly task that fails without producing a log
    Given the default aruba exit timeout is 180 seconds
    When I run `nucleotides all 7`
    And I get the url "/tasks/7"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the JSON should have the following:
      | complete               | true                        |
      | success                | false                       |
      | events/0/files/0/type  | "container_runtime_metrics" |


