Feature: Docker images should run as expected when run using `nucleoides run_image`

  Scenario: Executing a benchmark task when the required image has not been pulled
    Given I copy the file "../data/6bac51cc35ee2d11782e7e31ea1bfd7247de2bfcdec205798a27c820b2810414" to "nucleotides/6/inputs/reference_fasta/6bac51cc35.fa.gz"
    And I copy the file "../data/contigs.fa" to "nucleotides/6/inputs/contig_fasta/7e9f760161"
    And I copy the file "../../example_data/tasks/quast.json" to "nucleotides/6/metadata.json"
    And the image "bioboxes/crash-test-biobox" is not installed
    When I run `nucleotides --polling=1 run-image 6`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the file "nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz" should exist
    And the file "nucleotides/6/outputs/container_log/86bbc499b0" should exist
    And the file "nucleotides/6/outputs/assembly_metrics/684281f282" should exist
    And the file "nucleotides/6/benchmark.log" should exist
    And the exit status should be 0
