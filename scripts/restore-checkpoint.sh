#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" != "--confirm" ]; then
  printf 'usage: %s --confirm\n' "$0" >&2
  printf 'This overwrites selected app/api and optional app/web source files.\n' >&2
  exit 2
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
SOURCE="${WORKSHOP_CHECKPOINT_DIR:-}"

if [ -z "$SOURCE" ]; then
  printf 'FAIL: WORKSHOP_CHECKPOINT_DIR에 운영자용 checkpoint 디렉터리를 지정하세요.\n' >&2
  exit 2
fi
if [ -n "$(git status --porcelain)" ]; then
  printf 'FAIL: worktree가 깨끗하지 않습니다. 팀 작업을 먼저 commit하세요.\n' >&2
  exit 1
fi
for path in app/api/src app/api/tests; do
  if [ ! -d "$SOURCE/$path" ]; then
    printf 'FAIL: checkpoint 디렉터리가 없습니다: %s/%s\n' "$SOURCE" "$path" >&2
    exit 1
  fi
done

cp -R "$SOURCE/app/api/src/." app/api/src/
cp -R "$SOURCE/app/api/tests/." app/api/tests/
if [ -d "$SOURCE/app/web/src" ]; then
  cp -R "$SOURCE/app/web/src/." app/web/src/
fi

(cd app/api && uv run --frozen pytest -q)
if [ -d "$SOURCE/app/web/src" ]; then
  (cd app/web && npm test)
fi
printf 'OK: checkpoint restored. Review and commit the restored checkpoint.\n'
