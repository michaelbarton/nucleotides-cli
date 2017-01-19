Feature: Running a GAET-based reference assembly benchmark task

  Background:
    Given a clean set of benchmarks
    And no files in the S3 directory "s3://nucleotides-testing/uploads/"
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |
    And I copy the file "../../example_data/tasks/gaet.json" to "nucleotides/6/metadata.json"


  Scenario: Executing a GAET reference assembly benchmark task
    Given I copy the file "../data/6bac51cc35ee2d11782e7e31ea1bfd7247de2bfcdec205798a27c820b2810414" to "nucleotides/6/inputs/reference_fasta/6bac51cc35.fa.gz"
    And I copy the file "../data/contigs.fa" to "nucleotides/6/inputs/contig_fasta/7e9f760161.fa"
    When I run `nucleotides --polling=1 run-image 6`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz" should exist
    And the file "nucleotides/6/outputs/container_log/1661337965" should exist
    And the file "nucleotides/6/outputs/assembly_metrics/b0eeec7906" should exist
    And the file "nucleotides/6/benchmark.log" should exist
