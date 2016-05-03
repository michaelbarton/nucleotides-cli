Feature: Use the `all` sub-command to execute all steps in benchmarking

  Background:
    Given a clean set of benchmarks
    And the nucleotides directory is available on the path
    And no files in the S3 directory "s3://nucleotides-testing/uploads/"
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |

  Scenario: Removing all created files using the `clean-up` command
    When I run the bash command:
      """
      nucleotides fetch-data 1 && nucleotides clean-up 1
      """
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the directory "nucleotides/1" should not exist

  Scenario: Running all benchmark commands together using the `all` command
    Given the default aruba exit timeout is 300 seconds
    When I run the bash command:
      """
      export TMPDIR=$(pwd) && nucleotides all 1 && nucleotides all 2
      """
    And I get the url "/benchmarks/2f221a18eb86380369570b2ed147d8b4"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the JSON should have the following:
      | complete | true |
    And the directory "nucleotides/1" should not exist
    And the directory "nucleotides/2" should not exist
