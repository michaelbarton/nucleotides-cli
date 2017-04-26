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
    And I copy the file "../../example_data/generated_files/gaet_metrics.tsv" to "nucleotides/6/outputs/assembly_metrics/a5c753ccb2"
    And I copy the file "../../example_data/generated_files/log.txt" to "nucleotides/6/outputs/container_log/log.txt"
    And I copy the file "../../example_data/biobox/gaet.yaml" to "nucleotides/6/tmp/biobox.yaml"
    When I run `nucleotides post-data 6`
    And I get the url "/tasks/6"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/6/benchmark.log" should exist
    And the S3 bucket "nucleotides-testing" should contain the files:
      | uploads/f8/f8efa7d0bcace3be05f4fff453e414efae0e7d5f680bf215f8374b0a9fdaf9c4 |
      | uploads/e0/e0e8af37908fb7c275a9467c3ddbba0994c9a33dbf691496a60f4b0bec975f0a |
      | uploads/ff/ff9b3ce94aaac8738f382c2a027783f2b0794fae28e628f392f2a7b544e2dd6b |
    And the JSON should have the following:
      | complete                                                                  | true |
      | success                                                                   | true |
      | events/0/metrics/comparison.gene_type_distance.cds.n_symmetric_difference | 7.0  |
      | events/0/metrics/assembly.minimum_gene_set.single_copy                    | 0.0  |


  Scenario: Posting a GAET benchmark when the output includes non-mappable values
    Given I copy the file "../../example_data/generated_files/cgroup_metrics.json.gz" to "nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz"
    And I copy the file "../../example_data/tasks/gaet.json" to "nucleotides/6/metadata.json"
    And I copy the file "../../example_data/generated_files/log.txt" to "nucleotides/6/outputs/container_log/log.txt"
    And I copy the file "../../example_data/biobox/gaet.yaml" to "nucleotides/6/tmp/biobox.yaml"
    And the directory "nucleotides/6/outputs/assembly_metrics/"
    And I run the bash command:
      """
      sed '/assembly.gene_type_size.cds.sum_length/s/4233/unknown/' ../../example_data/generated_files/gaet_metrics.tsv > nucleotides/6/outputs/assembly_metrics/a5c753ccb2
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
      Error, unparsable value for assembly.gene_type_size.cds.sum_length: unknown
      """
