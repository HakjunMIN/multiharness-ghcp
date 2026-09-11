#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

check_ok() {
  local name="$1"
  shift
  local output
  if ! output="$("$@" 2>&1)"; then
    printf 'FAIL: %s\n%s\n' "$name" "$output" >&2
    exit 1
  fi
}

check_fail() {
  local name="$1"
  shift
  local output
  if output="$("$@" 2>&1)"; then
    printf 'FAIL: %s unexpectedly passed\n%s\n' "$name" "$output" >&2
    exit 1
  fi
}

make_fixture() {
  local target="$1"
  mkdir -p "$target/scripts" "$target/.agents/skills"
  cp "$ROOT/scripts/check-project-skills.mjs" "$target/scripts/"
  cp "$ROOT/scripts/required-project-skills.txt" "$target/scripts/"
  node - "$target" "$ROOT/scripts/required-project-skills.txt" <<'NODE'
const fs = require("node:fs");
const path = require("node:path");
const [root, inventory] = process.argv.slice(2);
const names = fs.readFileSync(inventory, "utf8").trim().split(/\n+/);
const skills = {};
for (const name of names) {
  const dir = path.join(root, ".agents", "skills", name);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, "SKILL.md"), `---\nname: ${name}\n---\n`);
  skills[name] = {
    source: name === "frontend-design" ? "anthropics/skills" : "mattpocock/skills",
    sourceType: "github",
    skillPath: `skills/engineering/${name}/SKILL.md`,
    computedHash: "a".repeat(64),
  };
}
fs.writeFileSync(path.join(root, "skills-lock.json"), JSON.stringify({ skills }, null, 2));
NODE
}

mkdir -p "$TMP/empty/scripts"
cp "$ROOT/scripts/check-project-skills.mjs" "$TMP/empty/scripts/"
cp "$ROOT/scripts/required-project-skills.txt" "$TMP/empty/scripts/"
check_ok "pre-install state is optional" \
  bash -c "cd '$TMP/empty' && node scripts/check-project-skills.mjs"
check_fail "required mode rejects a missing lock" \
  bash -c "cd '$TMP/empty' && node scripts/check-project-skills.mjs --required"

make_fixture "$TMP/valid"
check_ok "complete installation passes" \
  bash -c "cd '$TMP/valid' && node scripts/check-project-skills.mjs --required"

cp -R "$TMP/valid" "$TMP/missing-file"
rm -rf "$TMP/missing-file/.agents/skills/tdd"
check_fail "missing installed directory fails" \
  bash -c "cd '$TMP/missing-file' && node scripts/check-project-skills.mjs --required"

cp -R "$TMP/valid" "$TMP/missing-lock"
node -e '
const fs = require("node:fs");
const file = process.argv[1];
const lock = JSON.parse(fs.readFileSync(file, "utf8"));
delete lock.skills["to-spec"];
fs.writeFileSync(file, JSON.stringify(lock));
' "$TMP/missing-lock/skills-lock.json"
check_fail "missing lock entry fails" \
  bash -c "cd '$TMP/missing-lock' && node scripts/check-project-skills.mjs --required"

cp -R "$TMP/valid" "$TMP/wrong-source"
node -e '
const fs = require("node:fs");
const file = process.argv[1];
const lock = JSON.parse(fs.readFileSync(file, "utf8"));
lock.skills.tdd.source = "example/other-skills";
fs.writeFileSync(file, JSON.stringify(lock));
' "$TMP/wrong-source/skills-lock.json"
check_fail "wrong source fails" \
  bash -c "cd '$TMP/wrong-source' && node scripts/check-project-skills.mjs --required"

cp -R "$TMP/valid" "$TMP/bad-hash"
node -e '
const fs = require("node:fs");
const file = process.argv[1];
const lock = JSON.parse(fs.readFileSync(file, "utf8"));
lock.skills.tdd.computedHash = "short";
fs.writeFileSync(file, JSON.stringify(lock));
' "$TMP/bad-hash/skills-lock.json"
check_fail "invalid hash fails" \
  bash -c "cd '$TMP/bad-hash' && node scripts/check-project-skills.mjs --required"

legacy_assets=(
  wf
  .claude-plugin
  .github/agents/architect.agent.md
  .github/agents/implementer.agent.md
  .github/agents/verifier.agent.md
  .github/skills/workshop-status
  .github/skills/workshop-next
  .github/skills/issue-map
  .github/skills/handoff-brief
  .github/skills/uat-verify
)
for asset in "${legacy_assets[@]}"; do
  if [ -e "$ROOT/$asset" ]; then
    printf 'FAIL: legacy workflow asset remains: %s\n' "$asset" >&2
    exit 1
  fi
done

printf 'OK: project skill contract tests passed\n'
