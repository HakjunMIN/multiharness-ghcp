from typing import Protocol

from agent_framework import Agent
from agent_framework_openai import OpenAIChatClient

from consult.retrieval import RetrievalResult
from consult.settings import Settings


class Synthesizer(Protocol):
    async def synthesize(self, question: str, retrieval: RetrievalResult) -> str: ...


class RecordedSynthesizer:
    def __init__(self, answer: str) -> None:
        self._answer = answer
        self.questions: list[str] = []
        self.evidence: list[str] = []

    async def synthesize(self, question: str, retrieval: RetrievalResult) -> str:
        self.questions.append(question)
        self.evidence.append(retrieval.answer)
        return self._answer


class AgentFrameworkSynthesizer:
    def __init__(self, settings: Settings) -> None:
        base_url = settings.apim_base_url or ""
        client = OpenAIChatClient(
            model="workshop-model",
            api_key="apim-managed",
            base_url=f"{base_url.rstrip('/')}/model/v1",
            default_headers={
                "Ocp-Apim-Subscription-Key": settings.apim_key or "",
            },
        )
        self._agent = Agent(
            client,
            instructions=(
                f"당신은 {settings.brand_name} 제품 상담원입니다. "
                "제공된 공개 웹 근거만 사용하고 근거에 없는 내용은 추측하지 마세요."
            ),
        )

    async def synthesize(self, question: str, retrieval: RetrievalResult) -> str:
        citations = "\n".join(
            f"- {citation.title}: {citation.url}" for citation in retrieval.citations
        )
        response = await self._agent.run(
            f"질문: {question}\n\n검색 근거:\n{retrieval.answer}\n\n출처:\n{citations}"
        )
        return response.text