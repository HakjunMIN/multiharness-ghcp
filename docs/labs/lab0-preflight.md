# Lab 0 — 프리플라이트 (30분)

## 이 랩에서 배우는 것

실습을 시작하기 전에 로컬 도구, GitHub 인증, 저장소 컨텍스트, 파트너 에이전트 정책을 점검한다. 테스트 기준선을 확인하고 워크숍에서 사용할 11개 이슈 레이블을 준비한다.

## 하네스 / 모델

| 하네스 | 모델 |
|---|---|
| 해당 없음 | 해당 없음 |

## 시작 전 상태

워크숍 저장소를 로컬에서 열었지만 환경 점검 결과와 테스트 기준선은 아직 확인하지 않았고, 대상 GitHub 저장소의 워크숍 레이블 존재 여부도 보장되지 않는다.

## 단계

1. 저장소 루트에서 strict 프리플라이트를 실행한다. 워크샵 전날 확인한 모델 경로를 환경 변수로 지정한다.

   ```bash
   cd "$(git rev-parse --show-toplevel)"
   export WORKSHOP_CLAUDE_OPUS5_CONFIRMED=1
   export WORKSHOP_VERIFY_ROUTE=copilot-terra  # 옵션 경로는 codex-cloud
   export WORKSHOP_VERIFY_MODEL_CONFIRMED=1
   ./scripts/preflight.sh --strict
   ```

2. 출력된 모든 `FAIL`의 안내에 따라 환경을 수정하고, `FAIL`이 0개가 될 때까지 다시 실행한다.

   ```bash
   ./scripts/preflight.sh --strict
   ```

3. 의존성을 설치하지 말고 seed 테스트 기준선을 확인한다.

   ```bash
   cd seed && npm test && cd ..
   ```

4. 현재 디렉터리가 연결된 GitHub 저장소를 확인한다.

   ```bash
   gh repo view --json nameWithOwner,url
   ```

   저장소가 아직 없다면 GitHub에서 빈 저장소를 만든 뒤 현재 저장소의 remote를 연결한다. 이미 올바른 저장소가 표시되면 새로 만들지 않는다. 참가자는 강사가 미리 만든 실습 리포를 clone하는 경로를 기본으로 사용한다.

5. 워크숍 레이블을 생성하거나 기존 정의를 확인한다.

   ```bash
   ./scripts/bootstrap-labels.sh
   ```

6. 레이블이 정확히 11개인지 확인한다.

   ```bash
   gh label list --limit 100 --json name --jq '[.[].name | select(startswith("wf:") or startswith("phase:") or startswith("harness:"))] | length'
   ```

## 끝난 뒤 상태

`./scripts/preflight.sh --strict`가 `FAIL` 0개를 보고하고 seed 테스트가 통과한다. Claude Opus 5와 선택한 검증 경로가 실제 계정에서 준비되며, 현재 GitHub 저장소에는 `wf:` 4개, `phase:` 4개, `harness:` 3개로 총 11개의 워크숍 레이블이 존재한다. `codex-cloud`를 선택했다면 로컬 CLI가 아니라 GHEC 정책, 리포 활성화, 모델 선택, Actions minutes와 AI credits를 확인한다.

## 흔한 실패

- **증상:** 테스트가 TypeScript 구문 오류로 시작되지 않는다 → **원인:** Node.js가 22.18 미만이라 native type stripping 기준을 충족하지 않는다 → **조치:** Node.js 22.18 이상으로 전환한 뒤 `node --version`과 테스트를 다시 확인한다.
- **증상:** `gh` 명령이 인증 오류를 낸다 → **원인:** GitHub CLI가 로그인되지 않았거나 토큰 권한이 부족하다 → **조치:** `gh auth login`을 실행하고 `gh auth status`로 확인한다.
- **증상:** `gh repo view`가 저장소를 찾지 못한다 → **원인:** 현재 디렉터리에 GitHub remote가 없어 repo context가 없다 → **조치:** 대상 저장소를 생성하거나 올바른 `origin` remote를 연결한 뒤 다시 실행한다.
- **증상:** GHEC에서 Codex를 Issue에 할당할 수 없다 → **원인:** 조직 정책 또는 리포별 cloud agent 설정이 비활성화되어 있다 → **조치:** 옵션 경로 A 대신 `WORKSHOP_VERIFY_ROUTE=copilot-terra`를 사용한다.

환경 요구사항과 운영 근거는 [참고 자료](../reference/sources.md)에서 확인할 수 있다.
