"""Tests for infra/charts/bud/templates/extra/otel-collector.yaml correctness.

Spec: 004-observability-otel-refactor (Phase 1 — spans/traces).

The collector must gain a SECOND traces export pipeline to an EXTERNAL OTLP
sink (Tempo / LGTM) on which message-content and header attributes are
scrubbed before egress, while the existing ClickHouse pipeline is left fully
intact (Phase-2 InferenceFact still needs the content).

These tests render the chart with `helm template` and parse the embedded
OpenTelemetry Collector config out of the ConfigMap, then assert structure.
"""

import pathlib
import subprocess

import pytest
import yaml

CHART_DIR = pathlib.Path(__file__).parent.parent
TEMPLATE = "templates/extra/otel-collector.yaml"

# Attributes that MUST be deleted on the external egress pipeline only.
SCRUBBED_ATTRS = {
    "gen_ai.input.messages",
    "gen_ai.output.messages",
    "gen_ai.system.instructions",
}


def _helm_template(set_args=None):
    """Render only the otel-collector template and return its raw YAML text."""
    cmd = [
        "helm",
        "template",
        "bud",
        str(CHART_DIR),
        "--show-only",
        TEMPLATE,
    ]
    for k, v in (set_args or {}).items():
        cmd += ["--set", f"{k}={v}"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        pytest.fail(f"helm template failed:\n{result.stderr}")
    return result.stdout


def _collector_config(rendered_yaml):
    """Extract and parse the embedded otel-collector-config.yaml string."""
    for doc in yaml.safe_load_all(rendered_yaml):
        if not doc:
            continue
        if doc.get("kind") == "ConfigMap":
            cfg_str = doc["data"]["otel-collector-config.yaml"]
            return yaml.safe_load(cfg_str)
    raise AssertionError("otel-collector ConfigMap not found in rendered output")


@pytest.fixture(scope="module")
def config_default():
    """Collector config rendered with external export ENABLED.

    External export is opt-in (off by default, since the LGTM/Tempo sink is
    not part of this chart). These tests exercise the enabled path.
    """
    return _collector_config(
        _helm_template({"otelCollector.externalExport.enabled": "true"})
    )


@pytest.fixture(scope="module")
def config_external_disabled():
    """Collector config rendered with external export DISABLED (the default)."""
    return _collector_config(_helm_template())


class TestClickHousePipelineIntact:
    """The ClickHouse cold-path pipeline MUST NOT change (Phase-2 depends on it)."""

    def test_traces_pipeline_exports_to_clickhouse(self, config_default):
        traces = config_default["service"]["pipelines"]["traces"]
        assert "clickhouse" in traces["exporters"]

    def test_traces_pipeline_keeps_groupbytrace(self, config_default):
        traces = config_default["service"]["pipelines"]["traces"]
        assert "groupbytrace" in traces["processors"]

    def test_clickhouse_pipeline_has_no_scrub_processor(self, config_default):
        """ClickHouse must keep gen_ai content — no delete/scrub processor on it."""
        traces = config_default["service"]["pipelines"]["traces"]
        for proc in traces["processors"]:
            assert "scrub" not in proc and "redact" not in proc, (
                f"ClickHouse traces pipeline must not scrub content, found {proc}"
            )


class TestExternalExportPipeline:
    """A second traces pipeline egresses to an external OTLP (Tempo) sink."""

    def test_external_otlp_exporter_defined(self, config_default):
        exporters = config_default["exporters"]
        assert "otlp/external" in exporters, (
            f"expected otlp/external exporter, got {list(exporters)}"
        )

    def test_external_exporter_targets_configured_endpoint(self, config_default):
        ext = config_default["exporters"]["otlp/external"]
        assert "endpoint" in ext and ext["endpoint"], (
            "otlp/external exporter must have an endpoint"
        )

    def test_external_traces_pipeline_exists(self, config_default):
        pipelines = config_default["service"]["pipelines"]
        assert "traces/external" in pipelines, (
            f"expected traces/external pipeline, got {list(pipelines)}"
        )

    def test_external_pipeline_exports_to_external_otlp(self, config_default):
        ext = config_default["service"]["pipelines"]["traces/external"]
        assert "otlp/external" in ext["exporters"]
        assert "clickhouse" not in ext["exporters"], (
            "external pipeline must not also write to ClickHouse"
        )


class TestExternalScrubProcessor:
    """The external pipeline must DELETE content + header attrs before egress."""

    def _scrub_processor_name(self, config):
        ext = config["service"]["pipelines"]["traces/external"]
        for proc in ext["processors"]:
            if "scrub" in proc:
                return proc
        raise AssertionError(
            f"no scrub processor on traces/external, got {ext['processors']}"
        )

    def test_scrub_processor_on_external_pipeline(self, config_default):
        name = self._scrub_processor_name(config_default)
        assert name in config_default["processors"]

    def test_scrub_deletes_message_content_attrs(self, config_default):
        name = self._scrub_processor_name(config_default)
        proc = config_default["processors"][name]
        # transform processor: collect every statement string; attributes
        # processor: collect every action key. Support either shape.
        blob = yaml.safe_dump(proc)
        for attr in SCRUBBED_ATTRS:
            assert attr in blob, f"scrub processor must delete {attr}; config:\n{blob}"

    def test_scrub_deletes_header_attrs(self, config_default):
        name = self._scrub_processor_name(config_default)
        blob = yaml.safe_dump(config_default["processors"][name])
        assert "eader" in blob, (
            "scrub processor must remove request/response header attributes"
        )


class TestExternalExportDisabled:
    """With external export OFF (default), config still renders and CH is intact."""

    def test_no_external_pipeline(self, config_external_disabled):
        pipelines = config_external_disabled["service"]["pipelines"]
        assert "traces/external" not in pipelines

    def test_no_external_exporter(self, config_external_disabled):
        assert "otlp/external" not in config_external_disabled["exporters"]

    def test_no_scrub_processor(self, config_external_disabled):
        assert "transform/external_scrub" not in config_external_disabled["processors"]

    def test_clickhouse_pipeline_still_present(self, config_external_disabled):
        traces = config_external_disabled["service"]["pipelines"]["traces"]
        assert "clickhouse" in traces["exporters"]


class TestResourceAttributes:
    """Resource processor sets service.namespace=bud and deployment.environment.name."""

    def test_service_namespace_is_bud(self, config_default):
        attrs = config_default["processors"]["resource"]["attributes"]
        ns = [a for a in attrs if a["key"] == "service.namespace"]
        assert ns and ns[0]["value"] == "bud", (
            f"service.namespace must be 'bud', got {ns}"
        )

    def test_deployment_environment_name_present(self, config_default):
        attrs = config_default["processors"]["resource"]["attributes"]
        keys = {a["key"] for a in attrs}
        assert "deployment.environment.name" in keys, (
            f"expected deployment.environment.name resource attr, got {keys}"
        )
