# Lab 4 — 검증과 수락 테스트 (60분)
> 독립 검증은 필수다. 경로 A는 GHEC Codex cloud agent를 사용할 수 있는 팀만 선택하는 옵션이다.

## 이 랩에서 배우는 것

- 구현자의 대화 맥락 없이 Issue와 HANDOFF만으로 수락 기준을 복원한다.
- 구현과 최소 한 축 이상 다른 조합에서 고정 UAT를 수행한다.
- 검증 실패를 직접 고치지 않고 재현 가능한 `wf:verify` Issue로 돌려보낸다.
- 옵션 경로에서는 비동기 cloud agent의 draft PR을 검증 증거로 리뷰한다.

## 검증 경로

| 경로 | 하네스 / 모델 | 사용 조건 |
|---|---|---|
| **A — 옵션** | **GHEC OpenAI Codex cloud agent + 시작 화면에서 제공되는 Codex 모델** | GHEC 정책, 리포 활성화, Actions minutes, AI credits가 확인됨 |
| **B — 기본** | **Copilot + GPT-5.6 Terra + 새 로컬 세션** | 모든 참가자가 사용할 기본·fallback 경로 |

**Codex + GPT-5.6 Terra는 지원 조합이 아니다.** VS Code의 로컬 Codex
하네스도 이 랩의 경로 A가 아니다. 경로 A를 사용할 수 없거나 cloud task가
실패하면 즉시 경로 B로 전환한다.

## 시작 전 상태

모든 `wf:task` Issue가 닫혀 있고, 구현 세션의 단위 테스트가 통과하며,
map Issue에 완전한 `## HANDOFF`가 게시되어 있어야 한다.

## 공통 준비

1. 구현 세션을 종료한다.
2. 구현 파일을 읽기 전에 map, decision, task Issue에서 수락 기준을 추출한다.

   ```bash
   printf 'Map issue number: '; read -r MAP_ISSUE
   printf 'Decision issue number: '; read -r DECISION_ISSUE
   printf 'Task issue number: '; read -r TASK_ISSUE
   gh issue view "$MAP_ISSUE" --comments
   gh issue view "$DECISION_ISSUE" --comments
   gh issue view "$TASK_ISSUE" --comments
   ```

3. `docs/uat/acceptance-matrix.md`에서 지역별 cloud 허용·차단,
   on-device fallback, telemetry opt-out의 기대 결과를 먼저 적는다.

## 경로 A — Optional GHEC Codex cloud agent

1. 경로를 명시하고 Lab 3 구현 commit에서 옵션 검증 전용 base branch를
   만든다. 이 branch는 Codex report merge 외에는 행사 중 갱신하지 않는다.

   ```bash
   set -euo pipefail
   export WORKSHOP_VERIFY_ROUTE=codex-cloud
   REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
   IMPLEMENTATION_BRANCH="$(git branch --show-current)"
   SOURCE_COMMIT="$(git rev-parse HEAD)"
   SOURCE_BRANCH="workshop-verify-${SOURCE_COMMIT:0:12}"
   git show-ref --verify --quiet "refs/heads/$SOURCE_BRANCH" ||
     git branch "$SOURCE_BRANCH" "$SOURCE_COMMIT"
   git push -u origin "$SOURCE_BRANCH"
   test "$(git ls-remote origin "refs/heads/$SOURCE_BRANCH" | cut -f1)" = "$SOURCE_COMMIT"
   ```

2. 검증 Issue 본문의 세 metadata 행을 실제 값으로 자동 치환하고 정확히
   기록됐는지 확인한다.

   ```bash
   MAP_URL="$(gh issue view "$MAP_ISSUE" --json url --jq .url)"
   awk -v map="$MAP_URL" -v commit="$SOURCE_COMMIT" -v branch="$SOURCE_BRANCH" '
     /^- Map Issue:/ {$0="- Map Issue: " map}
     /^- Source commit:/ {$0="- Source commit: " commit}
     /^- Source branch:/ {$0="- Source branch: " branch}
     {print}
   ' docs/templates/codex-cloud-verification-issue.md > /tmp/codex-verify.md
   grep -Fx -- "- Map Issue: $MAP_URL" /tmp/codex-verify.md
   grep -Fx -- "- Source commit: $SOURCE_COMMIT" /tmp/codex-verify.md
   grep -Fx -- "- Source branch: $SOURCE_BRANCH" /tmp/codex-verify.md
   ```

