Feature: Running a GAET-based reference assembly benchmark task

  Background:
    Given a clean set of benchmarks
    And no files in the S3 directory "s3://nucleotides-testing/uploads/"
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |


  Scenario: Executing a GAET reference assembly benchmark task
    Given I copy the file "../../example_data/generated_files/reference.fa.gz" to "nucleotides/6/inputs/reference_fasta/6bac51cc35.fa.gz"
    And I copy the file "../../example_data/tasks/gaet_crash_test.json" to "nucleotides/6/metadata.json"
    And I copy the file "../../example_data/generated_files/contigs.fa" to "nucleotides/6/inputs/contig_fasta/de3d9f6d31.fa"
    When I run `nucleotides --polling=1 run-image 6`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz" should exist
    And the file "nucleotides/6/outputs/container_log/1661337965" should exist
    And the file "nucleotides/6/outputs/assembly_metrics/d70c163200" should exist
    And the file "nucleotides/6/benchmark.log" should exist


  Scenario: Posting successful GAET benchmark results
    Given I copy the file "../../example_data/generated_files/cgroup_metrics.json.gz" to "nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz"
    And I copy the file "../../example_data/tasks/gaet.json" to "nucleotides/6/metadata.json"
    And I copy the file "../../example_data/generated_files/gaet_metrics.tsv" to "nucleotides/6/outputs/assembly_metrics/af9bc02c71"
    And I copy the file "../../example_data/generated_files/log.txt" to "nucleotides/6/outputs/container_log/log.txt"
    And I copy the file "../../example_data/biobox/gaet.yaml" to "nucleotides/6/tmp/biobox.yaml"
    When I run `nucleotides post-data 6`
    And I get the url "/tasks/6"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/6/benchmark.log" should exist
    And the S3 bucket "nucleotides-testing" should contain the files:
      | uploads/42/4222372031d3d09abf572f6e87f5ad4e364925f63f521592a96075a9e7fed5a1 |
      | uploads/e0/e0e8af37908fb7c275a9467c3ddbba0994c9a33dbf691496a60f4b0bec975f0a |
      | uploads/f8/f8efa7d0bcace3be05f4fff453e414efae0e7d5f680bf215f8374b0a9fdaf9c4 |
    And the JSON should have the following:
       | complete                                                     | true   |
       | success                                                      | true   |
       | events/0/metrics/reference.size_metrics.cds.n50              | 1287.0 |
       | events/0/metrics/comparison.gene_set_agreement.trna          | 1.0    |
       | events/0/metrics/assembly.gene_count.eukarya_rrna.5_8s_rrna	| 0.0    |
