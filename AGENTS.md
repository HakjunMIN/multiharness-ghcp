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

## 고정 APIM runtime 경계

APIM 접근은 `APIM_BASE_URL`과 `APIM_KEY` 하나의 조합만 사용합니다. 별도 model
endpoint나 model ID runtime 설정을 추가하지 않습니다.

- 답변 합성은 `${APIM_BASE_URL}/model/v1/responses`를 호출합니다.
- Foundry IQ 근거 검색은
  `${APIM_BASE_URL}/search/knowledgebases/${KNOWLEDGE_BASE_NAME}/retrieve`를
  호출합니다.
- `KNOWLEDGE_BASE_NAME`의 실습 기본값은 `workshop-products`입니다.
- 두 API 모두 `APIM_KEY`를 `Ocp-Apim-Subscription-Key` header로 전달합니다.
- 실제 `APIM_BASE_URL`과 `APIM_KEY`는 gitignored 루트 `.env`에만 둡니다.
- 두 API의 request/response payload 정본은
  [`docs/reference/apim-payloads.md`](docs/reference/apim-payloads.md)입니다.
  retrieval이나 synthesis adapter, 그 fixture를 만들거나 고치기 전에 이 문서를
  먼저 읽고 응답 shape을 추측하지 않습니다. 실제 응답과 다르면 코드보다 이
  문서를 먼저 갱신합니다.

## 범위

모든 참가자는 다음을 포함한 제품 상담 앱 전체를 구현합니다.

- Python, FastAPI, Microsoft Agent Framework, Foundry IQ retrieval
- answer, structured citations, no-evidence behavior
- React 질문 입력, loading/error 상태, answer와 citation UI

## 절대 규칙

1. 고객사를 식별할 수 있는 이름, origin credential, APIM key를 commit, Issue, 채팅, 로그에 남기지 않습니다.
2. 실제 runtime 값은 gitignored `.env`에만 둡니다. 커밋 기본 브랜드는 `한빛전자`이고 URL 예시는 `example.invalid` 같은 non-routable 값만 사용합니다.
3. 기본 unit/contract test는 네트워크를 사용하지 않습니다. 실제 APIM test는 `e2e` marker로 분리합니다.
4. 결정은 local work item, `CONTEXT.md`, ADR에 남깁니다. 채팅만 믿지 않습니다.
5. 검증자는 production implementation을 고치지 않고 재현 근거와 local defect 문서를 만듭니다.
6. `git push --force`를 금지합니다.
7. 전역(global) 스킬은 사용하지 않습니다. 스킬은 이 저장소의 `.agents/skills/`에 있는 project scope 스킬만 탐색하고 실행합니다.
8. frontend의 한글 본문 서체는 나눔고딕을 우선 사용합니다. 제목용 display 서체는 이 규칙의 예외로 둘 수 있습니다.

## 필요한 문맥만 읽기

`AGENTS.md`는 공통 계약, 스킬은 해당 작업의 절차, reference는 상세 형식입니다.
작업에 맞는 `.agents/skills/<name>/SKILL.md`만 로드하고, 보조 문서는 해당
단계에서 필요할 때 읽습니다. 공통 규칙·템플릿·일반 코딩 지식을 스킬마다
복제하지 않습니다. 스킬과 외부 예시가 이 파일의 계약과 충돌하면 계약을 따릅니다.
스킬 도구나 sub-agent가 없으면 해당 local 문서를 읽고 직접 수행하되,
병렬·독립 검증을 했다고 주장하지 않습니다. 역할별 fresh session은 여전히 필수입니다.

- 세션 시작: `CONTEXT.md`, 해당 local work item과 연결된 ADR을 읽습니다.
- `HANDOFF`가 있으면 artifact와 commit을 확인하고 `verify`를 먼저 실행합니다.
  결과가 `expected`와 다르면 다음 작업보다 그 차이를 먼저 해소합니다.
