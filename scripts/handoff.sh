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

case "$issue" in
  ''|*[!0-9]*)
    printf 'FAIL: Issue 번호는 숫자여야 합니다: %s\n' "$issue" >&2
    exit 2
    ;;
esac

if [ ! -f "$brief" ]; then
  printf 'FAIL: 브리프 파일이 없습니다: %s\n' "$brief" >&2
  exit 2
fi

head -1 "$brief" | grep -qx '## HANDOFF' || {
  printf 'FAIL: 인수인계 브리프는 첫 줄이 "## HANDOFF" 여야 합니다\n' >&2
  exit 1
}

fields=(
  "- from/to:"
  "- artifacts:"
  "- done:"
  "- not done:"
  "- decisions:"
  "- verify:"
  "- risks:"
)

for field in "${fields[@]}"; do
  line="$(awk -v prefix="$field" 'index($0, prefix) == 1 { print; exit }' "$brief")"
  if [ -z "$line" ]; then
    printf 'FAIL: 인수인계 브리프에 %s 가 없습니다\n' "$field" >&2
    exit 1
  fi
  value="${line#"$field"}"
  value="$(printf '%s' "$value" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  if [ -z "$value" ] || printf '%s' "$value" | grep -qE '<[^>]+>|\{\{[^}]+\}\}'; then
    printf 'FAIL: 인수인계 브리프의 %s 값이 비어 있거나 템플릿 상태입니다\n' "$field" >&2
    exit 1
  fi
done

artifact_line="$(awk 'index($0, "- artifacts:") == 1 { print; exit }' "$brief")"
artifacts="${artifact_line#"- artifacts:"}"
while IFS= read -r artifact; do
  artifact="$(printf '%s' "$artifact" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  [ -z "$artifact" ] && continue
  case "$artifact" in
    http://*|https://*|\#*)
      printf 'FAIL: artifacts에는 Issue URL이나 번호가 아니라 커밋된 레포 경로만 씁니다: %s\n' "$artifact" >&2
      exit 1
      ;;
    /*|../*|*/../*|*/..)
      printf 'FAIL: artifact는 리포 내부의 상대 파일 경로여야 합니다: %s\n' "$artifact" >&2
      exit 1
      ;;
  esac
  if [ -d "$artifact" ]; then
    printf 'FAIL: artifact는 디렉터리가 아니라 개별 파일이어야 합니다: %s\n' "$artifact" >&2
    exit 1
  fi
  if [ ! -f "$artifact" ] ||
     ! git ls-tree -r --name-only HEAD -- "$artifact" | grep -Fxq -- "$artifact"; then
    printf 'FAIL: artifact가 현재 커밋에 존재하지 않습니다: %s\n' "$artifact" >&2
    exit 1
  fi
  if ! git diff --quiet HEAD -- "$artifact"; then
    printf 'FAIL: artifact에 커밋되지 않은 변경이 있습니다: %s\n' "$artifact" >&2
    exit 1
  fi
done < <(printf '%s\n' "$artifacts" | tr ',' '\n')

gh issue comment "$issue" --body-file "$brief"
