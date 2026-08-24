#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 2 ] || [ "$2" != "--confirm" ]; then
  printf 'usage: %s <output.tar.gz> --confirm\n' "$0" >&2
  exit 2
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT="$1"

if [ -e "$OUTPUT" ]; then
  printf 'FAIL: output already exists: %s\n' "$OUTPUT" >&2
  exit 1
fi

if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then
  printf 'FAIL: worktree가 깨끗하지 않습니다. 배포본을 만들기 전에 변경을 commit하세요.\n' >&2
  exit 1
fi

(
  cd "$ROOT"
  git archive --format=tar HEAD -- . \
    ':(exclude)docs/instructor/reference-solution'
) | gzip > "$OUTPUT"

if tar -tzf "$OUTPUT" | grep -q 'docs/instructor/reference-solution'; then
  printf 'FAIL: participant bundle contains the instructor solution\n' >&2
  rm -f "$OUTPUT"
  exit 1
fi

printf 'OK: participant bundle created without instructor solution: %s\n' "$OUTPUT"
