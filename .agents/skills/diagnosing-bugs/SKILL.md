---
name: diagnosing-bugs
description: Diagnosis loop for hard bugs and performance regressions. Use when the user says "diagnose"/"debug this", or reports something broken/throwing/failing/slow.
---

# Diagnosing Bugs

Read `AGENTS.md`, `CONTEXT.md`, the ticket or defect and linked ADRs. A verifier
diagnoses and records a local defect; only an implementation session may fix production.

## 1. Establish the failing signal

Use an existing test, local HTTP/CLI invocation, browser scenario or synthetic fixture
to reproduce the user's exact symptom. Record one command you actually ran, the
expected result and the observed failure. A crash-free run alone is not an assertion.

Keep the loop fast and offline. For intermittent failures, pin controllable inputs
and measure failure count / attempts rather than claiming determinism. For performance,
measure a baseline before making a change. If human interaction is unavoidable, use
the local [HITL template](scripts/hitl-loop.template.sh).

If no useful reproduction is possible, report attempts and the missing access or
evidence. Do not present a speculative cause as a diagnosis or add production
instrumentation without permission.

## 2. Minimise and discriminate

- Reduce inputs and steps one at a time, retaining the original symptom.
- Rank plausible competing causes and state a falsifiable prediction for each;
  do not invent extra hypotheses to fill a quota.
- Test one prediction / change one variable at a time. Prefer debugger inspection,
  targeted instrumentation, or a measured old/new comparison over broad logging.
- Revise the hypothesis when evidence disagrees; retain the original repro for
  final verification.

## 3. Fix or hand off

At an agreed seam that exercises the real failure, preserve a failing regression
test before the fix. If no suitable seam exists, document that limitation.

- Verification or acceptance role: record expected/actual results and reproduction
  in the local work item, then hand off; expected red is valid here.
- Implementation role: apply the scoped fix, run the regression and the original
  repro, then relevant existing suites. Explain the supported cause, not just the edit.

## Evidence and cleanup

Never collect or print credentials, customer identifiers, original questions/answers
or provider payloads. Use synthetic fixtures and non-sensitive diagnostics; live
APIM checks require the operator's `e2e` gate. Redaction is not permission to commit
raw captures.

Remove temporary instrumentation and scratch artifacts you added, without deleting
existing regression tests or committed prototype references. Report commands,
results, unresolved limitations and hand off under `AGENTS.md`.
