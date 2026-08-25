#!/usr/bin/env bash
set -euo pipefail

# Repository asset integrity gate.
#  1) every path in the manifest exists
#  2) no forbidden strings (placeholders / customer identifiers)
#  3) relative markdown links resolve to real files
#  4) shell scripts parse, are executable, and follow the house style

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

MANIFEST="scripts/repo-manifest.txt"
fail=0
err() { printf 'FAIL: %s\n' "$1" >&2; fail=1; }

# --- 1) manifest paths ---
count=0
while IFS= read -r path || [ -n "$path" ]; do
  [ -z "$path" ] && continue
  case "$path" in \#*) continue ;; esac
  count=$((count + 1))
  [ -e "$path" ] || err "manifest path missing: $path"
done < "$MANIFEST"

# --- 2) forbidden strings ---
targets=()
for d in docs .github scripts seed agent-seed; do [ -d "$d" ] && targets+=("$d"); done
for f in README.md AGENTS.md CLAUDE.md; do [ -f "$f" ] && targets+=("$f"); done

if [ ${#targets[@]} -gt 0 ]; then
  if hits=$(grep -rInE '\b(TBD|TODO|FIXME)\b|작성 예정' \
        "${targets[@]}" \
        --exclude-dir=superpowers --exclude-dir=node_modules \
        --exclude-dir=.venv --exclude-dir=__pycache__ \
        --exclude=repo-manifest.txt --exclude=check-repo.sh 2>/dev/null); then
    err "placeholder found:"$'\n'"$hits"
  fi
  if hits=$(grep -rInE '삼성|Samsung|SAMSUNG' \
        "${targets[@]}" \
        --exclude-dir=superpowers --exclude-dir=node_modules \
        --exclude-dir=.venv --exclude-dir=__pycache__ \
        --exclude=check-repo.sh 2>/dev/null); then
    err "customer identifier found:"$'\n'"$hits"
  fi
fi

# --- 3) relative markdown links ---
while IFS= read -r md; do
  base="$(dirname "$md")"
  while IFS= read -r link; do
    case "$link" in http*|mailto:*|'') continue ;; esac
    target="${link%%#*}"
    [ -z "$target" ] && continue
    if [ ! -e "$base/$target" ] && [ ! -e "$target" ]; then
      err "broken link in $md -> $target"
    fi
  done < <(grep -oE '\]\([^)#][^)]*\)' "$md" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//' || true)
done < <(
  find . -name '*.md' \
    -not -path './node_modules/*' \
    -not -path './docs/superpowers/*' \
    -not -path './.agents/skills/*' \
    -not -path './.github/skills/*' \
    -not -path './.git/*'
)

# --- 4) shell script hygiene ---
# 서브셸에서 fail 플래그를 잃지 않도록 프로세스 치환을 유지한다.
while IFS= read -r sh; do
  bash -n "$sh" 2>/dev/null || err "shell syntax error: $sh"
  [ -x "$sh" ] || err "not executable: $sh"
  head -1 "$sh" | grep -q '^#!/usr/bin/env bash$' || err "missing bash shebang: $sh"
  grep -q 'set -euo pipefail' "$sh" || err "missing 'set -euo pipefail': $sh"
done < <(
  find scripts tests -name '*.sh' 2>/dev/null
  true
)

# --- 5) zero-dependency seed contract ---
if [ -f seed/package.json ]; then
  if ! node -e '
    const p = require("./seed/package.json");
    if (p.dependencies || p.devDependencies || p.optionalDependencies || p.peerDependencies) process.exit(1);
    if (!p.engines || p.engines.node !== ">=22.18.0") process.exit(2);
  '; then
    err "seed/package.json must have no dependency keys and engines.node must equal >=22.18.0"
  fi
fi

# --- 6) pinned agent track dependencies ---
if [ -f agent-seed/pyproject.toml ]; then
  # git 체크아웃이 아닌 배포본(tarball)에서도 돌아야 하므로 존재 여부를 먼저 본다.
  if [ ! -f agent-seed/uv.lock ]; then
    err "agent-seed/uv.lock must be committed so the workshop resolves offline"
  elif git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
    ! git ls-files --error-unmatch agent-seed/uv.lock >/dev/null 2>&1; then
    err "agent-seed/uv.lock must be committed so the workshop resolves offline"
  fi
  # 모든 agent-framework* 의존성은 == 로 정확히 고정되어야 한다.
  # 워크샵 도중 상위 버전이 나와 API 가 흔들리면 실습이 멈춘다.
  python3 - <<'PIN' || err "agent-seed dependencies must be pinned with == so the API cannot shift mid-workshop"
import re
import sys

text = open("agent-seed/pyproject.toml", encoding="utf-8").read()
specs = re.findall(r'"(agent-framework[^"]*)"', text)
if not specs:
    sys.exit(1)
sys.exit(0 if all(re.fullmatch(r"[A-Za-z0-9._-]+==[A-Za-z0-9._-]+", s) for s in specs) else 1)
PIN
  # 테스트는 네트워크를 쓰지 않는다. 실제 엔드포인트를 부르는 코드가 들어오면 막는다.
  # BSD grep 에는 -P 가 없으므로 두 단계로 거른다.
  if hits=$(grep -rInE 'https?://[A-Za-z0-9]' agent-seed/src agent-seed/tests 2>/dev/null |
              grep -vE 'https?://example\.invalid'); then
    err "agent-seed must not reference live endpoints:"$'\n'"$hits"
  fi
fi

# --- 7) optional Matt skill installation contract ---
if [ -f scripts/check-matt-skills.mjs ]; then
  node scripts/check-matt-skills.mjs >/dev/null ||
    err "Matt skill installation contract failed"
fi

if [ "$fail" -ne 0 ]; then
  printf 'FAIL: repo check failed\n' >&2
  exit 1
fi
printf 'OK: repo check passed (%d paths)\n' "$count"
