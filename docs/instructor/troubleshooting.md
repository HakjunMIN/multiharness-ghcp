# 문제 해결

| 증상 | 원인 | 조치 |
|---|---|---|
| `ExperimentalWarning: Type Stripping` 출력 | Node version 또는 warning flag 차이 | 무해하므로 무시한다. `npm test`는 `--disable-warning=ExperimentalWarning`을 이미 붙인다. |
| `.ts` 실행 실패 | Node 22.18 미만 | Node.js 22.18 이상으로 upgrade한다. `npm install`로 우회하지 않는다. |
| `gh: Not Found` | GitHub repo context가 없는 directory에서 실행 | `gh repo create`로 repo를 만들거나 올바른 repo directory로 `cd`한다. |
| `addSubIssue` mutation 실패 | token scope 부족 | `gh auth refresh -s repo` 실행 후 다시 시도한다. |
| `--parent` flag가 없음 | 설치된 `gh` 2.65가 해당 flag를 제공하지 않음 | GraphQL을 사용한다. workshop script가 이미 GraphQL 방식으로 처리한다. |
| cloud sandbox에서 `-p`가 무시됨 | cloud sandbox는 대화형 전용 | `copilot --cloud --experimental`로 열고 대화형으로 실행한다. |
| cloud agent가 추가 comment를 무시 | 할당 이후 Issue comment를 읽지 않는 설계 | 생성된 PR에서 지시하거나 새 작업으로 다시 할당한다. |
| worktree에 파일이 없음 | 파일이 미커밋 상태이거나 gitignored | 파일을 commit하거나 필요한 pattern을 `git.worktreeIncludeFiles`에 설정한다. |
| 검증 session이 구현 session의 맥락을 알고 있음 | session을 새로 열지 않음 | 구현 session을 종료하고 다른 harness/model 조합의 새 session을 강제한다. |
| Lab 4에서 Codex + `GPT-5.6 Terra` 선택 불가 | Codex cloud agent의 model matrix 제약 | Copilot + `GPT-5.6 Terra`의 경로 B로 전환한다. |
| GHEC Issue에서 Codex를 선택할 수 없음 | enterprise/org 정책 또는 리포별 cloud agent 설정 비활성 | 관리자가 활성화하지 못하면 경로 B로 전환한다. |
| Codex draft PR이 없거나 timeout | cloud task 실패 또는 Actions/AI credit 부족 | 위임 URL을 기록하고 경로 B로 전환한다. |
| Codex draft PR이 `seed/`를 변경 | report-only 역할 경계를 따르지 않음 | merge하지 말고 한 번 재시도하거나 경로 B로 전환한다. |
| `preflight.sh`에서 `claude` WARN | Claude CLI가 설치되지 않음 | VS Code Claude session으로 진행할 수 있다. |
| local sandbox가 파일 쓰기를 막지 않음 | CLI built-in file tool은 OS sandbox 밖에서 best-effort로 강제됨 | sandbox를 security boundary로 신뢰하지 않고 별도 격리 환경을 사용한다. |
| `frontier.sh`가 아무 Issue도 출력하지 않음 | 모든 task가 assigned 상태이거나 열린 `blockedBy`가 존재 | stale assignee를 해제하고 blocker Issue의 open/closed 상태와 dependency를 확인한다. |
| `handoff.sh`가 brief를 거부함 | 첫 줄 또는 필수 field가 contract와 다름 | 첫 줄을 `## HANDOFF`로 두고 `from/to`, `artifacts`, `verify`를 포함한 뒤 다시 실행한다. |
| `npm test`는 통과하지만 요구 동작이 실패 | 현재 동작을 고정한 `known gap:` test의 기대값을 바꾸지 않음 | test를 삭제하지 말고 새 정책에 맞게 expectation을 뒤집고 acceptance case를 추가한다. |
| `check-repo.sh`가 금지어를 보고함 | 문서나 generated artifact에 고객 식별 정보 또는 금지 marker가 있음 | 해당 표현을 익명화하거나 완성된 설명으로 바꾼 뒤 다시 실행한다. |
