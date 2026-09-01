# Lab 1 - 발견과 도메인 결정

## 이 랩에서 배우는 것

- 구현 전에 제품 상담 경계와 동작 질문을 해소한다.
- 공유 용어는 `CONTEXT.md`, 되돌리기 어려운 결정은 ADR에 남긴다.
- 승인된 발견 결과를 다음 세션이 읽을 discovery 문서로 발행한다.
- unit, recorded contract, live test의 책임을 분리한다.

## Runtime card

```text
Host: VS Code
Agent runtime: Copilot harness (New Chat → Session Target: Copilot)
Model: GPT-5.6 Sol (chat 입력창의 language model picker)
Context: fresh session. 결과는 채팅이 아니라 커밋된 문서로 남긴다.
```

## 시작

VS Code Chat view(또는 Agents 창)에서 New Chat으로 세션을 열고 Session
Target을 Copilot로, model picker에서 GPT-5.6 Sol을 선택합니다. 이후 채팅에
다음을 붙여넣습니다.

```text
/grill-with-docs

Microsoft Agent Framework Python backend와 React frontend로 제품 상담 agent를
만듭니다. 구현하지 말고 다음 결정을 문서로 확정하세요: POST /api/consult의
request/response fields, 공개 웹 근거 전달 경계, 근거 없음/상충 시 행동,
React 질문/응답/citation/loading/error 상태, deterministic unit/recorded
contract/live APIM test seams.
```

반드시 결정할 항목:

- `POST /api/consult`가 받는 question과 반환하는 answer/citations envelope
- Foundry IQ의 공개 웹 근거가 답변 합성에 전달되는 경계
- 근거가 없거나 상충하면 답을 꾸며내지 않는 규칙
- React가 질문, loading, answer, citations, 오류를 표시하는 규칙
- live APIM 없이 red-green이 가능한 adapter seam

## 산출물

Lab 2의 Claude 세션은 이 대화를 물려받지 않습니다. 세 가지를 커밋합니다.

- `docs/work/<feature>/discovery.md`: 승인된 결정, 확인한 사실과 출처, 제약,
  의존성, 열린 질문, 관련 `CONTEXT.md`와 ADR 링크
- `CONTEXT.md`: 제품 상담의 공유 언어와 동작 용어. 비어 있는 섹션을 채운다.
- `docs/adr/`: APIM credential boundary나 no-evidence behavior처럼 되돌리기
  어려운 결정만

아직 구현 코드는 수정하지 않는다.

## 종료 조건

- `docs/work/<feature>/discovery.md`, `CONTEXT.md`, 필요한 ADR이 commit되어 있다.
- HTTP envelope와 테스트 경계가 관찰 가능한 형태로 결정됐다.
- discovery 문서만 읽고도 다음 세션이 spec을 쓸 수 있다.
- spec을 막는 미해결 질문이 없다.
- 구현 코드는 변경되지 않았다.

## 막힐 때

- 질문이 퍼지면 HTTP envelope, evidence, UI states, test seam 네 경계로 돌아온다.
- 구현 세부 논쟁은 ADR의 대안과 결과로 기록하고 코딩으로 결정하지 않는다.
- 결론이 채팅에만 있으면 아직 산출물이 아니다. discovery 문서에 먼저 적는다.
- 세션이 끊기면 commit된 discovery 문서, `CONTEXT.md`, ADR을 읽고 같은 runtime
  card로 재개한다.
- 미해결 결정이 한 세션 대화에 안 담길 만큼 갈라지면 local ticket으로 나누되
  첫 frontier가 비지 않게 blocking edge를 점검한다.
