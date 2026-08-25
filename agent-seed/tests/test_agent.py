"""에이전트 배선 테스트. 네트워크를 쓰지 않는다."""

import pytest

from hanbit_consult import INSTRUCTIONS, ScriptedChatClient, build_agent


async def test_runs_without_network() -> None:
    client = ScriptedChatClient(["HB-9000 의 기본 보증은 24개월입니다."])
    agent = build_agent(client)
    response = await agent.run("HB-9000 보증 기간 알려주세요")
    assert "24개월" in response.text


async def test_passes_the_user_question_to_the_model() -> None:
    client = ScriptedChatClient(["확인했습니다."])
    agent = build_agent(client)
    await agent.run("HB-9000 무게가 어떻게 되나요")
    sent = "".join(m.text for m in client.seen[0])
    assert "HB-9000" in sent


def test_registers_the_web_search_tool() -> None:
    agent = build_agent(ScriptedChatClient(["확인했습니다."]))
    names = {tool.name for tool in agent.default_options["tools"]}
    assert "web_search" in names


def test_the_instructions_forbid_guessing() -> None:
    assert "추측하지" in INSTRUCTIONS


def test_a_scripted_client_needs_at_least_one_reply() -> None:
    with pytest.raises(ValueError):
        ScriptedChatClient([])


async def test_replies_are_consumed_in_order() -> None:
    client = ScriptedChatClient(["첫 번째", "두 번째"])
    agent = build_agent(client)
    assert "첫 번째" in (await agent.run("질문 하나")).text
    assert "두 번째" in (await agent.run("질문 둘")).text
