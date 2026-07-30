"""Tests for infra/charts/bud/templates/dapr/cron.yaml correctness."""

import pathlib
import yaml

CRON_YAML = pathlib.Path(__file__).parent.parent / "templates" / "dapr" / "cron.yaml"


def _load_components():
    """Parse cron.yaml and return a list of Dapr Component dicts."""
    text = CRON_YAML.read_text()
    return [doc for doc in yaml.safe_load_all(text) if doc is not None]


def _find(components, name):
    for c in components:
        if c.get("metadata", {}).get("name") == name:
            return c
    return None


def _meta_value(component, key):
    for item in component.get("spec", {}).get("metadata", []):
        if item.get("name") == key:
            return item.get("value")
    return None


class TestRegistryCleanupCron:
    """Issue #1811: registry-cleanup-scheduler must be present for budmodel."""

    def test_component_exists(self):
        components = _load_components()
        assert _find(components, "registry-cleanup-scheduler") is not None, (
            "registry-cleanup-scheduler is missing from cron.yaml"
        )

    def test_scope_is_budmodel(self):
        components = _load_components()
        comp = _find(components, "registry-cleanup-scheduler")
        assert comp is not None
        scopes = comp.get("scopes", [])
        assert "budmodel" in scopes, (
            f"registry-cleanup-scheduler scopes should include budmodel, got {scopes}"
        )

    def test_schedule_is_hourly(self):
        components = _load_components()
        comp = _find(components, "registry-cleanup-scheduler")
        assert comp is not None
        schedule = _meta_value(comp, "schedule")
        assert schedule == "@every 24h", (
            f"Expected schedule '@every 24h', got '{schedule}'"
        )

    def test_route_is_correct(self):
        components = _load_components()
        comp = _find(components, "registry-cleanup-scheduler")
        assert comp is not None
        route = _meta_value(comp, "route")
        assert route == "/model-info/registry-cleanup-cron", (
            f"Expected route '/model-info/registry-cleanup-cron', got '{route}'"
        )

    def test_direction_is_input(self):
        components = _load_components()
        comp = _find(components, "registry-cleanup-scheduler")
        assert comp is not None
        direction = _meta_value(comp, "direction")
        assert direction == "input", f"Expected direction 'input', got '{direction}'"


class TestBudeventSessionReaperCron:
    """budevent-session-reaper must be present so budevent's /cron/{name} reaper fires.

    The reaper handler (services/budevent/server/src/dapr.rs) TTL-sweeps stale
    thread_sessions; without this binding nothing POSTs to it on a schedule.
    """

    def test_component_exists(self):
        components = _load_components()
        assert _find(components, "budevent-session-reaper") is not None, (
            "budevent-session-reaper is missing from cron.yaml"
        )

    def test_scope_is_budevent(self):
        components = _load_components()
        comp = _find(components, "budevent-session-reaper")
        assert comp is not None
        scopes = comp.get("scopes", [])
        assert "budevent" in scopes, (
            f"budevent-session-reaper scopes should include budevent, got {scopes}"
        )

    def test_schedule_is_daily(self):
        components = _load_components()
        comp = _find(components, "budevent-session-reaper")
        assert comp is not None
        schedule = _meta_value(comp, "schedule")
        assert schedule == "@every 24h", (
            f"Expected schedule '@every 24h', got '{schedule}'"
        )

    def test_route_matches_handler(self):
        components = _load_components()
        comp = _find(components, "budevent-session-reaper")
        assert comp is not None
        route = _meta_value(comp, "route")
        # budevent registers POST /cron/{name}; the reaper is /cron/session-reaper.
        assert route == "/cron/session-reaper", (
            f"Expected route '/cron/session-reaper', got '{route}'"
        )

    def test_direction_is_input(self):
        components = _load_components()
        comp = _find(components, "budevent-session-reaper")
        assert comp is not None
        direction = _meta_value(comp, "direction")
        assert direction == "input", f"Expected direction 'input', got '{direction}'"
