"""\
Provides functions for converting the streamed cgroup data produced from monitoring
the Docker container into metrics that may be uploaded to the nucleotides API.
"""

"""
Interval in seconds in which cgroup data is collected
"""

import funcy, os
import ruamel.yaml as yaml

from functools import partial

import biobox.cgroup    as cgroup
import nucleotides.util as util




SAMPLING_INTERVAL      = 15
BYTE_TO_MIBIBYTE       = 1.0 / 1024 ** 2
SECONDS                = 1
NANOSECONDS_TO_SECONDS = 1e-9


def time_diff(xs):
    return cgroup.time_diff_in_seconds(xs[0], xs[-1])


CGROUP_JMESPATHS = {
    "total_memory_usage_in_mibibytes"          : [funcy.last, "memory_stats.max_usage", BYTE_TO_MIBIBYTE],
    "total_rss_in_mibibytes"                   : [max, "memory_stats.stats.total_rss", BYTE_TO_MIBIBYTE],
    "total_cpu_usage_in_seconds"               : [funcy.last, "cpu_stats.cpu_usage.total_usage", NANOSECONDS_TO_SECONDS],
    "total_cpu_usage_in_seconds_in_kernelmode" : [funcy.last, "cpu_stats.cpu_usage.usage_in_kernelmode", NANOSECONDS_TO_SECONDS],
    "total_cpu_usage_in_seconds_in_usermode"   : [funcy.last, "cpu_stats.cpu_usage.usage_in_usermode", NANOSECONDS_TO_SECONDS],
    "total_read_io_in_mibibytes"               : [funcy.last, "sum(blkio_stats.io_service_bytes_recursive[?op=='Read'].value)", BYTE_TO_MIBIBYTE],
    "total_write_io_in_mibibytes"              : [funcy.last, "sum(blkio_stats.io_service_bytes_recursive[?op=='Write'].value)", BYTE_TO_MIBIBYTE],
    "total_wall_clock_time_in_seconds"         : [time_diff,  "read", SECONDS]}


def get_expected_keys_from_mapping_file(name):
    """
    Returns the list of metrics that should be collected based on the metric file name
    """
    path = os.path.join('mappings', name + '.yml')
    mappings = yaml.safe_load(util.get_asset_file_contents(path))
    return list(map(lambda x: x['key'], mappings))


def parse_quast_value(x):
    quast_mapping = {'-' : 0.0, 'true' : 1.0, 'false' : 0.0}
    return quast_mapping[x] if x in quast_mapping else x


def parse_metrics(metrics, mappings):
    """
    Given a dictionary of metrics, and an array of mappings for those metrics,
    convert the input dictionary of metrics using these mappings.
    """
    function_list = globals()
    def f(mapping):
        import jmespath
        key   = mapping["key"]
        value = jmespath.compile(mapping['path']).search(metrics)

        if value is None:
            return (key, value)

        if "lift" in mapping:
            lift  = map(lambda name: function_list[name], mapping["lift"])
            value = reduce(lambda x, f: f(x), lift, value)

        return (key, float(value))

    return dict(map(f, mappings))


def are_metrics_complete(app, expected, collected):
    """
    Determine if the required metrics are found.
    """
    expected  = set(expected)
    collected = set(collected)

    missing_metrics = expected.difference(collected)
    if missing_metrics:
        msg = "Expected metrics not found: {}"
        app["logger"].info(msg.format(",".join(missing_metrics)))

    return not missing_metrics


def extract_metric(doc, path):
    """
    Given a JSON document, fetches fields out for a given jmespath path, if
    >= 10% of the values are None, returns None.
    """
    import jmespath
    f = funcy.rcompose(
            partial(map, jmespath.compile(path).search),
            partial(filter, lambda x: x is not None))

    values = f(doc)
    perc_missing = round(1 - float(len(values)) /  len(doc), 2)
    return None if perc_missing >= 0.1 else values



def parse_runtime_metrics(metrics):
    """
    Given a list of cgroup dictionaries, parses them into a single dictionary of
    nucleotides metrics that can be uploaded to the nucleotides API. Ignores metrics
    where more than 10% of the values are missing.
    """
    def parse(acc, (name, (f, path, units))):
        values = extract_metric(metrics, path)
        if values:
            acc.append([name, round(f(values) * units, 3)])
        return acc

    nucleotides_metrics = dict(reduce(parse, CGROUP_JMESPATHS.iteritems(), []))
    return nucleotides_metrics
