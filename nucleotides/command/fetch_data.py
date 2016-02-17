"""
nucleotides fetch-data - Download all data necessary to perform a benchmarking task

Usage:
    nucleotides fetch-data [<args>...]
"""

import nucleotides.util as util

def run(args):
    util.parse(__doc__, args)
