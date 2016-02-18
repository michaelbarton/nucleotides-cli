"""
nucleotides - Command line interface for running nucleotides benchmarks

Usage:
    nucleotides <command> [<args>...]

Commands:
    fetch-data       Download all data necessary to perform a benchmarking task
"""

import biobox_cli.main  as bbx_main
import nucleotides.util as util
import nucleotides.command.fetch_data

def select_command(c):
    return {
            'fetch-data' : nucleotides.command.fetch_data
            }[c]

def run():
    args    = bbx_main.input_args()
    command = util.parse(__doc__, args)['<command>']
    select_command(command).run(args)
