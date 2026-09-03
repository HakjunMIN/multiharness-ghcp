import os

import pytest

REQUIRED_E2E_SETTINGS = ("APIM_BASE_URL", "APIM_KEY", "KNOWLEDGE_BASE_NAME")


def _missing_e2e_settings() -> list[str]:
    return [name for name in REQUIRED_E2E_SETTINGS if not os.getenv(name)]


def pytest_configure(config: pytest.Config) -> None:
    markexpr = config.option.markexpr or ""
    if "e2e" in markexpr and "not e2e" not in markexpr:
        missing = _missing_e2e_settings()
        if missing:
            raise pytest.UsageError(
                "explicit e2e run requires: " + ", ".join(missing)
            )


def pytest_runtest_setup(item: pytest.Item) -> None:
    if "e2e" not in item.keywords:
        return

    missing = _missing_e2e_settings()
    if missing:
        pytest.skip("e2e credentials missing: " + ", ".join(missing))
