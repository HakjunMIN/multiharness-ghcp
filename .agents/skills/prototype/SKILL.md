---
name: prototype
description: Build a throwaway prototype to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look like.
---

# Prototype

A prototype is **throwaway code that answers a question**. The question decides the shape.

Read `AGENTS.md`, the approved `docs/work/<feature>/discovery.md`, `CONTEXT.md`
and linked ADRs in a fresh prototype session. Missing approved discovery is a blocker.

## Choose the reference

- Logic/state question → [LOGIC.md](LOGIC.md): a shareable interactive HTML demo.
- Appearance question → [UI.md](UI.md): structurally different, switchable variants.
- If ambiguous, clarify the question before building. Load only the relevant reference.

## Rules that apply to both

1. **Throwaway from day one.** Keep source on `prototype/<feature>-<slug>`, not main. If branch operations are unavailable or unauthorized, report the blocker rather than modifying production. Mark prototype code clearly and follow existing routing conventions.
2. **Trivial to run.** A UI prototype starts from one command in the project's task runner: `pnpm <name>`, `python <path>`, `bun <path>`, etc. A logic demo is a single HTML file the user double-clicks. Either way, no thinking required to start it.
3. **No persistence by default.** State lives in memory. Persistence is the thing the prototype is _checking_, not something it should depend on. If the question explicitly involves a database, hit a scratch DB or a local file with a clear "PROTOTYPE, wipe me" name.
4. **Skip the polish.** No tests, no error handling beyond what makes the prototype _runnable_, no abstractions. The point is to learn something fast.
5. **Surface the state.** After every action (logic) or on every variant switch (UI), print or render the full relevant state so the user can see what changed.
6. **Capture the approved choice, not production code.** Record `Status: decided`, `Question`, `Selected`, `Rationale`, and `Prototype ref` in `docs/work/<feature>/prototype.md`. Preserve all variants on the throwaway branch. The target branch receives only the selected static reference in `prototype/`: `index.html`, `styles.css`, `tokens.md`, state screenshots and landmarks. Do not promote the winner into production here; hand off to fresh planning, then ticketed implementation.
