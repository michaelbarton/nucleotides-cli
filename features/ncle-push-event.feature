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