- 제품 기능 단계 전환: [워크플로](docs/reference/workflow.md)와
  [local tracker](docs/agents/issue-tracker.md)를 읽습니다.
- 구현 완료: [인계 계약](docs/reference/handoff-contract.md)의 7개 필드와
  두 commit 순서를 따릅니다. credential, 질문·답변 원문, provider payload는
  구현 commit이나 `HANDOFF`에 포함하지 않습니다.

## Main development flow

역할별 fresh session을 사용하고 이전 대화 history 대신 커밋된 durable artifact로
복구합니다. 다음 역할은 아래 입력이 준비되기 전에는 시작하지 않습니다.

| 역할 | 실행과 남길 artifact |
| --- | --- |
| 발견 | `/grill-with-docs`; 합의 승인 후 `docs/work/<feature>/discovery.md`, `CONTEXT.md`, ADR |
| Prototype | `/prototype`; `prototype/<feature>-<slug>`의 throwaway code, `prototype.md`, 선택 시안의 `prototype/` |
| 기획 | discovery·prototype·ADR을 읽고 `/to-spec` → `/to-tickets`; 한 세션에서 기능 전체의 spec과 tickets 발행 |
| 구현 | 검토된 spec과 ticket을 읽고 ticket 하나당 fresh session에서 `/implement`; 구현 commit과 `HANDOFF` |
| 독립 검증 | 구현과 분리된 fresh session에서 `/code-review main` + UAT; production 수정 없이 UAT report와 local defect |

- discovery에는 승인된 결정, 사실과 출처, 제약, 의존성, 열린 질문, CONTEXT·ADR
  링크를 남깁니다. Prototype은 `Status: decided`, 질문·선택·이유·ref 및
  HTML/CSS, 상태별 스크린샷, `tokens.md`, landmark가 있어야 기획으로 넘어갑니다.
- ticket은 범위, 선행 조건, acceptance criteria, 검증 명령, 결정 링크를 갖춥니다.
  API 인수 → backend → 브라우저 인수 → frontend 통합 → UX·오류 개선 순서이며,
  인수 세션은 production을 고치지 않고 실패하는 테스트를 남깁니다.
- frontend는 prototype token과 상태별 landmark를 test로 고정하고 스크린샷
  육안 비교 결과를 `HANDOFF`에 기록합니다.
- 선택적 `/workflow`는 단계·exit gate를 확인하고 다음 fresh session을 안내합니다.
  개별 스킬이나 역할 경계를 대체하지 않습니다.

## Runtime selection

VS Code Chat view(또는 Agents 창)의 **Session Target** 컨트롤에서 harness를, 채팅 입력창의 **language model picker**에서 model을 고릅니다. `/agent`, `/model` 같은 슬래시 명령은 없습니다.

Copilot(발견·prototype·구현), Claude(기획), Codex(독립 검증)는 **권장 기본값**입니다.
모델 조합과 선택 기준은 [매트릭스](docs/reference/model-harness-matrix.md)를
참조합니다. 다른 조합도 같은 계약을 지키면 사용할 수 있습니다.
실제 host, harness, model, skill을 `HANDOFF`와 UAT report에 기록하며,
모델 이름이나 성능을 이유로 승인·검증·fresh session 경계를 생략하지 않습니다.

## Verification commands

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/web && npm test && npm run build)
for test in tests/scripts/test-*.sh; do "$test"; done
./scripts/check-repo.sh
```

브라우저 인수 시나리오는 `(cd app/web && npm run test:browser)`로 실행합니다.
인수 시나리오를 작성한 뒤 frontend를 구현하기 전까지는 이 명령이 실패하는
것이 정상이며, 그 기대 결과를 `HANDOFF`의 `verify`에 적습니다.

실제 APIM smoke는 운영자가 지정한 gate에서만 `(cd app/api && uv run --frozen pytest -m e2e -q)`로 실행합니다.
