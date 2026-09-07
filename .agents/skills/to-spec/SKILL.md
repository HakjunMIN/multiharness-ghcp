---
name: to-spec
description: "Synthesize approved discovery and prototype artifacts into the feature's local spec in a fresh planning session."
disable-model-invocation: true
---

1. Read `AGENTS.md`, `CONTEXT.md`, `docs/agents/issue-tracker.md`, the feature's
   `discovery.md`, decided `prototype.md`, `prototype/` references, and linked ADRs.
   Use committed artifacts, not previous conversation history. If approval or a
   required artifact is missing, report the blocker rather than inventing a decision.
2. Check relevant code and agree observable test seams with the user. Prefer existing,
   high-level seams; keep network-free tests separate from operator-gated live checks.
3. Use `docs/templates/spec.md` without duplicating its template here. Cover the
   approved scope with non-redundant user stories, contracts, test decisions and
   exclusions; do not pad the story count or add speculative features.
4. Publish the approved `docs/work/<feature>/spec.md`, linking its decision sources.
   Include code only if a small prototype excerpt expresses a decision more precisely
   than prose, with its source ref.
5. Continue with `/to-tickets` in this same planning session to publish all tickets
   for the feature. Do not implement; each ticket belongs to a fresh implementation
   session after the spec and tickets have been reviewed.
