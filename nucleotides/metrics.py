"""\
Provides functions for converting the streamed cgroup data produced from monitoring
the Docker container into metrics that may be uploaded to the nucleotides API.
"""

"""
Interval in seconds in which cgroup data is collected
"""
SAMPLING_INTERVAL      = 15
BYTE_TO_MIBIBYTE       = 1.0 / 1024 ** 2
NANOSECONDS_TO_SECONDS = 1e-9

CGROUP_JMESPATHS = {
    "total_memory_usage_in_mibibytes"          : ["max([*].memory_stats.max_usage)", BYTE_TO_MIBIBYTE],
    "total_rss_in_mibibytes"                   : ["max([*].memory_stats.stats.total_rss)", BYTE_TO_MIBIBYTE],
    "total_cpu_usage_in_seconds"               : ["max([*].cpu_stats.cpu_usage.total_usage)", NANOSECONDS_TO_SECONDS],
    "total_cpu_usage_in_seconds_in_kernelmode" : ["max([*].cpu_stats.cpu_usage.usage_in_kernelmode)", NANOSECONDS_TO_SECONDS],
    "total_cpu_usage_in_seconds_in_usermode"   : ["max([*].cpu_stats.cpu_usage.usage_in_usermode)", NANOSECONDS_TO_SECONDS],
    "total_read_io_in_mibibytes"               : ["max([*].sum(blkio_stats.io_service_bytes_recursive[?op=='Read'].value))", BYTE_TO_MIBIBYTE],
    "total_write_io_in_mibibytes"              : ["max([*].sum(blkio_stats.io_service_bytes_recursive[?op=='Write'].value))", BYTE_TO_MIBIBYTE] }

def parse_runtime_metrics(metrics):
    """
    Given a list of cgroup dictionaries, parses them into a single dictionary of
    nucleotides metrics that can be uploaded to the nucleotides API.
    """
    import jmespath
    f = lambda (name, (path, units)): [name, round(jmespath.search(path, metrics) * units, 3)]
    nucleotides_metrics = dict(map(f, CGROUP_JMESPATHS.iteritems()))
    nucleotides_metrics["total_wall_clock_time_in_seconds"] = len(metrics) * SAMPLING_INTERVAL
    return nucleotides_metrics
