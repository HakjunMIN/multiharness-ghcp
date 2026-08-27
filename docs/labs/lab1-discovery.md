# Lab 1 - 발견과 도메인 결정 (60분)

## 이 랩에서 배우는 것

- 구현 전에 제품 상담 경계와 정책 질문을 해소한다.
- 공유 용어는 `CONTEXT.md`, 되돌리기 어려운 결정은 ADR에 남긴다.
- unit, recorded contract, live test의 책임을 분리한다.

## Runtime card

```text
Host: VS Code
Agent runtime: Claude harness (New Chat → Session Target: Claude)
Model: Claude Opus 5 (chat 입력창의 language model picker)
Context: Lab 2 종료까지 같은 설계 대화
```

## 시작

VS Code Chat view(또는 Agents 창)에서 New Chat으로 세션을 열고 Session Target을 Claude로, model picker에서 Claude Opus 5를 선택한다. 이후 채팅에 다음을 붙여넣는다.

```text
/grill-with-docs

Microsoft Agent Framework Python backend와 React frontend로 제품 상담 agent를
만듭니다. 구현하지 말고 다음 결정을 문서로 확정하세요: POST /api/consult의
request/response fields, region source와 default, 지역별 trusted-domain policy,
근거 없음/상충 시 행동, telemetry opt-out boundary, deterministic unit/recorded
contract/live APIM test seams.
```

반드시 결정할 항목:

- `POST /api/consult`가 받는 question, region, telemetry 선택값과 answer/citations envelope
- region이 없거나 알 수 없을 때의 기본 동작
- 지역별 `BRAND_DOMAINS` 제한과 외부 검색 금지 시 fallback
- 근거가 없거나 상충하면 답을 꾸며내지 않는 규칙
- opt-out이 적용되는 telemetry sink 경계
- live APIM 없이 red-green이 가능한 adapter seam

## 산출물

공유 언어와 정책 용어를 `CONTEXT.md`에 기록한다. APIM trust boundary, domain policy, telemetry boundary처럼 되돌리기 어려운 결정만 `docs/adr/`에 남긴다. 아직 구현 코드는 수정하지 않는다.

## 종료 조건

- `CONTEXT.md`와 필요한 ADR이 commit되어 있다.
- HTTP envelope와 테스트 경계가 관찰 가능한 형태로 결정됐다.
- spec을 막는 미해결 질문이 없다.
- 구현 코드는 변경되지 않았다.

## 막힐 때

- 질문이 퍼지면 HTTP envelope, region, evidence, telemetry, test seam 다섯 경계로 돌아온다.
- 구현 세부 논쟁은 ADR의 대안과 결과로 기록하고 코딩으로 결정하지 않는다.
- 세션이 끊기면 commit된 `CONTEXT.md`와 ADR을 읽고 같은 runtime card로 재개한다.
- 미해결 결정이 한 세션 대화에 안 담길 만큼 갈라지면(예: 여러 정책 조합을 동시에 열어둬야 할 때) `wayfinder`로 결정 지도를 만들고 자식 이슈 단위로 나눈다. 이 랩의 기본 흐름에는 포함되지 않는다.
