# 개념

- **Host:** 대화, tools, sessions를 제공하는 VS Code
- **Harness:** Session Target에서 선택하는 Copilot, Claude, Codex agent runtime
- **Model:** GPT-5.6 Sol, Claude Opus 4.8, GPT-5.6 Terra 같은 추론 모델
- **Skill:** agent가 재사용하는 역할·규율·절차
- **Fresh session:** 다른 세션의 대화 history를 상속하지 않는 새 세션. 이 과정의 네 역할은 모두 fresh session이다
- **Handoff:** 기존 세션의 Session Target을 바꿔 전체 대화 history를 다른 harness로 옮기는 VS Code 동작. 이 과정에서는 사용하지 않는다
- **Durable state:** `CONTEXT.md`, ADR, local work items, commits처럼 세션 밖에 남는 상태
- **Runway:** health, 설정, test/build만 제공하고 domain behavior는 비워 둔 시작점
- **Tracer bullet:** React 질문 입력부터 API, retrieval, answer와 citations 렌더링까지 모든 계층을 관통하는 얇은 end-to-end slice
- **Foundry IQ:** 공개 웹에서 cited evidence를 가져오는 retrieval 경계
- **APIM:** 참가자 key를 origin credential과 분리하고 quota를 적용하는 gateway

이 과정은 같은 host에서 역할별 fresh session을 분리하는 에이전틱 개발
워크플로를 사용합니다. 역할별 harness와 model 표는 권장 기본값이며 다른 조합도
사용할 수 있습니다. 실제 선택은 durable artifact에 기록합니다.
`mattpocock/skills`는 이 흐름을 위한 샘플 구현체이며, Superpowers나
Ouroboros를 포함한 다른 스킬 세트도 활용할 수 있습니다. 기본 test는
deterministic하며 실제 APIM smoke는 `e2e` marker로 분리합니다.
