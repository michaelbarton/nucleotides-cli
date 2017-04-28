Feature: Docker images should run as expected when run using `nucleoides run_image`

  Scenario: Executing a benchmark task when the required image has not been pulled
    Given I copy the example data files:
      | tasks/quast_crash_test.json | nucleotides/6/metadata.json |
    And I copy the example data files to their SHA256 named versions:
      | generated_files/contigs.fa      | nucleotides/6/inputs/contig_fasta/              |
      | generated_files/reference.fa.gz | nucleotides/6/inputs/reference_fasta/           |
    And the image "bioboxes/crash-test-biobox" is not installed
    When I run `nucleotides --polling=1 run-image 6`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the file "nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz" should exist
    And the file "nucleotides/6/outputs/container_log/86bbc499b0" should exist
    And the file "nucleotides/6/outputs/assembly_metrics/684281f282" should exist
    And the file "nucleotides/6/benchmark.log" should exist
    And the exit status should be 0

  Scenario: Removing all created files using the `clean-up` command
    When I run `nucleotides fetch-data 1`
    And I run `nucleotides clean-up 1`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the directory "nucleotides/1" should not exist

