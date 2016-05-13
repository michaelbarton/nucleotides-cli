"""
nucleotides - Command line interface for running nucleotides benchmarks

Usage:
    nucleotides <command> <task>

Commands:
    fetch-data       Download all data necessary to perform a benchmarking task
    all              Execute all nucleotides benchmark commands in order
"""

import funcy, string, sys
import nucleotides.util as util

import nucleotides.command.fetch_data
import nucleotides.command.run_image
import nucleotides.command.post_data
import nucleotides.command.clean_up
import nucleotides.command.all

def select_command(c):
    return {
            'fetch-data' : nucleotides.command.fetch_data,
            'run-image'  : nucleotides.command.run_image,
            'post-data'  : nucleotides.command.post_data,
            'clean-up'   : nucleotides.command.clean_up,
            'all'        : nucleotides.command.all
            }[c]

def input_args():
    f = funcy.compose(
            funcy.rest,
            funcy.partial(map, string.strip),
            funcy.partial(filter, lambda x: len(x) != 0))
    return f(sys.argv)

def run():
    args = util.parse(__doc__, input_args(), True)
    select_command(args['<command>']).run(args['<task>'])
