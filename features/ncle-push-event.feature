Feature: Fetching sequence data using ncle-fetch-data

  Scenario: Running ncle-push-event without any arguments
   Given the ncle directory is available on the path
    When I run `ncle-push-event`
    Then the stdout should not contain anything
     And the stderr should contain "Missing arguments: "
     And the exit status should be 1

  Scenario: Running ncle-push-event without any files
   Given the ncle directory is available on the path
    When I run the bash command:
      """
      ncle-push-event \
        --benchmark-id="dummy" \
        --benchmark-type-code="dummy" \
        --status-code="dummy" \
        --event-type-code="dummy"
      """
    Then the stderr should not contain anything
     And the exit status should be 0
     And the output should match /^\d+$/

  Scenario Outline: Running ncle-push-event with file arguments
   Given the ncle directory is available on the path
     And a file named "dummy-file" with:
     """
     dummy-contents
     """
    When I run the bash command:
      """
      ncle-push-event \
        --benchmark-id="dummy" \
        --benchmark-type-code="dummy" \
        --status-code="dummy" \
        --event-type-code="dummy" \
        --s3-access-key=${AWS_ACCESS_KEY} \
        --s3-secret-key=${AWS_SECRET_KEY} \
        --s3-region="us-west-1" \
        --s3-url="s3://nucleotid-es-dev/ncle-uploads/" \
        --<argument>=dummy-file
      """
    Then the stderr should not contain anything
     And the exit status should be 0
     And the output should match /^\d+$/

    Examples:
      | argument    |
      | event-file  |
      | log-file    |
      | cgroup-file |
