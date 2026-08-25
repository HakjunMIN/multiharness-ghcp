---
name: uat-verify
description: 검증, UAT, 수락 테스트, 리뷰 요청이 나오면 요구사항 기반의 독립 검증을 새 세션에서 수행한다
---

# UAT Verify

## 절차

1. 구현 코드를 읽기 **전에** 요구사항 이슈에서 수락 기준을 먼저 추출한다.
2. 각 수락 기준마다 실행 가능한 확인 절차를 작성한다.
3. 확인 절차와 사용자 관점의 UAT 시나리오를 실행한다.
4. 통과와 실패를 명령 출력 발췌와 함께 기록한다.
5. 실패마다 재현 절차와 기대 결과를 담은 새 이슈를 `wf:verify` 라벨로 발행한다.

```bash
: "${MAP_ISSUE:?MAP_ISSUE를 먼저 설정하세요}"
[[ "$MAP_ISSUE" =~ ^[0-9]+$ ]] || { echo "MAP_ISSUE는 숫자여야 합니다" >&2; exit 2; }
gh issue view "$MAP_ISSUE" --comments
(cd seed && npm test)
./scripts/check-repo.sh
```

실패가 확인된 경우에만 `verification-failure.md`를 작성하고 Issue를 만든다. 선택한 경로가 Copilot이면 `harness:copilot`, Codex이면 `harness:codex`를 사용한다. Issue 생성 전에 대상 리포, 제목, 라벨을 표시한다.

## 세션 규칙

검증은 구현과 최소 한 축, 즉 하네스 또는 모델 이상이 다른 조합에서 수행한다. 반드시 새 세션을 시작한다.

- **경로 A(옵션):** GHEC Codex cloud agent + Codex가 실제 제공하는 모델. `docs/uat/report.md`만 변경하는 draft PR로 수행한다.
- **경로 B:** Copilot 하네스 + `GPT-5.6 Terra`

`Codex + GPT-5.6 Terra`는 지원 조합으로 취급하지 않는다.

## 금지

**구현을 수정해 통과시키지 않는다. 검증자가 고치면 그것은 검증이 아니다.**

- 실패 근거 없이 결함 이슈를 발행하지 않는다.
- 기존 구현 세션의 대화나 숨은 가정을 수락 기준으로 사용하지 않는다.
