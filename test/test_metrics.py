import nose.tools          as nose
import nucleotides.metrics as met

def test_parse_runtime_metrics():
    inputs = [{"memory_stats": {"max_usage" : 10}, "cpu_stats" : {"cpu_usage" : {"total_usage" : 40}}},
              {"memory_stats": {"max_usage" : 20}, "cpu_stats" : {"cpu_usage" : {"total_usage" : 80}}}]
    outputs = {"max_memory_usage" : 20, "max_cpu_usage" : 80, "total_wall_clock_time_in_seconds" : 30}
    nose.assert_equal(met.parse_runtime_metrics(inputs), outputs)