3. `wf:verify` Issue를 만들고 URL을 저장한다.

   ```bash
   VERIFY_URL="$(gh issue create \
     --title "독립 검증: GHEC Codex cloud UAT" \
     --label "wf:verify,phase:verification,harness:codex" \
     --body-file /tmp/codex-verify.md)"
   VERIFY_ISSUE="${VERIFY_URL##*/}"
   printf 'Verification issue: %s\n' "$VERIFY_URL"
   ```

4. GitHub.com의 Agents 화면에서 **OpenAI Codex**, 이 Issue, 그리고
   `$SOURCE_BRANCH`를 starting branch로 선택한다. 현재 제공되는 모델을
   선택해 task를 시작한다. Codex는 비동기로 정확히 `$SOURCE_COMMIT`을 확인한
   뒤 UAT를 실행하고 `docs/uat/report.md`만 담은 draft PR을 만들어야 한다.

5. draft PR이 생성되면 Issue timeline에서 연결된 PR을 열고 상태, base branch,
   명령 근거와 변경 파일을 확인한다. 모든 `test`가 통과해야 한다.

   ```bash
   set -euo pipefail
   printf 'Codex draft PR number: '; read -r PR
   gh pr view "$PR" --json number,title,url,isDraft,headRefName,state
   PR_HEAD="$(gh pr view "$PR" --json headRefOid --jq .headRefOid)"
   test "$(gh pr view "$PR" --json state,isDraft --jq '.state == "OPEN" and .isDraft == true')" = "true"
   test "$(gh pr view "$PR" --json baseRefName --jq .baseRefName)" = "$SOURCE_BRANCH"
   test "$(gh pr view "$PR" --json baseRefOid --jq .baseRefOid)" = "$SOURCE_COMMIT"
   test "$(gh pr diff "$PR" --name-only)" = "docs/uat/report.md"
   REPORT_CONTENT="$(gh api \
     "repos/$REPO/contents/docs/uat/report.md?ref=$PR_HEAD" \
     -H "Accept: application/vnd.github.raw+json")"
   printf '%s\n' "$REPORT_CONTENT" |
     grep -Fx -- "- source branch: $SOURCE_BRANCH"
   printf '%s\n' "$REPORT_CONTENT" |
     grep -Fx -- "- source commit: $SOURCE_COMMIT"
   ```

   다른 경로가 있거나 `seed/`가 변경됐다면 merge하지 않는다.

   ```bash
   gh pr close "$PR" --comment "검증 역할 경계를 벗어난 변경이 있어 merge하지 않습니다."
   ```

   지시를 고쳐 한 번 다시 위임하거나 경로 B로 전환한다.

6. report-only diff와 UAT 근거가 유효하면 draft를 ready로 바꾸고
   `$SOURCE_BRANCH`에 merge한다. 로컬 branch를 fast-forward하고 보고서가
   현재 `HEAD`에 있는지 확인한다.

   ```bash
   set -euo pipefail
   test "$(git ls-remote origin "refs/heads/$SOURCE_BRANCH" | cut -f1)" = "$SOURCE_COMMIT"
   test "$(gh pr view "$PR" --json baseRefOid --jq .baseRefOid)" = "$SOURCE_COMMIT"
   test "$(gh pr view "$PR" --json headRefOid --jq .headRefOid)" = "$PR_HEAD"
   gh pr ready "$PR"
   gh pr checks "$PR" --watch --fail-fast
   test "$(git ls-remote origin "refs/heads/$SOURCE_BRANCH" | cut -f1)" = "$SOURCE_COMMIT"
   test "$(gh pr view "$PR" --json baseRefOid --jq .baseRefOid)" = "$SOURCE_COMMIT"
   test "$(gh pr view "$PR" --json headRefOid --jq .headRefOid)" = "$PR_HEAD"
   gh pr merge "$PR" --merge --match-head-commit "$PR_HEAD"
   test "$(gh pr view "$PR" --json state --jq .state)" = "MERGED"
   git switch "$SOURCE_BRANCH"
   git pull --ff-only origin "$SOURCE_BRANCH"
   git ls-tree -r --name-only HEAD -- docs/uat/report.md |
     grep -Fx "docs/uat/report.md"
   ```

   UAT 실패가 있으면 merge 여부와 별개로 실패마다 별도 구현 Issue를 만든다.
   Codex에게 구현 수정을 요청하지 않는다.

