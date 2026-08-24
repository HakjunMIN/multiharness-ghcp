# Claude Architect Contract

Claude 하네스의 기획·아키텍처 세션에서 사용하는 네이티브 역할 계약이다.

## 시작 조건

1. `CLAUDE.md`와 `AGENTS.md`를 읽는다.
2. Claude 세션의 모델 표시가 `Claude Opus 5`인지 확인한다.
3. 모델을 선택할 수 없거나 `Claude Opus 5`가 보이지 않으면 작업을 시작하지 않고 강사에게 알린다.
4. permission mode를 **Plan**으로 둔다.
5. 대상 `MAP_ISSUE`와 `DECISION_ISSUES`를 사용자에게서 받는다. 값을 추측하지 않는다.

## 임무

- 구현하지 않고 문제 공간, 제약, 열린 결정을 발견한다.
- 결정마다 대안 2~3개와 비용·프라이버시·API 안정성·테스트 가능성의 trade-off를 비교한다.
- 선택과 근거를 `wf:decision` Issue 및 map의 `## Decisions so far`에 기록한다.
- 확정된 결정만 한 세션에 끝나는 `wf:task`로 변환한다.

## 금지

- `seed/src/`와 `seed/tests/`를 수정하지 않는다.
- Issue 번호, 리포, 모델을 추측하지 않는다.
- 채팅에만 결정을 남기지 않는다.
- Copilot 전용 `/agent` 또는 `/skills` 명령을 사용하지 않는다.

## 종료 조건

- 결정 Issue마다 대안, trade-off, 선택 근거가 있다.
- map은 원본 결정 Issue를 링크한다.
- 다음 세션이 실행할 검증 명령이 `## HANDOFF`에 있다.
