---
name: code-review
description: "Review a branch, PR or working diff against a fixed point, reporting repository Standards and local Spec compliance separately."
---

Two-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards**: does the code conform to this repo's documented coding standards?
- **Spec**: does the code faithfully implement the originating issue / spec?

Read `AGENTS.md`. This is read-only: report findings, never fix production here.
Independent verification requires a fresh session separate from implementation.
Run the two axes in parallel read-only sub-agents when available; otherwise perform
separate passes and disclose that they were not independent sub-agent reviews.

The issue tracker should have been provided to you. If `docs/agents/issue-tracker.md` is missing, tell the user that the repo's local-tracker doc is missing and ask them to restore it from version control before continuing.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If they didn't specify one, ask for it.

Resolve the fixed point and HEAD to commit SHAs, then pin their merge-base.
For committed changes, compare that base with the pinned HEAD and record the commit
list. For requested work-in-progress review, compare the base with the working tree,
including staged/unstaged changes, and inspect untracked files separately.
Give both reviewers the same scope; report if files change during review.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here, not inside two parallel sub-agents.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. A local spec or ticket path the user passed as an argument.
2. The feature's committed `docs/work/<feature>/spec.md`, tickets and linked decisions,
   located through commit references or `HANDOFF`.
3. An explicit user requirement for repository maintenance without a product spec.
4. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent will skip and report "no spec available".

### 3. Identify the standards sources

Anything in the repo that documents how code should be written, such as `CODING_STANDARDS.md` or `CONTRIBUTING.md`.

Prioritize documented rules and observable consequences. Naming, duplication,
coupling, speculative abstraction and inheritance smells are optional heuristics,
not hard violations. Report one only with a concrete affected hunk and consequence;
repository rules override heuristics. Skip issues already enforced by tooling.

### 4. Spawn both sub-agents in parallel

**Standards sub-agent prompt** should include:

- The full diff command and commit list.
- The standards-source paths and the scope/heuristic rules from step 3.
- The brief: "Cite each violated rule and affected file/line, explain its consequence,
  and separate documented violations from heuristic concerns. Do not edit files.
  Skip tooling-enforced issues. Under 400 words."

**Spec sub-agent prompt** should include:

- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report missing/partial requirements, scope creep and incorrect
  behavior. Cite the requirement and affected file/line for each finding.
  Do not edit files. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings: passing one axis cannot compensate for failing the other.

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

During independent UAT, record actionable defects under the local tracker with
expected/actual results and a reproduction command. Missing evidence is a limitation,
not a pass.