## 경로 B — Copilot + GPT-5.6 Terra

1. 별도 터미널에서 새 검증 세션을 연다.

   ```bash
   set -euo pipefail
   cd "$(git rev-parse --show-toplevel)"
   export WORKSHOP_VERIFY_ROUTE=copilot-terra
   copilot --model gpt-5.6-terra
   ```

2. 새 세션에서 `/agent verifier`를 선택하고 “`uat-verify` skill을 사용하세요”라고
   요청한다. 다음 고정 명령을 실행하고 `docs/templates/uat-report.md`에서
   `docs/uat/report.md`를 만든다.

   ```bash
   (cd seed && npm test)
   node --disable-warning=ExperimentalWarning --test docs/uat/acceptance.test.ts
   ./scripts/check-repo.sh
   cp docs/templates/uat-report.md docs/uat/report.md
   ```

3. 검증 보고서만 커밋한다.

   ```bash
   git add docs/uat/report.md
   git commit -m "docs: record independent UAT results"
   ```

## 실패 반환과 HANDOFF

실패마다 기대값, 실제값, 재현 명령을 `verification-failure.md`에 기록하고
사람이 구현 Issue를 만든다. 경로 A는 `harness:codex`, 경로 B는
`harness:copilot`을 사용한다.

```bash
${EDITOR:-vi} verification-failure.md
printf 'Failed criterion title: '; read -r FAILED_CRITERION
test -s verification-failure.md
case "${WORKSHOP_VERIFY_ROUTE:-}" in
  codex-cloud) HARNESS_LABEL="harness:codex" ;;
  copilot-terra) HARNESS_LABEL="harness:copilot" ;;
  *) printf 'Unknown verification route\n' >&2; exit 2 ;;
esac
gh issue create \
  --title "검증 실패: $FAILED_CRITERION" \
  --label "wf:verify,phase:verification,$HARNESS_LABEL" \
  --body-file verification-failure.md
```

마지막으로 `docs/uat/report.md`가 현재 branch에 커밋된 상태에서
`/tmp/handoff-verification.md`를 작성해 게시한다.

```bash
./scripts/handoff.sh "$MAP_ISSUE" /tmp/handoff-verification.md
gh issue view "$MAP_ISSUE" --comments
```

경로 A의 `from/to`는 선택한 Codex 모델을, 경로 B는
`Copilot/GPT-5.6 Terra`를 기록한다.

## 끝난 뒤 상태

모든 수락 기준에 명령 출력이 첨부된 판정이 있고, 실패마다 열린
`wf:verify` Issue가 있다. 경로 A를 사용했다면 report-only Codex PR의
diff를 사람이 확인했다. map Issue에는 다음 세션이 실행할 수 있는
`## HANDOFF`가 게시되어 있다.

## 흔한 실패

- **Codex 선택 항목이 없음:** GHEC 정책 또는 리포별 cloud agent 설정이 꺼져 있다. 경로 B로 전환한다.
- **Codex 모델이 보이지 않음:** 모델 카탈로그가 변경됐거나 정책이 제한한다. 관찰한 모델을 기록하고 경로 B로 전환한다.
- **draft PR이 생성되지 않거나 timeout:** 실패한 위임 URL을 기록하고 경로 B로 전환한다.
- **Codex PR이 `seed/`를 수정함:** 역할 경계 위반이다. merge하지 않고 한 번 재시도하거나 경로 B로 전환한다.
- **검증자가 결함을 직접 수정함:** 검증이 아니다. 결함 Issue를 새 구현 세션으로 돌려보낸다.
