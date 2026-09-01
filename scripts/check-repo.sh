#!/usr/bin/env bash
set -euo pipefail

# Repository asset integrity gate.
#  1) every path in the manifest exists
#  2) no forbidden strings, customer identifiers, or committed secrets
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

for legacy_path in seed agent-seed docs/instructor/reference-solution; do
  [ ! -e "$legacy_path" ] || err "legacy workshop path must stay removed: $legacy_path"
done

# --- 2) forbidden strings ---
targets=()
for d in app docs .github scripts; do [ -d "$d" ] && targets+=("$d"); done
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
  if hits=$(grep -rInE '^[[:space:]]*APIM_KEY=.+$' \
        . --exclude-dir=.git --exclude-dir=.worktrees --exclude-dir=node_modules \
        --exclude-dir=.venv --exclude='.env' 2>/dev/null); then
    err "nonempty APIM key found:"$'\n'"$hits"
  fi
  if hits=$(grep -rInE 'https://(pypi\.org|files\.pythonhosted\.org|api\.nuget\.org)' \
        "${targets[@]}" \
        --exclude-dir=superpowers --exclude-dir=node_modules \
        --exclude-dir=.venv --exclude-dir=__pycache__ 2>/dev/null); then
    err "public Python or NuGet package feed found:"$'\n'"$hits"
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
    -not -path '*/node_modules/*' \
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

# --- 5) pinned greenfield runway dependencies ---
[ -f app/api/uv.lock ] || err "app/api/uv.lock is required"
[ -f app/web/package-lock.json ] || err "app/web/package-lock.json is required"

python3 - <<'PIN' || err "app/api direct dependencies must use exact == pins"
import re
import sys

text = open("app/api/pyproject.toml", encoding="utf-8").read()
blocks = re.findall(r"(?ms)^(?:dependencies|dev) = \[(.*?)^\]", text)
specs = [spec for block in blocks for spec in re.findall(r'"([^"]+)"', block)]
sys.exit(0 if specs and all(
    re.fullmatch(r"[A-Za-z0-9._-]+==[A-Za-z0-9._-]+", spec) for spec in specs
) else 1)
PIN

node - <<'PIN' || err "app/web dependencies must use exact versions"
const project = require('./app/web/package.json');
for (const group of [project.dependencies, project.devDependencies]) {
  for (const version of Object.values(group || {})) {
    if (!/^\d+\.\d+\.\d+$/.test(version)) process.exit(1);
  }
}
PIN

# --- 7) optional project skill installation contract ---
if [ -f scripts/check-project-skills.mjs ]; then
  node scripts/check-project-skills.mjs >/dev/null ||
    err "project skill installation contract failed"
fi

if [ "$fail" -ne 0 ]; then
  printf 'FAIL: repo check failed\n' >&2
  exit 1
fi
printf 'OK: repo check passed (%d paths)\n' "$count"
