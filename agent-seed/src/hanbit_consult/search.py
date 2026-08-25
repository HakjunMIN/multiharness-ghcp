"""웹검색 도구.

워크샵 테스트는 네트워크를 쓰지 않는다. 기본 백엔드는 리포에 커밋된
fixture 를 읽는 오프라인 인덱스이며, 실제 검색 백엔드를 붙이는 것은
``SearchBackend`` 를 갈아끼우는 일이다.
"""

from __future__ import annotations

import json
from collections.abc import Sequence
from pathlib import Path
from typing import Protocol

from .types import SearchResult

_FIXTURE_DIR = Path(__file__).parent / "fixtures"


class SearchBackend(Protocol):
    """검색 백엔드가 만족해야 하는 최소 계약."""

    def search(self, query: str, *, limit: int = 3) -> Sequence[SearchResult]:
        """``query`` 에 대한 검색 결과를 관련도 순으로 돌려준다."""
        ...


class OfflineIndex:
    """커밋된 fixture 위에서 도는 검색 백엔드.

    관련도 계산은 질의어 토큰이 제목과 본문에 몇 번 나오는지 세는 것이
    전부다. 워크샵의 학습 목표는 검색 품질이 아니라 에이전트 배선이다.
    """

    def __init__(self, documents: Sequence[SearchResult] | None = None) -> None:
        self._documents = list(documents) if documents is not None else _load_fixtures()

    def search(self, query: str, *, limit: int = 3) -> Sequence[SearchResult]:
        tokens = [t for t in query.lower().split() if t]
        scored: list[tuple[int, SearchResult]] = []
        for doc in self._documents:
            haystack = f"{doc.title} {doc.snippet}".lower()
            score = sum(haystack.count(token) for token in tokens)
            if score > 0:
                scored.append((score, doc))
        scored.sort(key=lambda pair: (-pair[0], pair[1].url))
        return [doc for _, doc in scored[:limit]]


def _load_fixtures() -> list[SearchResult]:
    documents: list[SearchResult] = []
    for path in sorted(_FIXTURE_DIR.glob("*.json")):
        payload = json.loads(path.read_text(encoding="utf-8"))
        for entry in payload:
            documents.append(
                SearchResult(
                    title=entry["title"],
                    url=entry["url"],
                    snippet=entry["snippet"],
                )
            )
    return documents


_DEFAULT_BACKEND = OfflineIndex()


def web_search(query: str) -> str:
    """제품 지식을 웹에서 찾는다.

    상담 질문에 답할 근거가 필요할 때 호출한다. 결과는 사람이 읽을 수 있는
    형태의 문자열이며 각 항목에 출처 URL 이 포함된다.

    Args:
        query: 찾을 내용. 사용자의 질문을 그대로 넣지 말고 핵심어로 줄인다.
    """
    results = _DEFAULT_BACKEND.search(query)
    if not results:
        return "검색 결과 없음"
    lines = [f"- {r.title} ({r.url}): {r.snippet}" for r in results]
    return "\n".join(lines)
