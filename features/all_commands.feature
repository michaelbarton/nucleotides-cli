Feature: Use the `all` sub-command to execute all steps in benchmarking

  Background:
    Given a clean set of benchmarks
    And no files in the S3 directory "s3://nucleotides-testing/uploads/"
    And I set the environment variables to:
      | variable           | value                             |
      | NUCLEOTIDES_S3_URL | s3://nucleotides-testing/uploads/ |

  Scenario: Removing all created files using the `clean-up` command
    When I run `nucleotides fetch-data 1`
    And I run `nucleotides clean-up 1`
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the directory "nucleotides/1" should not exist

  Scenario Outline: Running all short read assembly benchmark commands together using `all`
    Given the default aruba exit timeout is 900 seconds
    When I run `nucleotides all <task_1>`
    And I run `nucleotides all <task_2>`
    And I get the url "/benchmarks/<url>"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the JSON should have the following:
      | complete                       | true                        |
      | tasks/0/events/0/files/0/type  | "container_log"             |
      | tasks/0/events/0/files/1/type  | "container_runtime_metrics" |
      | tasks/0/events/0/files/2/type  | "contig_fasta"              |
      | tasks/1/events/0/metrics/nga50 | 25079.0                     |
      | tasks/1/events/0/files/0/type  | "assembly_metrics"          |
      | tasks/1/events/0/files/1/type  | "container_log"             |
      | tasks/1/events/0/files/2/type  | "container_runtime_metrics" |
    And the directory "nucleotides/<task_1>" should not exist
    And the directory "nucleotides/<task_2>" should not exist

    Examples:
      | task_1 | task_2 | url                              |
      | 9      | 10     | 98c1d2a9d58ce748c08cf65dd3354676 |


  Scenario: Executing a short read assembly task that fails whilst producing a log
    Given the default aruba exit timeout is 900 seconds
    When I run `nucleotides all 5`
    And I get the url "/tasks/5"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the JSON should have the following:
      | complete               | false                       |
      | events/0/files/0/type  | "container_log"             |
      | events/0/files/1/type  | "container_runtime_metrics" |


  Scenario: Executing a short read assembly task that fails without producing a log
    Given the default aruba exit timeout is 900 seconds
    When I run `nucleotides all 1`
    And I get the url "/tasks/1"
    Then the stderr should not contain anything
    And the stdout should not contain anything
    And the exit status should be 0
    And the JSON should have the following:
      | complete               | false                       |
      | events/0/files/0/type  | "container_runtime_metrics" |
