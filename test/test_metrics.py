import nose.tools          as nose
import nucleotides.metrics as met

from nose.plugins.attrib import attr

@attr('wip')
def test_parse_runtime_metrics():
    import gzip, json
    with gzip.open('data/cgroup_metrics.json.gz') as f:
        metrics = met.parse_runtime_metrics(json.loads(f.read()))

    expected = {
        "total_cpu_usage_in_seconds"               : 53.546,
        "total_cpu_usage_in_seconds_in_kernelmode" : 1.75,
        "total_cpu_usage_in_seconds_in_usermode"   : 11.11,
        "total_memory_usage_in_mibibytes"          : 175.348,
        "total_rss_in_mibibytes"                   : 80.543,
        "total_read_io_in_mibibytes"               : 38.641,
        "total_write_io_in_mibibytes"              : 0.0,
        "total_wall_clock_time_in_seconds"         : 15.0}

    for k,v in expected.iteritems():
        nose.assert_in(k, metrics)
        nose.assert_equal(metrics[k], v,
                "Exected {} to equal {} but was {}.".format(k, v, metrics[k]))
