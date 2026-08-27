# 에이전트 작업 규칙

이 파일이 모든 하네스의 정본입니다.

## 과제

제품 상담 에이전트를 그린필드로 만들고, 공개 웹 근거와 구조화된 출처로 답하며, 지역별 신뢰 도메인과 텔레메트리 옵트아웃을 강제합니다.

## 고정 HTTP 경계

```text
POST /api/consult
request: {"question":"...", ...}
response: {"answer":"...", ...}
```

참가자는 이 경계를 확장할 수 있지만 시작 필드와 응답 필드를 바꾸지 않습니다. runway는 health와 개발 plumbing만 제공하며 상담 동작은 ticket에서 구현합니다.

## 범위

- `core`: Python, FastAPI, Microsoft Agent Framework, Foundry IQ retrieval, citations, region/telemetry policy
- `full`: core 전체와 React 질문/응답/citation/오류 UI. full은 core의 strict superset입니다.

## 절대 규칙

1. 고객사를 식별할 수 있는 이름, origin credential, APIM key를 commit, Issue, 채팅, 로그에 남기지 않습니다.
2. 실제 runtime 값은 gitignored `.env`에만 둡니다. 커밋 기본 브랜드는 `한빛전자`, 기본 도메인은 `example.invalid`입니다.
3. 기본 unit/contract test는 네트워크를 사용하지 않습니다. live APIM test는 `live` marker로 분리합니다.
4. 결정은 GitHub Issue, `CONTEXT.md`, ADR에 남깁니다. 채팅만 믿지 않습니다.
5. 검증자는 production implementation을 고치지 않고 재현 근거와 defect Issue를 만듭니다.
6. `git push --force`를 금지합니다.

## Main development flow

1. `/grill-with-docs`
2. `/to-spec`
3. `/to-tickets`
4. 티켓별 새 세션에서 `/implement`
5. 독립 세션에서 `/code-review main`과 UAT

## Runtime selection

VS Code Chat view(또는 Agents 창)의 **Session Target** 컨트롤에서 harness를, 채팅 입력창의 **language model picker**에서 model을 고릅니다. `/agent`, `/model` 같은 슬래시 명령은 없습니다.

| 역할 | Agent runtime (harness) | Model | 스킬 |
| --- | --- | --- | --- |
| 발견, 아키텍처, 기획 | Claude harness | Claude Opus 5 | `grill-with-docs`, `domain-modeling`, `codebase-design`, `to-spec`, `to-tickets` |
| 구현 | Copilot(native) harness | GPT-5.6 Sol | `implement`, `tdd` |
| 독립 검증 | Copilot(native) harness, 새 세션 | Claude Sonnet 5 | `code-review` + UAT |

Host, agent runtime(harness), model, skill, durable state는 서로 다른 축입니다. harness를 바꾸면 VS Code는 이를 handoff로 취급해 대화 history를 그대로 옮깁니다.

## Durable state와 세션 경계

`grill-with-docs`부터 `to-tickets`까지 한 설계 세션을 유지합니다. 구현은 ticket마다 새 세션, 검증은 구현 문맥이 없는 새 세션에서 시작합니다. Day 1 종료에는 `CONTEXT.md`, ADR, Issues, commits와 `HANDOFF`를 남기고 Day 2는 이것만으로 cold-start합니다.

## Verification commands

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/web && npm test && npm run build)
for test in tests/scripts/test-*.sh; do "$test"; done
./scripts/check-repo.sh
```

Live smoke는 강사가 지정한 gate에서만 `(cd app/api && uv run --frozen pytest -m live -q)`로 실행합니다.
