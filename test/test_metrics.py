import gzip, json
import nose.tools          as nose
import helper.application  as app
import nucleotides.metrics as met

from nose.plugins.attrib import attr

def test_parse_metrics_with_only_path():
    app.mock_app()
    metrics = {"old_name": 1}
    mapping = [{"key": "new_name", "path" : "old_name"}]
    nose.assert_equal(met.parse_metrics(app.mock_app(), metrics, mapping), {"new_name": 1})


def test_parse_metrics_with_no_path():
    app.mock_app()
    metrics = {"metric": "1"}
    mapping = [{"key": "metric"}]
    nose.assert_equal(met.parse_metrics(app.mock_app(), metrics, mapping), {"metric": 1})


def test_parse_metrics_with_missing_value():
    metrics = {}
    mapping = [{"key": "new_name", "path" : "old_name"}]
    nose.assert_equal(met.parse_metrics(app.mock_app(), metrics, mapping), {})


def test_parse_metrics_with_lift():
    metrics = {"old_name": "-"}
    mapping = [{"key": "new_name", "path" : "old_name", "lift" : ["parse_quast_value"]}]
    parsed  = met.parse_metrics(app.mock_app(), metrics, mapping)
    nose.assert_equal(parsed, {"new_name": 0.0})
    nose.assert_is_instance(parsed["new_name"], float)


def test_parse_metrics_with_unmappable_value():
    metrics = {"old_name": "unmappable_value"}
    mapping = [{"key": "new_name", "path" : "old_name", "lift" : ["parse_quast_value"]}]
    parsed  = met.parse_metrics(app.mock_app(), metrics, mapping)
    nose.assert_equal(parsed, {})
