import os

import pytest
from fastapi.testclient import TestClient

from consult.main import app

DEFAULT_SMOKE_QUESTION = "공개 제품 정보와 출처 하나를 알려 주세요."


@pytest.mark.live
def test_consult_through_managed_apim():
    question = os.getenv("LIVE_SMOKE_QUESTION", DEFAULT_SMOKE_QUESTION)

    response = TestClient(app).post("/api/consult", json={"question": question})

    assert response.status_code == 200
    payload = response.json()
    assert payload["answer"]
    assert payload["citations"]
