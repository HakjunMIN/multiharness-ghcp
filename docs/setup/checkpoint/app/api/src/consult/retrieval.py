from dataclasses import dataclass
from typing import Any, Protocol
from urllib.parse import quote

import httpx

from consult.contracts import Citation
from consult.settings import Settings


@dataclass(frozen=True)
class RetrievalResult:
    answer: str
    citations: list[Citation]


class Retriever(Protocol):
    async def retrieve(self, question: str) -> RetrievalResult: ...


def _answer_text(payload: dict[str, Any]) -> str:
    answer = payload.get("answer")
    if isinstance(answer, str):
        return answer

    response = payload.get("response", [])
    for item in response if isinstance(response, list) else []:
        content = item.get("content") if isinstance(item, dict) else None
        if isinstance(content, str):
            return content
        for part in content if isinstance(content, list) else []:
            if isinstance(part, dict) and isinstance(part.get("text"), str):
                return part["text"]
    return "근거를 찾지 못했습니다."


def parse_retrieve_response(payload: dict[str, Any]) -> RetrievalResult:
    references = payload.get("references", [])
    citations = [
        Citation(title=str(item.get("title", "출처")), url=str(item["url"]))
        for item in references
        if isinstance(item, dict) and item.get("url")
    ]
    return RetrievalResult(answer=_answer_text(payload), citations=citations)


class RecordedRetriever:
    def __init__(self, payload: dict[str, Any]) -> None:
        self._payload = payload

    async def retrieve(self, question: str) -> RetrievalResult:
        return parse_retrieve_response(self._payload)


class ApimRetriever:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    async def retrieve(self, question: str) -> RetrievalResult:
        base_url = self._settings.apim_base_url or ""
        knowledge_base = quote(self._settings.knowledge_base_name or "", safe="")
        url = (
            f"{base_url.rstrip('/')}/search/knowledgebases/{knowledge_base}/retrieve"
            "?api-version=2026-04-01"
        )
        headers = {"Ocp-Apim-Subscription-Key": self._settings.apim_key or ""}
        body = {"intents": [{"type": "semantic", "search": question}]}
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(url, headers=headers, json=body)
            response.raise_for_status()
        return parse_retrieve_response(response.json())
