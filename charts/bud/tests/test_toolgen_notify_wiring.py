"""Spec 009 — the mcpgateway → budapp progress-push wire, as the chart renders it.

Two properties, both of which are silent when they regress:

* **M4 — the shared secret is a Secret.** The route it authenticates
  (`POST /connectors/generate/events`) is reachable from the public ingress, and a value
  rendered through a Deployment's generic `env: name/value` loop lands in the pod spec,
  in `helm get values`, in any manifest diff a CI job prints, and in git via any overlay
  that pins it. Every other shared secret on these two Deployments already uses
  `secretKeyRef`.
* **M5 — a default install must be silent.** Upstream's `_notify` short-circuits *only*
  on an empty `TOOL_GEN_NOTIFY_URL`. A url set while the token is empty means every event
  of every job — including legacy register-mode jobs that predate this feature — POSTs to
  budapp, is refused, logs an ERROR and increments `toolgen_notify_failures_total`, for
  the life of the install.

These parse the templates as text rather than rendering them, like the other tests here:
`helm` is not assumed to be installed in CI.
"""

import pathlib
import re

import yaml


_TEMPLATES = pathlib.Path(__file__).parent.parent / "templates"
_VALUES = pathlib.Path(__file__).parent.parent / "values.yaml"

BUDAPP = _TEMPLATES / "microservices" / "budapp.yaml"
MCPGATEWAY = _TEMPLATES / "mcpgateway" / "deployment.yaml"
SECRET = _TEMPLATES / "microservices" / "toolgen-notify-token.yaml"


def _values():
    return yaml.safe_load(_VALUES.read_text())


def _env_block(values, service):
    return values["microservices"][service].get("env", {})


class TestTheSecretIsNotAnEnvValue:
    def test_the_secret_template_exists_and_reads_the_shared_value(self):
        assert SECRET.exists(), "the shared toolgen secret has no template"
        text = SECRET.read_text()
        assert "kind: Secret" in text
        assert "toolgen-notify-token" in text
        assert ".Values.microservices.mcpgateway.toolGenNotifyToken" in text

    def test_budapp_reads_the_ingest_token_from_the_secret(self):
        text = BUDAPP.read_text()
        assert "MCP_TOOLGEN_INGEST_TOKEN" in text
        block = text.split("MCP_TOOLGEN_INGEST_TOKEN", 1)[1][:400]
        assert "secretKeyRef" in block
        assert "toolgen-notify-token" in block

    def test_mcpgateway_reads_the_notify_token_from_the_secret(self):
        text = MCPGATEWAY.read_text()
        assert "TOOL_GEN_NOTIFY_TOKEN" in text
        block = text.split("TOOL_GEN_NOTIFY_TOKEN", 1)[1][:400]
        assert "secretKeyRef" in block
        assert "toolgen-notify-token" in block

    def test_neither_token_is_rendered_through_the_generic_env_loop(self):
        """The `env:` maps in values.yaml are rendered as literal `value:` entries."""
        values = _values()
        assert "MCP_TOOLGEN_INGEST_TOKEN" not in _env_block(values, "budapp")
        assert "TOOL_GEN_NOTIFY_TOKEN" not in _env_block(values, "mcpgateway")

    def test_the_token_default_is_empty(self):
        """A shipped default secret is worse than no secret at all."""
        assert _values()["microservices"]["mcpgateway"]["toolGenNotifyToken"] == ""


class TestTheDefaultInstallDoesNotPushAnywhere:
    def test_the_notify_url_is_gated_on_the_token(self):
        url = _env_block(_values(), "mcpgateway")["TOOL_GEN_NOTIFY_URL"]
        assert "toolGenNotifyToken" in url, (
            "an unconditional url makes every event of every job POST to budapp and 401, "
            "logging an ERROR per event on a default install"
        )
        # `{{ if <token> }}…{{ end }}` — empty token renders an empty string.
        assert re.search(
            r"\{\{\s*if\s+\.Values\.microservices\.mcpgateway\.toolGenNotifyToken\s*\}\}",
            url,
        )
        assert re.search(r"\{\{\s*end\s*\}\}\s*$", url)

    def test_the_url_still_points_at_budapps_ingest_route_when_enabled(self):
        url = _env_block(_values(), "mcpgateway")["TOOL_GEN_NOTIFY_URL"]
        assert "/connectors/generate/events" in url
        # 9082 in-cluster, not the 9081 of the local dev shell.
        assert "budapp:9082" in url
