from hanbit_consult import Question, build_answer, needs_web_search
from hanbit_consult.answer import FALLBACK_TEXT


def test_searches_for_a_product_question() -> None:
    assert needs_web_search(Question("HB-9000 보증 기간 알려주세요", "KR"))


def test_does_not_search_for_a_greeting() -> None:
    assert not needs_web_search(Question("안녕하세요", "KR"))


def test_does_not_search_for_a_question_that_is_too_short() -> None:
    assert not needs_web_search(Question("응", "KR"))


def test_does_not_search_for_an_order_cancellation() -> None:
    assert not needs_web_search(Question("주문 취소하고 싶어요", "KR"))


def test_searches_for_an_order_status_question() -> None:
    assert needs_web_search(Question("주문 언제 도착하나요", "KR"))


def test_answers_a_product_question_with_evidence() -> None:
    answer = build_answer(Question("HB-9000 보증 기간 알려주세요", "KR"))
    assert answer.used_web_search
    assert "https://" in answer.text


def test_falls_back_when_nothing_is_found() -> None:
    answer = build_answer(Question("존재하지않는제품명에대하여", "KR"))
    assert answer.text == FALLBACK_TEXT


def test_falls_back_without_searching_for_a_greeting() -> None:
    answer = build_answer(Question("안녕하세요", "KR"))
    assert answer.text == FALLBACK_TEXT
    assert not answer.used_web_search


def test_known_gap_the_region_is_not_consulted_before_web_search() -> None:
    """알려진 부채: EU 사용자의 질문도 그대로 외부 검색으로 나간다.

    지역별 규제를 반영하면 이 기대값을 뒤집어야 한다. 테스트를 지우지 말고
    기대값을 바꾸고, 그 이유를 커밋 메시지에 적는다.
    """
    korea = build_answer(Question("HB-9000 보증 기간 알려주세요", "KR"))
    europe = build_answer(Question("HB-9000 보증 기간 알려주세요", "EU"))
    assert korea.text == europe.text
    assert europe.used_web_search is True


def test_known_gap_the_answer_carries_no_structured_citations() -> None:
    """알려진 부채: 근거 URL 이 본문 문자열에만 있고 citations 는 비어 있다.

    출처를 구조화해서 돌려주면 이 기대값을 뒤집어야 한다.
    """
    answer = build_answer(Question("HB-9000 보증 기간 알려주세요", "KR"))
    assert answer.citations == []
