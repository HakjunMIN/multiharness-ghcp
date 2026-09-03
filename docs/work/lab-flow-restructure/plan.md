# Backend-First Lab Flow Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorder the workshop into prototype-first, backend-first, then frontend integration labs while replacing Python's `live` test marker with gated `e2e` and removing cold-start checkpoint assets.

**Architecture:** The workshop remains a documentation-driven workflow with fresh sessions and committed durable artifacts. The implementation is split into four coherent changes: test/runtime terminology, lab files, workflow contracts, and repository integrity tests; each change is independently reviewable and ends green.

**Tech Stack:** Markdown, Bash, Python 3.11, pytest 8.4.2, React, Vitest, Playwright, GitHub Actions

## Global Constraints

- Keep `POST /api/consult` request field `question` and response field `answer`.
- Use only `APIM_BASE_URL` and `APIM_KEY` for APIM runtime access; do not add model endpoint or model ID settings.
- Default unit and contract tests must not use external networks.
- Python `uv run --frozen pytest -m e2e -q` is the gated real-APIM suite; remove the Python `live` marker.
- JavaScript names remain `npm run test:e2e` for deterministic interception and `npm run test:e2e:live` for the real full-stack flow.
- Prototype is mandatory and must commit the selected static reference under `docs/work/<feature>/prototype/`.
- Frontend body copy must prefer Nanum Gothic.
- Do not change the decisions in `docs/work/consult-ui-prototype/discovery.md`; only repair its renamed lab link.
- Do not modify `.worktrees/`.
- Do not run gated APIM or browser-live suites without operator approval and credentials.

---

## File Map

### Runtime boundary

- Modify `app/api/pyproject.toml`: replace the `live` pytest marker and default exclusion with `e2e`.
- Modify `app/api/tests/conftest.py`: require credentials only for explicit `e2e` runs.
- Rename `app/api/tests/test_live_config.py` to `app/api/tests/test_e2e_config.py`: lock the new gate behavior.
- Rename `scripts/test-live.sh` to `scripts/test-e2e.sh`: load `.env` and invoke the new marker.
- Rename `tests/scripts/test-live-test-boundary.sh` to `tests/scripts/test-e2e-boundary.sh`: validate the runtime boundary from participant-owned files.

### Labs

- Keep `docs/labs/lab0-preflight.md` and `docs/labs/lab1-discovery.md`, updating prototype and test language.
- Create `docs/labs/lab2-prototype.md`: mandatory static UI reference workflow.
- Rename and rewrite the remaining labs as `lab3-spec-tickets.md` through `lab10-cloud-agent.md`.
- Delete `docs/labs/lab5-cold-start.md` rather than carrying its content forward.

### Durable workflow contracts

- Modify `README.md`, `AGENTS.md`, `docs/reference/workflow.md`, `.agents/skills/workflow/SKILL.md`: define the same phase sequence and gates.
- Modify `docs/agents/issue-tracker.md`, `docs/work/README.md`: define mandatory `prototype.md` and `prototype/` artifacts.
- Modify `docs/reference/model-harness-matrix.md`, `docs/reference/handoff-contract.md`: remove optional/cold-start wording.
- Modify `docs/00-concepts.md`, `docs/templates/spec.md`, `docs/templates/uat-report.md`, `docs/uat/acceptance-matrix.md`, `docs/setup/azure-setup.md`: align marker names and evidence.
- Modify `docs/work/consult-ui-prototype/discovery.md`: update only the Lab 3 spec/ticket link.

### Removed checkpoint infrastructure and integrity gates

- Delete `docs/setup/checkpoint/`, `scripts/restore-checkpoint.sh`, `tests/scripts/test-checkpoint.sh`, and `tests/scripts/test-checkpoint-overlay.sh`.
- Modify `scripts/build-participant-bundle.sh`, `.github/workflows/verify.yml`, and `tests/scripts/test-usage.sh`: remove checkpoint-specific behavior.
- Modify `tests/scripts/test-lab-structure.sh`: enforce labs 0–10 and the new API/browser split.
- Modify `scripts/repo-manifest.txt`: enumerate the final repository assets.

---

### Task 1: Replace the Python live gate with e2e

