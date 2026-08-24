#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/bin"
cat > "$TMP/bin/gh" <<'FAKE'
#!/usr/bin/env bash
printf '%s\n' "$*" > "$GH_CAPTURE"
FAKE
chmod 755 "$TMP/bin/gh"
export PATH="$TMP/bin:$PATH"
export GH_CAPTURE="$TMP/gh.args"

mkdir -p "$TMP/repo/seed/src"
printf '# workshop\n' > "$TMP/repo/README.md"
printf 'export const route = true;\n' > "$TMP/repo/seed/src/router.ts"
(
  cd "$TMP/repo"
  git init -q
  git add .
  git -c user.name=test -c user.email=test@example.invalid commit -qm fixture
)
cd "$TMP/repo"

failures=0
expect_fail() {
  if "$@" >/dev/null 2>&1; then
    printf 'FAIL: command unexpectedly succeeded: %s\n' "$*" >&2
    failures=$((failures + 1))
  fi
}

cat > "$TMP/valid.md" <<'EOF'
## HANDOFF
- from/to: Copilot/GPT-5.6 Sol -> Copilot/GPT-5.6 Terra
- artifacts: README.md, seed/src/router.ts
- done: implementation complete
- not done: independent UAT
- decisions: Issue 12
- verify: (cd seed && npm test)
- risks: EU fallback needs independent verification
EOF

"$ROOT/scripts/handoff.sh" 12 "$TMP/valid.md"
grep -qF 'issue comment 12 --body-file' "$GH_CAPTURE"

sed '/^- risks:/d' "$TMP/valid.md" > "$TMP/missing.md"
expect_fail "$ROOT/scripts/handoff.sh" 12 "$TMP/missing.md"

sed '/^- risks:/d; s#^- done:.*#- done: prose mentions - risks: but no risks field#' \
  "$TMP/valid.md" > "$TMP/embedded-field.md"
expect_fail "$ROOT/scripts/handoff.sh" 12 "$TMP/embedded-field.md"

sed 's#README.md, seed/src/router.ts#https://github.com/example/repo/issues/12#' \
  "$TMP/valid.md" > "$TMP/url-artifact.md"
expect_fail "$ROOT/scripts/handoff.sh" 12 "$TMP/url-artifact.md"

sed 's#README.md, seed/src/router.ts#not-tracked.txt#' \
  "$TMP/valid.md" > "$TMP/untracked.md"
expect_fail "$ROOT/scripts/handoff.sh" 12 "$TMP/untracked.md"

sed 's#README.md, seed/src/router.ts#seed/src#' \
  "$TMP/valid.md" > "$TMP/directory.md"
expect_fail "$ROOT/scripts/handoff.sh" 12 "$TMP/directory.md"

printf 'unstaged\n' >> README.md
expect_fail "$ROOT/scripts/handoff.sh" 12 "$TMP/valid.md"
git restore README.md

printf 'staged\n' >> README.md
git add README.md
expect_fail "$ROOT/scripts/handoff.sh" 12 "$TMP/valid.md"
git restore --staged README.md
git restore README.md

sed 's#implementation complete#<완료된 것>#' "$TMP/valid.md" > "$TMP/template.md"
expect_fail "$ROOT/scripts/handoff.sh" 12 "$TMP/template.md"

expect_fail "$ROOT/scripts/handoff.sh" abc "$TMP/valid.md"

if [ "$failures" -ne 0 ]; then
  exit 1
fi
printf 'OK: handoff behavior tests passed\n'
