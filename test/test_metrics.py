import gzip, json
import nose.tools          as nose
import nucleotides.metrics as met

from nose.plugins.attrib import attr

def test_extract_metric():
    with gzip.open('example_data/generated_files/cgroup_metrics_incomplete.json.gz') as f:
        metrics = met.parse_runtime_metrics(json.loads(f.read()))

    metrics = [{"variable" : 1}] * 10
    nose.assert_is_not_none(met.extract_metric(metrics, "variable"))

    metrics[-1] = {"variable" : None}
    nose.assert_is_none(met.extract_metric(metrics, "variable"))


def test_parse_runtime_metrics():
    with gzip.open('example_data/generated_files/cgroup_metrics.json.gz') as f:
        metrics = met.parse_runtime_metrics(json.loads(f.read()))

    expected = {
        "total_cpu_usage_in_seconds"               : 53.546,
        "total_cpu_usage_in_seconds_in_kernelmode" : 1.75,
        "total_cpu_usage_in_seconds_in_usermode"   : 11.11,
        "total_memory_usage_in_mibibytes"          : 175.348,
        "total_rss_in_mibibytes"                   : 80.543,
        "total_read_io_in_mibibytes"               : 38.641,
        "total_write_io_in_mibibytes"              : 0.0,
        "total_wall_clock_time_in_seconds"         : 0.0}

    for k,v in expected.iteritems():
        nose.assert_in(k, metrics)
        nose.assert_equal(metrics[k], v,
                "Exected {} to equal {} but was {}.".format(k, v, metrics[k]))

def test_parse_incomplete_runtime_metrics():
    with gzip.open('example_data/generated_files/cgroup_metrics_incomplete.json.gz') as f:
        metrics = met.parse_runtime_metrics(json.loads(f.read()))

    nose.assert_not_in('total_rss_in_mibibytes', metrics)

    expected = {
        "total_cpu_usage_in_seconds"               : 53.546,
        "total_cpu_usage_in_seconds_in_kernelmode" : 1.75,
        "total_cpu_usage_in_seconds_in_usermode"   : 11.11,
        "total_memory_usage_in_mibibytes"          : 175.348,
        "total_read_io_in_mibibytes"               : 38.641,
        "total_write_io_in_mibibytes"              : 0.0,
        "total_wall_clock_time_in_seconds"         : 0.0}

    for k,v in expected.iteritems():
        nose.assert_in(k, metrics)
        nose.assert_equal(metrics[k], v,
                "Exected {} to equal {} but was {}.".format(k, v, metrics[k]))
