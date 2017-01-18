Feature: Processing a short read assembly benchmark

  Background:
    Given a clean set of benchmarks
    And no files in the S3 directory "s3://nucleotides-testing/uploads/"
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |
    And I copy the file "../../example_data/tasks/short_read_assembler.json" to "nucleotides/5/metadata.json"


  Scenario: Executing a short read assembler docker image
    Given the default aruba exit timeout is 900 seconds
    And I copy the file "../data/11948b41d44931c6a25cabe58b138a4fc7ecc1ac628c40dcf1ad006e558fb533" to "nucleotides/5/inputs/short_read_fastq/11948b41d4.fq.gz"
    When I run `nucleotides run-image 5`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/5/outputs/contig_fasta/01eb7cec61" should exist
    And the file "nucleotides/5/outputs/container_runtime_metrics/metrics.json.gz" should exist
    And the file "nucleotides/5/outputs/container_log/1099992390" should exist
    And the file "nucleotides/5/benchmark.log" should exist


  Scenario: Posting a successful benchmark
    Given I copy the file "../../data/cgroup_metrics.json.gz" to "nucleotides/5/outputs/container_runtime_metrics/metrics.json.gz"
    And I copy the file "../../data/log.txt" to "nucleotides/5/outputs/container_log/log.txt"
    And I copy the file "../data/contigs.fa" to "nucleotides/5/outputs/contig_fasta/5887df3630"
    When I run `nucleotides post-data 5`
    And I get the url "/tasks/5"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the S3 bucket "nucleotides-testing" should contain the files:
      | uploads/7e/7e9f760161e13ffdd4f81fdfec2222ccd3c568f4abcbcadcb10487d43b2a0092 |
      | uploads/e0/e0e8af37908fb7c275a9467c3ddbba0994c9a33dbf691496a60f4b0bec975f0a |
      | uploads/f8/f8efa7d0bcace3be05f4fff453e414efae0e7d5f680bf215f8374b0a9fdaf9c4 |
    And the JSON should have the following:
      | complete                                                  | true                        |
      | success                                                   | true                        |
      | events/0/metrics/total_cpu_usage_in_seconds               | 53.546                      |
      | events/0/metrics/total_cpu_usage_in_seconds_in_kernelmode | 1.75                        |
      | events/0/metrics/total_cpu_usage_in_seconds_in_usermode   | 11.11                       |
      | events/0/metrics/total_memory_usage_in_mibibytes          | 175.348                     |
      | events/0/metrics/total_rss_in_mibibytes                   | 80.543                      |
      | events/0/metrics/total_read_io_in_mibibytes               | 38.641                      |
      | events/0/metrics/total_write_io_in_mibibytes              | 0.0                         |
      | events/0/metrics/total_wall_clock_time_in_seconds         | 0.0                         |
      | events/0/files/0/type                                     | "container_log"             |
      | events/0/files/1/type                                     | "container_runtime_metrics" |
      | events/0/files/2/type                                     | "contig_fasta"              |
    And the file "nucleotides/5/benchmark.log" should exist


  Scenario: Posting a failed benchmark
    Given I copy the file "../../data/cgroup_metrics.json.gz" to "nucleotides/5/outputs/container_runtime_metrics/metrics.json.gz"
    And I copy the file "../../data/log.txt" to "nucleotides/5/outputs/container_log/log.txt"
    When I run `nucleotides post-data 5`
    And I get the url "/tasks/5"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the S3 bucket "nucleotides-testing" should contain the files:
      | uploads/f8/f8efa7d0bcace3be05f4fff453e414efae0e7d5f680bf215f8374b0a9fdaf9c4 |
    And the JSON should have the following:
      | success                                                   | false                       |
      | complete                                                  | true                        |
      | events/0/metrics/total_cpu_usage_in_seconds               | 53.546                      |
      | events/0/metrics/total_cpu_usage_in_seconds_in_kernelmode | 1.75                        |
      | events/0/metrics/total_cpu_usage_in_seconds_in_usermode   | 11.11                       |
      | events/0/metrics/total_memory_usage_in_mibibytes          | 175.348                     |
      | events/0/metrics/total_rss_in_mibibytes                   | 80.543                      |
      | events/0/metrics/total_read_io_in_mibibytes               | 38.641                      |
      | events/0/metrics/total_write_io_in_mibibytes              | 0.0                         |
      | events/0/metrics/total_wall_clock_time_in_seconds         | 0.0                         |
      | events/0/files/0/type                                     | "container_log"             |
      | events/0/files/1/type                                     | "container_runtime_metrics" |
    And the file "nucleotides/5/benchmark.log" should exist

  Scenario: Posting a benchmark with missing cgroup data
    Given I copy the file "../../data/cgroup_metrics_incomplete.json.gz" to "nucleotides/5/outputs/container_runtime_metrics/metrics.json.gz"
    And I copy the file "../../data/log.txt" to "nucleotides/5/outputs/container_log/log.txt"
    And I copy the file "../data/contigs.fa" to "nucleotides/5/outputs/contig_fasta/5887df3630"
    When I run `nucleotides post-data 5`
    And I get the url "/tasks/5"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the S3 bucket "nucleotides-testing" should contain the files:
      | uploads/7e/7e9f760161e13ffdd4f81fdfec2222ccd3c568f4abcbcadcb10487d43b2a0092 |
      | uploads/e0/e0e8af37908fb7c275a9467c3ddbba0994c9a33dbf691496a60f4b0bec975f0a |
      | uploads/1c/1c4bdb15285e6ee5be63753fcbae5148cffce29dd7745f82e4ea763634f6e70b |
    And the JSON should have the following:
      | success                                     | true   |
      | complete                                    | true   |
      | events/0/metrics/total_cpu_usage_in_seconds | 53.546 |
    And the JSON response should not have "events/0/metrics/total_rss_in_mibibytes"
    And the file "nucleotides/5/benchmark.log" should exist
