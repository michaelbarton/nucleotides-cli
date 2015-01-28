Feature: Fetching sequence data using ncle-fetch-data

  Scenario: Running ncle-fetch-data without any arguments
    When I run the script `ncle-fetch-data`
    Then the exit status should be 1

  Scenario: Running ncle-fetch-data without any arguments
   Given the ncle binary directory is available on the path
    When I run the bash command:
      """
      ncle-fetch-data \
        --s3-access-key=${AWS_ACCESS_KEY} \
        --s3-secret-key=${AWS_SECRET_KEY} \
        --s3-url=
        --output-file=./reads.fq.gz
        --
      """
    Then the stderr should not contain anything
     And the exit status should be 0
     And a file named "reads.fq.gz" should exist
