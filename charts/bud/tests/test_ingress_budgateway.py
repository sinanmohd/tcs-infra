"""Tests for infra/charts/bud/templates/ingress.yaml budgateway exposure.

Issue #1878 (HIGH): the budgateway public ingress used a catch-all ``path: /``,
publishing the gateway's unauthenticated native routes to the internet
(``/inference``, ``/internal/object_storage`` file-read/SSRF, ``/feedback``,
``/datasets/*``, ``/metrics``, ``/status`` ...). Only the ``/v1/*`` and
``/a2a/*`` surfaces are intended to be public, so the public ingress rule must
be restricted to exactly those prefixes.

These tests parse the Helm template text directly (no ``helm`` binary needed),
mirroring ``test_dapr_crons.py``. We only need the budgateway host rule, which
uses plain enough templating to extract by structure.
"""

import pathlib
import re

INGRESS_YAML = pathlib.Path(__file__).parent.parent / "templates" / "ingress.yaml"

# The only prefixes that may be published to the internet for the gateway: the
# authenticated OpenAI-compatible API (incl. OTLP /v1/{traces,metrics,logs}) and
# the A2A proxy.
ALLOWED_BUDGATEWAY_PATHS = {"/v1", "/a2a"}

# Unauthenticated native routes / telemetry that must never be reachable via the
# public ingress (prefixes from gateway/src/main.rs public_routes + the broad
# catch-all "/" itself).
FORBIDDEN_NATIVE_PREFIXES = [
    "/inference",
    "/batch_inference",
    "/feedback",
    "/datasets",
    "/internal",
    "/dynamic_evaluation_run",
    "/status",
    "/health",
    "/metrics",
]


def _budgateway_host_block():
    """Return the text of the singular ``- host: ...budgateway`` rule.

    Scoped to the ``- host:`` rule (not the plural ``- hosts:`` TLS block which
    also references the budgateway host). Spans until the next ``- host:`` rule
    or the ``tls:`` section.
    """
    lines = INGRESS_YAML.read_text().splitlines()
    start = None
    for i, line in enumerate(lines):
        if re.match(r"\s*- host:", line) and "budgateway" in line:
            start = i
            break
    assert start is not None, "budgateway host rule not found in ingress.yaml"

    end = len(lines)
    for j in range(start + 1, len(lines)):
        stripped = lines[j].strip()
        if re.match(r"\s*- host:", lines[j]) or stripped == "tls:":
            end = j
            break
    return "\n".join(lines[start:end])


def _budgateway_paths():
    """Return the set of ``path:`` values declared in the budgateway host rule."""
    block = _budgateway_host_block()
    return {m.group(1) for m in re.finditer(r"-\s*path:\s*(\S+)", block)}


def test_no_catch_all_path():
    """The budgateway host rule must not publish a catch-all ``path: /``."""
    paths = _budgateway_paths()
    assert "/" not in paths, f"budgateway ingress still exposes catch-all '/': {paths}"


def test_paths_are_exactly_v1_and_a2a():
    """Only the authenticated /v1 and /a2a surfaces may be published."""
    assert _budgateway_paths() == ALLOWED_BUDGATEWAY_PATHS


def test_no_unauth_native_prefix_published():
    """None of the removed/unauthenticated native prefixes may be published."""
    paths = _budgateway_paths()
    for prefix in FORBIDDEN_NATIVE_PREFIXES:
        offending = [p for p in paths if p == prefix or p.startswith(prefix)]
        assert not offending, (
            f"budgateway ingress publishes forbidden prefix(es): {offending}"
        )
