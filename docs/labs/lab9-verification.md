# Lab 9 - 독립 검증

## 이 랩에서 배우는 것

- 구현 문맥을 상속하지 않는 verifier를 운영한다.
- API 통합, API e2e, React browser deterministic, browser live 결과를 분리한다.
- 결함을 재현 근거와 local defect 문서로 넘기고 구현은 고치지 않는다.

## Runtime card

```text
Host: VS Code
Recommended agent runtime: Codex harness (New Chat → Session Target: Codex)
Recommended model: GPT-5.6 Terra, Copilot-backed provider
Context: 구현과 분리된 fresh verifier session
```

## 정적 검토

spec, tickets, prototype 정적 참조, acceptance matrix와 마지막 `HANDOFF`를 읽고
verify를 먼저 실행합니다.

```text
/code-review main
```

standards와 spec finding을 분리하고 production implementation을 수정하지 않습니다.

## 실행 검증

다음 네 결과를 UAT report에 별도로 기록합니다.

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/api && uv run --frozen pytest -m e2e -q)
(cd app/web && npm run test:e2e)
(cd app/web && npm run test:e2e:live)
```

첫 번째와 세 번째는 외부 네트워크 없이 실행합니다. Python `pytest -m e2e`는
실제 APIM을 호출하며, JavaScript `npm run test:e2e`는 같은 이름이지만 route
interception을 씁니다. 두 번째와 네 번째는 운영자가 승인하고 gitignored
`.env`가 준비된 gate에서만 실행합니다. gate가 없으면 실행하지 않은 이유와
승인 주체를 기록합니다.

HTML report, screenshot, trace, 질문·답변 원문, provider payload와 credential을
evidence에 남기지 않습니다. 결함이면 가장 작은 failing reproduction을 추가할
수 있고 `docs/work/<feature>/defects/`에 기대값, 실제값, severity, 재현 명령,
Standards/Spec finding을 기록합니다.

## 종료 조건

- standards, spec, black-box UAT verdict가 분리된 report가 있다.
- 네 suite 결과 또는 gated suite의 not-run 이유가 별도로 기록됐다.
- 발견한 결함마다 재현 근거와 local defect가 있다.
- verifier가 production implementation을 수정하지 않았다.

## 막힐 때

- deterministic 실패를 gated 결과로 덮지 않는다.
- infrastructure 문제는 제품 defect와 분리해 secret-safe하게 기록한다.
- 구현 의도보다 spec acceptance criteria와 black-box response로 판정한다.