**Files:**
- Modify: `app/api/pyproject.toml`
- Modify: `app/api/tests/conftest.py`
- Rename: `app/api/tests/test_live_config.py` → `app/api/tests/test_e2e_config.py`
- Rename: `scripts/test-live.sh` → `scripts/test-e2e.sh`
- Rename: `tests/scripts/test-live-test-boundary.sh` → `tests/scripts/test-e2e-boundary.sh`
- Modify: `tests/scripts/test-usage.sh`

**Interfaces:**
- Consumes: environment variables `APIM_BASE_URL`, `APIM_KEY`, `KNOWLEDGE_BASE_NAME`
- Produces: `pytest -m e2e` as the only Python external-network gate and `scripts/test-e2e.sh` as its repository entry point

- [ ] **Step 1: Rename the files without changing their content**

```bash
mv app/api/tests/test_live_config.py app/api/tests/test_e2e_config.py
mv scripts/test-live.sh scripts/test-e2e.sh
mv tests/scripts/test-live-test-boundary.sh tests/scripts/test-e2e-boundary.sh
```

- [ ] **Step 2: Rewrite the config tests to specify the e2e gate**

Use these tests in `app/api/tests/test_e2e_config.py`:

```python
from types import SimpleNamespace

import pytest

from conftest import pytest_configure


def test_explicit_e2e_run_requires_credentials(monkeypatch):
    for name in ("APIM_BASE_URL", "APIM_KEY", "KNOWLEDGE_BASE_NAME"):
        monkeypatch.delenv(name, raising=False)

    config = SimpleNamespace(option=SimpleNamespace(markexpr="e2e"))

    with pytest.raises(pytest.UsageError, match="APIM_BASE_URL"):
        pytest_configure(config)


def test_default_non_e2e_run_does_not_require_credentials(monkeypatch):
    for name in ("APIM_BASE_URL", "APIM_KEY", "KNOWLEDGE_BASE_NAME"):
        monkeypatch.delenv(name, raising=False)

    config = SimpleNamespace(option=SimpleNamespace(markexpr="not e2e"))

    pytest_configure(config)
```

- [ ] **Step 3: Run the renamed tests and confirm they fail**

Run:

```bash
(cd app/api && uv run --frozen pytest -q tests/test_e2e_config.py)
```

Expected: FAIL because `conftest.py` still recognizes `live`, not `e2e`.

- [ ] **Step 4: Implement the pytest e2e boundary**

In `app/api/pyproject.toml`, use:

```toml
addopts = ["-m", "not e2e"]
markers = [
    "e2e: calls the instructor APIM and requires workshop credentials",
]
```

In `app/api/tests/conftest.py`, rename the constants and helper to
`REQUIRED_E2E_SETTINGS` and `_missing_e2e_settings`, then make both hooks
recognize `e2e`. Explicit selection must raise:

```python
raise pytest.UsageError(
    "explicit e2e run requires: " + ", ".join(missing)
)
```

An individual `e2e` item reached without settings must skip with:

```python
pytest.skip("e2e credentials missing: " + ", ".join(missing))
```

- [ ] **Step 5: Update the executable wrapper**

The final line of `scripts/test-e2e.sh` must be:

```bash
exec uv run --frozen pytest -m e2e -q
```

Preserve its `.env` loading and `set -euo pipefail`.

- [ ] **Step 6: Rewrite the shell boundary test**

`tests/scripts/test-e2e-boundary.sh` must assert:

```bash
grep -Fq 'addopts = ["-m", "not e2e"]' app/api/pyproject.toml
grep -Fq 'e2e:' app/api/pyproject.toml
grep -Fq 'source "$ROOT/.env"' scripts/test-e2e.sh
grep -Fq 'pytest -m e2e -q' scripts/test-e2e.sh
```

Keep the hard-coded endpoint scan, but exclude `test_e2e_*.py` and
`test_healthz.py`. Remove all checks under `docs/setup/checkpoint/`.

- [ ] **Step 7: Update the script usage test**

In `tests/scripts/test-usage.sh`, test only `build-participant-bundle.sh` for
the two-argument usage contract. Replace its Azure setup assertion with:

