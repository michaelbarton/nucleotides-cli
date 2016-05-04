Feature: Reporting useful error messages

  Background:
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |

  Scenario Outline: Reporting errors when environment variables are not set
    Given the nucleotides directory is available on the path
    And I copy the file "../data/container_runtime.json" to "nucleotides/5/outputs/container_runtime_metrics/metrics.json"
    And I copy the file "../data/contigs.fa" to "nucleotides/5/outputs/contig_fasta/5887df3630"
    And the file named "nucleotides/5/metadata.json" with:
      """
      {
          "benchmark": "6151f5ab282d90e4cee404433b271dda",
          "complete": false,
          "id": 5,
          "image": {
              "name": "bioboxes/velvet",
              "sha256": "digest_1",
              "task": "default",
              "type": "short_read_assembler"
          },
          "inputs": [
              {
                  "sha256": "11948b41d44931c6a25cabe58b138a4fc7ecc1ac628c40dcf1ad006e558fb533",
                  "type": "short_read_fastq",
                  "url": "s3://nucleotides-testing/short-read-assembler/reads.fq.gz"
              }
          ],
          "type": "produce"
      }
      """
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
