Feature: Reporting useful error messages

  Background:
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |


  Scenario Outline: Reporting errors when environment variables are not set
    Given the nucleotides directory is available on the path
    And I copy the file "../../example_data/generated_files/cgroup_metrics.json.gz" to "nucleotides/4/outputs/container_runtime_metrics/metrics.json.gz"
    And I copy the file "../../example_data/generated_files/contigs.fa" to "nucleotides/4/inputs/contig_fasta/de3d9f6d31.fa"
    And I copy the file "../../example_data/tasks/short_read_assembler.json" to "nucleotides/4/metadata.json"
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


  Scenario: Posting a benchmark when the output includes unexpected non-mappable values
    Given I copy the file "../../example_data/generated_files/cgroup_metrics.json.gz" to "nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz"
    And I copy the file "../../example_data/tasks/quast.json" to "nucleotides/6/metadata.json"
    And I copy the file "../../example_data/biobox/quast.yaml" to "nucleotides/6/tmp/biobox.yaml"
    And the directory "nucleotides/6/outputs/assembly_metrics/"
    And I run the bash command:
      """
      sed /NGA50/s/6456/unknown/ ../../example_data/generated_files/quast_metrics.tsv > nucleotides/6/outputs/assembly_metrics/67ba437ffa
      """
    When I run `nucleotides post-data 6`
    And I get the url "/tasks/6"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the JSON should have the following:
       | complete          | true  |
       | success           | false |
       | events/0/metrics  | {}    |
    And the file "nucleotides/6/benchmark.log" should contain:
      """
      Error, unparsable value for nga50: unknown
      """