```bash
grep -Fq './scripts/test-e2e.sh' docs/setup/azure-setup.md
```

This assertion will remain red until Task 4 updates the documentation.

- [ ] **Step 8: Run the focused runtime tests**

Run:

```bash
(cd app/api && uv run --frozen pytest -q tests/test_e2e_config.py)
tests/scripts/test-e2e-boundary.sh
```

Expected: both PASS. Do not run `scripts/test-e2e.sh`.

- [ ] **Step 9: Commit the runtime boundary**

```bash
git add app/api/pyproject.toml app/api/tests/conftest.py \
  app/api/tests/test_e2e_config.py scripts/test-e2e.sh \
  tests/scripts/test-e2e-boundary.sh tests/scripts/test-usage.sh
git add -u app/api/tests/test_live_config.py scripts/test-live.sh \
  tests/scripts/test-live-test-boundary.sh
git commit -m "refactor: name the Python APIM gate e2e"
```

---

### Task 2: Remove cold-start checkpoint infrastructure

**Files:**
- Delete: `docs/setup/checkpoint/`
- Delete: `scripts/restore-checkpoint.sh`
- Delete: `tests/scripts/test-checkpoint.sh`
- Delete: `tests/scripts/test-checkpoint-overlay.sh`
- Modify: `scripts/build-participant-bundle.sh`
- Modify: `.github/workflows/verify.yml`

**Interfaces:**
- Consumes: tracked Git repository state and an output tar path
- Produces: participant bundle protection for `.env` only; no checkpoint restore surface

- [ ] **Step 1: Add a regression assertion for the simplified bundle boundary**

In `.github/workflows/verify.yml`, change the final assertion to:

```bash
! tar -tzf "$bundle" | grep -Eq '(^|/)\.env$'
```

This makes CI stop treating a removed checkpoint directory as an active
contract.

- [ ] **Step 2: Remove checkpoint handling from the bundle script**

In `scripts/build-participant-bundle.sh`, make `git archive`:

```bash
git archive --format=tar HEAD -- . ':(exclude).env'
```

Make the archive validation reject only `.env`, and change messages to:

```text
FAIL: participant bundle contains local secrets
OK: participant bundle created without local secrets: %s
```

- [ ] **Step 3: Delete the checkpoint assets**

Delete only these resolved paths:

```text
docs/setup/checkpoint/
scripts/restore-checkpoint.sh
tests/scripts/test-checkpoint.sh
tests/scripts/test-checkpoint-overlay.sh
```

- [ ] **Step 4: Run focused shell validation**

Run:

```bash
bash -n scripts/build-participant-bundle.sh
git grep -n 'restore-checkpoint\|docs/setup/checkpoint' -- \
  ':!docs/work/lab-flow-restructure/spec.md' \
  ':!docs/work/lab-flow-restructure/plan.md'
```

Expected: syntax PASS and no matches outside the approved design/plan history.

- [ ] **Step 5: Commit checkpoint removal**

```bash
git add .github/workflows/verify.yml scripts/build-participant-bundle.sh
git add -u docs/setup/checkpoint scripts/restore-checkpoint.sh \
  tests/scripts/test-checkpoint.sh tests/scripts/test-checkpoint-overlay.sh
git commit -m "refactor: remove workshop checkpoint recovery"
```

---

### Task 3: Establish the new lab structure with contract tests

**Files:**
- Modify: `tests/scripts/test-lab-structure.sh`
- Create: `docs/labs/lab2-prototype.md`
- Create: `docs/labs/lab3-spec-tickets.md`
- Create: `docs/labs/lab4-api-acceptance.md`
- Create: `docs/labs/lab5-backend-slice.md`
- Create: `docs/labs/lab6-browser-acceptance.md`
- Create: `docs/labs/lab7-frontend-integration.md`
- Create: `docs/labs/lab8-improvement.md`
- Create: `docs/labs/lab9-verification.md`
- Create: `docs/labs/lab10-cloud-agent.md`
- Delete: old `docs/labs/lab2-*.md` through `docs/labs/lab9-*.md`
- Modify: `docs/labs/lab0-preflight.md`
- Modify: `docs/labs/lab1-discovery.md`

