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

node - "$ROOT" <<'NODE'
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = process.argv[2];
const read = (file) => fs.readFileSync(path.join(root, file), "utf8");
const skill = (name) => read(`.agents/skills/${name}/SKILL.md`);
const inventory = (file) => read(file).split(/\r?\n/)
  .map((line) => line.trim()).filter((line) => line && !line.startsWith("#"));
const names = [
  ...inventory("scripts/required-project-skills.txt"),
  ...inventory("scripts/local-project-skills.txt"),
];

for (const name of names) {
  const text = skill(name);
  assert.ok(text.startsWith("---\n"), `${name}: missing frontmatter`);
  const metadata = text.split("---")[1];
  assert.ok(metadata.includes(`name: ${name}\n`), `${name}: wrong name`);
  assert.match(metadata, /\ndescription: \S/, `${name}: missing description`);
  const uiPath = `.agents/skills/${name}/agents/openai.yaml`;
  if (fs.existsSync(path.join(root, uiPath))) {
    assert.equal(
      /allow_implicit_invocation: false/.test(read(uiPath)),
      /disable-model-invocation: true/.test(metadata),
      `${name}: explicit invocation policies disagree`,
    );
  }
}

// Reference prose is loaded on demand; broken pointers must not silently pass.
function checkLinks(directory) {
  for (const entry of fs.readdirSync(path.join(root, directory), { withFileTypes: true })) {
    const file = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      checkLinks(file);
    } else if (entry.name.endsWith(".md")) {
      const prose = read(file).replace(/```[\s\S]*?```/g, "");
      for (const [, link] of prose.matchAll(/\]\(([^)]+)\)/g)) {
        if (/^(https?:|mailto:|#)/.test(link)) continue;
        const target = link.split("#")[0];
        assert.ok(fs.existsSync(path.resolve(root, path.dirname(file), target)),
          `${file}: broken reference ${link}`);
      }
    }
  }
}
checkLinks(".agents/skills");

assert.match(skill("to-spec"), /discovery\.md/);
assert.match(skill("to-spec"), /docs\/templates\/spec\.md/);
assert.doesNotMatch(skill("to-spec"), /current conversation context|<spec-template>/);
assert.match(read(".agents/skills/to-spec/agents/openai.yaml"), /approved artifacts/);
assert.match(skill("to-tickets"), /API acceptance → backend → browser acceptance → frontend integration/);
assert.match(skill("to-tickets"), /\*\*Verify:\*\*/);
assert.match(skill("to-tickets"), /\*\*Decisions:\*\*/);
assert.doesNotMatch(skill("to-tickets"), /<issue-template>|native blocking/);
assert.match(skill("implement"), /fresh independent verification session/);
assert.match(skill("implement"), /handoff-contract\.md/);
assert.match(skill("tdd"), /acceptance-only sessions stop at expected red/);
assert.match(skill("prototype"), /Do not promote the winner into production/);
assert.match(skill("prototype"), /Status: decided/);
assert.match(skill("microsoft-agent-framework"), /operator-gated `e2e` pytest marker/);
assert.doesNotMatch(skill("microsoft-agent-framework"), /`live`.*marker/);
assert.match(skill("domain-modeling"), /Preserve this repository's existing sections/);
assert.match(skill("frontend-design"), /나눔고딕/);
assert.match(skill("code-review"), /read-only/);
assert.match(skill("research"), /verified facts, inference and unknowns/);
assert.match(skill("diagnosing-bugs"), /only an implementation session may fix production/);
NODE

printf 'OK: project skill contract tests passed\n'
