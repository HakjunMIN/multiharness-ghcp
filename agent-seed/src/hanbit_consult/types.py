"""상담 에이전트가 다루는 값들.

이 모듈에는 정책이 없다. 정책은 answer.py 와 telemetry.py 에 있다.
"""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(frozen=True)
class SearchResult:
    """웹검색 한 건."""

    title: str
    url: str
    snippet: str


@dataclass(frozen=True)
class Question:
    """상담 요청 한 건.

    Attributes:
        text: 사용자가 실제로 쓴 질문.
        region: 사용자가 있는 지역. ISO 3166-1 alpha-2 또는 ``"EU"``.
        telemetry_opt_out: 사용자가 텔레메트리 수집을 거부했는가.
    """

    text: str
    region: str
    telemetry_opt_out: bool = False


@dataclass
class Answer:
    """상담 응답 한 건."""

    text: str
    citations: list[SearchResult] = field(default_factory=list)
    used_web_search: bool = False
