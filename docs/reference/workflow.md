# 에이전틱 개발 워크플로

이 과정은 역할별 harness, model, skill, durable state를 조합하는 에이전틱
개발 워크플로를 local work item에 맞게 사용합니다. 이 저장소에 설치된
`mattpocock/skills`는 이 워크플로를 구현하는 샘플 스킬 세트이며,
Superpowers나 Ouroboros 등 다른 스킬 세트로 대체하거나 함께 활용할 수 있습니다.

```text
discovery grill-with-docs → discovery.md
→ fresh prototype → prototype.md + prototype/ + throwaway branch ref
→ fresh planning to-spec → to-tickets
→ fresh API acceptance → fresh backend implementation
→ fresh browser acceptance → fresh frontend integration
→ UX/error improvement
→ fresh independent verification code-review + UAT
```

역할이 바뀌면 새 세션을 엽니다. 세션 사이의 문맥은 채팅 history가 아니라
커밋된 durable artifact로 전달합니다.

## 역할별 실행

아래 runtime/model은 권장 기본값입니다. 사용할 수 없으면 필요한 skill을
지원하는 다른 조합을 선택하고 실제 선택을 durable artifact에 기록합니다.

발견은 New Chat에서 권장 Session Target인 Copilot, model인 GPT-5.6 Sol을 선택하고
`/grill-with-docs`를 실행합니다. 결정 frontier가 닫히고 사용자가 합의를
승인하면 `docs/work/<feature>/discovery.md`, `CONTEXT.md`, 필요한 ADR을
커밋합니다.

New Chat에서 권장 Session Target인 Copilot, model인 GPT-5.6 Sol을 선택하고
`/prototype`을 실행합니다. 전체 source는 `prototype/<feature>-<slug>` branch에
보존하고, 질문, 선택, 이유와 branch ref는 `prototype.md`에, 선택 시안의 HTML,
CSS, token, landmark와 상태별 screenshot은 `prototype/`에 커밋합니다.
`Status: decided`와 정적 참조가 모두 갖춰지기 전에는 planning으로 넘어가지 않습니다.

아키텍처·기획은 New Chat으로 fresh session을 열고 권장 Session Target인 Claude,
model인 Claude Opus 4.8을 선택합니다. `AGENTS.md`, `CONTEXT.md`, discovery
문서, `prototype.md`, `prototype/`와 연결된 ADR을 먼저 읽은 뒤 `codebase-design`,
`/to-spec`, `/to-tickets`로 local work item을 만듭니다.

기획은 **한 세션에서 기능의 spec 전체와 ticket 전체를 한 번에 발행**합니다.
기능이 작다고 해서 spec이나 ticket을 slice별로 나눠 여러 기획 세션에서 만들지
않습니다. 세션을 나누는 단위는 기획 산출물이 아니라 **구현**입니다.

구현은 API 인수, backend, browser 인수, frontend 통합 ticket마다 fresh
session을 엽니다. 인수 세션은 production code를 고치지 않고 실패하는 scenario를
남깁니다. backend는 HTTP contract까지, frontend는 같은 contract와 선택된
prototype의 시각 언어를 화면까지 연결합니다. 각 구현은 commit과 루트
`HANDOFF`를 남깁니다.

검증도 New Chat을 엽니다. 권장 Session Target인 Codex, provider인
Copilot-backed, model인 GPT-5.6 Terra를 선택합니다. local spec과 acceptance
matrix를 먼저 읽고
`/code-review main`을 수행한 뒤 API 기본 suite, 운영자 gate의
`pytest -m e2e`, network-free `npm run test:e2e`, 운영자 gate의
`npm run test:e2e:live`를 실행합니다. Python e2e는 실제 APIM을 호출하지만
JavaScript `test:e2e`는 route interception을 사용합니다. 네 결과는 UAT
report에서 분리합니다.

권장 조합을 대체할 때도 역할별 fresh session을 유지합니다. 특히 verifier는
구현 세션의 대화를 상속하거나 구현 코드를 직접 수정하지 않으며, 실제 host,
harness, model, skill을 UAT report에 기록합니다.

harness(Session Target)와 model(picker)은 서로 다른 컨트롤입니다. 자세한
전환 방법은 [Host/harness/model 매트릭스](model-harness-matrix.md)를,
세션 개념은 [VS Code Sessions](https://code.visualstudio.com/docs/agents/concepts/sessions)
문서를 참고합니다.

## Session boundaries

발견, prototype, 기획, 구현, 검증 역할은 모두 fresh session입니다. 기존
세션의 Session Target을 바꾸면 VS Code는 이를 handoff로 취급해 full
conversation history를 새 harness로 옮기므로, 이 워크플로에서는 사용하지
않습니다.

각 세션이 다음 역할에 남기는 입력은 다음과 같습니다.

| 세션 | 남기는 durable artifact |
| --- | --- |
| 발견 | `docs/work/<feature>/discovery.md`, `CONTEXT.md`, ADR |
| Prototype | `prototype.md`, `prototype/`, `prototype/<feature>-<slug>` branch ref |
| 아키텍처·기획 | `docs/work/<feature>/spec.md`, `tickets/` |
| 구현 | 구현 commit, 루트 `HANDOFF` |
| 독립 검증 | UAT report, `docs/work/<feature>/defects/` |

세션을 닫기 전에 [`HANDOFF`](handoff-contract.md)에 첫 verify 명령을 남기고,
다음 세션은 이전 채팅 없이 commit된 durable state로 시작합니다.

첫 vertical slice는 Python API, Foundry IQ retrieval, answer와 citations를
HTTP contract까지 연결합니다. 다음 slice는 React 질문 입력부터 같은 contract의
렌더링까지 연결합니다. 이후 ticket은 no-evidence와 오류 UI를 개선합니다.

## 선택: `/workflow` conductor

`.agents/skills/workflow/`는 이 저장소가 직접 작성한 project-scope 스킬입니다.
외부에서 설치하지 않으므로 `skills-lock.json`에는 없고
`scripts/local-project-skills.txt`가 인벤토리입니다.

conductor는 다음 순서로 동작합니다.

1. `docs/work/<feature>/`의 discovery, prototype 정적 참조, spec, tickets, defects와 루트
   `HANDOFF`, `git status`를 읽는다.
2. 처음 일치하는 조건으로 현재 단계를 판정한다.
3. 직전 단계의 exit gate를 실제로 검증한다. `HANDOFF`의 `verify` 명령까지
   실행한다.
4. phase, evidence, gate, blockers, 다음 harness/model, 다음 명령을 담은 status
   card를 출력한다.
5. 판정된 단계가 현재 세션의 역할과 같을 때만 해당 하위 스킬을 실행한다.
   다르면 실행하지 않고 새 fresh session을 열라고 안내한다.

conductor는 필수가 아닙니다. 개별 스킬을 직접 실행하는 흐름과 동등하게
지원되며, 어느 쪽을 쓰든 역할별 fresh session과 durable artifact 규칙은
동일하게 적용됩니다.

## 샘플 스킬 설치와 업데이트

```text
npx skills experimental_install
npx skills update code-review codebase-design \
  diagnosing-bugs domain-modeling grill-with-docs grilling implement prototype \
  research tdd to-spec to-tickets
npx skills update frontend-design
```

Matt Pocock 스킬 12개와 Anthropic의 `frontend-design`은 `.agents/skills/`에 미리
설치되어 있습니다.
`skills-lock.json`과 설치 파일을 함께 커밋하며 업데이트 diff를 검토합니다.
이 project-scope 스킬은 이 워크플로의 참고 구현체일 뿐 필수 전제는 아닙니다.
