# 랩 흐름 재구성 설계

## Problem Statement

현재 랩 구성에는 세 가지 문제가 있습니다.

1. **구현 순서가 워크숍 규모에 맞지 않습니다.** Lab 4 tracer bullet은 React 질문
   입력부터 FastAPI, Microsoft Agent Framework, Foundry IQ retrieval, citation
   렌더링까지를 한 세션에서 끝내라고 요구합니다. 한 세션이 감당할 범위를 넘어
   참가자가 어느 층에서 막혔는지 구분하지 못하고, 실패해도 backend 문제인지
   frontend 문제인지 판정할 수 없습니다.
2. **prototype 결과가 실제 화면으로 이어지지 않습니다.** prototype 단계는
   선택이고, 산출물은 결정을 서술한 `prototype.md`와 throwaway branch ref뿐입니다.
   구현 세션은 그 branch를 읽을 의무가 없어 사실상 화면을 처음부터 다시 그립니다.
   그 결과 prototype에서 고른 시안과 완성된 UI가 크게 벌어집니다.
3. **Lab 5 cold-start 복구가 중복입니다.** 모든 구현 랩이 이미 fresh session에서
   `HANDOFF`의 `verify`를 먼저 실행하도록 요구합니다. 별도 랩은 같은 학습 목표를
   한 번 더 다루면서, 이 랩에서만 쓰이는 checkpoint 복구 인프라를 저장소에
   남겨 둡니다.

## Solution

랩을 backend-first 순서로 다시 나누고, prototype을 필수 랩으로 올려 산출물을
구현이 이식할 수 있는 정적 참조로 만들고, Lab 5와 checkpoint 인프라를 제거합니다.

### 새 랩 라인업

| # | 랩 | 파일 | 권장 harness/model | 다음 랩에 남기는 것 |
| --- | --- | --- | --- | --- |
| 0 | Runway preflight | `lab0-preflight.md` | — | 환경 확인 |
| 1 | Discovery | `lab1-discovery.md` | Copilot / GPT-5.6 Sol | `discovery.md`, `CONTEXT.md`, ADR |
| 2 | Prototype | `lab2-prototype.md` | Copilot / GPT-5.6 Sol | `prototype.md`, `docs/work/<feature>/prototype/` |
| 3 | Spec과 tickets | `lab3-spec-tickets.md` | Claude / Claude Opus 4.8 | `spec.md`, `tickets/` |
| 4 | API 인수 시나리오 | `lab4-api-acceptance.md` | Copilot / GPT-5.6 Sol | 실패하는 API 통합 테스트 |
| 5 | 백엔드 구현 | `lab5-backend-slice.md` | Copilot / GPT-5.6 Sol | API green, 구현 commit, `HANDOFF` |
| 6 | 브라우저 인수 시나리오 | `lab6-browser-acceptance.md` | Copilot / GPT-5.6 Sol | 실패하는 deterministic Playwright |
| 7 | 프론트엔드와 통합 | `lab7-frontend-integration.md` | Copilot / GPT-5.6 Sol | UI green, 시각 일치 근거, `HANDOFF` |
| 8 | UX와 오류 개선 | `lab8-improvement.md` | Copilot / GPT-5.6 Sol | no-evidence와 오류 상태 |
| 9 | 독립 검증 | `lab9-verification.md` | Codex / GPT-5.6 Terra | UAT report, `defects/` |
| 10 | Cloud agent (선택) | `lab10-cloud-agent.md` | — | 평가 경로 밖 |

랩 번호는 파일 이름과 문서 제목 양쪽에서 바뀝니다. Lab 5 cold-start는 삭제하고
대체 랩을 만들지 않습니다.

### Ticket 분해 규칙 변경

Lab 3(구 Lab 2)의 ticket 검토 기준을 **contract-first 2단 vertical**로 바꿉니다.

- **백엔드 ticket**은 `POST /api/consult`가 실제 answer와 structured citations를
  반환하는 지점까지 자릅니다. acceptance criteria는 HTTP 응답으로 관찰합니다.
- **프론트엔드 ticket**은 같은 계약을 질문 입력부터 화면 렌더링까지 잇습니다.
  acceptance criteria는 브라우저에서 관찰합니다.
- `model layer`, `search layer`, `component layer` 같은 진짜 horizontal ticket은
  계속 거부합니다. 두 ticket 모두 각자의 경계에서 사용자가 관찰할 수 있는 동작을
  끝까지 자른 vertical slice입니다.

기존 "React 질문 입력부터 citations 표시까지 한 ticket" 규칙은 삭제합니다.

### Prototype 필수화와 결속

Lab 1 discovery는 더 이상 `Prototype: required` / `not-required`를 선언하지
않습니다. prototype은 항상 수행합니다.

Lab 2 prototype이 남기는 산출물은 두 가지입니다.

1. `prototype/<feature>-<slug>` branch — 탈락 시안을 포함한 전체 throwaway
   source. `prototype.md`의 `Prototype ref`가 이 branch의 commit을 가리킵니다.
