# 에이전틱 개발 워크플로

이 과정은 역할별 harness, model, skill, durable state를 조합하는 에이전틱
개발 워크플로를 local work item에 맞게 사용합니다. 이 저장소에 설치된
`mattpocock/skills`는 이 워크플로를 구현하는 샘플 스킬 세트이며,
Superpowers나 Ouroboros 등 다른 스킬 세트로 대체하거나 함께 활용할 수 있습니다.

```text
Copilot grill-with-docs → discovery.md
→ fresh Claude to-spec → to-tickets
→ fresh Copilot implement → commit + HANDOFF
→ fresh Codex code-review + UAT
```

역할이 바뀌면 새 세션을 엽니다. 세션 사이의 문맥은 채팅 history가 아니라
커밋된 durable artifact로 전달합니다.

## 역할별 실행

발견은 New Chat에서 Session Target을 Copilot, model을 GPT-5.6 Sol로 선택하고
`/grill-with-docs`를 실행합니다. 결정 frontier가 닫히고 사용자가 합의를
승인하면 `docs/work/<feature>/discovery.md`, `CONTEXT.md`, 필요한 ADR을
커밋합니다.

아키텍처·기획은 New Chat으로 fresh session을 열고 Session Target을 Claude,
model을 Claude Opus 4.8로 선택합니다. `AGENTS.md`, `CONTEXT.md`, discovery
문서와 연결된 ADR을 먼저 읽은 뒤 `codebase-design`, `/to-spec`,
`/to-tickets`로 local work item을 만듭니다.

구현은 local ticket마다 fresh session을 열고 Session Target을 Copilot,
model picker에서 GPT-5.6 Sol을 선택한 뒤
`/implement docs/work/<feature>/tickets/<ticket>.md`를 사용합니다. 완료 시
구현 commit과 루트 `HANDOFF`를 남깁니다.

검증도 New Chat을 엽니다. Session Target을 Codex, provider를 Copilot-backed,
model을 GPT-5.6 Terra로 선택합니다. local spec과 acceptance matrix를 먼저 읽고
`/code-review main`을 수행한 뒤 독립 UAT를 실행합니다.

harness(Session Target)와 model(picker)은 서로 다른 컨트롤입니다. 자세한
전환 방법은 [Host/harness/model 매트릭스](model-harness-matrix.md)를,
세션 개념은 [VS Code Sessions](https://code.visualstudio.com/docs/agents/concepts/sessions)
문서를 참고합니다.

## Session boundaries

네 역할은 모두 fresh session입니다. 기존 세션의 Session Target을 바꾸면 VS
Code는 이를 handoff로 취급해 full conversation history를 새 harness로 옮기므로,
이 워크플로에서는 사용하지 않습니다.

각 세션이 다음 역할에 남기는 입력은 다음과 같습니다.

| 세션 | 남기는 durable artifact |
| --- | --- |
| 발견 | `docs/work/<feature>/discovery.md`, `CONTEXT.md`, ADR |
| 아키텍처·기획 | `docs/work/<feature>/spec.md`, `tickets/` |
| 구현 | 구현 commit, 루트 `HANDOFF` |
| 독립 검증 | UAT report, `docs/work/<feature>/defects/` |

세션을 닫기 전에 [`HANDOFF`](handoff-contract.md)에 첫 verify 명령을 남기고,
다음 세션은 이전 채팅 없이 commit된 durable state로 시작합니다.

첫 vertical slice는 React 질문 입력부터 Python API, Foundry IQ retrieval,
answer와 citations 렌더링까지 앱 전체를 관통합니다. 이후 ticket은 같은
`POST /api/consult` contract 위에서 no-evidence와 오류 UI를 개선합니다.

## 샘플 스킬 설치와 업데이트

```text
npx skills experimental_install
npx skills update code-review codebase-design \
  diagnosing-bugs domain-modeling grill-with-docs grilling implement research tdd \
  to-spec to-tickets
npx skills update frontend-design
```

Matt Pocock 스킬 11개와 Anthropic의 `frontend-design`은 `.agents/skills/`에 미리
설치되어 있습니다.
`skills-lock.json`과 설치 파일을 함께 커밋하며 업데이트 diff를 검토합니다.
이 project-scope 스킬은 이 워크플로의 참고 구현체일 뿐 필수 전제는 아닙니다.
