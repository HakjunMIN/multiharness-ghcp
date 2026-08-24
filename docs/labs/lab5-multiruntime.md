# Lab 5 — 멀티 런타임 (45분, 옵션)
> 옵션 모듈입니다. 시간이 부족하면 건너뛰고 Lab 6으로 갑니다.

## 이 랩에서 배우는 것

- 로컬 sandbox, cloud sandbox, cloud agent의 격리 범위와 실행 제약을 직접 확인한다.
- 보안 경계, 비용, 세션 제약을 기준으로 작업에 맞는 runtime을 선택한다.
- 문서의 주장을 믿는 데서 멈추지 않고 작은 실험으로 실제 동작을 검증한다.

## 하네스 / 모델

| 실습 | 하네스 / 모델 |
|---|---|
| 세 가지 runtime 비교 | Copilot / 현재 환경에서 사용 가능한 모델 |

## 시작 전 상태

Lab 4 검증 결과와 인수인계 브리프가 map Issue에 게시되어 있고, 실습 리포에 미완료 구현 변경이 없어야 한다.

## 단계

1. **로컬 샌드박스**

   **언제 이걸 쓰는가:** 로컬 명령의 OS 접근 범위를 줄이고 싶지만, 리포 자체를 강한 보안 경계로 간주하지 않는 짧은 탐색 작업에 쓴다.

   먼저 platform requirement를 확인한다.

   - macOS: Seatbelt 지원 환경
   - Linux: `bwrap` 설치 환경
   - Windows: Windows Insiders 환경

   새 세션을 sandbox mode로 시작하거나 현재 세션에서 활성화한다.

   ```bash
   copilot --sandbox --experimental
   ```

   ```text
   /sandbox enable
   ```

   shell command로 작업 디렉터리 밖 파일 쓰기를 시도해 차단 여부를 관찰한다. 이어서 CLI 내장 파일 도구로 실습 리포 안의 추적하지 않는 실험 파일을 만들고 지운다. **CLI 내장 파일 도구는 OS sandbox가 가로채지 않으며 Copilot이 best-effort로 자체 강제한다.** 따라서 sandbox를 보안 경계로 신뢰하지 않는다.

   ```text
   내장 파일 도구로 sandbox-probe.txt를 만들고, 내용 확인 후 삭제해 줘.
   ```

2. **클라우드 샌드박스**

   **언제 이걸 쓰는가:** 로컬 환경과 분리된 일회성 대화형 실행이 필요하고, 시간·메모리·snapshot 비용을 감수할 수 있을 때 쓴다.

   ```bash
   copilot --cloud --experimental
   ```

   대화형 prompt에서 `pwd`, `git status`, `node --version`을 실행한다. 종료한 다음 prompt mode를 일부러 시도한다.

   ```bash
   copilot --cloud --experimental -p "pwd"
   ```

   `-p`가 동작하지 않는 것을 직접 확인한다. cloud sandbox는 **대화형 전용**이다. 비용 판단에는 다음 단가를 사용한다.

   | 항목 | 단가 |
   |---|---:|
   | 컴퓨트 | `$0.000024/초` |
   | 메모리 | `$0.000003/GiB·초` |
   | 스냅샷 | `$0.005/GiB·월` |