**Interfaces:**
- Consumes: the approved sequence and test semantics in `docs/work/lab-flow-restructure/spec.md`
- Produces: labs 0–10 with mandatory prototype, backend-first implementation, and distinct API/browser acceptance gates

- [ ] **Step 1: Rewrite the lab structure test first**

Make `tests/scripts/test-lab-structure.sh` iterate:

```bash
for index in 0 1 2 3 4 5 6 7 8 9 10; do
```

Keep the three required section checks and no-duration/no-day checks. Add
focused checks:

```bash
lab2="docs/labs/lab2-prototype.md"
for requirement in \
  'docs/work/<feature>/prototype/' \
  'tokens.md' \
  '나눔고딕' \
  '상태별 스크린샷'; do
  grep -Fq "$requirement" "$lab2"
done

lab4="docs/labs/lab4-api-acceptance.md"
for requirement in \
  'TestClient' \
  'pytest -m e2e' \
  '실제 APIM' \
  '실패'; do
  grep -Fq "$requirement" "$lab4"
done

lab6="docs/labs/lab6-browser-acceptance.md"
for requirement in \
  'npm run test:e2e' \
  'test:e2e:live' \
  'Playwright' \
  'route interception'; do
  grep -Fq "$requirement" "$lab6"
done

lab7="docs/labs/lab7-frontend-integration.md"
for requirement in \
  'tokens.md' \
  'landmark' \
  '스크린샷' \
  'HANDOFF'; do
  grep -Fq "$requirement" "$lab7"
done

lab9="docs/labs/lab9-verification.md"
for requirement in \
  '/code-review main' \
  'pytest -m e2e' \
  'npm run test:e2e' \
  'npm run test:e2e:live'; do
  grep -Fq "$requirement" "$lab9"
done
```

- [ ] **Step 2: Run the structure test and confirm it fails**

Run:

```bash
tests/scripts/test-lab-structure.sh
```

Expected: FAIL because `lab2-prototype.md` and the rest of the new file set do
not exist.

- [ ] **Step 3: Write Lab 2 as the mandatory prototype gate**

`docs/labs/lab2-prototype.md` must:

- open a fresh Copilot / GPT-5.6 Sol session;
- invoke `/prototype` and `frontend-design`;
- preserve all variants on `prototype/<feature>-<slug>`;
- commit `prototype.md` plus selected static HTML/CSS, `tokens.md`, landmark
  names, and five state screenshots under `docs/work/<feature>/prototype/`;
- prohibit credentials, live APIM calls, mutation, and persistence;
- end only when `Status: decided` and all static reference assets are committed.

- [ ] **Step 4: Write Lab 3 with contract-first two-stage tickets**

Move the existing spec/ticket procedure to `docs/labs/lab3-spec-tickets.md`.
Require planning to read the prototype artifacts. Replace the old ticket rule
with:

- a backend ticket observable through `POST /api/consult`;
- a frontend integration ticket observable in the browser and blocked by the
  backend ticket;
- separate API acceptance and browser acceptance tickets executed before their
  corresponding implementations;
- no model/search/component-layer horizontal tickets.

Every emitted ticket must retain `Status: ready-for-agent`, `Blocked by`,
observable acceptance criteria, and exact verification commands.

- [ ] **Step 5: Write Lab 4 for failing API acceptance tests**

`docs/labs/lab4-api-acceptance.md` must create no production code. Require:

- network-free TestClient integration tests that stub only the APIM adapter;
- a gated `pytest.mark.e2e` scenario for the actual APIM and Foundry IQ flow;
- explicit failure without credentials, not a silent skip, when `-m e2e` is
  selected;
- answer, structured citations, no-evidence, and safe error contract coverage;
- `pytest -q` to be red only for unimplemented behavior while the e2e suite is
  not run without an operator gate.

Explicitly state that Python `pytest -m e2e` calls the real APIM, while
JavaScript `npm run test:e2e` later uses route interception.

- [ ] **Step 6: Write Lab 5 for backend implementation**

`docs/labs/lab5-backend-slice.md` must implement through the fixed
`POST /api/consult` contract only. Require focused red-green for:

