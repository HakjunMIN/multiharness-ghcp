#!/usr/bin/env bash
set -euo pipefail

# Post a handoff brief as an issue comment, but only if it follows the contract.
# Usage: ./scripts/handoff.sh <issue-number> <brief-file>

if [ $# -lt 2 ]; then
  printf 'usage: %s <issue-number> <brief-file>\n' "$0" >&2
  exit 2
fi

issue="$1"
brief="$2"

if [ ! -f "$brief" ]; then
  printf 'FAIL: 브리프 파일이 없습니다: %s\n' "$brief" >&2
  exit 2
fi

head -1 "$brief" | grep -qx '## HANDOFF' || {
  printf 'FAIL: 인수인계 브리프는 첫 줄이 "## HANDOFF" 여야 합니다\n' >&2
  exit 1
}

for field in "- from/to:" "- artifacts:" "- verify:"; do
  grep -qF -- "$field" "$brief" || {
    printf 'FAIL: 인수인계 브리프에 %s 가 없습니다\n' "$field" >&2
    exit 1
  }
done

gh issue comment "$issue" --body-file "$brief"