2. `docs/work/<feature>/prototype/` — main에 커밋하는 **선택된 시안의 정적 참조**.
   - 선택 시안의 정적 HTML과 CSS
   - 상태별 스크린샷: 질문 입력, loading, answer와 citations, no-evidence, 오류
   - `tokens.md`: `app/web/src/styles.css`에 그대로 들어갈 CSS 변수 목록과
     본문 서체(나눔고딕), 제목 서체, 간격과 색 토큰
   - 각 상태의 landmark와 접근성 이름 목록

Lab 7 프론트엔드 랩은 이 디렉터리를 출발점으로 사용합니다. exit gate는 두 가지입니다.

- 프론트엔드 테스트가 `tokens.md`의 토큰과 상태별 landmark를 assert한다.
- prototype 스크린샷과 구현 스크린샷을 육안 비교한 결과를 `HANDOFF`에 기록한다.

pixel diff 기반 visual regression은 도입하지 않습니다. 워크숍 환경에서 flaky하고
실패 원인이 설계 불일치인지 렌더링 차이인지 구분되지 않습니다.

### 테스트 층

`live` marker를 없애고 `e2e` marker가 실제 APIM 호출을 담당합니다.

| 명령 | 범위 | 네트워크 |
| --- | --- | --- |
| `uv run --frozen pytest -q` | unit과 통합. FastAPI TestClient로 APIM adapter만 stub한 in-process 전체 스택 | 없음 |
| `uv run --frozen pytest -m e2e -q` | 앱 전체를 실제 APIM과 Foundry IQ에 붙여 `POST /api/consult` 호출 | 운영자 gate |
| `npm test` | React component와 unit | 없음 |
| `npm run test:e2e` | Playwright. `POST /api/consult`를 route interception으로 통제 | 없음 |
| `npm run test:e2e:live` | Playwright. React → FastAPI → APIM → Foundry IQ 전체 흐름 | 운영자 gate |

Python `e2e`와 JavaScript `test:e2e`는 이름이 같지만 범위가 다릅니다. Python
`-m e2e`는 실제 APIM을 호출하고, JavaScript `test:e2e`는 네트워크를 쓰지 않으며
실제 APIM을 호출하는 쪽은 `test:e2e:live`입니다. 이 차이를 Lab 4, Lab 6, Lab 9
문서에 명시합니다.

`app/api/pyproject.toml`은 `addopts = ["-m", "not e2e"]`와 `e2e` marker를
가집니다. `live` marker와 그 문구는 저장소에서 사라집니다.

### 삭제

- `docs/labs/lab5-cold-start.md`
- `docs/setup/checkpoint/` 전체
- `scripts/restore-checkpoint.sh`
- `tests/scripts/test-checkpoint.sh`
- `tests/scripts/test-checkpoint-overlay.sh`

`tests/scripts/test-live-test-boundary.sh`는 `docs/setup/checkpoint`를 근거로
live 경계를 검증하고 있으므로 `app/api` 기준으로 다시 쓰고
`tests/scripts/test-e2e-boundary.sh`로 이름을 바꿉니다.

## User Stories

1. 참가자로서 백엔드 랩을 마치면 `POST /api/consult`를 직접 호출해 answer와
   citations를 확인할 수 있어, 프론트엔드가 없는 상태에서도 진행 여부를 판정할 수 있다.
2. 참가자로서 프론트엔드 랩을 시작할 때 `docs/work/<feature>/prototype/`의 정적
   시안을 이식하므로, 완성된 화면이 prototype에서 고른 시안과 같은 모양이 된다.
3. 참가자로서 실패한 테스트가 API 통합 suite인지 브라우저 suite인지로 어느 층에
   문제가 있는지 즉시 안다.
4. 운영자로서 `pytest -m e2e`와 `npm run test:e2e:live` 두 gate만 관리하면 되고,
   저장소에 정답 구현이 남지 않아 참가자 번들과 운영자 자산을 분리할 필요가 없다.

## Implementation Decisions

### 랩 문서

- 랩 문서 9개를 새 번호로 옮기고 3개를 새로 씁니다.
  - `lab2-spec-tickets.md` → `lab3-spec-tickets.md` (ticket 규칙 교체)
  - `lab3-acceptance-scenarios.md` → `lab6-browser-acceptance.md` (브라우저 범위만)
  - `lab4-tracer-bullet.md` → `lab5-backend-slice.md` (백엔드 범위만)
  - `lab6-improvement.md` → `lab8-improvement.md`
  - `lab7-verification.md` → `lab9-verification.md`
  - `lab9-cloud-agent.md` → `lab10-cloud-agent.md`
  - 신규: `lab2-prototype.md`, `lab4-api-acceptance.md`, `lab7-frontend-integration.md`
- 모든 랩 문서는 기존 골격(`## 이 랩에서 배우는 것`, `## 종료 조건`, `## 막힐 때`)을
  유지합니다. `tests/scripts/test-lab-structure.sh`가 이를 검사합니다.

### 함께 갱신하는 문서

