#!/usr/bin/env bash
set -euo pipefail

required=(
  app/api/pyproject.toml app/api/uv.lock
  app/api/src/consult/settings.py app/api/src/consult/main.py
  app/api/tests/conftest.py app/api/tests/test_healthz.py
  app/web/package.json app/web/package-lock.json
  app/web/src/App.tsx app/web/src/App.test.tsx app/web/vite.config.ts
  app/web/playwright.config.ts
  .env.example scripts/dev.sh
)
for path in "${required[@]}"; do
  if [ ! -f "$path" ]; then
    echo "missing runway asset: $path" >&2
    exit 1
  fi
done

# Lab 6 브라우저 인수 시나리오는 runway에 선탑재된 Playwright를 사용한다.
# 참가자가 랩 중에 새 의존성을 설치하지 않도록 여기서 계약을 고정한다.
for dir in app/web/e2e/deterministic app/web/e2e/live; do
  if [ ! -d "$dir" ]; then
    echo "missing browser acceptance directory: $dir" >&2
    exit 1
  fi
done

node -e '
  const project = require("./app/web/package.json");
  const dev = project.devDependencies || {};
  const scripts = project.scripts || {};
  if (!dev["@playwright/test"]) {
    console.error("app/web must preinstall @playwright/test");
    process.exit(1);
  }
  for (const name of ["test:browser", "test:browser:live"]) {
    if (!scripts[name]) {
      console.error(`app/web/package.json is missing the ${name} script`);
      process.exit(1);
    }
  }
'

# credential이 report에 남지 않도록 두 project 모두 artifact capture를 끈다.
for setting in 'trace: "off"' 'screenshot: "off"' 'video: "off"' \
  'name: "deterministic"' 'name: "live"'; do
  grep -Fq "$setting" app/web/playwright.config.ts || {
    echo "app/web/playwright.config.ts is missing: $setting" >&2
    exit 1
  }
done

# vitest는 src/만 수집해야 Playwright spec을 잘못 실행하지 않는다.
grep -Fq 'include: ["src/**/*.{test,spec}.{ts,tsx}"]' app/web/vite.config.ts

grep -Fq 'BRAND_NAME=한빛전자' .env.example
grep -Fq 'APIM_BASE_URL=' .env.example
grep -Fq 'POST /api/consult' AGENTS.md
printf 'OK: runway contract passed\n'
