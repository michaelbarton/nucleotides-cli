Feature: Fetching sequence data using ncle-fetch-data

  Scenario: Running ncle-push-event without any arguments
   Given the ncle directory is available on the path
    When I run `ncle-push-event`
    Then the stdout should not contain anything
     And the exit status should be 1
     And the stderr should contain exactly:
     """
     Missing arguments: benchmark_id, benchmark_type_code, status_code, event_type_code

     """

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
     <argument>

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
     And the corresponding event API entry should match:
       | key       | value_re                                         |
       | <field_1> | s3://nucleotid-es-dev/ncle-uploads/<digest>-\d+$ |
       | <field_2> | <digest>                                         |
     And the S3 file for the API entry "<field_1>" should exist.

    Examples:
      | argument    | field_1            | field_2            | digest                           |
      | event-file  | event_file_s3_url  | event_file_digest  | c9bf86684fa4d04b21f2a4aeea8328b044bb29d6deb989ffe32bffe40c65d94b |
      | log-file    | log_file_s3_url    | log_file_digest    | ec1633ab8ac264a5cc8c4d9828527e801fca9b6238e7a3da173fd4a16adccd19 |
      | cgroup-file | cgroup_file_s3_url | cgroup_file_digest | 7acba5986ce67131a5ca2e94946c7de80759bcf440a4dbb9810f415418727750 |

