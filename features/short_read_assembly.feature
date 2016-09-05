Feature: Processing a short read assembly benchmark

  Background:
    Given a clean set of benchmarks
    And no files in the S3 directory "s3://nucleotides-testing/uploads/"
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |
    And I copy the file "../../data/short_read_assembler.json" to "nucleotides/5/metadata.json"


  Scenario: Executing a short read assembler docker image
    Given I copy the file "../data/11948b41d44931c6a25cabe58b138a4fc7ecc1ac628c40dcf1ad006e558fb533" to "nucleotides/5/inputs/short_read_fastq/11948b41d4.fq.gz"
    When I run `nucleotides run-image 5`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/5/outputs/contig_fasta/7e9f760161" should exist
    And the file "nucleotides/5/outputs/container_runtime_metrics/metrics.json" should exist
    And the file "nucleotides/5/outputs/container_log/log.txt" should exist


  Scenario: Posting a successful benchmark
    Given I copy the file "../../data/cgroup_metrics.json.xz" to "nucleotides/5/outputs/container_runtime_metrics/metrics.json.xz"
    And I copy the file "../../data/log.txt" to "nucleotides/5/outputs/container_log/log.txt"
    And I copy the file "../data/contigs.fa" to "nucleotides/5/outputs/contig_fasta/5887df3630"
    When I run `nucleotides post-data 5`
    And I get the url "/tasks/5"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the S3 bucket "nucleotides-testing" should contain the files:
      | uploads/7e/7e9f760161e13ffdd4f81fdfec2222ccd3c568f4abcbcadcb10487d43b2a0092 |
      | uploads/c7/c7865010ffd5c1d91c5cc8b56ff3c6694fa143806ce5687cca77f0366674ee8d |
      | uploads/e0/e0e8af37908fb7c275a9467c3ddbba0994c9a33dbf691496a60f4b0bec975f0a |
    And the JSON should have the following:
      | complete                                          | true                        |
      | events/0/metrics/max_memory_usage                 | 183865344.0                 |
      | events/0/metrics/max_cpu_usage                    | 53545596799.0               |
      | events/0/metrics/total_wall_clock_time_in_seconds | 15.0                        |
      | events/0/files/0/type                             | "container_log"             |
      | events/0/files/1/type                             | "container_runtime_metrics" |
      | events/0/files/2/type                             | "contig_fasta"              |


  Scenario: Posting a failed benchmark
    Given I copy the file "../data/metrics.json" to "nucleotides/5/outputs/container_runtime_metrics/metrics.json"
    And I copy the file "../../data/log.txt" to "nucleotides/5/outputs/container_log/log.txt"
    When I run `nucleotides post-data 5`
    And I get the url "/tasks/5"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the S3 bucket "nucleotides-testing" should contain the files:
      | uploads/20/202313628063e33c1ba8320927357be02660f0b0b6b02a63cd5f256337a7e408 |
    And the JSON should have the following:
      | complete                                          | false                       |
      | events/0/metrics/max_memory_usage                 | 20.0                        |
      | events/0/metrics/max_cpu_usage                    | 80.0                        |
      | events/0/metrics/total_wall_clock_time_in_seconds | 30.0                        |
      | events/0/files/0/type                             | "container_log"             |
      | events/0/files/1/type                             | "container_runtime_metrics" |
