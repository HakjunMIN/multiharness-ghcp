#!/usr/bin/env bash
set -euo pipefail

grep -Fq 'addopts = ["-m", "not e2e"]' app/api/pyproject.toml
grep -Fq 'e2e:' app/api/pyproject.toml
grep -Fq 'source "$ROOT/.env"' scripts/test-e2e.sh
grep -Fq 'pytest -m e2e -q' scripts/test-e2e.sh
if grep -rInE 'https?://[A-Za-z0-9]' app/api/src app/api/tests \
  --exclude='test_e2e_*.py' --exclude='test_healthz.py'; then
  echo 'hard-coded external endpoint outside e2e tests' >&2
  exit 1
fi
printf 'OK: e2e test boundary passed\n'
