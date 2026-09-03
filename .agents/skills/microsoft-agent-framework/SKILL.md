---
name: microsoft-agent-framework
description: 'Create, update, refactor, explain, or review Microsoft Agent Framework code in this repository. Binds MAF usage to the fixed APIM runtime boundary defined in AGENTS.md.'
---

# Microsoft Agent Framework

Use this skill when working on agents, workflows, or model calls built on Microsoft
Agent Framework in this repository.

Microsoft Agent Framework is the unified successor to Semantic Kernel and AutoGen.
It is still in public preview and changes quickly, so ground implementation advice
in the installed package version and the latest official docs rather than stale
knowledge.

This repository is Python only. See [references/python.md](references/python.md).

## Fixed APIM boundary (overrides upstream guidance)

`AGENTS.md` defines a fixed runtime boundary. It wins over any generic MAF advice,
including the upstream guidance to prefer Azure AI Foundry clients or
`DefaultAzureCredential`.

- All LLM traffic goes through APIM. Do not call Azure OpenAI, Azure AI Foundry,
  or api.openai.com directly, and do not add a second provider path.
- There is exactly one credential pair: `APIM_BASE_URL` and `APIM_KEY`. Do not
  introduce a separate model endpoint or a runtime model-ID setting.
- Answer synthesis targets `${APIM_BASE_URL}/model/v1/responses`, so the MAF client
  base URL is `${APIM_BASE_URL}/model/v1`.
- Authenticate with the `Ocp-Apim-Subscription-Key` header. Do not use
  `DefaultAzureCredential`, managed identity, or `AZURE_OPENAI_*` environment
  variables.
- Foundry IQ retrieval is a plain HTTP call to
  `${APIM_BASE_URL}/search/knowledgebases/${KNOWLEDGE_BASE_NAME}/retrieve`, not a
  MAF model client. Keep retrieval separate from the MAF chat client.
- Read settings through `consult.settings.Settings.from_env()`. Never read APIM
  env vars ad hoc, never hardcode them, and never log `APIM_KEY` or a real base URL.

### Wiring the client

`agent-framework-openai` exposes `OpenAIChatClient`, which speaks the Responses API
and accepts a base URL, an API key, and extra headers. Point it at APIM:

```python
from agent_framework_openai import OpenAIChatClient

MODEL = "gpt-4.1-mini"  # code-level constant, not a runtime setting

client = OpenAIChatClient(
    MODEL,
    base_url=f"{settings.apim_base_url}/model/v1",
    api_key=settings.apim_key,
    default_headers={"Ocp-Apim-Subscription-Key": settings.apim_key},
)
```

The client appends `/responses` to the base URL, which yields the
`${APIM_BASE_URL}/model/v1/responses` target that `AGENTS.md` requires.

The constructor requires `model`; omitting it raises `SettingNotFoundError`. Keep
it a constant in code so no runtime model-ID setting is added, per `AGENTS.md`.
APIM decides the actual deployment.

## Shared guidance

- Use async patterns for agent and workflow operations.
- Implement explicit error handling and logging.
- Prefer strong typing, clear interfaces, and maintainable composition patterns.
- Use agents for autonomous decision-making, conversation flows, and tool usage.
- Use workflows for multi-step orchestration, predefined execution graphs, and
  human-in-the-loop scenarios.
- Use thread-based state handling, context providers, and middleware when they fit.

## Testing

- Default unit and contract tests must not touch the network. Stub the MAF client
  or the underlying transport.
- Tests must not depend on a real `.env`; `Settings.from_env` already skips
  `load_dotenv` under pytest.
- Any test that reaches live APIM belongs behind the `live` pytest marker.

## Workflow

1. Read `AGENTS.md` and the relevant ticket before changing agent code.
2. Confirm the installed package versions in `app/api/pyproject.toml`, then check
   the installed package source or current docs before using an unfamiliar API.
3. Keep every model call inside the APIM boundary above.
4. Verify with `(cd app/api && uv run --frozen pytest -q)`.

## Completion criteria

- Model traffic goes through `${APIM_BASE_URL}/model/v1` with the
  `Ocp-Apim-Subscription-Key` header, and no other provider path exists.
- No new model endpoint, model-ID, or credential setting was introduced.
- Retrieval stays a separate HTTP call from the MAF chat client.
- Default tests still pass offline; live checks stay behind the `live` marker.

Upstream source: `github/awesome-copilot` `skills/microsoft-agent-framework`,
adapted for this repository's fixed APIM boundary.
