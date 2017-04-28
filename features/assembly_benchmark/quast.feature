Feature: Running a QUAST-based reference assembly benchmark task

  Background:
    Given a clean set of benchmarks
    And no files in the S3 directory "s3://nucleotides-testing/uploads/"
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |


  Scenario: Executing a QUAST reference assembly benchmark task
    Given I copy the example data files:
      | tasks/quast_crash_test.json | nucleotides/6/metadata.json |
    And I copy the example data files to their SHA256 named versions:
      | generated_files/contigs.fa             | nucleotides/6/inputs/contig_fasta/              |
      | generated_files/reference.fa.gz        | nucleotides/6/inputs/reference_fasta/           |
    And I copy the example data files:
      | generated_files/cgroup_metrics.json.gz | nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz |
    When I run `nucleotides --polling=1 run-image 6`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz" should exist
    And the file "nucleotides/6/outputs/container_log/86bbc499b0" should exist
    And the file "nucleotides/6/outputs/assembly_metrics/684281f282" should exist
    And the file "nucleotides/6/benchmark.log" should exist


  Scenario: Executing a QUAST reference assembly benchmark task when there are no contigs
    # When the contigs are empty because none were generated or because they
    # were all too small and filtered out, then the client should not try to run the
    # image. The client should instead skip trying to run the container.
    Given the empty file "nucleotides/4/inputs/contig_fasta/0000000000.fa"
    And I copy the example data files:
      | tasks/quast_crash_test.json | nucleotides/4/metadata.json |
    And I copy the example data files to their SHA256 named versions:
      | generated_files/reference.fa.gz | nucleotides/4/inputs/reference_fasta/ |
    When I run `nucleotides --polling=1 run-image 4`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the directory "nucleotides/4/outputs/container_runtime_metrics/" should not exist
    And the directory "nucleotides/4/outputs/assembly_metrics/" should not exist
    And the directory "nucleotides/4/outputs/container_log/" should not exist
    And the file "nucleotides/4/benchmark.log" should exist


  Scenario: Posting successful QUAST benchmark results
    Given I copy the example data files:
      | tasks/quast.json  | nucleotides/6/metadata.json   |
      | biobox/quast.yaml | nucleotides/6/tmp/biobox.yaml |
      | generated_files/cgroup_metrics.json.gz | nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz |
    And I copy the example data files to their SHA256 named versions:
      | generated_files/log.txt                | nucleotides/6/outputs/container_log/             |
      | generated_files/quast_metrics.tsv      | nucleotides/6/outputs/assembly_metrics/          |
    When I run `nucleotides post-data 6`
    And I get the url "/tasks/6"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/6/benchmark.log" should exist
    And the S3 bucket "nucleotides-testing" should contain the files:
      | uploads/f8/f8efa7d0bcace3be05f4fff453e414efae0e7d5f680bf215f8374b0a9fdaf9c4 |
      | uploads/63/63d2a18fa1f1ecfc62bb0b6cc73007a735990e6d8c42c3bd36656ad0b25acb3e |
      | uploads/e0/e0e8af37908fb7c275a9467c3ddbba0994c9a33dbf691496a60f4b0bec975f0a |
    And the JSON should have the following:
      | complete                              | true                        |
      | success                               | true                        |
      | events/0/metrics/duplication_ratio    | 1.007                       |
      | events/0/metrics/l50                  | 31.0                        |
      | events/0/metrics/lga75                | 70.0                        |
      | events/0/metrics/total_aligned_length | 679979.0                    |
      | events/0/files/0/type                 | "assembly_metrics"          |
      | events/0/files/1/type                 | "container_log"             |
      | events/0/files/2/type                 | "container_runtime_metrics" |


  Scenario: Posting a benchmark when the QUAST output includes non numeric values
    Given I copy the example data files:
      | tasks/quast.json  | nucleotides/6/metadata.json   |
      | biobox/quast.yaml | nucleotides/6/tmp/biobox.yaml |
      | generated_files/cgroup_metrics.json.gz              | nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz |
    And I copy the example data files to their SHA256 named versions:
      | generated_files/log.txt                | nucleotides/6/outputs/container_log/             |
    And the directory "nucleotides/6/outputs/assembly_metrics/"
    And I run the bash command:
      """
      sed /NGA50/s/6456/-/ ../../example_data/generated_files/quast_metrics.tsv > nucleotides/6/outputs/assembly_metrics/67ba437ffa
      """
    When I run `nucleotides post-data 6`
    And I get the url "/tasks/6"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the JSON should have the following:
       | events/0/metrics/nga50  | 0.0  |
       | complete                | true |
       | success                 | true |


  Scenario: Posting a benchmark when QUAST was unable to calculate any alignments
    Given I copy the example data files:
      | tasks/quast.json  | nucleotides/6/metadata.json   |
      | biobox/quast.yaml | nucleotides/6/tmp/biobox.yaml |
      | generated_files/cgroup_metrics.json.gz | nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz |
    And I copy the example data files to their SHA256 named versions:
      | generated_files/log.txt                             | nucleotides/6/outputs/container_log/             |
      | generated_files/quast_metrics_alignment_missing.tsv | nucleotides/6/outputs/assembly_metrics/          |
    When I run `nucleotides post-data 6`
    And I get the url "/tasks/6"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the JSON should have the following:
      | complete         | true  |
      | success          | false |
      | events/0/metrics | {}    |


  Scenario: Posting a QUAST benchmark when the output includes non-mappable values
    Given I copy the example data files:
      | tasks/quast.json  | nucleotides/6/metadata.json   |
      | biobox/quast.yaml | nucleotides/6/tmp/biobox.yaml |
      | generated_files/cgroup_metrics.json.gz | nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz |
    And I copy the example data files to their SHA256 named versions:
      | generated_files/log.txt                             | nucleotides/6/outputs/container_log/             |
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
