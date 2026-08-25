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
  if gh repo view --json nameWithOwner,viewerPermission,hasIssuesEnabled >/dev/null 2>&1; then
    repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
    ok "GitHub 리포 컨텍스트 ($repo)"
    permission="$(gh repo view --json viewerPermission --jq .viewerPermission)"
    issues_enabled="$(gh repo view --json hasIssuesEnabled --jq .hasIssuesEnabled)"
    case "$permission" in
      TRIAGE|WRITE|MAINTAIN|ADMIN) issue_role=1 ;;
      *) issue_role=0 ;;
    esac
    if [ "$issues_enabled" != "true" ]; then
      bad "GitHub Issues 비활성화" "리포 설정에서 Issues를 활성화하세요."
    elif [ "$issue_role" -eq 1 ]; then
      ok "GitHub Issues 관리 권한 ($permission)"
    elif [ "$strict" -eq 1 ]; then
      bad "GitHub Issues 관리 권한 없음 ($permission)" "관리자에게 Triage 이상의 리포 역할을 요청하세요."
    else
      warn_ "GitHub Issues 관리 권한 미확인 ($permission)" "strict 점검: ./scripts/preflight.sh --strict"
    fi
  else
    if [ "$strict" -eq 1 ]; then
      bad "GitHub 리포 컨텍스트 없음" "강사가 제공한 실습 리포를 clone하거나 올바른 origin을 연결하세요."
    else
      warn_ "GitHub 리포 컨텍스트 없음" "이슈 실습 전에 강사가 제공한 실습 리포를 clone하세요."
    fi
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

# --- optional planning harness CLI ---
if command -v claude >/dev/null 2>&1; then
  ok "claude CLI ($(claude --version 2>/dev/null | head -1 || printf 'version unknown'))"
else
  warn_ "claude CLI 없음" "VS Code Claude session으로 Lab 1~2를 진행할 수 있습니다."
fi

if [ "$strict" -eq 1 ]; then
  if [ "${WORKSHOP_CLAUDE_OPUS5_CONFIRMED:-0}" = "1" ]; then
    ok "Claude Opus 5 session 접근 확인"
  else
    bad "Claude Opus 5 session 미확인" "VS Code에서 Claude/Claude Opus 5를 연 뒤 실행: export WORKSHOP_CLAUDE_OPUS5_CONFIRMED=1"
  fi

  case "${WORKSHOP_VERIFY_ROUTE:-}" in
    codex-cloud)
      if [ "${WORKSHOP_VERIFY_MODEL_CONFIRMED:-0}" = "1" ]; then
        ok "GHEC Codex cloud agent 정책·리포·모델·사용량 확인"
      else
        bad "GHEC Codex cloud agent 미확인" "정책, 리포 활성화, 할당, 모델, Actions minutes, AI credits를 확인한 뒤 WORKSHOP_VERIFY_MODEL_CONFIRMED=1을 설정하세요."
      fi
      ;;
    copilot-terra)
      if [ "${WORKSHOP_VERIFY_MODEL_CONFIRMED:-0}" = "1" ]; then
        ok "Copilot / GPT-5.6 Terra 검증 경로 확인"
      else
        bad "GPT-5.6 Terra 접근 미확인" "Copilot에서 모델을 확인한 뒤 실행: export WORKSHOP_VERIFY_MODEL_CONFIRMED=1"
      fi
      ;;
    *)
      bad "검증 경로 미선택" "실행: export WORKSHOP_VERIFY_ROUTE=codex-cloud 또는 export WORKSHOP_VERIFY_ROUTE=copilot-terra"
      ;;
  esac
fi

printf '\npreflight: %d pass, %d warn, %d fail\n' "$pass" "$warn" "$fail"
[ "$fail" -eq 0 ]
