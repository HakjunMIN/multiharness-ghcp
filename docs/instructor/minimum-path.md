# 최소 경로와 복구 checkpoint

시간이 밀릴 때 반드시 남겨야 하는 산출물입니다.

- Lab 0: required skills, `skills-lock.json`, `docs/agents/*`
- Lab 1: `CONTEXT.md`와 필요한 ADR
- Lab 2: spec Issue와 시작 가능한 `ready-for-agent` ticket
- Lab 3: 한 ticket의 red-green, review, commit
- Lab 4: Sonnet review와 선택 트랙 UAT report
- Lab 6: spec·tickets·report가 연결된 PR

## 복구 방법

- 설계 세션을 일찍 지웠다면 committed domain docs와 Issues에서 새
  Claude/Opus 세션을 시작합니다.
- 구현이 밀리면 ticket 수를 줄이고 한 ticket만 끝까지 완결합니다.
- 검증이 밀리면 결함을 고치지 말고 재현 가능한 Issue 기록까지만 합니다.

어떤 모델도 대체하지 않습니다. 필수 조합이 열리지 않으면 Lab 0에서
멈추고 entitlement 문제로 처리합니다.
