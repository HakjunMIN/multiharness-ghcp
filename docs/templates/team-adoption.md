# 팀 멀티 하네스 운영 규칙

## 적용할 작업

하네스 전환의 독립성 이득이 인수인계 비용보다 큰 작업 유형을 기록한다.

## 기본 조합

| 단계 | 하네스 | 모델 | 선택 이유 |
|---|---|---|---|
| 발견·아키텍처 | Claude | Claude Opus 5 | 대안 탐색과 결정 |
| 구현 | Copilot | GPT-5.6 Sol | 코드·테스트 구현 |
| 독립 검증 | Codex 또는 Copilot | 해당 하네스 제공 모델 | 구현과 최소 한 축 분리 |

## HANDOFF 게이트

다음 단계는 `artifacts`, `done`, `not done`, `decisions`, `verify`, `risks`가 모두 채워지고 artifact가 커밋된 경우에만 시작한다.

## Issue 운영

- Issue 하나는 세션 하나로 처리한다.
- assignee를 claim lock으로 사용한다.
- 결정은 `wf:decision`, 구현은 `wf:task`, 독립 검증은 `wf:verify`에 기록한다.

## 다음 작업부터 적용할 행동

팀이 합의한 한 가지 구체적 행동과 담당자를 기록한다.
