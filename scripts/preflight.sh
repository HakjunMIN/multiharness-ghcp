#!/usr/bin/env bash
set -euo pipefail

# Workshop environment preflight. Lab 0 is this script.
# PASS / WARN / FAIL per item. Only FAIL affects the exit code.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

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

# --- seed tests ---
if [ -f seed/package.json ]; then
  if (cd seed && npm test >/dev/null 2>&1); then
    ok "시드 테스트 통과 (seed/)"
  else
    bad "시드 테스트 실패" "실행해서 원인을 확인하세요: cd seed && npm test"
  fi
else
  bad "seed/package.json 없음" "리포 루트에서 실행하세요."
fi

# --- git ---
if command -v git >/dev/null 2>&1; then
  ok "git $(git --version | awk '{print $3}')"
else
  bad "git 없음" "git 을 설치하세요."
fi

# --- gh ---
if command -v gh >/dev/null 2>&1; then
  ok "gh $(gh --version | head -1 | awk '{print $3}')"
  if gh auth status >/dev/null 2>&1; then
    ok "gh 인증됨"
  else
    bad "gh 미인증" "실행: gh auth login"
  fi
  if gh repo view --json nameWithOwner >/dev/null 2>&1; then
    ok "GitHub 리포 컨텍스트 ($(gh repo view --json nameWithOwner --jq .nameWithOwner))"
  else
    warn_ "GitHub 리포 컨텍스트 없음" "이슈 실습 전에 실행: gh repo create"
  fi
  mutations="$(gh api graphql -f query='{ __type(name:"Mutation"){ fields{ name } } }' --jq '.data.__type.fields[].name' 2>/dev/null || true)"
  if printf '%s\n' "$mutations" | grep -qx addSubIssue; then
    ok "서브이슈 GraphQL API 접근 가능"
  else
    warn_ "서브이슈 API 확인 실패" "토큰 스코프를 갱신하세요: gh auth refresh -s repo"
  fi
else
  bad "gh 없음" "https://cli.github.com 에서 GitHub CLI 를 설치하세요."
fi

# --- copilot ---
if command -v copilot >/dev/null 2>&1; then
  ok "copilot CLI $(copilot --version 2>/dev/null | head -1)"
else
  bad "copilot CLI 없음" "GitHub Copilot CLI 를 설치하세요."
fi

# --- optional partner harness CLIs ---
if command -v claude >/dev/null 2>&1; then
  ok "claude CLI"
else
  warn_ "claude CLI 없음" "VS Code 확장으로도 Lab 1~2 를 진행할 수 있습니다."
fi

if command -v codex >/dev/null 2>&1; then
  ok "codex CLI"
else
  warn_ "codex CLI 없음" "Lab 4 는 경로 B(Copilot + GPT-5.6 Terra + 새 세션)로 진행할 수 있습니다."
fi

printf '\npreflight: %d pass, %d warn, %d fail\n' "$pass" "$warn" "$fail"
[ "$fail" -eq 0 ]
