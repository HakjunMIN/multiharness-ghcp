#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

for index in 0 1 2 3 4 5 6 7 9; do
  lab="$(ls docs/labs/lab${index}-*.md)"
  for section in '## 이 랩에서 배우는 것' '## 종료 조건' '## 막힐 때'; do
    grep -Fq "$section" "$lab" || {
      printf 'FAIL: %s is missing the section %s\n' "$lab" "$section" >&2
      exit 1
    }
  done
done

lab7="docs/labs/lab7-verification.md"
for requirement in \
  '/code-review main' \
  'npm run test:e2e' \
  'npm run test:e2e:live' \
  'Playwright'; do
  grep -Fq "$requirement" "$lab7" || {
    printf 'FAIL: %s is missing verification step %s\n' \
      "$lab7" "$requirement" >&2
    exit 1
  }
done

# 검증 랩이 실행하는 suite를 만들어 내는 랩이 없으면 Lab 7을 재현할 수 없다.
lab3="docs/labs/lab3-acceptance-scenarios.md"
for requirement in \
  'npm run test:e2e' \
  'test:e2e:live' \
  'Playwright' \
  'route interception'; do
  grep -Fq "$requirement" "$lab3" || {
    printf 'FAIL: %s is missing acceptance scenario step %s\n' \
      "$lab3" "$requirement" >&2
    exit 1
  }
done

# 랩은 일정이 아니라 순서로만 이어진다. 소요 시간과 일차 구분을 되돌리지 않는다.
if grep -InE '^# Lab [0-9].*\([0-9]+분\)' docs/labs/*.md 2>/dev/null; then
  printf 'FAIL: lab titles must not carry a duration\n' >&2
  exit 1
fi

if grep -rInE '[0-9]일차|Day [0-9]|2일 hands-on|시간표' \
  docs/labs docs/reference docs/setup docs/templates docs/uat docs/agents \
  README.md AGENTS.md CONTEXT.md docs/00-concepts.md 2>/dev/null; then
  printf 'FAIL: day-based schedule framing remains\n' >&2
  exit 1
fi

printf 'OK: lab structure contract passed\n'
