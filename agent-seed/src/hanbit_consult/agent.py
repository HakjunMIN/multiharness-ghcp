"""Microsoft Agent Framework 로 상담 에이전트를 조립한다.

모델 클라이언트는 밖에서 주입한다. 테스트는 ``ScriptedChatClient`` 를 넣고,
실제 실행은 ``OpenAIChatClient`` 같은 진짜 클라이언트를 넣는다.
어느 쪽이든 이 모듈은 바뀌지 않는다.
"""

from __future__ import annotations

from collections.abc import Sequence
from typing import Any

from agent_framework import Agent, ChatResponse, Message

from .search import web_search

INSTRUCTIONS = """너는 한빛전자 제품 상담원이다.

- 제품 사양, 보증, 수리에 대한 질문에는 web_search 도구로 근거를 찾은 뒤 답한다.
- 근거를 찾지 못하면 추측하지 말고 고객센터 안내로 넘긴다.
- 답변에는 근거의 출처 URL 을 함께 적는다.
"""


def build_agent(client: Any, *, name: str = "hanbit-consult") -> Agent:
    """상담 에이전트를 만든다.

    Args:
        client: ``SupportsChatGetResponse`` 를 만족하는 모델 클라이언트.
        name: 에이전트 이름.
    """
    return Agent(
        client=client,
        name=name,
        instructions=INSTRUCTIONS,
        tools=[web_search],
    )


class ScriptedChatClient:
    """오프라인 테스트용 모델 클라이언트.

    Agent 는 ``SupportsChatGetResponse`` 구조적 프로토콜만 요구한다.
    상속이 아니라 모양이 맞으면 된다. 그래서 네트워크 없이 에이전트 배선을
    통째로 테스트할 수 있다.
    """

    def __init__(self, replies: Sequence[str]) -> None:
        if not replies:
            raise ValueError("replies 는 최소 한 개가 필요합니다")
        self._replies = list(replies)
        self._turn = 0
        self.additional_properties: dict[str, Any] = {}
        self.seen: list[list[Message]] = []

    def get_response(self, messages: Sequence[Message], **kwargs: Any) -> Any:
        self.seen.append(list(messages))
        reply = self._replies[min(self._turn, len(self._replies) - 1)]
        self._turn += 1

        async def _respond() -> ChatResponse:
            return ChatResponse(messages=[Message("assistant", [reply])])

        return _respond()
