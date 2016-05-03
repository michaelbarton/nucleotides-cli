Feature: Running the all the nucleotides commands in order to execute a benchmark

  Background:
    Given a clean set of benchmarks
    And no files in the S3 directory "s3://nucleotides-testing/uploads/"
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |

  Scenario: completing a benchmark
    Given the nucleotides directory is available on the path
    And the default aruba exit timeout is 300 seconds
    When I run the bash command:
      """
      export TMPDIR=$(pwd) && \
      nucleotides fetch-data 1 && \
      nucleotides run-image  1 && \
      nucleotides post-data  1
      nucleotides fetch-data 2 && \
      nucleotides run-image  2 && \
      nucleotides post-data  2
      """
    And I get the url "/benchmarks/2f221a18eb86380369570b2ed147d8b4"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the JSON should have the following:
      | complete | true |
