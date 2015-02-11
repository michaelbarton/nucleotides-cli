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

  Scenario Outline: Running ncle-push-event with a missing file
   Given the ncle directory is available on the path
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
        --<argument>-file=missing-file
      """
    Then the stderr should contain:
      """
      The <argument> file does not exist: missing-file

      """
     And the exit status should be 1
     And the stdout should not contain anything

   Examples:
      | argument |
      | event    |
      | log      |
      | cgroup   |

  Scenario Outline: Running ncle-push-event with a non-compressed file
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
    Then the stderr should contain:
      """
      file should be xz compressed: dummy-file
      """
     And the exit status should be 1
     And the stdout should not contain anything

    Examples:
      | argument    | field_1            | field_2            | digest                           |
      | event-file  | event_file_s3_url  | event_file_digest  | 3039059c171e71be2f205324a540a990c8293f914838eb0c97eae3a3bbe9cbf1 |
      | cgroup-file | cgroup_file_s3_url | cgroup_file_digest | 715898daa8948856ecc43f662bb58e130bc360622854de013f4acc86ef50131c |

  Scenario Outline: Running ncle-push-event with a non xz-compressed file
   Given the ncle directory is available on the path
     And a file named "dummy-file" with:
     """
     <argument>

     """
     And I run `gzip dummy-file`
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
        --<argument>=dummy-file.gz
      """
    Then the stderr should contain:
      """
      should be xz compressed: dummy-file.gz
      """
     And the exit status should be 1
     And the stdout should not contain anything

    Examples:
      | argument    | field_1            | field_2            | digest                           |
      | event-file  | event_file_s3_url  | event_file_digest  | 3039059c171e71be2f205324a540a990c8293f914838eb0c97eae3a3bbe9cbf1 |
      | cgroup-file | cgroup_file_s3_url | cgroup_file_digest | 715898daa8948856ecc43f662bb58e130bc360622854de013f4acc86ef50131c |

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
     And I run `xz dummy-file`
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
        --<argument>=dummy-file.xz
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
      | event-file  | event_file_s3_url  | event_file_digest  | 3039059c171e71be2f205324a540a990c8293f914838eb0c97eae3a3bbe9cbf1 |
      | log-file    | log_file_s3_url    | log_file_digest    | 3f5150f9d763c4a2c2b99a2c1f057ee197840c11d7b794db042269b3e9c3e091 |
      | cgroup-file | cgroup_file_s3_url | cgroup_file_digest | 715898daa8948856ecc43f662bb58e130bc360622854de013f4acc86ef50131c |
