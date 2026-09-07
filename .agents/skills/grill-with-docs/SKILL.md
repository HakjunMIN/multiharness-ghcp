---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go.
disable-model-invocation: true
---

Read `AGENTS.md` and `CONTEXT.md`. Use the project `grilling` and `domain-modeling`
skills through the harness's skill mechanism; if unavailable, read their local
`SKILL.md` files and follow them without inventing a tool.

When the decision frontier is closed and the user approves, commit
`docs/work/<feature>/discovery.md` with the decisions, facts and sources, constraints,
dependencies, open questions and CONTEXT/ADR links. Hand off to a fresh prototype
session; do not proceed to planning or implementation here.
