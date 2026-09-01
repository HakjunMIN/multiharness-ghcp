#!/usr/bin/env bash
set -euo pipefail

grep -Fq 'addopts = ["-m", "not live"]' app/api/pyproject.toml
grep -Fq 'live:' app/api/pyproject.toml
grep -Fq '@pytest.mark.live' \
  docs/setup/checkpoint/app/api/tests/test_live_consult.py
grep -Fq 'AgentFrameworkSynthesizer' \
  docs/setup/checkpoint/app/api/src/consult/main.py
grep -Fq 'source "$ROOT/.env"' scripts/test-live.sh
grep -Fq 'pytest -m live -q' scripts/test-live.sh
if grep -rInE 'https?://[A-Za-z0-9]' app/api/src app/api/tests \
  --exclude='test_live_*.py' --exclude='test_healthz.py'; then
  echo 'hard-coded live endpoint outside live tests' >&2
  exit 1
fi
printf 'OK: live test boundary passed\n'
