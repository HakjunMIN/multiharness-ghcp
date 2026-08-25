from types import SimpleNamespace

import pytest

from conftest import pytest_configure


def test_explicit_live_run_requires_credentials(monkeypatch):
    for name in ("APIM_BASE_URL", "APIM_KEY", "KNOWLEDGE_BASE_NAME"):
        monkeypatch.delenv(name, raising=False)

    config = SimpleNamespace(option=SimpleNamespace(markexpr="live"))

    with pytest.raises(pytest.UsageError, match="APIM_BASE_URL"):
        pytest_configure(config)


def test_default_non_live_run_does_not_require_credentials(monkeypatch):
    for name in ("APIM_BASE_URL", "APIM_KEY", "KNOWLEDGE_BASE_NAME"):
        monkeypatch.delenv(name, raising=False)

    config = SimpleNamespace(option=SimpleNamespace(markexpr="not live"))

    pytest_configure(config)