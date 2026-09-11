#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

inventory="$(grep -vE '^[[:space:]]*(#|$)' scripts/local-project-skills.txt)"
[ -n "$inventory" ] || fail "local project skill inventory is empty"

while IFS= read -r name; do
  skill=".agents/skills/$name/SKILL.md"
  [ -f "$skill" ] || fail "locally authored skill is missing: $skill"

  # 직접 작성한 스킬은 외부 소스가 없으므로 잠금 파일에 등록되지 않는다.
  node -e '
    const fs = require("node:fs");
    const lock = JSON.parse(fs.readFileSync("skills-lock.json", "utf8"));
    if (lock.skills?.[process.argv[1]]) {
      console.error(`locally authored skill must not be locked: ${process.argv[1]}`);
      process.exit(1);
    }
  ' "$name" || fail "$name is registered in skills-lock.json"

  grep -Fq "name: $name" "$skill" || fail "$skill frontmatter name mismatch"
  grep -Fq 'disable-model-invocation: true' "$skill" ||
    fail "$skill must stay explicit-invocation only"
done <<<"$inventory"

# workflow conductor는 역할 경계를 우회하면 안 된다.
conductor=".agents/skills/workflow/SKILL.md"
for phrase in \
  '한 세션에서 두 개 이상의 역할을 실행하지 않는다' \
  '세션 전환을 대신하지 않는다' \
  'production implementation을 고치지 않는다' \
  'fresh session'; do
  grep -Fq "$phrase" "$conductor" ||
    fail "workflow skill is missing the session boundary rule: $phrase"
done

for command in \
  '/grill-with-docs' \
  '/prototype' \
  '/to-spec' \
  '/to-tickets' \
  '/implement' \
  '/code-review main'; do
  grep -Fq "$command" "$conductor" ||
    fail "workflow skill does not route to $command"
done

for artifact in \
  'docs/work/<feature>/discovery.md' \
  'prototype.md' \
  'spec.md' \
  'tickets/' \
  'defects/' \
  'HANDOFF' \
  'docs/uat/acceptance-matrix.md'; do
  grep -Fq "$artifact" "$conductor" ||
    fail "workflow skill does not read the durable artifact $artifact"
done

for phrase in \
  'prototype은 필수' \
  'Status: decided' \
  'prototype/<feature>-<slug>' \
  'prototype/' \
  'prototype → planning'; do
  grep -Fq "$phrase" "$conductor" ||
    fail "workflow skill is missing the prototype contract: $phrase"
done

# conductor는 선택적 경로여야 한다.
grep -Fq '선택' "$conductor" || fail "workflow skill is not documented as optional"
for file in README.md docs/reference/workflow.md; do
  grep -Fq '/workflow' "$file" || fail "$file does not document the optional conductor"
done

printf 'OK: workflow conductor skill contract passed\n'
