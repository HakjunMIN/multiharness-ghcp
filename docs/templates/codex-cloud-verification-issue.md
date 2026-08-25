# Optional GHEC Codex cloud verification

## Role

Act as an independent verifier. Use the OpenAI Codex third-party coding agent
and the model selected when this task starts. Do not implement fixes.

## Durable inputs

- Read `AGENTS.md`.
- Read `docs/prompts/codex-verifier.md`.
- Read `docs/uat/acceptance-matrix.md`.
- Read the latest `## HANDOFF` comment on the map Issue linked below.
- Treat committed Issues and repository files as authoritative; do not rely on
  prior chat context.

## Verification target

- Map Issue: replace this line with the map Issue URL before creating the Issue.
- Source commit: replace this line with `git rev-parse HEAD` before creating the Issue.
- Source branch: replace this line with `git branch --show-current` before creating the Issue.

The task must start from the source branch above. The agent will create its own
working branch, so its branch name will differ. Before making any report change,
confirm only that the initial `git rev-parse HEAD` equals the recorded source
commit. If it does not, record the mismatch in `docs/uat/report.md` and stop
without testing another revision.

## Commands

```bash
(cd seed && npm test)
node --disable-warning=ExperimentalWarning --test docs/uat/acceptance.test.ts
./scripts/check-repo.sh
```

## Output contract

1. Create or update only `docs/uat/report.md` from
   `docs/templates/uat-report.md`.
2. Record the selected model and these exact metadata lines:

   ```text
   - source branch: <the Source branch value from this Issue>
   - source commit: <the Source commit value from this Issue>
   ```

3. Record each command, relevant actual output, expected result, and pass/fail
   verdict.
4. Create a draft pull request for human review.
5. If a criterion fails, record reproducible evidence in the report. Do not
   change implementation code.

## Hard write boundary

The only allowed changed file is:

```text
docs/uat/report.md
```

Do not modify anything under `seed/` or any other repository path. If another
change seems necessary, describe it in the report instead.
