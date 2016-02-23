Feature: Running a docker container benchmark

  Scenario: Fetching input data from given a nucleotides task ID
    Given the nucleotides directory is available on the path
    And the file named "nucleotides/5/metadata.json" with:
    """
    {
        "benchmark": "6151f5ab282d90e4cee404433b271dda",
        "complete": false,
        "id": 5,
        "image": {
            "name": "bioboxes/velvet",
            "sha256": "digest_1",
            "task": "default",
            "type": "short_read_assembler"
        },
        "inputs": [
            {
                "sha256": "11948b41d44931c6a25cabe58b138a4fc7ecc1ac628c40dcf1ad006e558fb533",
                "type": "short_read_fastq",
                "url": "s3://nucleotides-testing/short-read-assembler/reads.fq.gz"
            }
        ],
        "type": "produce"
    }
    """
    And I copy the file "../data/reads.fq.gz" to "nucleotides/5/inputs/short_read_fastq/11948b41d4.fq.gz"
    When I run the bash command:
      """
      TMPDIR=$(pwd) nucleotides run-image 5
      """
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the file "nucleotides/5/outputs/contig_fasta/7e9f760161" should exist
