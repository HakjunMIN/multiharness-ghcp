#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

for index in 0 1 2 3 4 5 6 7 8 9 10; do
  lab="$(ls docs/labs/lab${index}-*.md)"
  for section in '## 이 랩에서 배우는 것' '## 종료 조건' '## 막힐 때'; do
    grep -Fq "$section" "$lab" || {
      printf 'FAIL: %s is missing the section %s\n' "$lab" "$section" >&2
      exit 1
    }
  done
done

lab2="docs/labs/lab2-prototype.md"
for requirement in \
  'docs/work/<feature>/prototype/' \
  'tokens.md' \
  '나눔고딕' \
  '상태별 스크린샷'; do
  grep -Fq "$requirement" "$lab2" || {
    printf 'FAIL: %s is missing prototype requirement %s\n' \
      "$lab2" "$requirement" >&2
    exit 1
  }
done

lab4="docs/labs/lab4-api-acceptance.md"
for requirement in \
  'TestClient' \
  'pytest -m e2e' \
  '실제 APIM' \
  '실패'; do
  grep -Fq "$requirement" "$lab4" || {
    printf 'FAIL: %s is missing API acceptance requirement %s\n' \
      "$lab4" "$requirement" >&2
    exit 1
  }
done

lab6="docs/labs/lab6-browser-acceptance.md"
for requirement in \
  'npm run test:e2e' \
  'test:e2e:live' \
  'Playwright' \
  'route interception'; do
  grep -Fq "$requirement" "$lab6" || {
    printf 'FAIL: %s is missing acceptance scenario step %s\n' \
      "$lab6" "$requirement" >&2
    exit 1
  }
done

lab7="docs/labs/lab7-frontend-integration.md"
for requirement in 'tokens.md' 'landmark' '스크린샷' 'HANDOFF'; do
  grep -Fq "$requirement" "$lab7" || {
    printf 'FAIL: %s is missing frontend integration requirement %s\n' \
      "$lab7" "$requirement" >&2
    exit 1
  }
done

lab9="docs/labs/lab9-verification.md"
for requirement in \
  '/code-review main' \
  'pytest -m e2e' \
  'npm run test:e2e' \
  'npm run test:e2e:live'; do
  grep -Fq "$requirement" "$lab9" || {
    printf 'FAIL: %s is missing verification step %s\n' \
      "$lab9" "$requirement" >&2
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
  README.md AGENTS.md CONTEXT.md 2>/dev/null; then
  printf 'FAIL: day-based schedule framing remains\n' >&2
  exit 1
fi

printf 'OK: lab structure contract passed\n'
