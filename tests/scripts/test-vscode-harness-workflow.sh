#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }

read_inventory() { grep -vE '^[[:space:]]*(#|$)' "$1" | LC_ALL=C sort; }

# --- 스킬 인벤토리는 required/local 목록 파일이 단일 정본이다. ---
# 테스트는 목록을 다시 적지 않고 세 소스(목록, 설치본, lock)가 일치하는지만 본다.
required_skills="$(read_inventory scripts/required-project-skills.txt)"
local_skills="$(read_inventory scripts/local-project-skills.txt)"
[ -n "$required_skills" ] || fail "required project skill inventory is empty"

expected_installed="$(printf '%s\n%s\n' "$required_skills" "$local_skills" | LC_ALL=C sort)"
installed_skills="$(
  find .agents/skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; |
    LC_ALL=C sort
)"
[ "$installed_skills" = "$expected_installed" ] ||
  fail "installed project skills do not match the required + local inventory"

locked_skills="$(
  node -e '
    const lock = require("./skills-lock.json");
    console.log(Object.keys(lock.skills).sort().join("\n"));
  '
)"
[ "$locked_skills" = "$required_skills" ] ||
  fail "locked project skills do not match scripts/required-project-skills.txt"

# --- harness 축은 문서에 남기되 model 세대는 고정하지 않는다. ---
for file in AGENTS.md README.md docs/reference/workflow.md \
  docs/reference/model-harness-matrix.md; do
  for harness in Copilot Claude Codex; do
    grep -Fq "$harness" "$file" ||
      fail "$file does not name the $harness harness"
  done
done

for file in AGENTS.md docs/reference/model-harness-matrix.md; do
  grep -Fq '권장 기본값' "$file" ||
    fail "$file must present the runtime matrix as a recommendation"
done

# --- VS Code 사전 설정은 버전 번호가 아니라 형태로 검사한다. ---
grep -qE 'VS Code \*\*[0-9]+\.[0-9]+(\.[0-9]+)? 이상\*\*' README.md ||
  fail "README.md does not state a minimum VS Code version"
for setting in github.copilot.chat.claudeAgent.enabled \
  chat.agentHost.codexAgent.enabled; do
  grep -Fq "$setting" README.md || fail "README.md is missing setting $setting"
done
for topic in 'Copilot Pro+' 'Cloud Codex' 'agent-harnesses'; do
  grep -Fq "$topic" README.md || fail "README.md is missing $topic"
done

# --- 권장 runtime 미확인은 경고여야 하고 실패여서는 안 된다. ---
for var in WORKSHOP_CLAUDE_OPUS48_CONFIRMED WORKSHOP_GPT56_SOL_CONFIRMED \
  WORKSHOP_CODEX_TERRA_CONFIRMED; do
  grep -Fq "$var" scripts/preflight.sh ||
    fail "scripts/preflight.sh does not handle $var"
done
grep -Fq 'WORKSHOP_CLAUDE_OPUS48_CONFIRMED' docs/labs/lab0-preflight.md ||
  fail "docs/labs/lab0-preflight.md does not document the runtime confirmation"
if grep -nE '^[[:space:]]*bad .*권장' scripts/preflight.sh; then
  fail "unconfirmed recommended runtime must warn, not fail"
fi
grep -Fq '실제로 사용한' docs/reference/handoff-contract.md ||
  fail "handoff contract must record the runtime actually used"
grep -Fq '실제로 사용한' docs/templates/uat-report.md ||
  fail "UAT report must record the runtime actually used"

# --- durable artifact 경계 ---
grep -Fq 'docs/work/<feature>/' docs/agents/issue-tracker.md
grep -Fq 'discovery.md' docs/agents/issue-tracker.md
grep -Fq 'full conversation history' docs/reference/handoff-contract.md
grep -Fq 'fresh verifier' docs/reference/handoff-contract.md
grep -Fq 'ticket' docs/labs/lab5-backend-slice.md
grep -Fq 'local defect' docs/labs/lab9-verification.md
grep -Fq 'Host: VS Code' docs/labs/lab9-verification.md

for file in README.md docs/reference/workflow.md docs/labs/lab1-discovery.md \
  docs/labs/lab3-spec-tickets.md; do
  grep -Fq 'discovery.md' "$file" ||
    fail "$file does not name the discovery durable artifact"
done

# --- React UI는 첫 tracer부터 UAT까지 필수 범위다. ---
for file in README.md AGENTS.md docs/labs/lab1-discovery.md \
  docs/labs/lab2-prototype.md docs/labs/lab3-spec-tickets.md \
  docs/labs/lab6-browser-acceptance.md docs/labs/lab7-frontend-integration.md \
  docs/labs/lab8-improvement.md docs/labs/lab9-verification.md \
  docs/uat/acceptance-matrix.md; do
  grep -Fq 'React' "$file" ||
    fail "$file does not include the required React UI scope"
done
grep -Fq 'backend contract를 소비' docs/labs/lab7-frontend-integration.md
grep -Fq 'React와 API는 모두 필수 UAT 범위' docs/uat/acceptance-matrix.md

# --- 작업 추적은 remote tracker가 아니라 local work item이다. ---
if grep -InE 'project issue tracker|Apply the `ready-for-agent` triage label' \
  .agents/skills/to-spec/SKILL.md 2>/dev/null; then
  fail "to-spec still instructs a remote tracker operation"
fi
if grep -InE 'gh issue (create|edit|close)' \
  AGENTS.md README.md docs/labs/*.md docs/reference/*.md 2>/dev/null; then
  fail "workshop flow must use local work items, not GitHub Issues"
fi

# --- ADR과 CONTEXT.md는 참가자 산출물이므로 자리만 유지한다. ---
for section in '## 도메인 용어' '## 동작 규칙' '## 테스트 경계'; do
  grep -Fq "$section" CONTEXT.md ||
    fail "CONTEXT.md is missing the participant section $section"
done

node scripts/check-project-skills.mjs --required >/dev/null

printf 'OK: VS Code multi-agent harness workflow contract passed\n'
