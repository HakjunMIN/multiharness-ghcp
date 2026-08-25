#!/usr/bin/env bash
set -euo pipefail

required=(
  app/api/pyproject.toml app/api/uv.lock
  app/api/src/consult/settings.py app/api/src/consult/main.py
  app/api/tests/conftest.py app/api/tests/test_healthz.py
  app/web/package.json app/web/package-lock.json
  app/web/src/App.tsx app/web/src/App.test.tsx app/web/vite.config.ts
  .env.example scripts/dev.sh
)
for path in "${required[@]}"; do
  if [ ! -f "$path" ]; then
    echo "missing runway asset: $path" >&2
    exit 1
  fi
done

grep -Fq 'BRAND_NAME=한빛전자' .env.example
grep -Fq 'APIM_BASE_URL=' .env.example
grep -Fq 'POST /api/consult' AGENTS.md
printf 'OK: runway contract passed\n'
