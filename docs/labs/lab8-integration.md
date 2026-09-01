# Lab 8 - 통합과 팀 채택 (45분)

## 이 랩에서 배우는 것

- spec부터 UAT까지 traceable한 PR을 만든다.
- 개인 실습을 팀 운영 규칙으로 전환한다.
- runtime 선택과 durable state 책임을 명시한다.

PR에 local spec, tracer/behavior tickets, ADR, 구현 commits, UAT report, 열린
local defect를 연결합니다. CI-equivalent 검증을 실행하고 실제 결과를 적습니다.

팀 채택 문서에는 다음을 한 문단씩 구분한다.

- Host: VS Code (작업 실행 환경)
- Agent runtime(harness): Session Target에서 선택하는 Copilot, Claude, Codex
- Model: 해당 runtime에서 선택한 모델
- Skill: 작업 절차를 강제하는 workflow
- Durable state: local work items, repo docs, commits, tests

reviewer/verifier가 implementation을 직접 수정하지 않는 규칙과 ticket별 fresh session 규칙을 합의한다.

## 종료 조건

- 모든 설계와 구현/UAT evidence를 연결한 PR이 있다.
- CI-equivalent 검증이 통과하거나 열린 결함이 명시됐다.
- 팀 채택 규칙이 owner와 함께 기록됐다.

## 막힐 때

- PR 링크가 끊기면 local spec 문서를 시작점으로 traceability를 다시 만든다.
- Lab 7은 생략할 수 있지만 검증과 UAT는 생략하지 않는다.
