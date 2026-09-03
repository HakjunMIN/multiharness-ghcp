# Microsoft Agent Framework for Python

Use this reference when working on the Python API in `app/api`.

## Authoritative sources

- Repository: <https://github.com/microsoft/agent-framework/tree/main/python>
- Samples: <https://github.com/microsoft/agent-framework/tree/main/python/samples>

Public samples usually authenticate straight to Azure OpenAI or OpenAI. This
repository routes everything through APIM instead, so translate samples onto the
boundary in `SKILL.md` rather than copying their client setup.

## Packages

Dependencies are pinned in `app/api/pyproject.toml` and managed with `uv`. Do not
`pip install agent-framework`; add or change dependencies through `uv` so the
lockfile stays in sync.

The import name is `agent_framework` (core) and `agent_framework_openai` (clients).
There is no `agents_framework` package; treat that spelling as a sign the source
material is wrong.

## Python-specific guidance

- Use async patterns throughout agent and workflow operations.
- Add type hints and keep APIs explicit.
- Verify an unfamiliar API against the installed package under
  `app/api/.venv/lib/python3.12/site-packages/agent_framework*/` before using it.
  The preview API surface moves faster than blog posts and model memory.
