Feature: Fetching sequence data using ncle-fetch-data

  Scenario: Running ncle-fetch-data without any arguments
    When I run the script `ncle-fetch-data`
    Then the exit status should be 1
