#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" != "--confirm" ]; then
  printf 'usage: %s --confirm\n' "$0" >&2
  printf 'This overwrites selected seed source and test files.\n' >&2
  exit 2
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SOURCE="${WORKSHOP_CHECKPOINT_DIR:-}"
if [ -z "$SOURCE" ]; then
  printf 'FAIL: WORKSHOP_CHECKPOINT_DIR에 강사용 checkpoint 디렉터리를 지정하세요.\n' >&2
  exit 2
fi

if [ -n "$(git status --porcelain)" ]; then
  printf 'FAIL: worktree가 깨끗하지 않습니다. 팀 작업을 먼저 commit하세요.\n' >&2
  exit 1
fi

required=(
  src/policy.ts src/router.ts src/gate.ts src/index.ts
  tests/router.test.ts tests/gate.test.ts
)
for path in "${required[@]}"; do
  if [ ! -f "$SOURCE/$path" ]; then
    printf 'FAIL: checkpoint 파일이 없습니다: %s/%s\n' "$SOURCE" "$path" >&2
    exit 1
  fi
done

cp "$SOURCE/src/policy.ts" seed/src/policy.ts
cp "$SOURCE/src/router.ts" seed/src/router.ts
cp "$SOURCE/src/gate.ts" seed/src/gate.ts
cp "$SOURCE/src/index.ts" seed/src/index.ts
cp "$SOURCE/tests/router.test.ts" seed/tests/router.test.ts
cp "$SOURCE/tests/gate.test.ts" seed/tests/gate.test.ts

(cd seed && npm test)
node --disable-warning=ExperimentalWarning --test docs/uat/acceptance.test.ts
printf 'OK: Lab 3 reference checkpoint restored. Review and commit the changes.\n'
