# VS Code multi-agent harness workshop migration

## Problem Statement

현재 워크숍은 역할별 실행 방법을 오래된 GitHub Copilot 중심 표현과 GitHub
Issues에 결합하고 있습니다. 참가자는 VS Code의 Session Target, model picker,
handoff, fresh session 차이를 일관되게 배우기 어렵고, Claude와 Codex를 사용하기
위한 사전 설정도 한곳에서 확인할 수 없습니다. 전체 Matt Pocock 스킬 저장소를
설치하는 절차도 실제 랩에서 사용하는 범위보다 큽니다.

## Solution

워크숍을 VS Code 멀티 에이전트 하네스 흐름으로 전환합니다. 발견은 Copilot,
아키텍처·기획은 Claude, 구현은 Copilot, 독립 검증은 Codex가 담당합니다.
발견에서 기획으로는 handoff를 사용하고 구현과 검증은 fresh session으로
분리합니다. 사전 설정과 exact model 확인 절차를 README와 Lab 0에 제공하며,
spec·ticket·defect는 커밋되는 local work item으로 관리합니다. 설치되는 Matt
Pocock 스킬은 합의된 10개로 제한합니다.

## User Stories

1. 참가자로서 VS Code에서 Session Target을 찾고 싶다. 역할에 맞는 harness를 선택하기 위해서다.
2. 참가자로서 model picker가 Session Target과 다른 컨트롤임을 이해하고 싶다. harness와 model을 혼동하지 않기 위해서다.
3. 참가자로서 발견을 Copilot과 GPT-5.6 Sol로 시작하고 싶다. 제품 질문을 빠르게 구조화하기 위해서다.
4. 참가자로서 발견 세션을 Claude와 Claude Opus 4.8로 handoff하고 싶다. 조사 문맥을 잃지 않고 아키텍처와 기획을 이어가기 위해서다.
5. 참가자로서 handoff가 전체 history와 context를 전달함을 알고 싶다. 의도하지 않은 문맥 상속을 피하기 위해서다.
6. 참가자로서 ticket마다 fresh Copilot 세션을 열고 싶다. 구현 범위를 한 context window에 제한하기 위해서다.
7. 참가자로서 구현에 GPT-5.6 Sol을 사용하고 싶다. 정해진 비교 조건을 유지하기 위해서다.
8. 검증자로서 fresh Codex 세션을 열고 싶다. 구현자의 추론을 상속하지 않고 검증하기 위해서다.
9. 검증자로서 GPT-5.6 Terra를 사용하고 싶다. 합의된 독립 검증 모델로 review와 UAT를 수행하기 위해서다.
10. 참가자로서 Claude harness의 인증과 billing 경로를 미리 설정하고 싶다. 아키텍처 세션 시작 시 막히지 않기 위해서다.
11. 참가자로서 Codex extension 또는 Agent Host 설정을 미리 완료하고 싶다. Codex Session Target을 사용할 수 있게 하기 위해서다.
12. 참가자로서 Terra가 Copilot-backed local Codex 경로를 요구함을 알고 싶다. Cloud Codex나 ChatGPT provider를 잘못 선택하지 않기 위해서다.
13. 강사로서 최소 VS Code 버전과 workspace trust 조건을 확인하고 싶다. picker가 제한되는 환경을 수업 전에 찾기 위해서다.
14. 참가자로서 exact model이 보이지 않을 때 중단하고 보고하고 싶다. 임의 대체로 실험 조건이 달라지는 일을 막기 위해서다.
15. 참가자로서 랩에 필요한 Matt Pocock 스킬만 설치하고 싶다. 불필요한 명령과 인지 부하를 줄이기 위해서다.
16. 참가자로서 spec을 저장소 문서로 관리하고 싶다. GitHub Issue 권한이나 네트워크 없이 durable state를 남기기 위해서다.
17. 참가자로서 tracer-bullet ticket을 개별 문서로 관리하고 싶다. blocking edge와 frontier를 로컬에서 추적하기 위해서다.
18. 검증자로서 defect를 개별 문서로 기록하고 싶다. production implementation을 고치지 않고 재현 근거를 전달하기 위해서다.
19. 참가자로서 cold-start에서 local work item과 HANDOFF만 읽고 싶다. 이전 채팅 없이 작업 상태를 복구하기 위해서다.
20. 강사로서 하나의 저장소 계약 검증을 실행하고 싶다. 역할 매트릭스, 설치 범위, 문서 tracker, 세션 경계의 drift를 한 번에 찾기 위해서다.
21. 참가자로서 worktree에 ignored `.env`가 자동 복사되지 않음을 알고 싶다. runtime 설정 누락을 안전하게 진단하기 위해서다.
22. 참가자로서 harness마다 도구와 권한이 다를 수 있음을 알고 싶다. handoff 후 실행 환경 변화를 예상하기 위해서다.
23. 강사로서 README와 각 lab의 runtime card가 같은 역할 매트릭스를 사용하게 하고 싶다. 상충하는 안내를 없애기 위해서다.
24. 팀으로서 역할, harness, model, skill, durable state를 별도 축으로 기록하고 싶다. 결과 비교와 책임 분리를 재현하기 위해서다.

