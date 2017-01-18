"""
nucleotides - Command line interface for running nucleotides benchmarks

Usage:
    nucleotides [--polling=<s>] <command> <task>

Options:
    task                The numeric ID of a nucleotides benchmarking task.
    -p, --polling=<s>   Interval in seconds when polling a Docker container for cgroup metrics [default: 15].

Commands:
    fetch-data      Download all data necessary to perform a benchmarking task.
    run-image       Start the docker image defined in the benchmarking task.
    post-data       Send the metrics collected from running the image to nucleotides API.
    clean-up        Remove files created from running the benchmarking task.
    all             Run all of the above nucleotides benchmark commands in order.
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
    args    = util.parse(__doc__, input_args(), True)
    command = args.pop('<command>')
    task    = args.pop('<task>')
    select_command(command).run(task, args)
