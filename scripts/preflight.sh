#!/usr/bin/env bash
set -euo pipefail

# Workshop environment preflight. Lab 0 is this script.
# PASS / WARN / FAIL per item. Only FAIL affects the exit code.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

strict=0
if [ "${1:-}" = "--strict" ]; then
  strict=1
elif [ $# -gt 0 ]; then
  printf 'usage: %s [--strict]\n' "$0" >&2
  exit 2
fi

pass=0
warn=0
fail=0

ok()   { printf 'PASS  %s\n' "$1"; pass=$((pass + 1)); }
warn_() { printf 'WARN  %s — %s\n' "$1" "$2"; warn=$((warn + 1)); }
bad()  { printf 'FAIL  %s — %s\n' "$1" "$2"; fail=$((fail + 1)); }

# ver_ge <have> <want> -> 0 when have >= want
ver_ge() {
  printf '%s\n%s\n' "$2" "$1" | sort -t. -k1,1n -k2,2n -k3,3n | head -1 | grep -qx "$2"
}

# --- Node.js ---
if command -v node >/dev/null 2>&1; then
  have="$(node -v | sed 's/^v//')"
  if ver_ge "$have" "22.18.0"; then
    ok "Node.js $have (>= 22.18.0)"
  else
    bad "Node.js $have" "22.18 이상이 필요합니다. TypeScript 네이티브 실행이 안 됩니다. 업그레이드하세요."
  fi
else
  bad "Node.js 없음" "https://nodejs.org 에서 22.18 이상을 설치하세요."
fi

# --- web runway ---
if [ -f app/web/package.json ]; then
  web_ready=1
  if [ ! -d app/web/node_modules ]; then
    if (cd app/web && npm ci >/dev/null 2>&1); then
      ok "web 의존성 설치"
    else
      bad "web 의존성 설치 실패" "실행해서 원인을 확인하세요: cd app/web && npm ci"
      web_ready=0
    fi
  else
    ok "web 의존성 설치됨"
  fi
  if [ "$web_ready" -eq 1 ]; then
    if (cd app/web && npm test >/dev/null 2>&1 && npm run build >/dev/null 2>&1); then
      ok "web test/build 통과"
    else
      warn_ "web test/build 실패" "환경이 아니라 작업 중 코드 문제일 수 있습니다. 확인하세요: cd app/web && npm test && npm run build"
    fi
  fi
else
  bad "app/web/package.json 없음" "리포 루트에서 실행하세요."
fi

# --- API runway ---
if [ -f app/api/pyproject.toml ]; then
  if command -v uv >/dev/null 2>&1; then
    ok "uv $(uv --version | awk '{print $2}')"
    if (cd app/api && uv sync --frozen >/dev/null 2>&1); then
      ok "API 의존성 설치"
      if (cd app/api && uv run --frozen pytest -q >/dev/null 2>&1); then
        ok "API 기본 테스트 통과"
      else
        warn_ "API 기본 테스트 실패" "환경이 아니라 작업 중 코드 문제일 수 있습니다. 확인하세요: cd app/api && uv run --frozen pytest -q"
      fi
    else
      bad "API 의존성 설치 실패" "실행해서 원인을 확인하세요: cd app/api && uv sync --frozen"
    fi
  else
    bad "uv 없음" "API runway에 필요합니다. 설치: https://docs.astral.sh/uv/"
  fi
else
  bad "app/api/pyproject.toml 없음" "리포 루트에서 실행하세요."
fi

# --- git ---
if command -v git >/dev/null 2>&1; then
  ok "git $(git --version | awk '{print $3}')"
else
  bad "git 없음" "git 을 설치하세요."
fi

# --- gh (only required for the optional final-PR fork step) ---
if command -v gh >/dev/null 2>&1; then
  ok "gh $(gh --version | head -1 | awk '{print $3}')"
  if gh auth status >/dev/null 2>&1; then
    ok "gh 인증됨"
  else
    warn_ "gh 미인증" "최종 PR을 만들 때만 필요합니다: gh auth login"
  fi
  if gh repo view --json nameWithOwner >/dev/null 2>&1; then
    repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
    ok "GitHub 리포 컨텍스트 ($repo)"
  else
    warn_ "GitHub 리포 컨텍스트 없음" "최종 PR을 만들 참가자만 fork를 origin으로 설정하세요."
  fi
else
  warn_ "gh 없음" "VS Code 하네스 워크플로우 자체에는 필요하지 않습니다. 최종 PR을 만들 때만 https://cli.github.com 에서 설치하세요."
fi

# --- skills.sh runner ---
if command -v npx >/dev/null 2>&1; then
  ok "npx 사용 가능"
else
  bad "npx 없음" "Matt Pocock 스킬 설치에 필요합니다. Node.js 설치를 확인하세요."
fi

if [ "$strict" -eq 1 ]; then
  if [ "${WORKSHOP_CLAUDE_OPUS48_CONFIRMED:-0}" = "1" ]; then
    ok "권장 Claude harness + Claude Opus 4.8 확인"
  else
    warn_ "권장 Claude harness + Claude Opus 4.8 미확인" "사용 가능한 다른 runtime/model로 진행하고 실제 선택을 durable artifact에 기록하세요."
  fi

  if [ "${WORKSHOP_GPT56_SOL_CONFIRMED:-0}" = "1" ]; then
    ok "권장 Copilot harness + GPT-5.6 Sol 확인"
  else
    warn_ "권장 Copilot harness + GPT-5.6 Sol 미확인" "사용 가능한 다른 runtime/model로 진행하고 실제 선택을 durable artifact에 기록하세요."
  fi

  if [ "${WORKSHOP_CODEX_TERRA_CONFIRMED:-0}" = "1" ]; then
    ok "권장 local Codex + Copilot-backed GPT-5.6 Terra 확인"
  else
    warn_ "권장 local Codex + GPT-5.6 Terra 미확인" "구현 세션과 분리된 verifier runtime/model을 선택하고 실제 선택을 UAT report에 기록하세요."
  fi
fi

printf '\npreflight: %d pass, %d warn, %d fail\n' "$pass" "$warn" "$fail"
[ "$fail" -eq 0 ]
