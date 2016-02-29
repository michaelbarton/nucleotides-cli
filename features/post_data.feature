Feature: Post generated data back to nucleotides API

  Background:
    Given a clean set of benchmarks
    And no files in the S3 directory "s3://nucleotides-testing/upload/"
    And the nucleotides directory is available on the path
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
    And the file named "nucleotides/5/outputs/container_runtime_metrics/metrics.json" with:
      """
      [
        {"memory_stats": {"stats" : {"rss" : 10}}, "cpu_stats" : {"cpu_usage" : {"total_usage" : 40}}},
        {"memory_stats": {"stats" : {"rss" : 20}}, "cpu_stats" : {"cpu_usage" : {"total_usage" : 80}}}
      ]
      """

  Scenario: Posting a successful benchmark
    And the file "nucleotides/5/outputs/contig_fasta/5887df3630" with:
      """
      >NODE_1_length_240_cov_20
      CCACGGCTGTCCCCAGCCGTGTTTGCATCTGGCAAGGGCTACACTCTGCTGGGCGGCACA
      CACGGCATGCGATGGTTCGCTTGTCACTTGAAACTTCTAAACGCTGCGATCAGTAGACTC
      CAGGCCTCCCTGAAAACTGCCTGTGAACCGAAAAAACCCGAGTTCCAGTCTGCACTAAAA
      CTCGGGTTATCCTTATCTGCTAACCAAGTTCATCGCGCACCCCTGCGCAACAAACGAAAC
      """
    When I run the bash command:
      """
      nucleotides post-data 5 --s3-upload=s3://nucleotides-testing/uploads/
      """
    And I get the url "/tasks/5"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the S3 bucket "nucleotides-testing" should contain the files:
      | uploads/58/5887df363024aea48765075ea9bdb232a0f9f206b80324e7c8b18ed764dde529 |
    And the JSON should have the following:
      | complete                               | true |
      | events/0/metrics/max_resident_set_size | 20.0 |
      | events/0/metrics/max_cpu_usage         | 80.0 |

  Scenario: Posting a failed benchmark
    When I run the bash command:
      """
      nucleotides post-data 5 --s3-upload=s3://nucleotides-testing/uploads/
      """
    And I get the url "/tasks/5"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the JSON should have the following:
      | complete                               | false |
      | events/0/metrics/max_resident_set_size | 20.0  |
      | events/0/metrics/max_cpu_usage         | 80.0  |
