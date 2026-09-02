# 에이전트 작업 규칙

이 파일이 모든 하네스의 정본입니다.

## 과제

제품 상담 에이전트를 그린필드로 만들고, 공개 웹 근거와 구조화된 출처로 답합니다.

## 고정 HTTP 경계

```text
POST /api/consult
request: {"question":"...", ...}
response: {"answer":"...", ...}
```

참가자는 이 경계를 확장할 수 있지만 시작 필드와 응답 필드를 바꾸지 않습니다. runway는 health와 개발 plumbing만 제공하며 상담 동작은 ticket에서 구현합니다.

## 범위

모든 참가자는 다음을 포함한 제품 상담 앱 전체를 구현합니다.

- Python, FastAPI, Microsoft Agent Framework, Foundry IQ retrieval
- answer, structured citations, no-evidence behavior
- React 질문 입력, loading/error 상태, answer와 citation UI

## 절대 규칙

1. 고객사를 식별할 수 있는 이름, origin credential, APIM key를 commit, Issue, 채팅, 로그에 남기지 않습니다.
2. 실제 runtime 값은 gitignored `.env`에만 둡니다. 커밋 기본 브랜드는 `한빛전자`이고 URL 예시는 `example.invalid` 같은 non-routable 값만 사용합니다.
3. 기본 unit/contract test는 네트워크를 사용하지 않습니다. live APIM test는 `live` marker로 분리합니다.
4. 결정은 local work item, `CONTEXT.md`, ADR에 남깁니다. 채팅만 믿지 않습니다.
5. 검증자는 production implementation을 고치지 않고 재현 근거와 local defect 문서를 만듭니다.
6. `git push --force`를 금지합니다.
7. 전역(global) 스킬은 사용하지 않습니다. 스킬은 이 저장소의 `.agents/skills/`에 있는 project scope 스킬만 탐색하고 실행합니다.
8. frontend의 한글 본문 서체는 나눔고딕을 우선 사용합니다. 제목용 display 서체는 이 규칙의 예외로 둘 수 있습니다.

## Main development flow

아래 runtime/model은 권장 기본값입니다. 사용할 수 없으면 역할에 필요한 스킬을
실행할 수 있는 다른 조합을 선택하고, 실제 조합을 durable artifact에 기록합니다.

1. 발견 세션에서 `/grill-with-docs` (권장: Copilot)
2. 승인된 발견 결정을 `docs/work/<feature>/discovery.md`에 영속화
3. fresh 기획 세션에서 discovery 문서를 읽고 `/to-spec`, `/to-tickets` (권장: Claude)
4. local ticket별 fresh 구현 세션에서 `/implement` (권장: Copilot)
5. 구현과 분리된 fresh 검증 세션에서 `/code-review main`과 UAT (권장: Codex)

역할이 바뀌면 agent runtime도 새 세션에서 선택합니다. 새 세션은 이전 대화
history를 상속하지 않는다고 전제하며, chat handoff만으로 역할 경계를 넘지
않습니다. 보내는 세션은 다음 세션이 채팅 없이 작업을 재구성할 수 있는 durable
artifact를 먼저 남기고, 받는 세션은 그 artifact를 읽은 뒤 작업을 시작합니다.

선택적으로 project scope 스킬 `/workflow`를 conductor로 사용할 수 있습니다.
현재 단계 판정, 직전 단계 exit gate 검증, 다음 fresh session 안내만 수행하며
위 스킬들을 대체하지 않습니다. conductor를 쓰더라도 역할별 fresh session,
durable artifact, 구현과 검증의 분리는 그대로 적용됩니다.

### Discovery → spec/tickets 경계

- `/grill-with-docs`의 decision frontier가 닫히고 사용자가 합의를 승인하면,
  발견 세션은 `docs/work/<feature>/discovery.md`를 만듭니다.
- discovery 문서에는 승인된 결정, 확인한 사실과 출처, 제약, 의존성, 열린 질문,
  관련 `CONTEXT.md`와 ADR 링크를 기록합니다. 채팅 history만을 입력으로 남기지
  않습니다.
- fresh 기획 세션은 `AGENTS.md`, `CONTEXT.md`, discovery 문서와 연결된 ADR을
  먼저 읽고 `/to-spec`, `/to-tickets`를 수행합니다.
- spec과 ticket이 생성되어 검토되기 전에는 구현 세션을 시작하지 않습니다.

### Tickets → implementation 경계

- 기획 세션은 승인된 spec과 local ticket을
  `docs/work/<feature>/` 아래에 영속화합니다. ticket에는 범위, 선행 조건,
  acceptance criteria, 검증 명령과 관련 결정 링크가 있어야 합니다.
