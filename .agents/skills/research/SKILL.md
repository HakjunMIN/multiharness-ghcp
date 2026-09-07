---
name: research
description: "Investigate questions using primary sources and report cited findings; update local artifacts only when authorized. Use for topic research, documentation or API fact-checking."
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