- Microsoft Agent Framework synthesis;
- Foundry IQ retrieval through the APIM adapter boundary;
- answer plus structured citations;
- no-evidence and secret-safe error behavior;
- TestClient integration tests.

The default suite must pass without network. Run `./scripts/test-e2e.sh` only
at the approved operator gate. End with an implementation commit followed by a
separate seven-field `HANDOFF` commit.

- [ ] **Step 7: Write Lab 6 for failing browser acceptance tests**

Move the browser portions of the old acceptance lab to
`docs/labs/lab6-browser-acceptance.md`. Require:

- `npm run test:e2e` with route interception and no external network;
- `npm run test:e2e:live` with no interception and both servers running;
- loading, answer, structured citations, no-evidence, and actionable error
  scenarios;
- trace, screenshot, video, and provider payload capture disabled;
- no production changes and no weakened assertions.

- [ ] **Step 8: Write Lab 7 for frontend implementation and integration**

`docs/labs/lab7-frontend-integration.md` must:

- read `prototype.md`, `prototype/tokens.md`, static HTML/CSS, screenshots,
  spec, frontend ticket, and backend `HANDOFF`;
- run the backend `HANDOFF.verify` command first;
- use only `POST /api/consult` for domain behavior;
- implement question, loading, answer, citations, no-evidence, and error UI;
- assert CSS tokens and state landmarks in frontend tests;
- pass component tests, build, and deterministic Playwright;
- compare implementation screenshots with prototype screenshots manually and
  record the result in `HANDOFF`;
- produce implementation and separate `HANDOFF` commits.

- [ ] **Step 9: Move improvement, verification, and cloud labs**

Create:

- `lab8-improvement.md` from old Lab 6, updating predecessor and scenario
  references;
- `lab9-verification.md` from old Lab 7, adding API unit/integration,
  gated Python e2e, deterministic browser e2e, and gated live browser e2e as
  four separately reported results;
- `lab10-cloud-agent.md` from old Lab 9, replacing Python `live` marker wording
  with `e2e` while retaining JavaScript `test:e2e:live`.

Delete the old numbered source files, including `lab5-cold-start.md`.

- [ ] **Step 10: Update Lab 0 and Lab 1**

In Lab 0, call prototype mandatory and identify the new Python e2e command as a
gated command. In Lab 1, require discovery to decide UI behavior and test seams
but no longer decide whether prototype is required.

- [ ] **Step 11: Run the lab contract**

Run:

```bash
tests/scripts/test-lab-structure.sh
```

Expected: PASS.

- [ ] **Step 12: Commit the lab sequence**

```bash
git add docs/labs tests/scripts/test-lab-structure.sh
git commit -m "docs: restructure labs around backend-first delivery"
```

---

### Task 4: Align durable workflow documentation and conductor gates

**Files:**
- Modify: `README.md`
- Modify: `AGENTS.md`
- Modify: `docs/reference/workflow.md`
- Modify: `.agents/skills/workflow/SKILL.md`
- Modify: `docs/reference/model-harness-matrix.md`
- Modify: `docs/reference/handoff-contract.md`
- Modify: `docs/agents/issue-tracker.md`
- Modify: `docs/work/README.md`
- Modify: `docs/work/consult-ui-prototype/discovery.md`
- Modify: `docs/00-concepts.md`
- Modify: `docs/templates/spec.md`
- Modify: `docs/templates/uat-report.md`
- Modify: `docs/uat/acceptance-matrix.md`
- Modify: `docs/setup/azure-setup.md`

**Interfaces:**
- Consumes: lab files from Task 3 and runtime commands from Task 1
- Produces: a single consistent workflow contract for participants, planning agents, implementation agents, and independent verifiers

- [ ] **Step 1: Update the top-level workflow contract**

In `AGENTS.md`, replace the main flow with:

```text
discovery → mandatory prototype → spec/tickets
→ API acceptance scenarios → backend implementation
→ browser acceptance scenarios → frontend integration
→ UX/error improvement → independent verification
```

State that each arrow crossing a role or ticket opens a fresh session. Replace
Python `live` marker text and commands with `e2e`. Preserve
`npm run test:e2e:live`. Add the prototype static-reference and screenshot
comparison requirements.

