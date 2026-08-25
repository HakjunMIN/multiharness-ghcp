# Codex Cloud Verification Path Design

## Purpose

Lab 4 keeps independent verification mandatory while making Codex an optional
GHEC cloud path. The default path remains a new Copilot session with GPT-5.6
Terra. Teams with the required GHEC policies can instead delegate verification
to the OpenAI Codex third-party coding agent.

## Supported execution model

Path A is explicitly:

> GitHub Enterprise Cloud + GitHub Copilot cloud agent platform + OpenAI Codex
> third-party coding agent + a Codex-supported GPT model.

GitHub documents third-party coding agents as asynchronous agents that receive a
prompt or Issue and create a pull request. The workshop must not describe this
path as a local Codex CLI or interactive VS Code session. Local Codex remains a
separate product capability and is outside this workshop path.

Path B remains:

> Copilot harness + GPT-5.6 Terra + a new local session.

Codex plus GPT-5.6 Terra is not a supported combination.

## Path A workflow

1. The participant creates a dedicated `wf:verify` Issue after Lab 3.
2. The Issue contains the committed HANDOFF, acceptance criteria, and exact
   verification commands.
3. The Issue explicitly permits changes only to `docs/uat/report.md` and
   prohibits changes under `seed/`.
4. The participant assigns the Issue to the OpenAI Codex coding agent and
   selects one of the models currently offered by Codex.
5. Codex runs the fixed unit and acceptance commands asynchronously and creates
   a draft pull request containing only the UAT report.
6. A human reviews the command evidence and pull-request diff.
7. If verification failed, the human creates a separate implementation Issue.
   The Codex verification pull request never fixes the implementation.
8. After the report is accepted, the participant merges or records the report
   according to the instructor's repository policy and posts the verification
   HANDOFF to the map Issue.

## Role boundary

Codex is a verifier, not an implementer. Its allowed write surface is exactly
`docs/uat/report.md`. Any `seed/` change invalidates the verification attempt:
the participant closes the draft pull request without merging it and either
re-runs Path A with corrected instructions or switches to Path B.

The human owns GitHub governance actions that Codex cannot safely infer:

- confirming the selected repository and model
- reviewing the generated diff and command evidence
- creating implementation defect Issues
- deciding whether to merge or close the report pull request
- posting the final HANDOFF

## Preconditions

Path A is available only when all of the following are confirmed:

- the account uses GitHub Enterprise Cloud
- enterprise or organization policy allows the OpenAI Codex coding agent
- Codex is enabled for the workshop repository
- the participant can assign cloud coding agents and review their pull requests
- sufficient GitHub Actions minutes and AI credits are available
- the selected Codex model is visible when the task starts

Failure of any precondition does not block the workshop. The participant uses
Path B instead.

## Preflight behavior

Strict preflight requires one verification route:

- `WORKSHOP_VERIFY_ROUTE=codex-cloud`
- `WORKSHOP_VERIFY_ROUTE=copilot-terra`

For `codex-cloud`, preflight uses a manual confirmation variable because local
CLI presence cannot prove GHEC policy, repository enablement, model visibility,
or available cloud-agent capacity. The local `codex` executable is neither
required nor evidence that Path A is ready.

## Failure handling

| Failure | Required action |
|---|---|
| Codex is unavailable or disabled | Switch to Path B |
| No supported model is visible | Switch to Path B and record the observed catalog |
| Agent times out or does not create a PR | Record the failed delegation and switch to Path B |
| Draft PR changes `seed/` | Close without merge; retry once or switch to Path B |
| UAT fails | Keep the report evidence and create a separate implementation Issue |
| Report lacks reproducible output | Request a report-only iteration in the PR |

## Documentation changes

The implementation updates all participant and instructor surfaces together:

- README and Lab 4 identify Path A as optional GHEC cloud verification.
- Lab 0 and preflight check `codex-cloud`, not a local Codex session or CLI.
- The Codex verifier contract is rewritten as a cloud-agent Issue contract.
- Model and harness documentation separates local Codex capability from the
  workshop's cloud-only Path A.
- Instructor prerequisites and troubleshooting cover policy, repository
  enablement, usage, timeout, and Path B fallback.
- Labels continue to use `harness:codex` for artifacts produced by Path A.

## Validation

The repository gate must pass with no contradictory description of Path A.
Automated checks should assert that:

- Path A is described as optional and cloud-based.
- `codex-cloud` and `copilot-terra` are the only strict preflight route values.
- no participant instruction requires a local `codex` executable.
- Path A allows only `docs/uat/report.md` changes.
- Path B remains the fallback and independent UAT remains mandatory.

The live cloud path is validated before the workshop in a disposable GHEC
repository by assigning the verification Issue to Codex, confirming a
report-only draft pull request, and cleaning up the Issue, pull request, and
branch.

## Sources

- GitHub Docs, "About third-party coding agents":
  https://docs.github.com/en/copilot/concepts/agents/about-third-party-coding-agents
- GitHub Changelog, "Model selection for Claude and Codex agents on
  github.com":
  https://github.blog/changelog/2026-04-14-model-selection-for-claude-and-codex-agents-on-github-com/
- Visual Studio Code, "Choose and use an agent harness":
  https://code.visualstudio.com/docs/agents/run/agent-harnesses