- 각 ticket은 별도의 fresh 구현 세션에서 수행합니다. 구현 세션은 이전
  기획 대화를 전제로 하지 않고 `AGENTS.md`, `CONTEXT.md`, 해당 spec, ticket과
  ADR을 읽어 작업을 재구성합니다.
- 구현 세션은 완료한 변경, 검증 결과, 남은 위험과 다음 세션의 첫 verify 명령을
  commit과 `HANDOFF`에 남깁니다. ticket과 durable artifact 없이 채팅 지시만으로
  구현하지 않습니다.

구현 ticket을 마칠 때는 다음 순서를 따릅니다.

1. production code, test와 ticket 상태 변경을 검증하고 하나의 구현 commit으로
   남깁니다.
2. `git rev-parse --short HEAD`로 구현 commit을 확정합니다.
3. 저장소 루트의 `HANDOFF`를 현재 상태로 작성하거나 교체합니다. `HANDOFF`에는
   다음 7개 필드를 모두 둡니다.

   ```markdown
   ## HANDOFF
   - from/to: <현재 harness/model> → <다음 fresh session의 harness/model>
   - artifacts: <구현 commit과 변경된 개별 파일 경로>
   - done: <완료한 ticket과 관찰 가능한 동작>
   - not done: <다음 ticket 또는 남은 범위>
   - decisions: <spec, ticket, CONTEXT.md, ADR 경로>
   - verify: <다음 세션이 첫 단계로 실행할 복사 가능한 명령>
   - risks: <실패한 시도, 외부 의존성, live gate 등 남은 위험>
   ```

4. `HANDOFF`만 별도 documentation commit으로 남깁니다. 현재 구현 commit SHA를
   문서가 가리킬 수 있도록 구현 commit과 분리합니다. 이전 `HANDOFF`는 git
   history로 보존됩니다.
5. 다음 fresh session은 `HANDOFF`의 artifact와 commit이 실제 repository 상태와
   일치하는지 확인하고 `verify` 명령을 가장 먼저 실행합니다.

credential, 질문·답변 원문과 provider payload는 구현 commit이나 `HANDOFF`에
포함하지 않습니다.

## Runtime selection

VS Code Chat view(또는 Agents 창)의 **Session Target** 컨트롤에서 harness를, 채팅 입력창의 **language model picker**에서 model을 고릅니다. `/agent`, `/model` 같은 슬래시 명령은 없습니다.

아래 표는 과정의 **권장 기본값**이며 특정 조합을 강제하지 않습니다. 권장 조합을 사용할 수
없으면 역할에 필요한 스킬을 지원하는 다른 harness/model을 선택합니다. 단,
역할별 fresh session, durable artifact, 구현과 검증의 분리는 유지하고 실제
host, harness, model, skill을 `HANDOFF`와 UAT report에 기록합니다.

| 역할 | 권장 agent runtime (harness) | 권장 model | 스킬 |
| --- | --- | --- | --- |
| 발견 | Copilot harness, fresh session | GPT-5.6 Sol | `grill-with-docs`, `grilling`, `domain-modeling`, `research` |
| 아키텍처, 기획 | Claude harness, fresh session | Claude Opus 4.8 | `codebase-design`, `to-spec`, `to-tickets` |
| 구현 | Copilot harness, fresh session | GPT-5.6 Sol | `implement`, `tdd` |
| 독립 검증 | Codex harness, fresh session | GPT-5.6 Terra | `code-review` + UAT |

Host, harness, model, skill, durable state는 서로 다른 축입니다. Session Target을
선택해 역할에 맞는 새 세션을 시작합니다. 새 세션은 다른 세션의 conversation
history를 상속하지 않으며 역할 간 context는 durable artifact로 전달합니다.

## Durable state와 세션 경계

발견, 기획, 구현과 검증은 역할별 fresh session으로 나눕니다. 발견 세션은
discovery 문서를, 기획 세션은 spec과 ticket을, 구현 세션은 commit과 `HANDOFF`를
다음 역할의 입력으로 남깁니다. 세션을 닫기 전에 `CONTEXT.md`, ADR, local work
items, commits와 `HANDOFF`를 남기고, 다음 세션은 이것만으로 cold-start합니다.

## Verification commands

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/web && npm test && npm run build)
for test in tests/scripts/test-*.sh; do "$test"; done
./scripts/check-repo.sh
```

Live smoke는 운영자가 지정한 gate에서만 `(cd app/api && uv run --frozen pytest -m live -q)`로 실행합니다.
