Feature: Fetching sequence data using ncle-fetch-data

  Scenario: Running ncle-push-event without any arguments
   Given the ncle directory is available on the path
    When I run `ncle-push-event`
    Then the exit status should be 1
