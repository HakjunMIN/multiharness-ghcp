# GHEC Codex Cloud Verifier Contract

GitHub Enterprise Cloud의 OpenAI Codex third-party coding agent에 위임하는
비동기 독립 검증 계약이다. 이 계약은 로컬 Codex CLI나 VS Code Codex
세션을 위한 것이 아니다.

## 입력

- 검증 전용 `wf:verify` Issue
- map Issue의 최신 `## HANDOFF`
- `docs/uat/acceptance-matrix.md`
- `docs/templates/uat-report.md`
- 현재 커밋의 구현

## 임무

1. 구현 파일을 읽기 전에 Issue와 acceptance matrix에서 기대 결과를 추출한다.
2. cloud agent는 source branch에서 별도 working branch를 만든다. 보고서를
   수정하기 전 최초 `git rev-parse HEAD`가 Issue의 source commit과 같은지만
   확인한다. branch 이름은 비교하지 않는다. commit이 다르면 보고서에
   mismatch를 기록하고 다른 revision을 테스트하지 않는다.
3. 다음 명령을 그대로 실행한다.

   ```bash
   (cd seed && npm test)
   node --disable-warning=ExperimentalWarning --test docs/uat/acceptance.test.ts
   ./scripts/check-repo.sh
   ```

4. 모델 이름과 테스트한 revision을 다음 exact metadata line으로 기록하고,
   명령, 실제 출력, 기대 결과, 판정을 `docs/uat/report.md`에 기록한다.

   ```text
   - source branch: <Issue의 Source branch 값>
   - source commit: <Issue의 Source commit 값>
   ```
5. `docs/uat/report.md`만 변경한 draft PR을 만든다.
6. 실패는 보고서에 재현 가능한 근거로 기록하되 구현을 고치지 않는다.

## 변경 경계

허용된 유일한 변경 경로는 `docs/uat/report.md`다.

- `seed/`와 기존 테스트를 수정하지 않는다.
- 다른 문서, workflow, script, 설정 파일을 수정하지 않는다.
- dependency를 추가하지 않는다.
- 결함 Issue를 직접 만들거나 기존 Issue를 닫지 않는다.
- 구현의 현재 동작을 수락 기준으로 재해석하지 않는다.

허용 경로 밖의 변경이 필요하다고 판단하면 파일을 수정하지 말고 그 이유를
UAT 보고서의 risks에 기록한다.

## 완료 조건

- 다섯 고정 UAT 시나리오가 모두 근거와 함께 판정됐다.
- 보고서의 source branch와 commit이 검증 Issue의 값과 일치한다.
- draft PR의 변경 파일은 `docs/uat/report.md` 하나뿐이다.
- 실패가 있으면 기대값, 실제값, 재현 명령이 보고서에 있다.
- 사람 검토자가 diff와 근거를 확인할 수 있다.
