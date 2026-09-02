# Lab 6 - 독립 검증

## 이 랩에서 배우는 것

- 구현 문맥을 상속하지 않는 verifier를 운영한다.
- standards, spec, black-box UAT를 분리한다.
- deterministic Playwright E2E와 gated live 상담 흐름을 모두 검증한다.
- 결함을 재현 테스트와 local defect 문서로 넘기고 구현은 고치지 않는다.

## Runtime card

```text
Host: VS Code
Recommended agent runtime: Codex harness (New Chat → Session Target: Codex)
Recommended model: GPT-5.6 Terra, Copilot-backed provider (language model picker)
Context: 구현 세션과 분리된 새 세션
```

구현 세션을 handoff하지 않습니다. New Chat으로 fresh session을 열고 Session
Target local Codex, Copilot-backed provider, GPT-5.6 Terra를 권장 조합으로
사용합니다. 다른 조합을 사용해도 되지만 구현 세션의 대화를 상속하지 않고
구현을 직접 수정하지 않는 독립 verifier여야 하며, 실제 host, harness, model,
skill을 UAT report에 기록합니다.

```text
/code-review main
```

`/code-review main`은 standards/spec 정적 검토만 담당하며 이것만으로 Lab 6를
종료하지 않습니다. 이어서 [UAT matrix](../uat/acceptance-matrix.md)를 기준으로
다음 두 Playwright suite를 실행합니다.

### 1. Deterministic black-box E2E

```bash
(cd app/web && npm run test:e2e)
```

이 suite는 외부 네트워크를 사용하지 않습니다. 브라우저에서 실제 상담 화면을
열고 `POST /api/consult` seam의 응답을 route interception 또는 verifier가
통제하는 test adapter로 바꿔 다음 동작을 검증합니다.

- 질문 제출 중 loading이 표시되고 완료 후 answer가 렌더링된다.
- answer와 URL을 가진 structured citations가 함께 렌더링된다.
- no-evidence 응답을 답으로 꾸미지 않고 해당 상태를 표시한다.
- 429 응답을 actionable하고 secret-safe한 오류로 표시한다.

Playwright 설정이나 `test:e2e` script가 없다면 verifier가 production
implementation을 대신 고치지 않습니다. 이는 최종 검증을 재현할 수 없는
blocking spec finding으로 기록하고 local defect를 만듭니다.

### 2. Gated live E2E

운영자가 Lab 6를 live gate로 지정하고 gitignored `.env`에
`APIM_BASE_URL`, `APIM_KEY`와 공개 정보만 묻는 synthetic 질문을 준비한
경우에만 실행합니다.

```bash
(cd app/web && npm run test:e2e:live)
```

이 suite는 route interception 없이 실제 React → FastAPI → APIM → Foundry IQ
상담 흐름을 통과해야 합니다. 공개 근거가 있는 질문을 제출해 answer와 citation
URL이 UI에 표시되는지 확인하고, 같은 response의 `POST /api/consult` envelope도
검증합니다. quota를 소진해 429를 인위적으로 만들지 않으며 429 UI는
deterministic suite의 책임으로 둡니다.

HTML report, screenshot, trace와 response capture에는 APIM key, origin
credential, provider payload를 남기지 않습니다. 질문은 고객을 식별하지 않는
공개 제품 질문만 사용합니다. live 환경 문제는 제품 verdict와 분리해 route와
secret-safe status만 기록합니다.

verifier는 구현 코드를 수정하지 않습니다. 결함이면 가장 작은 failing
reproduction test를 추가할 수 있고, evidence와 severity를 담은 local defect
문서를 `docs/work/<feature>/defects/`에 만듭니다. 구현자는 별도 세션에서
수정합니다.

## 종료 조건

- API와 React UI를 포함한 standards/spec findings와 UAT verdict가 분리된 report가 있다.
- deterministic Playwright 결과와 gated live Playwright 결과가 별도로 기록됐다.
- live gate가 승인되지 않았다면 실행하지 않은 이유와 승인 주체가 기록됐다.
- 발견한 결함마다 재현 근거와 local defect 문서가 있다.
- verifier가 production implementation을 수정하지 않았다.

## 막힐 때

- 구현 의도를 추측하지 말고 spec acceptance criteria와 black-box response를 기준으로 판정한다.
- deterministic E2E가 실패하면 live 결과로 덮지 말고 먼저 독립 결함으로 기록한다.
- live infrastructure 결함은 제품 결함과 분리해 운영자에게 route/status를 전달한다.
