Feature: Docker images should run as expected when run using `nucleoides run_image`

  Scenario: Executing a benchmark task when the required image has not been pulled
    Given I copy the file "../../example_data/generated_files/reference.fa.gz" to "nucleotides/6/inputs/reference_fasta/6bac51cc35.fa.gz"
    And I copy the file "../../example_data/generated_files/contigs.fa" to "nucleotides/6/inputs/contig_fasta/de3d9f6d31.fa"
    And I copy the file "../../example_data/tasks/quast_crash_test.json" to "nucleotides/6/metadata.json"
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

