# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## 0.2.0

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

## 0.1.0

### Changed

  * This is the initial release of a complete rewrite of the client for the new
    nucleotid.es API. This rewrite currently supports nucleotid.es tasks for
    `short-read-assembler` and `assembly-evaluator` bioboxes.
