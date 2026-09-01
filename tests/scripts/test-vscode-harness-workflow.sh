#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

expected_skills="$(cat <<'SKILLS'
code-review
codebase-design
diagnosing-bugs
domain-modeling
frontend-design
grill-with-docs
grilling
implement
research
tdd
to-spec
to-tickets
SKILLS
)"
actual_skills="$(
  grep -vE '^[[:space:]]*(#|$)' scripts/required-project-skills.txt |
    LC_ALL=C sort
)"
[ "$actual_skills" = "$expected_skills" ] || {
  printf 'FAIL: required project skills are not the agreed inventory\n' >&2
  exit 1
}

installed_skills="$(
  find .agents/skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; |
    LC_ALL=C sort
)"
[ "$installed_skills" = "$expected_skills" ] || {
  printf 'FAIL: installed project skills are not the agreed inventory\n' >&2
  exit 1
}

locked_skills="$(
  node -e '
    const lock = require("./skills-lock.json");
    console.log(Object.keys(lock.skills).sort().join("\n"));
  '
)"
[ "$locked_skills" = "$expected_skills" ] || {
  printf 'FAIL: locked project skills are not the agreed inventory\n' >&2
  exit 1
}

for file in AGENTS.md README.md docs/reference/workflow.md \
  docs/reference/model-harness-matrix.md; do
  grep -Fq 'Copilot' "$file"
  grep -Fq 'GPT-5.6 Sol' "$file"
  grep -Fq 'Claude' "$file"
  grep -Fq 'Claude Opus 4.8' "$file"
  grep -Fq 'Codex' "$file"
  grep -Fq 'GPT-5.6 Terra' "$file"
done

grep -Fq '1.128.0' README.md
grep -Fq 'github.copilot.chat.claudeAgent.enabled' README.md
grep -Fq 'chat.agentHost.codexAgent.enabled' README.md
grep -Fq 'Copilot Pro+' README.md
grep -Fq 'Cloud Codex' README.md
grep -Fq 'agent-harnesses' README.md
grep -Fq 'WORKSHOP_CLAUDE_OPUS48_CONFIRMED' docs/labs/lab0-preflight.md
grep -Fq 'WORKSHOP_CODEX_TERRA_CONFIRMED' docs/labs/lab0-preflight.md
grep -Fq 'WORKSHOP_CLAUDE_OPUS48_CONFIRMED' scripts/preflight.sh
grep -Fq 'WORKSHOP_CODEX_TERRA_CONFIRMED' scripts/preflight.sh

grep -Fq 'docs/work/<feature>/' docs/agents/issue-tracker.md
grep -Fq 'discovery.md' docs/agents/issue-tracker.md
grep -Fq 'full conversation history' docs/reference/handoff-contract.md
grep -Fq 'fresh Codex' docs/reference/handoff-contract.md
grep -Fq 'local ticket' docs/labs/lab3-tracer-bullet.md
grep -Fq 'local defect' docs/labs/lab6-verification.md
grep -Fq 'Host: VS Code' docs/labs/lab8-integration.md
grep -Fq 'Copilot, Claude, Codex' docs/labs/lab8-integration.md

# 발견 -> 기획 경계는 handoff가 아니라 커밋된 discovery 문서다.
for file in README.md docs/reference/workflow.md docs/labs/lab1-discovery.md \
  docs/labs/lab2-spec-tickets.md; do
  grep -Fq 'discovery.md' "$file" || {
    printf 'FAIL: %s does not name the discovery durable artifact\n' "$file" >&2
    exit 1
  }
done

for file in docs/labs/lab2-spec-tickets.md docs/reference/model-harness-matrix.md \
  docs/reference/workflow.md; do
  if grep -InE 'Claude(로| harness).*handoff|handoff.*Claude' "$file" 2>/dev/null; then
    printf 'FAIL: %s still routes discovery into planning by handoff\n' "$file" >&2
    exit 1
  fi
done

# ADR과 CONTEXT.md는 참가자 산출물이므로 정답이 미리 커밋되어 있으면 안 된다.
# 참가자는 실습 중 여기에 자신의 문서를 추가하므로 존재 여부가 아니라
# seed CONTEXT.md가 채울 자리를 유지하는지를 검사한다.
for section in '## 도메인 용어' '## 동작 규칙' '## 테스트 경계'; do
  grep -Fq "$section" CONTEXT.md || {
    printf 'FAIL: CONTEXT.md is missing the participant section %s\n' "$section" >&2
    exit 1
  }
done

if grep -InE 'project issue tracker|Apply the `ready-for-agent` triage label' \
  .agents/skills/to-spec/SKILL.md 2>/dev/null; then
  printf 'FAIL: to-spec still instructs a remote tracker operation\n' >&2
  exit 1
fi

if grep -InE \
  'Claude Opus 5|Claude Sonnet 5|/implement #[0-9]+|gh issue|GitHub Issue|spec Issue|defect Issue' \
  AGENTS.md README.md docs/labs/*.md docs/setup/*.md \
  docs/reference/workflow.md docs/reference/model-harness-matrix.md \
  docs/reference/handoff-contract.md 2>/dev/null; then
  printf 'FAIL: legacy role matrix or GitHub Issue workflow remains\n' >&2
  exit 1
fi

if grep -InF \
  'npx skills@latest add mattpocock/skills --agent github-copilot --copy' \
  README.md docs/labs/*.md docs/reference/*.md 2>/dev/null; then
  printf 'FAIL: full Matt skill installation remains\n' >&2
  exit 1
fi

node scripts/check-project-skills.mjs --required >/dev/null

printf 'OK: VS Code multi-agent harness workflow contract passed\n'
