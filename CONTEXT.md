# Workshop Context

이 문서는 VS Code 멀티 에이전트 하네스 기반 워크숍의 공유 언어를 정의합니다.
작업 규칙은 `AGENTS.md`, 되돌리기 어려운 결정은 ADR을 따릅니다.

## 용어 사전

| 용어 | 뜻 |
| --- | --- |
| host | 대화, 도구, 세션 UI를 제공하는 VS Code. |
| harness | 에이전트 루프를 실행하는 런타임. Session Target으로 선택한다. |
| Session Target | 현재 세션이 사용할 harness를 선택하는 VS Code 컨트롤. |
| model | 추론에 사용하는 언어 모델. harness와 별개로 language model picker에서 선택한다. |
| role | 발견, 아키텍처·기획, 구현, 독립 검증 중 하나의 작업 책임. |
| handoff | 기존 세션의 대화 history와 누적 context를 다른 harness로 넘기는 전환. |
| fresh session | 다른 세션의 대화 history를 상속하지 않는 새 세션. |
| durable artifact | fresh session이 작업을 재구성할 수 있도록 커밋한 spec, ticket, defect, ADR, HANDOFF, test, commit. |
| local work item | GitHub Issue 대신 저장소에서 관리하는 spec, ticket 또는 defect 문서. |
| frontier | blocking ticket이 모두 완료되어 지금 시작할 수 있는 ticket 집합. |
| independent verification | 구현 대화 history를 상속하지 않는 fresh Codex 세션에서 수행하는 review와 UAT. |