## Implementation Decisions

- VS Code를 단일 host로 사용하고 Session Target에서 Copilot, Claude, Codex
  harness를 선택합니다.
- language model picker에서 exact model을 별도로 선택합니다.
- 발견과 구현은 Copilot + GPT-5.6 Sol, 아키텍처·기획은 Claude + Claude
  Opus 4.8, 독립 검증은 Codex + GPT-5.6 Terra를 사용합니다.
- 발견에서 아키텍처·기획으로만 handoff합니다. 구현과 검증은 각각 fresh
  session이며 검증에는 구현 history를 전달하지 않습니다.
- Codex 검증은 Cloud target이 아닌 로컬 Codex harness의 Copilot-backed
  provider를 사용합니다.
- local work item은 기능별 spec, dependency 순서의 ticket, defect 문서로
  구성하고 상태와 blocking edge를 문서에 기록합니다.
- 설치 스킬은 `grill-with-docs`, `grilling`, `domain-modeling`, `research`,
  `codebase-design`, `to-spec`, `to-tickets`, `implement`, `tdd`,
  `code-review`로 제한합니다.
- 기존 HTTP 경계와 제품 구현 범위는 변경하지 않습니다.

## Testing Decisions

- 테스트는 참가자가 실행하는 저장소 검증 명령을 단일 public seam으로 사용합니다.
- 계약 테스트는 역할별 harness/model, Claude·Codex 사전 설정, 최소 스킬
  inventory, local work item 규약, handoff와 fresh-session 경계를 관찰합니다.
- 문구의 내부 배치보다 참가자가 필요한 절차를 찾을 수 있는지를 검증합니다.
- 기존 runtime matrix, lab runtime, Matt skill 계약 테스트의 의도는 새 단일
  seam으로 통합하고 중복 assertion은 제거합니다.
- 제품 API와 web 동작은 바뀌지 않지만 전체 기존 suite로 회귀를 확인합니다.

## Out of Scope

- 제품 상담 API 또는 React UI 구현 변경
- 실제 Anthropic, OpenAI, APIM credential 발급
- 조직별 Copilot entitlement 또는 model policy 변경
- Cloud agent를 통한 Codex 검증
- GitHub Issue, label, blocking relationship 자동화
- 모든 Matt Pocock 스킬 설치

## Further Notes

공개 문서가 exact harness/model 호환 표를 보장하지 않으므로 참가자의 실제
picker preflight가 최종 gate입니다. 요청한 조합이 보이지 않으면 Auto나 다른
모델로 대체하지 않습니다.

