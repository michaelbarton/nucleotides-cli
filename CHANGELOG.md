# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## 0.5.0 - DATE


## 0.4.0 - 2016-10-03

### Added

  * A new metric total wall clock time is collected and sent to the nucleotides
    API with the name `total_wall_clock_time_in_seconds`. This is calculated
    from the difference in approximate stop time and start time of the
    container within the Docker client timeout (15s) and sampling interval
    (15s).

  * Additional cgroup metrics are collected from the running container. These
    metrics are io reads, io writes, total resident set size (rss), CPU usage
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