3. **클라우드 에이전트**

   **언제 이걸 쓰는가:** 범위가 명확한 `wf:task`를 독립 branch와 PR로 비동기 위임할 수 있고, 위임 후 요구사항이 바뀌지 않을 때 쓴다.

   실험용 `wf:task` Issue를 만들고 번호를 저장한 뒤 `@copilot`에 명시적으로 할당한다. PR이 반드시 생기도록 작은 추적 파일 하나를 추가하는 작업을 요청한다.

   ```bash
   ISSUE_URL="$(gh issue create \
     --title "runtime 실험: 리포 상태 확인" \
     --label "wf:task,phase:implementation,harness:copilot" \
     --body "docs/runtime-observation.md를 추가해 npm test와 check-repo.sh 실행 결과를 기록하고 PR을 만든다.")"
   ISSUE="${ISSUE_URL##*/}"
   gh issue edit "$ISSUE" --add-assignee "@copilot"
   printf 'Delegated issue: %s\n' "$ISSUE_URL"
   ```

   agent session이 시작된 것을 Agents 화면에서 확인한 뒤 Issue에 추가 지시 코멘트를 게시한다.

   ```bash
   gh issue comment "$ISSUE" --body "추가 지시: telemetry 경계 조건도 확인한다."
   ```

   그 코멘트가 실행 맥락에 반영되지 않는 것을 직접 확인한다. **할당 이후의 Issue 코멘트는 설계상 읽히지 않으므로** 추가 지시는 PR에서 전달한다. cloud agent의 시간·사용량·작업 범위 제한은 preview 기간에 바뀔 수 있으므로 [참고 자료](../reference/sources.md)의 공식 cloud agent 문서를 행사 전날 확인한다.

4. **실험 상태를 정리한다.**

   관찰 결과를 기록한 뒤 Issue timeline에서 교차 참조된 open PR을 찾는다. 정확히 하나일 때만 상세 정보를 표시하고, 같은 번호를 직접 다시 입력해 확인한 뒤 닫는다.

   ```bash
   REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
   FILTER="[.[] | select(.event == \"cross-referenced\") |
     .source.issue |
     select(.repository_url == \"https://api.github.com/repos/$REPO\" and
       .pull_request != null and .state == \"open\")] |
     unique_by(.number)"
   COUNT="$(gh api "repos/$REPO/issues/$ISSUE/timeline" \
     -H "Accept: application/vnd.github+json" --jq "$FILTER | length")"
   [ "$COUNT" -eq 1 ] || {
     printf 'Expected exactly one linked open PR, found %s\n' "$COUNT" >&2
     exit 1
   }
   PR="$(gh api "repos/$REPO/issues/$ISSUE/timeline" \
     -H "Accept: application/vnd.github+json" --jq "$FILTER | .[0].number")"
   gh pr view "$PR" --repo "$REPO" --json number,title,url,headRefName,state
   PR_ID="$REPO#$PR"
   printf 'Type %s to confirm cleanup: ' "$PR_ID"
   read -r CONFIRM_PR
   [ "$CONFIRM_PR" = "$PR_ID" ] || { printf 'Cleanup cancelled.\n' >&2; exit 1; }
   gh pr close "$PR" --repo "$REPO" --delete-branch
   gh issue close "$ISSUE" --comment "Runtime 실험 관찰과 정리를 완료했습니다."
   ```

## 끝난 뒤 상태

세 runtime 각각에 대해 실행 명령, 관찰 결과, 사용할 조건과 피할 조건이 기록되어 있고, 실험 중 만든 로컬 파일과 불필요한 Issue·branch·PR이 정리되어 있어야 한다.

## 흔한 실패

- **증상:** local sandbox에서 내장 파일 도구가 파일을 썼다. → **원인:** OS sandbox가 CLI 내장 파일 도구를 가로채지 않고 best-effort 정책만 적용한다. → **조치:** sandbox를 보안 경계로 신뢰하지 말고 민감한 리포에는 별도 격리를 사용한다.
- **증상:** cloud sandbox에서 `-p` prompt가 실행되지 않는다. → **원인:** cloud sandbox는 대화형 전용이다. → **조치:** `copilot --cloud --experimental`로 열고 대화형 prompt를 입력한다.
- **증상:** cloud agent가 assign 이후 Issue 코멘트를 무시한다. → **원인:** 시작 시점의 Issue 내용만 실행 맥락으로 가져간다. → **조치:** 변경 지시는 생성된 PR에서 전달하거나 작업을 다시 위임한다.
- **증상:** cloud agent가 요구한 범위를 한 작업에서 처리하지 못한다. → **원인:** 작업 범위 또는 현재 세션 제한을 넘겼다. → **조치:** 공식 제한을 확인하고 작업을 분리해 별도 Issue와 session으로 위임한다.