- [ ] **Step 2: Update README navigation and diagram**

Update the text flow, mermaid nodes and edges, roles table, and Labs list to
exactly match labs 0–10. Remove the recovery node. Show distinct API and browser
acceptance nodes before their implementation nodes. Make Prototype mandatory.

- [ ] **Step 3: Update the reference workflow**

In `docs/reference/workflow.md`:

- remove every optional-prototype branch;
- add `prototype/` to durable artifacts;
- describe backend and frontend as separate implementation sessions;
- distinguish Python gated e2e from JavaScript deterministic e2e;
- retain independent verification and defect loops.

- [ ] **Step 4: Update the workflow conductor**

In `.agents/skills/workflow/SKILL.md`:

- always select prototype when discovery exists but `prototype.md` is not
  `Status: decided`;
- require the committed `prototype/` static-reference assets in the prototype
  gate;
- choose the next `ready-for-agent` ticket in dependency order so API
  acceptance/backend precede browser acceptance/frontend;
- keep implementation and verification gates;
- replace Python `-m live` commands with `-m e2e`;
- report prototype as `pending` or `decided`, never `not-required`.

- [ ] **Step 5: Update artifact and harness references**

In `docs/agents/issue-tracker.md` and `docs/work/README.md`, define:

```text
docs/work/<feature>/prototype.md
docs/work/<feature>/prototype/index.html
docs/work/<feature>/prototype/styles.css
docs/work/<feature>/prototype/tokens.md
docs/work/<feature>/prototype/<state>.png
```

State that the exact screenshot names come from the feature's state list.
Remove `Prototype: required` and optional wording. Update Lab links to 1, 2, 3,
and 9. In the model/harness matrix, rename `Prototype (선택)` to `Prototype`.
In the handoff contract, remove Lab 5/cold-start framing while retaining fresh
session reconstruction and first verification.

- [ ] **Step 6: Update test and UAT terminology**

- `docs/00-concepts.md`: actual APIM smoke uses Python `e2e`.
- `docs/templates/spec.md`: list network-free unit/integration, gated Python
  e2e, deterministic browser e2e, and gated live browser e2e.
- `docs/templates/uat-report.md`: add separate API unit/integration and gated
  Python e2e result sections before the two Playwright sections.
- `docs/uat/acceptance-matrix.md`: use “Gated external evidence” for actual
  APIM evidence and explicitly map the two same-named e2e commands.
- `docs/setup/azure-setup.md`: invoke `./scripts/test-e2e.sh`; explain that
  default pytest excludes `e2e`.

- [ ] **Step 7: Repair renamed links only in the historical discovery**

Change the relative link in `docs/work/consult-ui-prototype/discovery.md` from
`lab2-spec-tickets.md` to `lab3-spec-tickets.md`. Do not alter its decisions.

- [ ] **Step 8: Search for stale workflow language**

Run:

```bash
git grep -n \
  -e 'lab5-cold-start' \
  -e 'lab2-spec-tickets' \
  -e 'lab3-acceptance-scenarios' \
  -e 'lab4-tracer-bullet' \
  -e 'lab6-improvement' \
  -e 'lab7-verification' \
  -e 'lab9-cloud-agent' \
  -e 'Prototype (선택)' \
  -e 'Prototype: required' \
  -- ':!docs/work/lab-flow-restructure/spec.md' \
     ':!docs/work/lab-flow-restructure/plan.md'
```

Expected: no matches. Then inspect Python marker references:

```bash
git grep -n -e 'pytest -m live' -e '@pytest.mark.live' -e 'not live'
```

Expected: no matches.

- [ ] **Step 9: Run document and workflow gates**

Run:

```bash
tests/scripts/test-lab-structure.sh
tests/scripts/test-vscode-harness-workflow.sh
tests/scripts/test-workflow-skill.sh
./scripts/check-repo.sh
```

Expected: all PASS after Task 5 updates the manifest; if `check-repo.sh` fails
only on manifest paths, continue directly to Task 5 without weakening checks.

- [ ] **Step 10: Commit durable workflow documentation**

