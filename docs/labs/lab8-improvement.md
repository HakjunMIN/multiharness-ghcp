# Lab 8 - 상담 UX와 오류 상태 개선

## 이 랩에서 배우는 것

- 후속 ticket도 focused red-green으로 구현한다.
- no-evidence와 오류 동작을 React UI까지 일관되게 연결한다.
- API와 UI가 같은 HTTP contract를 유지하게 한다.

## Runtime card

```text
Host: VS Code
Recommended agent runtime: Copilot harness (New Chat → Session Target: Copilot)
Recommended model: GPT-5.6 Sol
Context: 개선 ticket 하나의 fresh session
```

## 구현

Lab 7의 `HANDOFF.verify`를 먼저 실행하고 다음을 사용합니다.

```text
/implement docs/work/<feature>/tickets/<behavior-or-ui-ticket>.md
```

API와 React focused failing test, 최소 구현, focused GREEN, 전체 suite 순서를
지킵니다. UI는 `POST /api/consult` 외에 별도 domain logic을 만들지 않습니다.
Lab 6에서 남긴 no-evidence와 오류 Playwright 시나리오를 모두 green으로 만듭니다.

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/web && npm test && npm run build && npm run test:browser)
./scripts/check-repo.sh
```

## 종료 조건

- no-evidence와 오류 상태가 red-green 근거와 함께 commit됐다.
- 질문, loading, answer, citations, no-evidence와 오류 상태가 모두 검증됐다.
- deterministic API와 browser suite 전체가 통과한다.
- 구현 commit과 별도 `HANDOFF` commit이 있다.

## 막힐 때

- 상태가 많아지면 새 화면보다 기존 상담 화면의 상태 전환에 집중한다.
- 실제 429를 만들지 말고 controlled deterministic response로 검증한다.
- 다른 참가자의 key나 provider payload를 사용하지 않는다.
