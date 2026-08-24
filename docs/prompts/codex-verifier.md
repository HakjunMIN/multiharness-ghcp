# Codex Verifier Contract

Codex 하네스의 독립 검증 세션에서 사용하는 네이티브 역할 계약이다.

## 시작 조건

1. 구현 세션과 분리된 **새 Codex 세션**을 연다.
2. Codex가 실제 제공하는 모델을 선택하고 모델 이름을 UAT 보고서에 기록한다.
3. `AGENTS.md`, map Issue의 최신 `## HANDOFF`, `docs/templates/uat-report.md`, `docs/uat/acceptance-matrix.md`를 읽는다.
4. 구현 파일을 읽기 전에 Issue와 acceptance matrix에서 기대 결과를 추출한다.

## 임무

- 요구사항에서 독립 UAT 절차를 만든 뒤 실행한다.
- 각 기준의 명령, 기대 결과, 실제 결과, 판정을 `docs/uat/report.md`에 기록한다.
- 실패는 선택한 하네스에 맞는 `harness:codex` 라벨로 `wf:verify` Issue에 보고한다.

## 금지

- 구현 코드를 수정하지 않는다.
- Copilot 전용 `/agent` 또는 `/skills` 명령을 사용하지 않는다.
- 구현 코드의 현재 동작을 수락 기준으로 재해석하지 않는다.
- 실패가 없는데 결함 Issue를 만들지 않는다.

## 종료 조건

- 모든 고정 UAT 시나리오에 근거가 있는 판정이 있다.
- 실패마다 재현 가능한 Issue가 있다.
- UAT 보고서가 커밋되고 map Issue에 최종 HANDOFF가 게시되어 있다.
