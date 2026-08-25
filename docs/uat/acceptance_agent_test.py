"""에이전트 트랙의 독립 UAT.

이 파일은 구현 세션이 시작되기 전에 확정된 블랙박스 계약이다.
참가자는 이 파일을 수정하지 않는다. 시드 상태에서 실패하는 것이 정상이다.

실행:

    cd agent-seed && uv run --frozen pytest ../docs/uat/acceptance_agent_test.py
"""

from __future__ import annotations

import pytest

from hanbit_consult import Question, TelemetrySink, build_answer

RESTRICTED = "EU"
ALLOWED = "KR"
PRODUCT_QUESTION = "한빛 냉장고 소음 문제 해결 방법"


@pytest.fixture
def sink() -> TelemetrySink:
    return TelemetrySink()


def test_auat_01_restricted_region_never_reaches_web_search() -> None:
    """AUAT-01: 제한 지역의 질문은 외부 검색으로 나가지 않는다."""
    answer = build_answer(Question(text=PRODUCT_QUESTION, region=RESTRICTED))
    assert answer.used_web_search is False


def test_auat_02_allowed_region_uses_web_search() -> None:
    """AUAT-02: 허용 지역에서는 검색이 정상 동작한다."""
    answer = build_answer(Question(text=PRODUCT_QUESTION, region=ALLOWED))
    assert answer.used_web_search is True


def test_auat_03_grounded_answers_carry_structured_citations() -> None:
    """AUAT-03: 검색을 쓴 응답은 기계가 검증할 수 있는 출처를 갖는다."""
    answer = build_answer(Question(text=PRODUCT_QUESTION, region=ALLOWED))
    assert answer.citations, "검색 기반 응답에는 출처가 최소 한 건 있어야 한다"
    assert all("://" in citation.url for citation in answer.citations)


def test_auat_04_opt_out_records_nothing(sink: TelemetrySink) -> None:
    """AUAT-04: 옵트아웃한 사용자의 상담은 기록되지 않는다."""
    question = Question(text=PRODUCT_QUESTION, region=ALLOWED, telemetry_opt_out=True)
    sink.record(question, build_answer(question))
    assert sink.events == []


def test_auat_05_opt_in_records_one_event(sink: TelemetrySink) -> None:
    """AUAT-05: 옵트인 상태에서는 관측이 유지된다."""
    question = Question(text=PRODUCT_QUESTION, region=ALLOWED, telemetry_opt_out=False)
    sink.record(question, build_answer(question))
    assert len(sink.events) == 1


def test_auat_06_the_raw_question_text_is_never_stored(sink: TelemetrySink) -> None:
    """AUAT-06: 기록에 질문 원문이 그대로 남지 않는다."""
    question = Question(text=PRODUCT_QUESTION, region=ALLOWED)
    sink.record(question, build_answer(question))
    assert all(
        PRODUCT_QUESTION not in event.question_text for event in sink.events
    )
