import pytest
from fastapi.testclient import TestClient

from consult.main import app


@pytest.mark.live
def test_consult_through_instructor_apim():
    response = TestClient(app).post(
        "/api/consult",
        json={"question": "공개 제품 정보와 출처 하나를 알려 주세요."},
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["answer"]
    assert payload["citations"]