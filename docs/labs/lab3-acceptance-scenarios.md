# Lab 3 - 인수 시나리오와 브라우저 안전망

## 이 랩에서 배우는 것

- spec의 acceptance criteria를 실행 가능한 브라우저 시나리오로 먼저 옮긴다.
- 구현 전에 실패하는 outside-in 시나리오로 다음 랩의 완료 조건을 고정한다.
- network-free deterministic suite와 gated live suite를 처음부터 분리한다.

## Runtime card

```text
Host: VS Code
Recommended agent runtime: Copilot harness (New Chat → Session Target: Copilot)
Recommended model: GPT-5.6 Sol (chat 입력창의 language model picker)
Context: fresh session. Lab 2 대화를 물려받지 않고 커밋된 spec과 ticket만 읽는다.
```

## 왜 구현보다 먼저인가

Lab 2의 acceptance criteria는 문장입니다. 사람이 읽고 해석하는 동안에는 무엇이
완료인지 세션마다 달라집니다. 이 랩에서 그 문장을 브라우저에서 실행되는
시나리오로 바꾸면, 이후 구현 랩은 통과 여부로 완료를 판정하고 검증 랩은 같은
명령을 재현할 수 있습니다. 시나리오는 지금 모두 실패해야 정상입니다. 실패가
Lab 4와 Lab 6이 갚아야 할 빚입니다.

## 시나리오 작성

New Chat으로 fresh session을 엽니다. 권장 조합은 Session Target Copilot과
GPT-5.6 Sol입니다. 다른 조합을 사용하면 `HANDOFF`에 실제 host, harness, model,
skill을 기록합니다. 먼저 `AGENTS.md`, `CONTEXT.md`,
`docs/work/<feature>/spec.md`와 ticket을 읽습니다. 채팅에 다음을 입력합니다.

```text
/implement docs/work/<feature>/tickets/<acceptance-scenarios-ticket>.md
```

시나리오는 React UI에서 사용자가 하는 행동으로만 씁니다. 컴포넌트 내부 상태나
함수 이름이 아니라 질문 입력, 제출, 화면에 나타나는 loading, answer, citation
링크, 근거 부족 안내, 오류 문구를 확인합니다.

`app/web`에 다음 두 script를 남깁니다.

- `test:e2e`는 `/healthz`와 `POST /api/consult` seam을 route interception이나
  verifier가 통제하는 test adapter로 대체해 네트워크 없이 실행합니다. 최소한
  loading에서 answer까지의 전이, URL을 가진 structured citations, no-evidence
  상태, actionable하고 secret-safe한 오류 상태를 덮습니다.
- `test:e2e:live`는 interception 없이 실제 React → FastAPI → APIM → Foundry IQ
  흐름만 검증합니다. `.env`가 준비된 명시적 Lab gate 밖에서 자동 실행되면 안
  되고, gate 값이 없을 때 조용히 통과하지 말고 실패해야 합니다. route
  interception이 없으므로 API 서버와 web 서버가 모두 떠 있어야 하며,
  Playwright `webServer` 설정에서 `scripts/dev.sh`처럼 두 서버를 함께 기동하는
  명령을 쓰거나 실행 전에 수동으로 띄워 둡니다.

두 suite 모두 trace, screenshot, video를 끄고 report에 provider payload나
credential이 남지 않게 합니다. 실패한 시나리오 목록은 정상 산출물이므로 통과를
만들려고 단언을 약하게 고치지 않습니다.

```bash
(cd app/web && npm test && npm run build)
(cd app/web && npm run test:e2e) || true
./scripts/check-repo.sh
```

deterministic suite는 이 시점에 실패합니다. 실패 이유가 "아직 구현되지 않은
동작"인지 "시나리오 자체의 오류"인지 구분해 기록합니다. 브라우저가 없으면
`npx playwright install chromium`을 먼저 실행합니다.

## 인계

시나리오 commit 후 [handoff contract](../reference/handoff-contract.md)에 따라
루트 `HANDOFF`를 작성합니다. 실패 중인 시나리오와 각 시나리오가 어느 ticket을
가리키는지, 다음 세션의 첫 `verify` 명령을 포함하고 commit합니다.

## 종료 조건

- `app/web`에 `test:e2e`와 `test:e2e:live` script가 있고 서로 분리되어 있다.
- deterministic 시나리오가 loading, answer, citations, no-evidence, 오류 상태를
  사용자 관점으로 덮고 네트워크 없이 실행된다.
- 지금은 실패하지만 실패 이유가 미구현 동작이라는 근거가 있다.
- live 시나리오는 gate 값이 없으면 통과가 아니라 실패한다.
- 시나리오가 commit됐고 다음 세션이 실행할 `HANDOFF`가 commit됐다.

## 막힐 때

- 시나리오가 화면 문구에 지나치게 묶이면 role과 label 같은 접근성 이름으로
  바꿔 잡는다.
- 시나리오를 통과시키려고 production code를 손대고 싶으면 멈춘다. 구현은
  Lab 4의 범위다.
- 상태가 너무 많으면 tracer bullet이 갚을 시나리오 하나를 먼저 고정하고
  나머지는 Lab 6이 갚을 시나리오로 남긴다.
- live gate 값이 없으면 시나리오를 지우지 말고 실패한 채로 두고 운영자에게
  gate를 요청한다.
