"""
nucleotides post-data - Post collected benchmark metrics back to nucleotides API

Usage:
    nucleotides post-data <task> [--s3-upload=<url>]

Options:
    task                 The current task number
    --s3-upload=<url>    S3 location to upload generated files to.
"""

import nucleotides.util as util

def run(args):
    opts = util.parse(__doc__, args)
    task = opts["<task>"]
