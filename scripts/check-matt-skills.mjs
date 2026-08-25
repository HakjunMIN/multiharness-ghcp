#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const requiredMode = process.argv.slice(2).includes("--required");
const root = process.cwd();
const inventoryPath = path.join(root, "scripts", "required-matt-skills.txt");
const lockPath = path.join(root, "skills-lock.json");
const required = fs
  .readFileSync(inventoryPath, "utf8")
  .split(/\r?\n/)
  .map((line) => line.trim())
  .filter((line) => line && !line.startsWith("#"));

if (!fs.existsSync(lockPath)) {
  if (requiredMode) {
    console.error("FAIL: skills-lock.json is required after Lab 0");
    process.exit(1);
  }
  console.log("SKIP: Matt skills are installed during Lab 0");
  process.exit(0);
}

let lock;
try {
  lock = JSON.parse(fs.readFileSync(lockPath, "utf8"));
} catch (error) {
  console.error(`FAIL: skills-lock.json is not valid JSON: ${error.message}`);
  process.exit(1);
}

const failures = [];
for (const name of required) {
  const entry = lock.skills?.[name];
  if (!entry) {
    failures.push(`required skill missing from lock: ${name}`);
    continue;
  }
  if (entry.source !== "mattpocock/skills") {
    failures.push(`unexpected source for ${name}: ${entry.source ?? "<missing>"}`);
  }
  if (!/^[a-f0-9]{64}$/.test(entry.computedHash ?? "")) {
    failures.push(`invalid computedHash for ${name}`);
  }
  const candidates = [
    path.join(root, ".agents", "skills", name, "SKILL.md"),
    path.join(root, ".github", "skills", name, "SKILL.md"),
  ];
  if (!candidates.some((candidate) => fs.existsSync(candidate))) {
    failures.push(`installed SKILL.md missing: ${name}`);
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL: ${failure}`);
  process.exit(1);
}

console.log(`OK: ${required.length} required Matt skills are locked and installed`);
