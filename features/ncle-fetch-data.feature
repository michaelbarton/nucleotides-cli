Feature: Fetching sequence data using ncle-fetch-data

  Scenario: Running ncle-fetch-data without any arguments
   Given the ncle directory is available on the path
    When I run `ncle-fetch-data`
    Then the exit status should be 1
     And the stderr should contain exactly:
     """
     Missing arguments: s3_access_key, s3_secret_key, s3_url, output_file

     """


  Scenario: Running ncle-fetch-data without any file arguments
   Given the ncle directory is available on the path
    When I run the bash command:
      """
      ncle-fetch-data \
        --s3-access-key=${AWS_ACCESS_KEY} \
        --s3-secret-key=${AWS_SECRET_KEY} \
        --s3-region="us-west-1" \
        --s3-url="s3://nucleotid-es-dev/ncle-feature-testing/reads.fq" \
        --output-file="./reads.fq"
      """
    Then the stderr should not contain anything
     And the stdout should contain:
     """
     Downloaded data to: ./reads.fq

     """
     And the exit status should be 0
     And the file "reads.fq" should contain exactly:
      """
      @read_1
      ATGC
      +
      ((%*

      """

