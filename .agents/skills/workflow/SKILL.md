---
name: workflow
description: "이 저장소의 에이전틱 개발 워크플로 conductor. 커밋된 durable artifact를 읽어 현재 단계를 판정하고, 이전 단계의 exit gate를 검증하고, 다음 fresh session이 열 harness/model과 실행할 스킬 명령을 지시한다. 개별 스킬을 직접 실행하는 대신 선택적으로 사용한다."
disable-model-invocation: true
---

# Workflow

`AGENTS.md`와 `docs/reference/workflow.md`의 워크플로를 조율하는 **선택적**
conductor입니다. 참가자는 `/grill-with-docs`, `/prototype`, `/to-spec`,
`/to-tickets`, `/implement`, `/code-review`를 직접 실행해도 되고, 어디에
있는지 모를 때 `/workflow`로 다음 한 걸음만 받아도 됩니다. 이 스킬은 하위
스킬을 대체하거나 수정하지 않고 **참조만** 합니다.

## 이 스킬이 하지 않는 것

<hard-limits>

- 한 세션에서 두 개 이상의 역할을 실행하지 않는다. 역할별 fresh session은
  이 워크플로의 전제이며 conductor가 우회할 수 없다.
- 세션 전환을 대신하지 않는다. Session Target과 language model picker는
  사람이 조작한다. conductor는 무엇을 고를지 알려주기만 한다.
- 검증 세션에서 production implementation을 고치지 않는다.
- 채팅 history를 상태의 근거로 쓰지 않는다. 판정 근거는 커밋된 파일뿐이다.
- credential, APIM key, 고객 식별 정보를 출력에 남기지 않는다.

</hard-limits>

## 인자

| 호출 | 동작 |
| --- | --- |
| `/workflow` | feature를 자동 선택해 판정하고 status card를 출력한다 |
| `/workflow <feature>` | `docs/work/<feature>/`를 대상으로 판정한다 |
| `/workflow status` | 판정만 한다. 어떤 하위 스킬도 실행하지 않는다 |
| `/workflow run` | 현재 세션의 역할이 판정된 단계와 같을 때만 해당 하위 스킬을 실행한다 |

feature를 지정하지 않고 `docs/work/` 아래 feature root가 둘 이상이면 목록을
보여주고 사용자에게 고르게 합니다.

## 절차

### 1. 상태를 읽는다 (읽기 전용)

- `AGENTS.md`, `CONTEXT.md`, `docs/agents/issue-tracker.md`
- `docs/work/<feature>/discovery.md`, `prototype.md`, `spec.md`, `tickets/`,
  `defects/`
- 루트 `HANDOFF`
- `docs/adr/`, `docs/uat/acceptance-matrix.md`
- `git status --short`, `git log --oneline -5`

### 2. 단계를 판정한다

위에서부터 **처음 일치하는 행**이 현재 단계입니다.

| 조건 | 단계 | 다음 명령 | 권장 조합 |
| --- | --- | --- | --- |
| 미해결 defect가 `defects/`에 있음 | implementation (defect) | `/implement docs/work/<feature>/defects/<NN>-<slug>.md` | Copilot / GPT-5.6 Sol |
| `discovery.md` 없음 | discovery | `/grill-with-docs` | Copilot / GPT-5.6 Sol |
| `discovery.md`에 `Prototype: required`가 있고 `prototype.md`에 `Status: decided`가 없음 | prototype | `/prototype` | Copilot / GPT-5.6 Sol |
| `spec.md` 없음 | planning (spec) | `/to-spec` | Claude / Claude Opus 4.8 |
| `tickets/`에 ticket 없음 | planning (tickets) | `/to-tickets` | Claude / Claude Opus 4.8 |
| `in-progress` ticket이 있음 | implementation (resume) | `HANDOFF`의 `verify`를 먼저 실행한 뒤 `/implement <ticket>` | Copilot / GPT-5.6 Sol |
| frontier ticket이 있음 | implementation | `/implement docs/work/<feature>/tickets/<NN>-<slug>.md` | Copilot / GPT-5.6 Sol |
| 모든 ticket이 `done`이고 UAT report 없음 | verification | `/code-review main` 후 독립 UAT | Codex / GPT-5.6 Terra |
| 위 어디에도 해당 없음 | complete | 남은 위험만 보고 | — |

**frontier ticket**은 상태가 `ready-for-agent`이고 `Blocked by`의 ticket이
모두 `done`인 ticket입니다. 여러 개면 번호가 가장 작은 것을 제안합니다.

`blocked` 상태 ticket만 남았다면 단계를 진행시키지 말고 무엇이 gate인지
blockers에 적어 보고합니다.

