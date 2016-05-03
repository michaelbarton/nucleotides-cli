Feature: Running a reference assembly benchmark task

  Background:
    Given a clean set of benchmarks
    And no files in the S3 directory "s3://nucleotides-testing/uploads/"
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |
    And the nucleotides directory is available on the path
    And the file named "nucleotides/6/metadata.json" with:
    """
    {
        "benchmark": "6151f5ab282d90e4cee404433b271dda",
        "complete": false,
        "id": 6,
        "image": {
            "name": "bioboxes/quast",
            "sha256": "digest_4",
            "task": "default",
            "type": "reference_assembly_evaluation"
        },
        "inputs": [
            {
                "sha256": "6bac51cc35ee2d11782e7e31ea1bfd7247de2bfcdec205798a27c820b2810414",
                "type": "reference_fasta",
                "url": "s3://nucleotides-testing/short-read-assembler/reference.fa"
            },
            {
                "sha256": "7e9f760161e13ffdd4f81fdfec2222ccd3c568f4abcbcadcb10487d43b2a0092",
                "type": "contig_fasta",
                "url": "s3://nucleotides-testing/uploads/7e/7e9f760161e13ffdd4f81fdfec2222ccd3c568f4abcbcadcb10487d43b2a0092"
            },
            {
                "sha256": "86e54db7dc0c982005a0e359eef85e5ca569cb6f661135d4af6ffcfe5ee38651",
                "type": "container_runtime_metrics",
                "url": "s3://nucleotides-testing/uploads/86/86e54db7dc0c982005a0e359eef85e5ca569cb6f661135d4af6ffcfe5ee38651"
            }
        ],
        "type": "evaluate"
    }
    """

  Scenario: Executing a reference assembly benchmark task
    Given I copy the file "../data/reference.fa" to "nucleotides/6/inputs/reference_fasta/6bac51cc35"
    And I copy the file "../data/contigs.fa" to "nucleotides/6/inputs/contig_fasta/7e9f760161"
    When I run the bash command:
      """
      export TMPDIR=$(pwd) && nucleotides run-image 6
      """
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/6/outputs/container_runtime_metrics/metrics.json" should exist
    And the file "nucleotides/6/outputs/assembly_metrics/67ba437ffa" should exist


  Scenario: Executing a benchmark task when the image has not been pulled
    Given I copy the file "../data/reference.fa" to "nucleotides/6/inputs/reference_fasta/6bac51cc35"
    And I copy the file "../data/contigs.fa" to "nucleotides/6/inputs/contig_fasta/7e9f760161"
    And the image "bioboxes/quast" is not installed
    And the default aruba exit timeout is 180 seconds
    When I run the bash command:
      """
      export TMPDIR=$(pwd) && nucleotides run-image 6
      """
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the file "nucleotides/6/outputs/container_runtime_metrics/metrics.json" should exist
    And the file "nucleotides/6/outputs/assembly_metrics/67ba437ffa" should exist
    And the exit status should be 0


  Scenario: Posting a successful benchmark
    Given I copy the file "../data/container_runtime.json" to "nucleotides/6/outputs/container_runtime_metrics/metrics.json"
    And I copy the file "../data/assembly_metrics.tsv" to "nucleotides/6/outputs/assembly_metrics/67ba437ffa"
    When I run the bash command:
      """
      nucleotides post-data 6
      """
    And I get the url "/tasks/6"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the S3 bucket "nucleotides-testing" should contain the files:
      | uploads/20/202313628063e33c1ba8320927357be02660f0b0b6b02a63cd5f256337a7e408 |
      | uploads/67/67ba437ffad3984921037194b41216b9fd3de1ed37162bc1d22803ccb9105e4b |
    And the JSON should have the following:
       | complete                                     | true     |
       | events/0/metrics/duplication_ratio           | 1.001    |
       | events/0/metrics/indels_per_100_kbp          | 0.0      |
       | events/0/metrics/l50                         | 6.0      |
       | events/0/metrics/l75                         | 16.0     |
       | events/0/metrics/la50                        | 6.0      |
       | events/0/metrics/la75                        | 16.0     |
       | events/0/metrics/largest_alignment           | 112386.0 |
       | events/0/metrics/largest_contig              | 112386.0 |
       | events/0/metrics/lg50                        | 6.0      |
       | events/0/metrics/lg75                        | 16.0     |
       | events/0/metrics/lga50                       | 6.0      |
       | events/0/metrics/lga75                       | 16.0     |
       | events/0/metrics/misassembled_contigs_length | 0.0      |
       | events/0/metrics/mismatches_per_100_kbp      | 0.0      |
       | events/0/metrics/n50                         | 25079.0  |
       | events/0/metrics/n75                         | 12243.0  |
       | events/0/metrics/n_contigs_gt_0              | 94.0     |
       | events/0/metrics/n_contigs_gt_1000           | 49.0     |
       | events/0/metrics/n_contigs_gt_10000          | 18.0     |
       | events/0/metrics/n_contigs_gt_25000          | 6.0      |
       | events/0/metrics/n_contigs_gt_5000           | 28.0     |
       | events/0/metrics/n_contigs_gt_50000          | 3.0      |
       | events/0/metrics/n_local_misassemblies       | 0.0      |
       | events/0/metrics/n_misassemblies             | 0.0      |
       | events/0/metrics/n_per_100_kbp               | 0.0      |
       | events/0/metrics/na50                        | 25079.0  |
       | events/0/metrics/na75                        | 12243.0  |
       | events/0/metrics/ng50                        | 25079.0  |
       | events/0/metrics/ng75                        | 12243.0  |
       | events/0/metrics/nga50                       | 25079.0  |
       | events/0/metrics/nga75                       | 12243.0  |
       | events/0/metrics/perc_gc                     | 53.19    |
       | events/0/metrics/perc_genome_fraction        | 99.108   |
       | events/0/metrics/perc_ref_gc                 | 53.16    |
       | events/0/metrics/reference_length            | 700000.0 |
       | events/0/metrics/total_length_gt_0           | 699048.0 |
       | events/0/metrics/total_length_gt_1000        | 687293.0 |
       | events/0/metrics/total_length_gt_10000       | 554039.0 |
       | events/0/metrics/total_length_gt_25000       | 359553.0 |
       | events/0/metrics/total_length_gt_5000        | 629401.0 |
       | events/0/metrics/total_length_gt_50000       | 260065.0 |
       | events/0/metrics/unaligned_length            | 0.0      |
