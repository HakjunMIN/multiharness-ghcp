# Codex Cloud Verification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make optional Lab 4 Path A run exclusively as a report-only OpenAI Codex third-party coding-agent task on GitHub Enterprise Cloud.

**Architecture:** Path A starts from a dedicated verification Issue and produces a draft PR that may change only `docs/uat/report.md`; Path B remains the mandatory fallback using a new Copilot/GPT-5.6 Terra session. Strict preflight records which route was confirmed without treating a local Codex CLI as evidence of cloud readiness.

**Tech Stack:** Markdown workshop assets, Bash 3.2-compatible scripts, GitHub CLI, GitHub Enterprise Cloud third-party coding agents, zero-dependency Node.js tests.

## Global Constraints

- Do not add dependencies or dependency keys to `seed/package.json`.
- Do not delete existing tests under `seed/tests/`.
- Do not expose customer-identifying information.
- Path A is optional; independent UAT through Path A or Path B remains mandatory.
- Path A may modify only `docs/uat/report.md`; it must not modify `seed/`.
- `Codex + GPT-5.6 Terra` is never presented as supported.

---

### Task 1: Define the Cloud Verification Contract

**Files:**
- Modify: `docs/prompts/codex-verifier.md`
- Create: `docs/templates/codex-cloud-verification-issue.md`
- Modify: `scripts/repo-manifest.txt`

**Interfaces:**
- Consumes: Lab 3 HANDOFF and `docs/uat/acceptance-matrix.md`
- Produces: an Issue body contract suitable for assignment to the GHEC OpenAI Codex coding agent

- [ ] **Step 1: Add the exact report-only Issue template**

Include purpose, immutable inputs, the three verification commands, allowed path `docs/uat/report.md`, prohibited `seed/` changes, and draft-PR completion criteria.

- [ ] **Step 2: Rewrite the Codex verifier prompt for asynchronous cloud execution**

Remove local-session language and define evidence, diff, and failure behavior.

- [ ] **Step 3: Register the new template and run the repository gate**

Run: `./scripts/check-repo.sh`

Expected: `OK: repo check passed`.

- [ ] **Step 4: Commit**

```bash
git add docs/prompts/codex-verifier.md docs/templates/codex-cloud-verification-issue.md scripts/repo-manifest.txt
git commit -m "docs: define Codex cloud verification contract"
```

### Task 2: Rewire Lab 4 and Participant Documentation

**Files:**
- Modify: `README.md`
- Modify: `docs/labs/lab4-verification.md`
- Modify: `docs/reference/model-harness-matrix.md`
- Modify: `.github/skills/uat-verify/SKILL.md`
- Modify: `docs/templates/team-adoption.md`

**Interfaces:**
- Consumes: `docs/templates/codex-cloud-verification-issue.md`
- Produces: Path A Issue delegation and report-only draft-PR review; Path B remains local

- [ ] **Step 1: Label Path A optional and cloud-only**

Use the exact name “Optional GHEC Codex cloud agent”.

- [ ] **Step 2: Replace local Codex steps with Issue delegation**

Copy the Issue template, populate HANDOFF references, create the Issue, assign Codex through the GitHub UI/Agents surface, choose a currently offered model, and inspect the resulting draft PR.

- [ ] **Step 3: Add the report-only diff gate**

Require `gh pr diff --name-only` to equal `docs/uat/report.md`; close without merge if any `seed/` path appears.

- [ ] **Step 4: Preserve Path B and defect-return behavior**

Path B continues using `copilot --model gpt-5.6-terra`; failures become separate `wf:verify` Issues.

- [ ] **Step 5: Run the repository gate and commit**

Run: `./scripts/check-repo.sh`

Expected: pass.

### Task 3: Align Preflight and Instructor Operations

**Files:**
- Modify: `scripts/preflight.sh`
- Modify: `docs/labs/lab0-preflight.md`
- Modify: `docs/instructor/pre-workshop-checklist.md`
- Modify: `docs/instructor/facilitation-notes.md`
- Modify: `docs/instructor/troubleshooting.md`
- Modify: `docs/reference/sources.md`
- Modify: `tests/scripts/test-usage.sh`

**Interfaces:**
- Consumes: `WORKSHOP_VERIFY_ROUTE=codex-cloud|copilot-terra`
- Produces: strict readiness result that does not depend on a local `codex` executable

- [ ] **Step 1: Remove local Codex CLI readiness**

Do not warn or pass based on `command -v codex`.

- [ ] **Step 2: Add the cloud confirmation gate**

For `codex-cloud`, require `WORKSHOP_VERIFY_MODEL_CONFIRMED=1` after policy, repository enablement, assignability, model visibility, Actions minutes, and AI credits were manually checked.

- [ ] **Step 3: Document live disposable-repository validation**

Require a report-only Codex draft PR before the event and document Path B fallback for policy, timeout, unexpected diff, or missing model.

- [ ] **Step 4: Update first-party sources**

Add the official third-party-agent concept and model-selection changelog URLs.

- [ ] **Step 5: Run strict/non-strict preflight behavior and commit**

Run:

```bash
./scripts/preflight.sh
WORKSHOP_VERIFY_ROUTE=codex-cloud \
WORKSHOP_VERIFY_MODEL_CONFIRMED=1 \
WORKSHOP_CLAUDE_OPUS5_CONFIRMED=1 \
  ./scripts/preflight.sh --strict
```

Expected: non-strict passes locally; strict may fail only for missing GitHub repository context in this checkout.

### Task 4: Add Consistency Gates and Complete Verification

**Files:**
- Modify: `scripts/check-repo.sh`
- Create: `tests/scripts/test-codex-cloud-docs.sh`
- Modify: `.github/workflows/verify.yml`
- Modify: `scripts/repo-manifest.txt`

**Interfaces:**
- Consumes: final participant and instructor documentation
- Produces: CI enforcement that Path A stays optional/cloud/report-only

- [ ] **Step 1: Write the failing documentation contract test**

Assert `codex-cloud` route exists, local `codex` CLI checks do not exist, Lab 4 names Path A optional GHEC cloud, only the report path is allowed, and Path B remains documented.

- [ ] **Step 2: Run the test and resolve every failure**

Run: `./tests/scripts/test-codex-cloud-docs.sh`

Expected before all documentation is aligned: fail; expected after alignment: pass.

- [ ] **Step 3: Add the test to CI and the repository gate**

Run the new test in the existing OS/Node matrix.

- [ ] **Step 4: Run complete verification**

```bash
(cd seed && npm test)
./tests/scripts/test-handoff.sh
./tests/scripts/test-usage.sh
./tests/scripts/test-codex-cloud-docs.sh
./scripts/check-repo.sh
git diff --check
```

Expected: all pass.

- [ ] **Step 5: Commit the completed workflow**

Use the required Copilot trailers and ensure `git status --short` is empty.
