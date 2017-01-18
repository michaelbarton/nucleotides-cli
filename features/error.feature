Feature: Reporting useful error messages

  Background:
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |

  Scenario Outline: Reporting errors when environment variables are not set
    Given the nucleotides directory is available on the path
    And I copy the file "../../example_data/generated_files/cgroup_metrics.json.gz" to "nucleotides/5/outputs/container_runtime_metrics/metrics.json.gz"
    And I copy the file "../data/contigs.fa" to "nucleotides/5/outputs/contig_fasta/5887df3630"
    And I copy the file "../../example_data/tasks/short_read_assembler.json" to "nucleotides/5/metadata.json"
    When I run the bash command:
      """
      unset <variable> && nucleotides post-data 5
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
