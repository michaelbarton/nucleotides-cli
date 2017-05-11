# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## 0.6.0 - UNRELEASED

### Added

  * Filter contigs less than 1000bp when fetching `contig_fasta` files from s3.
    This effectively removes all small contigs from being included in the
    assembly evaluation tasks.

  * Reference assembly benchmarking tasks fail if not all the required metrics
    are produced, or if any are null. This prevents the situation where some
    benchmarking tasks are marked as successful when in actuality an incomplete
    set of the metrics are collected.

  * Short read assembler tasks return 0 for any cgroup metric for which at
    least 85% of the data points could not be collected. This prevents
    inaccurate reporting of the Docker image performance if the cgroup data is
    able to be reliably collected.

### Fixed

  * If there are no usable contigs for a reference assembly task, the client
    will skip running the Docker image and continue as if the task was
    unsuccessful. Previously the client would error out and the task would
    remain incomplete.

### Changed

  * Added support for version 0.3.0 of GAET.

## 0.5.0 - 2017-01-30

### Added

  * A successful build and publication of the nucleotides client triggers a
    rebuild of the nucleotides Amazon machine image (AMI).

  * Added support for running benchmark 'evaluate' task using the bioboxes/gaet
    Docker image.

  * Added the command line flag `--polling`. This can be used to adjust how
    often the running Docker container is queried for cgroup data.

### Changed

  * Cgroup metrics are no longer collected during a 'produce' benchmark task
    when the Docker container fails to complete successfully. This is to
    standardise the client when no metrics are collected for any type of
    benchmark when the Docker container exits with an error.

  * The testing suite used to ensure the nucleotides client works as expected
    was significantly refactored to reduce the overall run time which was
    running for around 7 mins prior to refactoring. Most of the work done to
    reduce the run time was using the bioboxes/crash-test-biobox image, which
    outputs the expected files without doing any computational work.

## 0.4.0 - 2016-10-03

### Added

  * A new metric total wall clock time is collected and sent to the nucleotides
    API with the name `total_wall_clock_time_in_seconds`. This is calculated
    from the difference in approximate stop time and start time of the
    container within the Docker client timeout (15s) and sampling interval
    (15s).

  * Additional cgroup metrics are collected from the running container. These
    metrics are I/O reads, I/O writes, total resident set size (RSS), CPU usage
    in kernel mode, CPU usage in user mode. These are in additional to total
    memory usage and total CPU time.

  * The control group (cgroup) metrics collected from the running docker
    container are now uploaded as a gzip file to S3.

  * The client now can handle cases where the Docker image fails to complete or
    run successfully. In these cases the client will upload container logs and
    metrics to the API if they are available. This will be useful for
    diagnosing problematic biobox images.

  * The log file created by the Docker container is uploaded to S3 and a
    reference to the file is stored in the nucleotides API using the file type
    `container_log`.

  * Extended logging information is sent to the benchmark.log file in each
    nucleotides task directory. This should make debugging easier, where this
    file can be consulted to resolve any problems.

## 0.3.1 - 2016-08-01

### Fixed

  * QUAST mappings are now included in the python package

## 0.3.0 - 2016-07-28

### Fixed

  * Removed dependency on the `biobox_cli` python which was still present in
    the `setup.py`. This dependency is no longer needed but was still being
    installed. This is now fixed.

### Changed

  * Reference fasta files are now downloaded with the `.fq.gz` format. The
    assembly benchmark code has been updated correspondingly.

  * Tox is used to build and run tests for the client. This simplifies the
    process over virtualenv which was the previous method.

## 0.2.1 - 2016-07-21

### Fixed

  * File extensions are added to downloaded files. This fixes the problem where
    some bioboxes use the file extension to determine the file type.

### Changed

  * Switched to use the bioboxes.py python package for internally launching and
    monitoring biobox Docker containers. This library provides stability and
    bug fixes.

## 0.2.0 - 2016-05-17

### Added

  * Added the subcommand `all` to execute all the benchmarking tasks in order.
    This can be used instead of running each subcommand one after another.

  * Added the subcommand `clean-up` to remove all files created during
    nucleotides benchmarking. This is also included in the `all` subcommand.

  * Returns a useful error message and exits non-zero when required environment
    variables are missing.

### Changed

  * The S3 location to upload files is now specified in the environment
    variable `NUCLEOTIDES_S3_URL` instead of as a command line argument.

### Fixed

  * Handle the cases where QUAST returns '-' in the assembly metrics as 0.

## 0.1.0 - 2016-03-18

### Changed

  * This is the initial release of a complete rewrite of the client for the new
    nucleotid.es API. This rewrite currently supports nucleotid.es tasks for
    `short-read-assembler` and `assembly-evaluator` bioboxes.