```bash
git add README.md AGENTS.md .agents/skills/workflow/SKILL.md docs
git commit -m "docs: align workflow with backend-first labs"
```

---

### Task 5: Update repository manifest and integrity tests

**Files:**
- Modify: `scripts/repo-manifest.txt`
- Modify: `tests/scripts/test-usage.sh`
- Modify: `.github/workflows/verify.yml` if Task 2 did not fully remove stale wording

**Interfaces:**
- Consumes: final file set from Tasks 1–4
- Produces: repository checks and CI that reject stale or missing workshop assets

- [ ] **Step 1: Rewrite the manifest entries**

Remove:

- all `docs/setup/checkpoint/` entries;
- old lab filenames;
- `scripts/restore-checkpoint.sh`;
- old live-named tests and scripts;
- checkpoint shell tests.

Add:

- `app/api/tests/test_e2e_config.py`;
- labs `lab2-prototype.md` through `lab10-cloud-agent.md`;
- `scripts/test-e2e.sh`;
- `tests/scripts/test-e2e-boundary.sh`;
- `docs/work/lab-flow-restructure/spec.md`;
- `docs/work/lab-flow-restructure/plan.md`.

- [ ] **Step 2: Complete the usage test update**

Ensure `tests/scripts/test-usage.sh`:

- tests only `build-participant-bundle.sh` usage;
- requires `./scripts/test-e2e.sh` in Azure setup;
- retains all secret/domain/telemetry policy scans.

- [ ] **Step 3: Run all repository shell tests**

Run:

```bash
for test in tests/scripts/test-*.sh; do "$test"; done
```

Expected: every script reports `OK`.

- [ ] **Step 4: Run the repository asset gate**

Run:

```bash
./scripts/check-repo.sh
```

Expected: PASS with the new manifest path count and no broken links.

- [ ] **Step 5: Commit integrity contracts**

```bash
git add scripts/repo-manifest.txt tests/scripts/test-usage.sh \
  .github/workflows/verify.yml
git commit -m "test: enforce the restructured lab assets"
```

---

### Task 6: Perform full non-network validation and finalize the design artifacts

**Files:**
- Modify: `docs/work/lab-flow-restructure/spec.md` only if validation exposes a contradiction
- Modify: `docs/work/lab-flow-restructure/plan.md` only if the executed path differs materially

**Interfaces:**
- Consumes: all changes from Tasks 1–5
- Produces: verified commits with no external-network calls and a clean worktree

- [ ] **Step 1: Run the API default suite**

Run:

```bash
(cd app/api && uv run --frozen pytest -q)
```

Expected: PASS without requiring APIM credentials and without selecting `e2e`.

- [ ] **Step 2: Run the web unit tests and build**

Run:

```bash
(cd app/web && npm test && npm run build)
```

Expected: tests PASS and production build succeeds.

- [ ] **Step 3: Run all shell and asset checks together**

Run:

```bash
for test in tests/scripts/test-*.sh; do "$test"; done
./scripts/check-repo.sh
```

Expected: all PASS.

- [ ] **Step 4: Confirm removed and renamed surfaces**

Run:

```bash
test ! -e docs/labs/lab5-cold-start.md
test ! -e docs/setup/checkpoint
test ! -e scripts/restore-checkpoint.sh
test ! -e scripts/test-live.sh
test -x scripts/test-e2e.sh
git grep -n -e 'pytest -m live' -e '@pytest.mark.live' -e 'not live' && exit 1 || true
```

Expected: PASS and no stale Python live-marker references.

- [ ] **Step 5: Review the final diff**

Run:

```bash
git status --short
git diff --check
git --no-pager log --oneline -6
```

Expected: no whitespace errors. Confirm no unrelated files or credentials are
present.

- [ ] **Step 6: Commit any final consistency corrections**

If validation required corrections:

```bash
git add <only-the-corrected-files>
git commit -m "fix: complete lab workflow consistency"
```

If no correction was required, do not create an empty commit.

- [ ] **Step 7: Record commands intentionally not run**

In the implementation report, state that these were not run because they
require an operator-approved gate and credentials:

```bash
(cd app/api && uv run --frozen pytest -m e2e -q)
(cd app/web && npm run test:e2e:live)
```

