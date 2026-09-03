#!/usr/bin/env bash
set -euo pipefail

grep -Fq 'addopts = ["-m", "not e2e"]' app/api/pyproject.toml
grep -Fq 'e2e:' app/api/pyproject.toml
grep -Fq 'source "$ROOT/.env"' scripts/test-e2e.sh
grep -Fq 'pytest -m e2e -q' scripts/test-e2e.sh

# 금지 대상은 URL 리터럴이 아니라 실제로 라우팅되는 endpoint다.
# AGENTS.md는 example.invalid 같은 non-routable 값을 쓰라고 요구하므로
# .invalid / localhost / testserver 호스트는 허용한다.
if hits=$(grep -rInE 'https?://[A-Za-z0-9]' app/api/src app/api/tests \
      --exclude='test_e2e_*.py' 2>/dev/null |
    grep -vE 'https?://([A-Za-z0-9-]+\.)*(invalid|localhost|testserver)([]:/?#"'"'"'[:space:],)]|$)' |
    grep -vE 'https?://127\.0\.0\.1'); then
  printf '%s\n' "$hits" >&2
  echo 'routable external endpoint outside e2e tests' >&2
  exit 1
fi
printf 'OK: e2e test boundary passed\n'
