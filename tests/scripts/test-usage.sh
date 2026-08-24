#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for script in frontier.sh handoff.sh new-map.sh restore-lab3-checkpoint.sh build-participant-bundle.sh; do
  set +e
  "$ROOT/scripts/$script" >/dev/null 2>&1
  status=$?
  set -e
  if [ "$status" -ne 2 ]; then
    printf 'FAIL: %s without arguments returned %d, expected 2\n' "$script" "$status" >&2
    exit 1
  fi
done

printf 'OK: script usage tests passed\n'
