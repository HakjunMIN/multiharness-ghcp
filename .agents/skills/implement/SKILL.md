---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

1. Read `AGENTS.md`, `CONTEXT.md`, the approved spec, one ticket, and linked ADRs.
   If `HANDOFF` exists, check its artifacts/commit and run `verify` first; resolve
   any mismatch with `expected` before proceeding. Missing inputs or unfinished
   blockers prevent implementation.
2. Work only this ticket in this fresh session. Use `/tdd` at agreed seams.
   Acceptance tickets leave failing tests without changing production code.
3. Run existing targeted tests and typechecks during work, then the relevant full
   suites. Keep default tests offline and live checks behind the operator's gate.
4. Record observed results and ticket status; do not mark unverified criteria done.
   Commit the ticket's changes on the current branch, then write and separately
   commit `HANDOFF` using `docs/reference/handoff-contract.md`.
5. Hand off `/code-review` and UAT to a fresh independent verification session.
   Self-checking this diff does not replace independent verification.
