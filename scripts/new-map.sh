#!/usr/bin/env bash
set -euo pipefail

# Create the workshop map issue. Prints ONLY the issue number on stdout.
# Usage: ./scripts/new-map.sh "<destination>"

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
  printf 'usage: %s "<destination>"\n' "$0" >&2
  exit 2
fi

destination="$1"

if ! gh repo view --json nameWithOwner >/dev/null 2>&1; then
  printf 'FAIL: 이 스크립트는 GitHub 리포 안에서 실행해야 합니다. 먼저 실행: gh repo create\n' >&2
  exit 1
fi

body="$(cat <<BODY
> 이 맵은 색인이지 저장소가 아닙니다. 상세 내용은 자식 이슈에 씁니다.

## Destination
${destination}

## Notes
(하네스 전환 시 알아야 할 맥락을 여기에 누적합니다)

## Decisions so far
(결정된 항목을 \`#<이슈번호> — 한 줄 요약\` 형태로 추가합니다)

## Not yet specified
(아직 결정 이슈로 쪼개지 않은 열린 질문)

## Out of scope
(이번 워크샵에서 다루지 않기로 한 것)
BODY
)"

url="$(printf '%s' "$body" | gh issue create \
  --title "[map] ${destination}" \
  --label "wf:map" \
  --body-file -)"

printf 'created: %s\n' "$url" >&2
printf '%s\n' "${url##*/}"
