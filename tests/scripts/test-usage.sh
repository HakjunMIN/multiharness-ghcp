#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for script in build-participant-bundle.sh; do
  set +e
  "$ROOT/scripts/$script" >/dev/null 2>&1
  status=$?
  set -e
  if [ "$status" -ne 2 ]; then
    printf 'FAIL: %s without arguments returned %d, expected 2\n' "$script" "$status" >&2
    exit 1
  fi
done

grep -Fq '2026-04-01' docs/setup/azure-setup.md
grep -Fq 'Web Knowledge Source' docs/setup/azure-setup.md
grep -Fq '참가자별 subscription key' docs/setup/azure-setup.md
grep -Fq 'APIM_BASE_URL' docs/setup/azure-setup.md
grep -Fq 'BRAND_NAME' docs/setup/azure-setup.md
grep -Fq './scripts/test-e2e.sh' docs/setup/azure-setup.md

printf 'OK: script usage tests passed\n'
