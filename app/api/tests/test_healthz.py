from fastapi.testclient import TestClient

from consult.main import app
from consult.settings import Settings


def test_settings_use_safe_brand_default(monkeypatch):
    monkeypatch.delenv("BRAND_NAME", raising=False)

    settings = Settings.from_env(require_apim=False)

    assert settings.brand_name == "한빛전자"


def test_healthz_exposes_no_secret(monkeypatch):
    monkeypatch.setenv("APIM_KEY", "must-not-leak")

    response = TestClient(app).get("/healthz")

    assert response.status_code == 200
    assert response.json() == {"status": "ok", "brand": "한빛전자"}
    assert "must-not-leak" not in response.text
