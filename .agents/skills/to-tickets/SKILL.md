---
name: to-tickets
description: "Turn the approved local spec into dependency-ordered, contract-first tickets for separate fresh implementation sessions."
disable-model-invocation: true
---

# To Tickets

1. Read `AGENTS.md`, `CONTEXT.md`, `docs/agents/issue-tracker.md`, the approved
   `docs/work/<feature>/spec.md`, discovery, prototype references and linked ADRs.
   Missing approval or input is a blocker, not permission to reconstruct prior chat.
2. Plan a contract-first vertical slice across separate tickets:
   API acceptance → backend → browser acceptance → frontend integration → UX/error
   improvement. Acceptance tickets change tests, not production, and explicitly
   expect red until the corresponding implementation. Each ticket fits one fresh
   session; do not require every ticket to implement all layers.
3. Present all titles, deliverables and `Blocked by` edges for user approval.
   Dependencies must be acyclic and reflect actual prerequisites. Include only
   refactoring needed by the approved scope.
4. Publish all approved tickets in this planning session, one file per ticket at
   `docs/work/<feature>/tickets/<NN>-<slug>.md`, numbered from `01`, blockers first.
   Use local files only; do not create or modify remote tracker issues.
5. A frontier ticket is `ready-for-agent` with every blocker `done`. Hand off to a
   fresh implementation session rather than starting the first ticket here.

<local-ticket-template>

# <NN>: <Ticket title>

**What to build:** observable scope, role (acceptance or implementation), and exclusions.

**Blocked by:** the numbers/titles of the tickets that gate this one, or "None (can start immediately)".

**Status:** ready-for-agent

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

**Verify:** existing commands with expected green or red and reason; label operator-gated live checks separately.

**Decisions:** links to spec, discovery, prototype, CONTEXT.md and relevant ADRs.

</local-ticket-template>
