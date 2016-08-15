"""\
Provides functions for converting the streamed cgroup data produced from monitoring
the Docker container into metrics that may be uploaded to the nucleotides API.
"""

"""
Interval in seconds in which cgroup data is collected
"""
SAMPLING_INTERVAL = 15

def remap_cgroup_values(a):
    """
    Remaps the raw cgroup data paths into the metric names used by nucleotides.
    """
    return {"max_memory_usage" : a["memory_stats"]["max_usage"],
            "max_cpu_usage"    : a["cpu_stats"]["cpu_usage"]["total_usage"]}


# http://stackoverflow.com/a/25658642/91144
def max_values(a, b):
    """
    For two dictionaries a & b, returns a single dictionary containing the maximum
    value for each key in the dictionaries.
    """
    return {key: max(value, b[key]) for key, value in a.iteritems()}


def parse_runtime_metrics(metrics):
    """
    Given a list of cgroup dictionaries, parses them into a single dictionary of
    nucleotides metrics that can be uploaded to the nucleotides API.
    """
    nucleotides_metrics = reduce(max_values, map(remap_cgroup_values, metrics))
    nucleotides_metrics["total_wall_clock_time_in_seconds"] = len(metrics) * SAMPLING_INTERVAL
    return nucleotides_metrics

