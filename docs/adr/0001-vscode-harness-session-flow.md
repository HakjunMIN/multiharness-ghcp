# ADR 0001: VS Code harness handoff와 fresh session을 역할별로 분리

## Status

Accepted

## Context

워크숍은 발견의 맥락을 아키텍처와 기획에 이어야 하지만, 구현과 독립 검증은
앞선 대화에 끌려가지 않아야 합니다. VS Code handoff는 저장소 파일만 넘기는
동작이 아니라 기존 대화 history와 누적 context 전체를 새 harness에 전달합니다.
반대로 fresh session은 커밋된 durable artifact만으로 상태를 재구성합니다.

GitHub Issue를 사용하면 참가자별 fork와 원격 tracker 설정이 필요합니다. 이
워크숍은 실행 환경 학습에 집중하기 위해 work item을 저장소 문서로 관리합니다.

## Decision

- 발견은 Copilot harness와 GPT-5.6 Sol에서 시작합니다.
- 발견 세션을 Claude harness와 Claude Opus 4.8로 handoff해 아키텍처와 기획을
  이어갑니다.
- 구현은 ticket마다 fresh Copilot harness와 GPT-5.6 Sol 세션을 사용합니다.
- 독립 검증은 fresh Codex harness와 GPT-5.6 Terra 세션을 사용하며 구현
  history를 handoff하지 않습니다.
- spec, ticket, defect는 커밋되는 local work item으로 관리합니다.
- 모든 역할은 exact harness/model 조합이 picker에 보이는지 사전 점검하고,
  보이지 않으면 임의 모델로 대체하지 않습니다.

## Alternatives considered

### 모든 역할을 handoff

문맥 보존은 쉽지만 verifier가 구현자의 추론과 가정을 상속해 독립성이 사라집니다.

### 모든 역할을 fresh session

독립성은 높지만 발견에서 확정되지 않은 질문과 근거를 아키텍처 세션이 반복하게
됩니다.

### GitHub Issues 유지

원격 traceability는 좋지만 fork, 권한, label, 네트워크가 워크숍의 필수
선행조건이 됩니다.

## Consequences

- 발견에서 기획까지는 대화 문맥과 durable artifact를 함께 사용할 수 있습니다.
- 구현과 검증 품질은 local work item과 HANDOFF 품질에 직접 의존합니다.
- Codex 검증에는 로컬 Codex harness와 Copilot-backed GPT-5.6 Terra 경로를
  사전에 준비해야 합니다.

