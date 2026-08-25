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
for d in docs .github scripts seed; do [ -d "$d" ] && targets+=("$d"); done
for f in README.md AGENTS.md CLAUDE.md; do [ -f "$f" ] && targets+=("$f"); done

if [ ${#targets[@]} -gt 0 ]; then
  if hits=$(grep -rInE '\b(TBD|TODO|FIXME)\b|작성 예정' \
        "${targets[@]}" \
        --exclude-dir=superpowers --exclude-dir=node_modules \
        --exclude=repo-manifest.txt --exclude=check-repo.sh 2>/dev/null); then
    err "placeholder found:"$'\n'"$hits"
  fi
  if hits=$(grep -rInE '삼성|Samsung|SAMSUNG' \
        "${targets[@]}" \
        --exclude-dir=superpowers --exclude-dir=node_modules \
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
done < <(find . -name '*.md' -not -path './node_modules/*' -not -path './docs/superpowers/*' -not -path './.git/*')

# --- 4) shell script hygiene ---
while IFS= read -r sh; do
  bash -n "$sh" 2>/dev/null || err "shell syntax error: $sh"
  [ -x "$sh" ] || err "not executable: $sh"
  head -1 "$sh" | grep -q '^#!/usr/bin/env bash$' || err "missing bash shebang: $sh"
  grep -q 'set -euo pipefail' "$sh" || err "missing 'set -euo pipefail': $sh"
done < <(find scripts -name '*.sh' 2>/dev/null)

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

# --- 6) optional Codex path remains cloud-only and report-only ---
if [ -x tests/scripts/test-codex-cloud-docs.sh ]; then
  tests/scripts/test-codex-cloud-docs.sh >/dev/null ||
    err "Codex cloud documentation contract failed"
fi

if [ "$fail" -ne 0 ]; then
  printf 'FAIL: repo check failed\n' >&2
  exit 1
fi
printf 'OK: repo check passed (%d paths)\n' "$count"
