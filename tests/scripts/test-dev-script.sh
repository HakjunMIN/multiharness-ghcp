#!/usr/bin/env bash
set -euo pipefail

grep -Fxq '.env' .gitignore
grep -Fxq 'BRAND_NAME=한빛전자' .env.example
grep -Fq 'uv run uvicorn consult.main:app' scripts/dev.sh
grep -Fq 'npm run dev' scripts/dev.sh
grep -Fq 'trap cleanup EXIT INT TERM' scripts/dev.sh
if grep -Fq 'wait -n' scripts/dev.sh; then
	printf 'FAIL: dev script must support macOS Bash 3.2 (no wait -n)\n' >&2
	exit 1
fi
printf 'OK: dev script contract passed\n'
