# Lab 6 — 통합과 회고 (40분)

## 이 랩에서 배우는 것

- map Issue를 따라 발견, 결정, 구현, 검증의 근거를 다시 연결한다.
- `## Decisions so far`가 채팅 없이도 하루의 기술적 결정을 설명하는지 평가한다.
- 하네스 전환의 실익과 인수인계 비용을 팀 운영 규칙으로 바꾼다.

## 하네스 / 모델

| 활동 | 하네스 / 모델 |
|---|---|
| 통합 확인과 팀 회고 | Copilot / 모델 제한 없음 |

## 시작 전 상태

Lab 4의 모든 수락 기준에 판정 근거가 있고, 실패가 있었다면 `wf:verify` Issue와 구현 세션으로의 인수인계가 map Issue에 연결되어 있어야 한다.

## 단계

1. **map Issue에서 하루 전체를 역추적한다.**

   ```bash
   printf 'Map issue number: '; read -r MAP_ISSUE
   gh issue view "$MAP_ISSUE" --comments
   ```

   팀원이 번갈아 다음 세 지점을 찾아 링크와 함께 설명한다.

   - 어느 `wf:decision` Issue에서 지역별 privacy routing과 telemetry opt-out 규칙을 결정했는가?
   - 어느 `wf:task` Issue와 구현 세션에서 각 결정을 코드로 옮겼는가?
   - 어느 수락 기준을 검증했고, 독립 검증이 무엇을 잡아냈는가?

2. **map의 `## Decisions so far`가 하루의 요약인지 확인한다.**

   ```bash
   gh issue view "$MAP_ISSUE" --json body --jq '.body'
   ```

   채팅 기록이나 구두 설명 없이 읽는다. 최종 지역 정책, telemetry opt-out 의미, 주요 trade-off, 근거 decision Issue가 드러나지 않으면 map 본문을 갱신한다.

   ```bash
   gh issue view "$MAP_ISSUE" --json body --jq '.body' > /tmp/map-final.md
   ${EDITOR:-vi} /tmp/map-final.md
   gh issue edit "$MAP_ISSUE" --body-file /tmp/map-final.md
   ```

3. **팀 회고를 실행한다.**

   각 질문에 팀별로 하나의 구체적 사례와 다음 작업부터 적용할 행동 하나를 적는다.

   1. 인수인계 브리프 중 다음 사람이 실제로 막혔던 것은 어느 필드가 부실했기 때문인가?
   2. 어떤 작업에서 하네스/모델을 바꾼 것이 실제로 이득이었고, 어떤 것이 그냥 오버헤드였는가?
   3. `docs/reference/framework-landscape.md`의 프레임워크 중 우리 팀이 다음 분기에 도입할 것 하나와 그 이유는?

   결과는 map Issue 코멘트로 남긴다.

   ```bash
   cat > /tmp/retrospective.md <<'EOF'
   ## Retrospective
   - handoff 개선:
   - harness/model 선택 규칙:
   - 다음 분기 도입 프레임워크:
   - 다음 작업부터 할 행동:
   EOF
   gh issue comment "$MAP_ISSUE" --body-file /tmp/retrospective.md
   ```

4. **팀 도입 규칙을 커밋한다.**

   ```bash
   cp docs/templates/team-adoption.md docs/team-adoption.md
   ```

   회고의 실제 사례와 합의한 다음 행동을 반영한 뒤 커밋한다.

   ```bash
   git add docs/team-adoption.md
   git commit -m "docs: record team multi-harness operating rules"
   ```

## 끝난 뒤 상태

map Issue의 `## Decisions so far`만으로 하루의 핵심 결정을 설명할 수 있고, 발견·결정·구현·검증 산출물이 Issue로 추적되며, 팀의 다음 행동이 회고 코멘트와 커밋된 `docs/team-adoption.md`에 기록되어 있어야 한다.

## 흔한 실패

- **증상:** 하루의 결정을 설명할 때 특정 세션의 채팅을 찾아야 한다. → **원인:** decision Issue 또는 map의 `## Decisions so far`가 갱신되지 않았다. → **조치:** 근거 Issue 링크와 최종 결론을 map에 반영한다.
- **증상:** 회고가 “잘했다”, “더 신경 쓴다”로 끝난다. → **원인:** 구체적 사례와 다음 행동을 요구하지 않았다. → **조치:** 각 답에 실제 Issue 하나와 다음 작업부터 적용할 행동 하나를 붙인다.
- **증상:** 하네스 전환 횟수가 많을수록 좋다고 결론낸다. → **원인:** 독립성의 이득과 인수인계 비용을 비교하지 않았다. → **조치:** 실제 결함 발견 또는 품질 향상이 있었던 전환만 남기는 선택 규칙을 만든다.

## 워크샵 이후

이 리포를 팀 리포로 복사한 뒤 가장 먼저 `AGENTS.md`와 `.github/skills/`를 이식한다. 실제 코드베이스에서 즉시 효과가 가장 큰 자산은 모든 하네스가 공유하는 작업 규칙과 반복 가능한 skill이기 때문이다. 그다음 팀의 규모와 문제에 맞춰 [프레임워크 지형과 Wayfinder-lite](../reference/framework-landscape.md)에서 다음 분기에 도입할 프레임워크 하나를 고른다.
