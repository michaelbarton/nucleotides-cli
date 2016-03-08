Feature: Running a reference assembly benchmark task

  Scenario: Executing a reference assembly benchmark task
    Given the nucleotides directory is available on the path
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
    And I copy the file "../data/reference.fa" to "nucleotides/6/inputs/reference_fasta/6bac51cc35"
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
