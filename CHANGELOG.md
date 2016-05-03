# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## 0.2.0

### Changed

  * The S3 location to upload files is now specified in the environment
    variable `NUCLEOTIDES_S3_URL` instead of as a command line argument.

## 0.1.0

### Changed

  * This is the initial release of a complete rewrite of the client for the new
    nucleotid.es API. This rewrite currently supports nucleotid.es tasks for
    `short-read-assembler` and `assembly-evaluator` bioboxes.
