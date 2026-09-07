---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.
---

1. Define the question and check **primary sources**: official docs, source code,
   specs or first-party APIs. Cite the source owning each claim; distinguish
   verified facts, inference and unknowns. Do not send private repository content,
   credentials or provider payloads to external search services.
2. Delegate read-only research when the harness supports sub-agents and there is
   independent work to do meanwhile. Otherwise research directly; do not assume a
   particular tool exists.
3. Return findings with sources and limitations. When documenting is authorized,
   update the relevant local work item or reference instead of creating duplicate
   notes. Follow `AGENTS.md` for durable artifacts and role boundaries.
