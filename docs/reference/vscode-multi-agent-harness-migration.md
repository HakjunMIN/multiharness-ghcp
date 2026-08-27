# VS Code multi-agent harness migration research

**Scope:** current `main`; researched 2026-08-27. This note uses only
first-party VS Code, GitHub, Anthropic, and OpenAI documentation. It is a
capability and rollout note, not a change to the workshop's operating rules.

## Decision summary

VS Code supports **Local**, **Copilot**, **Claude**, **Codex**, and **Cloud**
agent harnesses. A harness runs the agent loop; **Session Target** is VS
Code's control for choosing that harness (and, for Cloud, execution first).
The **language model picker** separately selects the reasoning model. Thus,
neither “Claude” nor “Codex” in Session Target itself selects a model.
([VS Code: agent harnesses](https://code.visualstudio.com/docs/agents/concepts/agent-harnesses),
[VS Code: running harnesses](https://code.visualstudio.com/docs/agents/run/agent-harnesses))

Use the requested matrix only after a live picker preflight:

| Role | Requested Session Target | Requested model | Official-capability assessment |
| --- | --- | --- | --- |
| Discovery | Copilot | GPT-5.6 Sol | **Conditional.** Copilot is a local Agent Host harness using the GitHub sign-in context. GPT-5.6 Sol is a supported Copilot model in VS Code and requires VS Code 1.128.0 or later. |
| Architecture / planning | Claude | Claude Opus 4.8 | **Conditional.** Claude is enabled by default and uses the Claude Agent SDK. It may use Copilot-routed models with GitHub sign-in or Anthropic-native models with Anthropic authentication; Opus 4.8 is a supported Copilot model in VS Code and requires VS Code 1.118 or later. |
| Implementation | Copilot | GPT-5.6 Sol | **Conditional**, with the same Copilot, version, policy, and picker checks as discovery. |
| Independent verification | Codex | GPT-5.6 Terra | **Conditional and has extra setup.** GPT-5.6 Terra is a supported Copilot model in VS Code and requires VS Code 1.128.0 or later. For the local Agent Host Codex harness, a Copilot-backed model requires GitHub sign-in **and Copilot Pro+**. |

The model catalog establishes that all three requested names are available in
VS Code, but the VS Code harness documentation does **not** publish a
harness-by-model compatibility table. It explicitly says model availability
can differ by harness; plan, organization policy, account authentication,
model visibility, and workspace trust can further limit the picker. Treat
each row as approved only when its model appears under its selected Session
Target in the target workspace. In Restricted Mode the picker shows only
**Auto**. ([GitHub: supported models](https://docs.github.com/en/copilot/reference/ai-models/supported-models),
[VS Code: language models](https://code.visualstudio.com/docs/agent-customization/language-models))

## Claude and Codex setup

### Claude harness

Claude support is enabled by default; `github.copilot.chat.claudeAgent.enabled`
controls it. Select the **Claude** Session Target, then select the displayed
model/provider in the picker. GitHub authentication enables Copilot-routed
models and bills through the Copilot subscription. Alternatively, Anthropic
credentials use Anthropic billing; VS Code documents an Anthropic API key or
Claude Code OAuth token for this path. If both are configured, the picker
groups models by **Anthropic** and **Copilot**, and the selected provider
determines billing for the next turn. ([VS Code: Claude harness setup](https://code.visualstudio.com/docs/agents/run/agent-harnesses#_claude),
[Anthropic: authentication](https://code.claude.com/docs/en/authentication))

### Codex harness

Codex is not initially listed. Use **one** of: install and enable the OpenAI
Codex extension for Chat view, or enable the experimental
`chat.agentHost.codexAgent.enabled` setting for Agents window. To use the
Agent Host implementation in Chat view too, enable
`chat.editor.codex.preferAgentHost`. Agent Host Codex may authenticate through
GitHub Copilot (requires Copilot Pro+) or ChatGPT; when both are present the
picker labels the **Copilot** and **ChatGPT** provider groups, persists the
chosen provider with the session, and bills that provider. Therefore the
requested Terra verification row specifically needs the Copilot-backed
selection; a ChatGPT sign-in alone is not evidence that Terra is available.
([VS Code: Codex harness setup](https://code.visualstudio.com/docs/agents/run/agent-harnesses#_codex),
[OpenAI: Codex IDE](https://developers.openai.com/codex/ide/))

## Session Target, history, and handoff

Changing Session Target in an existing session is a **handoff**. VS Code
carries the full conversation history and accumulated context to the selected
harness, but the new harness can expose different tools, permissions, and
models. A **fork** instead creates an independent session at a point in the
conversation; a new chat starts blank and does not inherit another chat's
history. Chat view and Agents window share the same sessions. ([VS Code:
sessions and handoff](https://code.visualstudio.com/docs/agents/concepts/sessions),
[VS Code: handoff procedure](https://code.visualstudio.com/docs/agents/run/agent-harnesses#_hand-off-a-session))

Committed artifacts, `CONTEXT.md`, ADRs, local work items, a `HANDOFF`, and
verification commands remain the required durable state for a deliberately
fresh or cold-start session, but they are **not** the only material transferred
by a VS Code harness handoff. The official behavior transfers history and
context; durable artifacts are still needed for reproducibility and for any
new independent session. ([`AGENTS.md`](../../AGENTS.md),
[`handoff-contract.md`](handoff-contract.md),
[VS Code: sessions and handoff](https://code.visualstudio.com/docs/agents/concepts/sessions))

## Explicit mismatches and limits

1. **Do not substitute the Cloud target for the requested local Codex
   harness.** GitHub's documented *cloud* third-party Codex choices are Auto,
   GPT-5.3-Codex, GPT-5.4, and GPT-5.4 nano—not GPT-5.6 Terra. The Terra row is
   consequently unsupported if “Codex” is selected as a Cloud third-party
   agent rather than as local Codex in VS Code. ([GitHub: third-party coding
   agents](https://docs.github.com/en/copilot/concepts/agents/about-third-party-coding-agents))
2. **Exact local harness/model pairing is not guaranteed by the public
   documentation.** The named models are documented for VS Code, but the
   published documentation only promises that available models may differ by
   harness. Do not replace a missing requested model with Auto or another
   model; report the preflight failure. ([GitHub: supported
   models](https://docs.github.com/en/copilot/reference/ai-models/supported-models),
   [VS Code: language models](https://code.visualstudio.com/docs/agent-customization/language-models))
3. **Worktree isolation has operational limits.** It requires a repository
   with a commit, starts from committed base-branch files, and excludes
   uncommitted, untracked, and ignored files by default. In particular, do not
   assume a git-ignored `.env` is present. A worktree is code isolation, not a
   filesystem or network security boundary; configure sandboxing separately.
   Worktree sessions also use Bypass Approvals. ([VS Code: code
   isolation](https://code.visualstudio.com/docs/agents/run/agent-harnesses#_choose-code-isolation))
4. **Capability and safety limits differ by harness.** Copilot sessions lack
   some VS Code and extension tools and currently support only local,
   unauthenticated MCP servers. Codex Full Access permits unrestricted disk
   and network access, so it is inappropriate for routine verification.
   ([VS Code: Copilot limitations](https://code.visualstudio.com/docs/agents/run/agent-harnesses#_limitations),
   [VS Code: Codex permissions](https://code.visualstudio.com/docs/agents/run/agent-harnesses#_permissions-and-approvals-2))

## Minimal rollout preflight

1. Upgrade VS Code to **1.128.0 or later** (covers all requested model minimum
   versions), sign in to GitHub, and confirm organization model policy and
   model visibility permit the requested Copilot models. ([GitHub: supported
   models](https://docs.github.com/en/copilot/reference/ai-models/supported-models))
2. Configure the Claude authentication/billing route before creating the
   architecture session, and configure the Codex extension or Agent Host
   setting plus Copilot Pro+ before creating the verification session. ([VS
   Code: agent harnesses](https://code.visualstudio.com/docs/agents/run/agent-harnesses))
3. In a trusted workspace, create four **new** sessions. Select the intended
   Session Target first, then verify and select the exact model in the language
   model picker; record the observed provider. Do not use Auto for this
   controlled comparison. ([VS Code: language models](https://code.visualstudio.com/docs/agent-customization/language-models))
4. Use handoff only when intentional history transfer is wanted. Use a new
   session for independent verification and provide the repository's durable
   handoff artifacts instead. Choose folder isolation when a session needs
   permitted local ignored runtime files; otherwise use a clean worktree and
   its committed input. ([VS Code: sessions and
   handoff](https://code.visualstudio.com/docs/agents/concepts/sessions),
   [VS Code: code isolation](https://code.visualstudio.com/docs/agents/run/agent-harnesses#_choose-code-isolation))
