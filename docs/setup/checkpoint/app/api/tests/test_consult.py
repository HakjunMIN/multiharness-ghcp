import json
from pathlib import Path

from fastapi.testclient import TestClient

from consult.agent import RecordedSynthesizer
from consult.main import app, get_retriever, get_synthesizer
from consult.retrieval import RecordedRetriever


def test_consult_returns_answer_and_structured_citations():
    fixture = json.loads(
        (Path(__file__).parent / "fixtures" / "foundry_iq_retrieve.json").read_text()
    )
    retriever = RecordedRetriever(fixture)
    synthesizer = RecordedSynthesizer("공개 웹 근거를 찾았습니다.")
    app.dependency_overrides[get_retriever] = lambda: retriever
    app.dependency_overrides[get_synthesizer] = lambda: synthesizer

    try:
        response = TestClient(app).post(
            "/api/consult",
            json={"question": "제품 정보를 알려 주세요."},
        )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert response.json() == {
        "answer": "공개 웹 근거를 찾았습니다.",
        "citations": [
            {
                "title": "제품 개요",
                "url": "https://example.invalid/products/overview",
            }
        ],
    }
    assert synthesizer.questions == ["제품 정보를 알려 주세요."]
    assert "https://example.invalid/products/overview" in synthesizer.evidence[0]
