"""
nucleotides post-data - Post collected benchmark metrics back to nucleotides API

Usage:
    nucleotides post-data <task>
"""

import nucleotides.util as util

def run(args):
    opts = util.parse(__doc__, args)
    task = opts["<task>"]
