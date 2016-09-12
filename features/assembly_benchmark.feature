Feature: Running a reference assembly benchmark task

  Background:
    Given a clean set of benchmarks
    And no files in the S3 directory "s3://nucleotides-testing/uploads/"
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |
    And I copy the file "../../data/reference_assembly_evaluation.json" to "nucleotides/6/metadata.json"

  Scenario: Executing a reference assembly benchmark task
    Given the default aruba exit timeout is 900 seconds
    And I copy the file "../data/6bac51cc35ee2d11782e7e31ea1bfd7247de2bfcdec205798a27c820b2810414" to "nucleotides/6/inputs/reference_fasta/6bac51cc35.fa.gz"
    And I copy the file "../data/contigs.fa" to "nucleotides/6/inputs/contig_fasta/7e9f760161.fa"
    When I run `nucleotides run-image 6`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz" should exist
    And the file "nucleotides/6/outputs/container_log/log.txt" should exist
    And the file "nucleotides/6/outputs/assembly_metrics/718b9ad933" should exist


  Scenario: Executing a benchmark task when the image has not been pulled
    Given I copy the file "../data/6bac51cc35ee2d11782e7e31ea1bfd7247de2bfcdec205798a27c820b2810414" to "nucleotides/6/inputs/reference_fasta/6bac51cc35.fa.gz"
    And I copy the file "../data/contigs.fa" to "nucleotides/6/inputs/contig_fasta/7e9f760161"
    And the image "bioboxes/quast" is not installed
    And the default aruba exit timeout is 180 seconds
    When I run `nucleotides run-image 6`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the file "nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz" should exist
    And the file "nucleotides/6/outputs/container_log/log.txt" should exist
    And the file "nucleotides/6/outputs/assembly_metrics/718b9ad933" should exist
    And the exit status should be 0


  Scenario: Posting a successful benchmark
    Given I copy the file "../../data/cgroup_metrics.json.gz" to "nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz"
    And I copy the file "../../data/log.txt" to "nucleotides/6/outputs/container_log/log.txt"
    And I copy the file "../data/assembly_metrics.tsv" to "nucleotides/6/outputs/assembly_metrics/67ba437ffa"
    When I run `nucleotides post-data 6`
    And I get the url "/tasks/6"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the S3 bucket "nucleotides-testing" should contain the files:
      | uploads/f8/f8efa7d0bcace3be05f4fff453e414efae0e7d5f680bf215f8374b0a9fdaf9c4 |
      | uploads/67/67ba437ffad3984921037194b41216b9fd3de1ed37162bc1d22803ccb9105e4b |
      | uploads/e0/e0e8af37908fb7c275a9467c3ddbba0994c9a33dbf691496a60f4b0bec975f0a |
    And the JSON should have the following:
       | complete                                     | true                        |
       | events/0/metrics/duplication_ratio           | 1.001                       |
       | events/0/metrics/indels_per_100_kbp          | 0.0                         |
       | events/0/metrics/l50                         | 6.0                         |
       | events/0/metrics/l75                         | 16.0                        |
       | events/0/metrics/la50                        | 6.0                         |
       | events/0/metrics/la75                        | 16.0                        |
       | events/0/metrics/largest_alignment           | 112386.0                    |
       | events/0/metrics/largest_contig              | 112386.0                    |
       | events/0/metrics/lg50                        | 6.0                         |
       | events/0/metrics/lg75                        | 16.0                        |
       | events/0/metrics/lga50                       | 6.0                         |
       | events/0/metrics/lga75                       | 16.0                        |
       | events/0/metrics/misassembled_contigs_length | 0.0                         |
       | events/0/metrics/mismatches_per_100_kbp      | 0.0                         |
       | events/0/metrics/n50                         | 25079.0                     |
       | events/0/metrics/n75                         | 12243.0                     |
       | events/0/metrics/n_contigs_gt_0              | 94.0                        |
       | events/0/metrics/n_contigs_gt_1000           | 49.0                        |
       | events/0/metrics/n_contigs_gt_10000          | 18.0                        |
       | events/0/metrics/n_contigs_gt_25000          | 6.0                         |
       | events/0/metrics/n_contigs_gt_5000           | 28.0                        |
       | events/0/metrics/n_contigs_gt_50000          | 3.0                         |
       | events/0/metrics/n_local_misassemblies       | 0.0                         |
       | events/0/metrics/n_misassemblies             | 0.0                         |
       | events/0/metrics/n_per_100_kbp               | 0.0                         |
       | events/0/metrics/na50                        | 25079.0                     |
       | events/0/metrics/na75                        | 12243.0                     |
       | events/0/metrics/ng50                        | 25079.0                     |
       | events/0/metrics/ng75                        | 12243.0                     |
       | events/0/metrics/nga50                       | 25079.0                     |
       | events/0/metrics/nga75                       | 12243.0                     |
       | events/0/metrics/perc_gc                     | 53.19                       |
       | events/0/metrics/perc_genome_fraction        | 99.108                      |
       | events/0/metrics/perc_ref_gc                 | 53.16                       |
       | events/0/metrics/reference_length            | 700000.0                    |
       | events/0/metrics/total_length_gt_0           | 699048.0                    |
       | events/0/metrics/total_length_gt_1000        | 687293.0                    |
       | events/0/metrics/total_length_gt_10000       | 554039.0                    |
       | events/0/metrics/total_length_gt_25000       | 359553.0                    |
       | events/0/metrics/total_length_gt_5000        | 629401.0                    |
       | events/0/metrics/total_length_gt_50000       | 260065.0                    |
       | events/0/metrics/unaligned_length            | 0.0                         |
       | events/0/files/0/type                        | "assembly_metrics"          |
       | events/0/files/1/type                        | "container_log"             |
       | events/0/files/2/type                        | "container_runtime_metrics" |


  Scenario: Posting a benchmark when QUAST output includes non numeric values
    Given I copy the file "../../data/cgroup_metrics.json.gz" to "nucleotides/6/outputs/container_runtime_metrics/metrics.json.gz"
    And the directory "nucleotides/6/outputs/assembly_metrics/"
    And I run the bash command:
      """
      sed /NGA50/s/25079/-/ ../data/assembly_metrics.tsv > nucleotides/6/outputs/assembly_metrics/67ba437ffa
      """
    When I run `nucleotides post-data 6`
    And I get the url "/tasks/6"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the JSON should have the following:
       | events/0/metrics/nga50  | 0.0  |
       | complete                | true |
