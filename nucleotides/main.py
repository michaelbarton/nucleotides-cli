"""
nucleotides - Command line interface for running nucleotides benchmarks

Usage:
    nucleotides <command> <task>

Commands:
    fetch-data       Download all data necessary to perform a benchmarking task
    all              Execute all nucleotides benchmark commands in order
"""

import biobox_cli.main  as bbx_main
import nucleotides.util as util

import nucleotides.command.fetch_data
import nucleotides.command.run_image
import nucleotides.command.post_data
import nucleotides.command.all

def select_command(c):
    return {
            'fetch-data' : nucleotides.command.fetch_data,
            'run-image'  : nucleotides.command.run_image,
            'post-data'  : nucleotides.command.post_data,
            'all'        : nucleotides.command.all
            }[c]

def run():
    args = util.parse(__doc__, bbx_main.input_args(), True)
    select_command(args['<command>']).run(args['<task>'])
