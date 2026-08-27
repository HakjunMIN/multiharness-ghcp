# Local work item tracker

이 저장소는 GitHub Issues 대신 커밋되는 Markdown 문서를 tracker로 사용합니다.

## 위치

기능별 root는 `docs/work/<feature>/`입니다.

- `spec.md`: 기능의 승인된 spec
- `tickets/<NN>-<slug>.md`: dependency 순서의 tracer-bullet ticket
- `defects/<NN>-<slug>.md`: 독립 검증에서 발견한 defect

각 ticket의 `Blocked by`는 같은 기능 root의 ticket 번호와 제목을 참조합니다.
blocking ticket이 모두 완료된 문서만 frontier입니다.

## 상태

- `ready-for-agent`: 구현을 시작할 수 있음
- `in-progress`: 한 세션이 작업 중
- `done`: acceptance criteria와 검증이 완료됨
- `blocked`: 선행 ticket 또는 외부 조건을 기다림

## 완료 규칙

work item 상태 변경, 구현 commit, 검증 근거를 함께 커밋합니다. verifier는
production implementation을 수정하지 않고 defect 문서에 기대값, 실제값,
재현 명령, Standards/Spec finding을 기록합니다.

