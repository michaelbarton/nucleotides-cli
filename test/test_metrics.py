import nose.tools          as nose
import nucleotides.metrics as met

def test_parse_runtime_metrics():
    inputs = [{"memory_stats": {"stats" : {"rss" : 10}}, "cpu_stats" : {"cpu_usage" : {"total_usage" : 40}}},
              {"memory_stats": {"stats" : {"rss" : 20}}, "cpu_stats" : {"cpu_usage" : {"total_usage" : 80}}}]
    outputs = {"max_resident_set_size" : 20, "max_cpu_usage" : 80}
    nose.assert_equal(met.parse_runtime_metrics(inputs), outputs)
