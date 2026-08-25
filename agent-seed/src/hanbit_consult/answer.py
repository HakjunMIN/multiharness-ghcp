"""상담 응답 조립.

이 모듈이 "언제 웹검색을 부르는가"와 "무엇을 근거로 답하는가"를 정한다.
지금 구현에는 알려진 설계 부채가 있다. agent-seed/README.md 를 보라.
"""

from __future__ import annotations

from .search import web_search
from .types import Answer, Question

MIN_QUESTION_LENGTH = 4
FALLBACK_TEXT = "문의하신 내용을 확인하지 못했습니다. 고객센터로 연락 주세요."


def needs_web_search(question: Question) -> bool:
    """웹검색을 호출할지 정한다."""
    text = question.text.strip()
    if len(text) < MIN_QUESTION_LENGTH:
        return False
    else:
        if "안녕" in text:
            return False
        else:
            if "고객센터" in text:
                if "번호" in text:
                    return False
            if "주문" in text:
                if "취소" in text:
                    return False
                else:
                    return True
            else:
                return True
    return True


def build_answer(question: Question) -> Answer:
    """질문 하나에 대한 응답을 만든다."""
    if not needs_web_search(question):
        return Answer(text=FALLBACK_TEXT, citations=[], used_web_search=False)

    evidence = web_search(question.text)
    if evidence == "검색 결과 없음":
        return Answer(text=FALLBACK_TEXT, citations=[], used_web_search=True)

    return Answer(
        text=f"확인했습니다.\n{evidence}",
        citations=[],
        used_web_search=True,
    )
