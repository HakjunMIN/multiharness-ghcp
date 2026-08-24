# Lab 3 Reference Solution

코어 랩이 cutover 시각을 넘겼을 때만 사용하는 강사용 최소 구현이다. 지역 정책은 `docs/templates/spec.md`와 독립 UAT 기준을 따른다.

이 디렉터리는 강사용 authoring checkout에만 둔다. Git branch는 비밀 경계가 아니므로 참가자 리포의 어떤 ref나 history에도 이 디렉터리를 push하지 않는다. `build-participant-bundle.sh`가 만든 배포본에는 포함되지 않는다.

행사 전 이 디렉터리의 내용만 강사 접근이 제한된 외부 위치에 복사한다. 참가자 리포에서 그 위치를 지정해 복구한다.

```bash
WORKSHOP_CHECKPOINT_DIR=/secure/instructor/lab3-checkpoint \
  ./scripts/restore-lab3-checkpoint.sh --confirm
```

스크립트는 clean worktree에서만 동작하고, 복사 후 단위 테스트와 독립 UAT를 모두 실행한다.
