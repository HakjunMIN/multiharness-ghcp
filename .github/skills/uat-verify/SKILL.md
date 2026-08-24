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
ISSUE=123
gh issue view "$ISSUE" --comments
cd seed && npm test
./scripts/check-repo.sh
gh issue create --title "검증 실패: <acceptance criterion>" --label "wf:verify,phase:verification,harness:codex" --body-file verification-failure.md
```

## 세션 규칙

검증은 구현과 최소 한 축, 즉 하네스 또는 모델 이상이 다른 조합에서 수행한다. 반드시 새 세션을 시작한다. 기본 조합은 `Codex`와 `GPT-5.6 Terra` 또는 `Copilot`과 `GPT-5.6 Terra`다.

## 금지

**구현을 수정해 통과시키지 않는다. 검증자가 고치면 그것은 검증이 아니다.**

- 실패 근거 없이 결함 이슈를 발행하지 않는다.
- 기존 구현 세션의 대화나 숨은 가정을 수락 기준으로 사용하지 않는다.