| 파일 | 변경 |
| --- | --- |
| `README.md` | main flow 텍스트, mermaid 다이어그램, 역할표, 랩 목록 |
| `AGENTS.md` | 절대 규칙 3의 marker 이름, main development flow, prototype 필수, 검증 명령 |
| `docs/reference/workflow.md` | 흐름 텍스트, durable artifact 표, prototype 필수 |
| `docs/reference/model-harness-matrix.md` | Prototype 행에서 "(선택)" 제거 |
| `docs/agents/issue-tracker.md` | `Prototype: required` 조건 제거, `prototype/` 디렉터리 규약 추가 |
| `docs/work/README.md` | `prototype/` 디렉터리, 랩 링크 번호 |
| `docs/uat/acceptance-matrix.md` | 랩 번호와 marker 이름 |
| `docs/templates/spec.md` | Testing Decisions의 `live` → `e2e` |
| `docs/templates/uat-report.md` | Python gate 항목의 marker 이름 |
| `docs/00-concepts.md` | 실제 APIM smoke의 marker 이름 |
| `docs/labs/lab0-preflight.md` | "선택적 prototype" 문구, 랩 목록 |
| `docs/setup/azure-setup.md` | `./scripts/test-live.sh` → `./scripts/test-e2e.sh`, marker 이름 |
| `.agents/skills/workflow/SKILL.md` | 단계 판정표, prototype gate, 검증 명령 |

Python marker 이름만 `live`에서 `e2e`로 바뀝니다. JavaScript `npm run test:e2e:live`는
그대로이므로 브라우저 gated suite를 가리키는 "live" 표현은 문서에 남습니다.

### 코드와 스크립트

| 파일 | 변경 |
| --- | --- |
| `app/api/pyproject.toml` | `live` marker → `e2e`, `addopts = ["-m", "not e2e"]` |
| `app/api/tests/conftest.py` | markexpr 검사 문자열 `live` → `e2e` |
| `app/api/tests/test_live_config.py` | `test_e2e_config.py`로 rename, 단언 갱신 |
| `scripts/test-live.sh` | `scripts/test-e2e.sh`로 rename, `pytest -m e2e -q` |
| `scripts/build-participant-bundle.sh` | checkpoint 제외 로직과 검사 제거 |
| `scripts/repo-manifest.txt` | 삭제 경로 제거, 새 랩 경로 반영 |
| `tests/scripts/test-lab-structure.sh` | 인덱스 `0..10`, Lab 9 검증 요구, Lab 4/6 시나리오 요구 |
| `tests/scripts/test-live-test-boundary.sh` | `test-e2e-boundary.sh`로 rename, `app/api` 기준 재작성 |
| `tests/scripts/test-usage.sh` | `restore-checkpoint.sh` 제거, `test-e2e.sh` 참조 |
| `.github/workflows/verify.yml` | participant bundle 경계 검사에서 checkpoint 경로 제거 |

`tests/scripts/test-e2e-boundary.sh`가 검증할 내용은 다음과 같습니다.

- `app/api/pyproject.toml`에 `addopts = ["-m", "not e2e"]`와 `e2e:` marker가 있다
- `scripts/test-e2e.sh`가 `.env`를 읽고 `pytest -m e2e -q`를 실행한다
- `app/api/src`와 `app/api/tests`에 hard-coded live endpoint가 없다
  (`test_e2e_*.py`와 `test_healthz.py` 제외)

`docs/setup/checkpoint`를 근거로 한 `@pytest.mark.live`와 `AgentFrameworkSynthesizer`
검사는 사라집니다. 참조 구현이 저장소에 없으므로 대체 검사를 만들지 않습니다.

## Testing Decisions

이 변경은 문서와 워크숍 하네스 자체에 대한 것이므로, 검증은 저장소 계약
테스트로 합니다.

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/web && npm test && npm run build)
for test in tests/scripts/test-*.sh; do "$test"; done
./scripts/check-repo.sh
```

- `check-repo.sh`가 manifest 경로 존재, 상대 링크 해석, 스크립트 위생을 확인하므로
  랩 번호 변경과 파일 삭제의 누락을 잡습니다.
- `test-lab-structure.sh`가 새 랩 번호 집합과 각 랩의 필수 섹션을 강제합니다.
- `test-usage.sh`가 `restore-checkpoint.sh` 참조 제거를 강제합니다.
- `pytest -q`는 marker 이름 변경 후에도 통과해야 합니다.

`pytest -m e2e`와 `npm run test:e2e:live`는 이 변경의 검증 대상이 아닙니다.
운영자 credential이 필요하고 이 저장소에는 아직 상담 구현이 없습니다.

## Out of Scope

- 상담 기능 자체의 구현. 이 저장소는 runway와 랩 문서만 제공하며 `app/api`와
  `app/web`의 상담 코드는 참가자가 랩에서 만듭니다.
- `docs/work/consult-ui-prototype/discovery.md`의 결정 내용 변경. 이미 커밋된
  기존 발견 문서의 본문은 그대로 두고, 랩 번호가 바뀐 상대 링크만 고칩니다.
- Playwright visual regression 도입.
- 랩별 소요 시간이나 일차 구분 도입. `test-lab-structure.sh`가 계속 금지합니다.
- `.worktrees/` 아래 이전 워크숍 사본.