`Prototype: required`가 없거나 `Prototype: not-required`이면 prototype 단계를
건너뜁니다. prototype은 production 구현이 아니라 설계 질문에 답하는 throwaway
code입니다. 반드시 `prototype/<feature>-<slug>` branch에서 수행하고, main에는
결정 artifact인 `prototype.md`만 남깁니다.

권장 조합은 기본값입니다. 사용할 수 없으면 필요한 스킬을 지원하는 다른
harness/model을 고르고, 실제 조합을 `HANDOFF`와 UAT report에 기록하라고
안내합니다.

### 3. 이전 단계의 exit gate를 검증한다

판정된 단계로 **넘어오기 전 단계**의 gate를 실제로 확인합니다. 통과하지
못한 항목은 `blockers`에 넣고, 다음 명령 대신 **그 gate를 먼저 닫으라고**
지시합니다.

<gate name="discovery → prototype or planning">

- `discovery.md`에 승인된 결정, 확인한 사실과 출처, 제약, 의존성, 열린 질문,
  관련 `CONTEXT.md`·ADR 링크가 모두 있다
- 결정이 채팅 인용이 아니라 문서 본문으로 적혀 있다
- 문서가 커밋되어 있다: `git status --short docs/work/<feature>/discovery.md`가 비어 있다

</gate>

<gate name="prototype → planning">

- `prototype.md`에 다음 필드가 모두 있다.
  - `Status: decided`
  - `Question`
  - `Selected`
  - `Rationale`
  - `Prototype ref`
- `Prototype ref`가 `prototype/<feature>-<slug>` branch의 commit을 가리키며
  `git rev-parse --verify <prototype-ref>^{commit}`이 성공한다
- prototype variant와 switcher는 main에 없고, main에는 검증된 결정만 있다
- `prototype.md`가 커밋되어 있다:
  `git status --short docs/work/<feature>/prototype.md`가 비어 있다

</gate>

<gate name="planning → implementation">

- `spec.md`가 있고 `docs/templates/spec.md`의 골격을 따른다
- `tickets/`에 ticket이 1개 이상 있고 파일당 ticket 1개다
- 각 ticket에 `What to build`, `Blocked by`, `Status`, 체크박스 acceptance
  criteria가 있다
- ticket 번호가 dependency 순서(blocker 먼저)다

</gate>

<gate name="implementation → verification">

- ticket 상태가 `done`으로 갱신된 구현 commit이 있다
- 루트 `HANDOFF`에 `docs/reference/handoff-contract.md`의 7개 필드가 모두 있다
- `artifacts`가 디렉터리가 아닌 개별 파일 경로이며 HEAD에 존재하고 clean하다

  ```bash
  git ls-tree -r --name-only HEAD -- <path> | grep -Fx <path>
  git diff --quiet HEAD -- <path>
  ```

- `HANDOFF`의 `verify` 명령을 실제로 실행해 통과한다
- `HANDOFF`는 구현 commit과 분리된 documentation commit이다

</gate>

<gate name="verification → complete">

- `docs/templates/uat-report.md` 기반 UAT report가 있고 실제 host, harness,
  model, skill이 적혀 있다
- `docs/uat/acceptance-matrix.md`의 항목이 React UI를 포함해 모두 판정되었다
- 발견한 defect가 `defects/<NN>-<slug>.md`에 기대값, 실제값, 재현 명령,
  Standards/Spec finding과 함께 있다
- 검증 세션이 production implementation을 수정하지 않았다

</gate>

### 4. status card를 출력한다

```markdown
## Workflow status
- feature: docs/work/<feature>/
- phase: <단계>
- evidence: <이 판정의 근거가 된 파일 경로>
- gate: <직전 단계 gate 통과 / 미통과 항목>
- prototype: <not-required / pending / decided와 선택 결과>
- blockers: <없음 또는 먼저 닫아야 할 항목>
- next session: <권장 harness> / <권장 model> (fresh session)
- next command: <붙여넣을 명령 한 줄>
- verify first: <새 세션이 가장 먼저 실행할 명령>
```

`next session`이 지금 세션의 harness/model과 다르면, **New Chat으로 fresh
session을 여는 것**이 다음 행동이라고 명시합니다. 기존 세션의 Session Target을
바꾸는 handoff는 conversation history를 옮기므로 사용하지 않습니다.

### 5. 실행 여부를 정한다

- `/workflow status`이면 여기서 멈춘다.
- 판정된 단계가 현재 세션의 역할과 **같으면** 사용자 확인을 받은 뒤 해당
  하위 스킬을 그대로 실행한다.
- **다르면** 실행하지 않는다. status card만 남기고 세션을 닫으라고 안내한다.

## 검증 명령

단계 gate에서 필요할 때 실행합니다.

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/web && npm test && npm run build)
for test in tests/scripts/test-*.sh; do "$test"; done
./scripts/check-repo.sh
```

live smoke는 운영자가 지정한 gate에서만 실행합니다.
