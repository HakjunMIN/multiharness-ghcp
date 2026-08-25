#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for script in restore-checkpoint.sh build-participant-bundle.sh; do
  set +e
  "$ROOT/scripts/$script" >/dev/null 2>&1
  status=$?
  set -e
  if [ "$status" -ne 2 ]; then
    printf 'FAIL: %s without arguments returned %d, expected 2\n' "$script" "$status" >&2
    exit 1
  fi
done

grep -Fq '2026-04-01' docs/instructor/azure-setup.md
grep -Fq 'Web Knowledge Source' docs/instructor/azure-setup.md
grep -Fq '참가자별 subscription key' docs/instructor/azure-setup.md
grep -Fq 'APIM_BASE_URL' docs/instructor/azure-setup.md
grep -Fq 'BRAND_DOMAINS' docs/instructor/azure-setup.md
grep -Fq './scripts/test-live.sh' docs/instructor/azure-setup.md

printf 'OK: script usage tests passed\n'
