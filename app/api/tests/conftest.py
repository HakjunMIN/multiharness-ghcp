import os

import pytest

REQUIRED_LIVE_SETTINGS = ("APIM_BASE_URL", "APIM_KEY", "KNOWLEDGE_BASE_NAME")


def _missing_live_settings() -> list[str]:
    return [name for name in REQUIRED_LIVE_SETTINGS if not os.getenv(name)]


def pytest_configure(config: pytest.Config) -> None:
    markexpr = config.option.markexpr or ""
    if "live" in markexpr and "not live" not in markexpr:
        missing = _missing_live_settings()
        if missing:
            raise pytest.UsageError(
                "explicit live run requires: " + ", ".join(missing)
            )


def pytest_runtest_setup(item: pytest.Item) -> None:
    if "live" not in item.keywords:
        return

    missing = _missing_live_settings()
    if missing:
        pytest.skip("live credentials missing: " + ", ".join(missing))
