from types import SimpleNamespace

from consult.agent import AgentFrameworkSynthesizer
from consult.retrieval import RetrievalResult
from consult.settings import Settings


async def test_agent_framework_synthesizer_uses_the_apim_model_route(monkeypatch):
    client_options = {}
    prompts = []

    class FakeClient:
        def __init__(self, **kwargs):
            client_options.update(kwargs)

    class FakeAgent:
        def __init__(self, client, instructions):
            assert isinstance(client, FakeClient)
            assert "근거" in instructions

        async def run(self, prompt):
            prompts.append(prompt)
            return SimpleNamespace(text="근거 기반 답변")

    monkeypatch.setattr("consult.agent.OpenAIChatClient", FakeClient)
    monkeypatch.setattr("consult.agent.Agent", FakeAgent)
    settings = Settings(
        brand_name="한빛전자",
        apim_base_url="https://workshop.example.invalid",
        apim_key="participant-key",
        knowledge_base_name="products",
    )
    synthesizer = AgentFrameworkSynthesizer(settings)

    answer = await synthesizer.synthesize(
        "제품을 알려 주세요.",
        RetrievalResult(answer="검색 근거", citations=[]),
    )

    assert answer == "근거 기반 답변"
    assert client_options == {
        "model": "workshop-model",
        "api_key": "apim-managed",
        "base_url": "https://workshop.example.invalid/model/v1",
        "default_headers": {
            "Ocp-Apim-Subscription-Key": "participant-key",
        },
    }
    assert "검색 근거" in prompts[0]