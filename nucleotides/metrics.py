"""\
Provides functions for converting the streamed cgroup data produced from monitoring
the Docker container into metrics that may be uploaded to the nucleotides API.
"""

# Make all builtin functions accessible to mapping lifts
from __builtin__ import *

import funcy, os
import ruamel.yaml as yaml

from functools import partial

import biobox.cgroup    as cgroup
import nucleotides.util as util


def round_to_3(x):
    return round(x, 3)

def byte_to_mibibyte(x):
    return x * (1.0 / 1024 ** 2)

def nanoseconds_to_seconds(x):
    return x * 1e-9

def time_diff(xs):
    return cgroup.time_diff_in_seconds(xs[0], xs[-1])

def parse_quast_value(x):
    quast_mapping = {'-' : 0.0, 'true' : 1.0, 'false' : 0.0}
    return quast_mapping[x] if x in quast_mapping else x


def get_minimum_metric_set_keys_from_mapping_file(name):
    """
    Returns the list of metrics that should be collected based from the container.
    These metrics are defined in mapping files for each image name.
    """
    path = os.path.join('mappings', name + '.yml')
    mappings = yaml.safe_load(util.get_asset_file_contents(path))

    is_mandatory_metric = lambda x: not funcy.get_in(x, 'optional', False)

    return list(map(lambda x: x['key'],
        funcy.filter(is_mandatory_metric, mappings)))


def fetch_metric(metrics, mapping):
    """
    Given a dictionary of metrics and a single mapping, fetch the required metric
    from the dictionary. Return a key-value tuple. Return None for the value if the
    metric cannot be found.
    """
    import jmespath
    key = mapping["key"]

    if "path" in mapping:
        raw_value = jmespath.compile(mapping['path']).search(metrics)
    elif key in metrics:
        raw_value = metrics[key]
    else:
        raw_value = None

    return (key, raw_value)



def parse_metric(app, mapping, metric_tuple):
    """
    Given a key-value metric tuple, and the corresponding metric mapping, parse the
    metric as appropriate using data from the mapping. Return a key-value tuple.
    Return None for the value if the metric cannot be parsed.
    """
    function_list  = globals()
    key, raw_value = metric_tuple

    # When metric is missing but optional
    if (raw_value is None) and funcy.get_in(mapping, ['optional'], False):
        msg = "Optional metric '{}' not found, replaced with 0 instead.".format(key)
        app['logger'].warn(msg)
        return (key, 0.0)

    if raw_value is None:
        msg = "Mandatory metric '{}' not found.".format(key)
        app['logger'].error(msg)
        return (key, raw_value)

    lift = [float]

    if "lift" in mapping:
        lift = map(lambda name: function_list[name], mapping["lift"]) + lift

    try:
        value = reduce(lambda x, f: f(x), lift, raw_value)
    except ValueError:
        msg = "Error, unparsable value for {}: {}".format(key, raw_value)
        app['logger'].error(msg)
        value = None

    return (key, value)



def process_raw_metrics(app, metrics, mappings):
    """
    Given a dictionary of raw metrics retrieved from a container output file, and an
    array of mappings for those metrics, convert the input dictionary of metrics
    using these mappings.
    """
    function_list = globals()

    def parse(mapping):
        return parse_metric(app, mapping, fetch_metric(metrics, mapping))

    create_key_value_dict = funcy.rcompose(
            partial(map, parse),
            dict,
            partial(funcy.select_values, funcy.notnone))

    return create_key_value_dict(mappings)


def is_minimum_metric_set(app, expected, collected):
    """
    Determine if the required metrics are found.
    """
    expected  = set(expected)
    collected = set(collected)

    missing_metrics = expected.difference(collected)
    if missing_metrics:
        msg = "Expected metrics not found: {}"
        app["logger"].warn(msg.format(",".join(missing_metrics)))

    return not missing_metrics


def check_90_percent_real_values(x):
    """
    Given a list of values, if >= 10% of the values are None, returns None.

    This is used to allow some missing values from the cgroup metrics as these can
    sometimes be unreliable in their collection.
    """
    collection_threshold = 0.15

    if len(x) == 0:
        return [0.0]

    percent_none_values = len(funcy.remove(funcy.notnone, x)) / len(x)
    if percent_none_values >= collection_threshold:
        return [0.0]
    else:
        return x
