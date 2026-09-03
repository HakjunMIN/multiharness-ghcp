# Lab 2 - Spec과 ticket

## 이 랩에서 배우는 것

- 발견 결과를 검증 가능한 local spec 문서로 발행한다.
- 채팅 문맥 없이 커밋된 discovery 문서만으로 기획을 이어간다.
- 한 세션에서 끝나는 vertical tracer-bullet ticket을 만든다.
- 실제 선행 조건만 blocking edge로 표현한다.

## Runtime card

```text
Host: VS Code
Recommended agent runtime: Claude harness (New Chat → Session Target: Claude)
Recommended model: Claude Opus 4.8 (chat 입력창의 language model picker)
Context: fresh session. Lab 1 대화를 물려받지 않고 커밋된 문서만 읽는다.
```

## Spec

New Chat으로 fresh session을 엽니다. 권장 조합은 Session Target Claude와
Claude Opus 4.8입니다. 다른 조합을 사용하면 spec에 실제 host, harness, model,
skill을 기록합니다. Lab 1 세션은 닫아 두고, 먼저 `AGENTS.md`,
`CONTEXT.md`, `docs/work/<feature>/discovery.md`와 연결된 ADR을 읽습니다.
이전 채팅 요약을 붙여넣지 않습니다.

```text
/to-spec

`AGENTS.md`, 커밋된 `docs/work/<feature>/discovery.md`, `CONTEXT.md`,
그리고 discovery에서 참조한 `docs/adr/` 문서를 먼저 읽으세요.

이 문서에 기록된 승인된 결정만 사용하여
`docs/work/<feature>/spec.md`를 발행하세요. 인터뷰, test seam 확인,
spec 초안 승인 등 추가 질문은 하지 마세요.

문서에 없는 결정은 추측하거나 새로 결정하지 말고 열린 질문으로 명시하세요.
열린 질문이 있더라도 확정된 범위의 spec은 발행하되, 구현을 막는 질문은
명확히 구분하세요.
```

`<feature>`를 실제 기능 root 이름으로 바꿉니다. 이 스킬은 현재 대화를 종합할
뿐 인터뷰하지 않는데, 이 세션은 Lab 1 대화를 물려받지 않습니다. 읽을 문서를
지정하지 않으면 spec이 비거나 스킬이 추측하기 시작합니다.

Problem, solution, user stories, HTTP contract, behavior decisions, testing
decisions, out of scope를 검토한 뒤 `docs/work/<feature>/spec.md`에 발행합니다.
구현을 막는 열린 질문은 Lab 1로 되돌아가 discovery 문서를 보강합니다.

## Tickets

```text
/to-tickets docs/work/<feature>/spec.md

인수 시나리오 ticket을 별도로 만들되 tracer bullet ticket의 blocker로 걸지
마세요. 구현보다 먼저 수행하지만 실패하는 시나리오를 산출물로 남기는
ticket입니다. ticket breakdown 승인을 묻지 말고 spec만으로 전체 ticket을
발행하세요. 구현을 막는 열린 질문이 있으면 추측하지 말고 ticket 발행을 멈춘 뒤
Lab 1에서 보강할 질문을 명시하세요.
```

spec 경로를 인자로 넘겨야 스킬이 그 문서를 읽습니다. vertical slice, blocking
edge, ticket 문서 형식과 `ready-for-agent` 상태는 스킬이 이미 규정하므로
프롬프트에 반복하지 않습니다.

Lab 2에서 미리 만드는 것은 실행 코드가 아니라 인수 시나리오 ticket과 구체적인
acceptance criteria입니다. 실패하는 deterministic/live 브라우저 시나리오
코드는 Lab 3의 fresh 구현 세션에서 만들고, 최종 독립 UAT는 Lab 7에서 수행합니다.

생성된 ticket을 다음 기준으로 검토합니다.

- 첫 tracer bullet은 React 질문 입력부터 answer와 citations 표시까지 한
  흐름을 자른다. model layer, search layer, frontend layer 같은 horizontal
  ticket은 거부한다.
- 인수 시나리오 ticket이 별도로 있다. 이 ticket은 Lab 3에서 구현보다 먼저
  수행하며 실패하는 시나리오를 산출물로 남기므로, tracer bullet ticket의
  blocking edge로 걸지 않는다.
- no-evidence behavior와 오류/429 UI는 후속 ticket으로 남는다.
- 각 ticket이 `docs/work/<feature>/tickets/` 아래 개별 문서이고 observable
  acceptance criteria, focused test, 전체 검증 명령, `ready-for-agent`, 실제
  blocking edge를 갖는다.

## 종료 조건

- 승인된 local spec 문서가 있다.
- 실행 가능한 tracer-bullet ticket이 `ready-for-agent` 상태다.
- acceptance criteria가 React UI와 `POST /api/consult`에서 관찰 가능하다.
- 설계 대화를 닫아도 필요한 상태가 local work item과 repo에 남는다.

## 막힐 때

- ticket이 계층 이름이면 사용자 질문 한 번의 흐름으로 다시 자른다.
- 모든 ticket이 막혀 있으면 edge를 제거하고 첫 vertical slice를 찾는다.
- spec이 흔들리면 discovery 문서와 ADR로 돌아가며 구현으로 추측하지 않는다.
- discovery 문서가 부족해 spec을 못 쓰면 Lab 1로 되돌아가 문서를 보강한다.
  이것이 durable artifact 품질에 대한 피드백이다.
