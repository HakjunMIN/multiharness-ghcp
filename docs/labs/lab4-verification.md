# Lab 4 — 검증과 수락 테스트 (60분)
> 검증은 구현과 최소 한 축 이상 다른 조합에서, 반드시 새 세션으로 한다.

## 이 랩에서 배우는 것

- 구현자의 대화 맥락 없이 Issue와 인수인계 브리프만으로 수락 기준을 복원한다.
- 구현을 읽기 전에 요구사항 기반 UAT를 설계해 확증 편향을 줄인다.
- 실패를 직접 고치지 않고 재현 가능한 `wf:verify` Issue로 구현 세션에 돌려보낸다.

검증자는 인수인계 브리프만 보고 시작한다. 브리프가 부실하면 여기서 막힌다. 그것이 이 랩이 가르치는 것이다. 부족한 정보를 구현자에게 구두로 묻지 말고, 어느 필드 때문에 막혔는지 기록해 Lab 6 회고의 입력으로 남긴다.

## 하네스 / 모델

| 경로 | 하네스 / 모델 |
|---|---|
| A 또는 B | **A:** Codex + Codex가 실제로 제공하는 모델 **또는 B:** Copilot + `GPT-5.6 Terra` + 새 세션 |

환경에 따라 한 경로를 고른다.

- **경로 A:** 파트너 Codex 하네스에서 새 세션을 열고, 그 하네스가 실제로 제공하는 모델을 선택한다.
- **경로 B:** Copilot에서 `copilot --model gpt-5.6-terra`로 새 세션을 연다.

선택 이유는 [모델과 하네스 호환성](../reference/model-harness-matrix.md)에 있다. **“Codex 하네스 + GPT-5.6 Terra” 조합은 파트너 클라우드 하네스에 존재하지 않는다.** Codex를 선택했다면 Codex가 제공하는 모델을 쓰고, `GPT-5.6 Terra`를 선택했다면 Copilot 경로 B를 쓴다.

## 시작 전 상태

모든 `wf:task` Issue가 닫혀 있고, 구현 세션에서 `cd seed && npm test`가 통과하며, map Issue에 검증자가 읽을 수 있는 `## HANDOFF` 코멘트가 게시되어 있어야 한다.

## 단계

1. **기존 구현 세션을 완전히 종료하고 새 검증 세션을 연다.**

   경로 A는 Codex 하네스 UI에서 **New session**을 선택한다. 경로 B는 구현 세션을 종료한 별도 터미널에서 다음 명령을 실행한다.

   ```bash
   cd /path/to/your/workshop-repo
   copilot --model gpt-5.6-terra
   ```

   새 세션에서 verifier profile을 선택한다.

   ```text
   /agent verifier
   ```

2. **구현 파일을 열기 전에 결정·작업 Issue에서 수락 기준을 추출한다.**

   map, decision, task Issue 번호를 인수인계 브리프에서 찾은 뒤 조회한다. 이 단계가 끝날 때까지 `seed/src/`를 읽지 않는다.

   ```bash
   MAP_ISSUE=<map-issue-number>
   DECISION_ISSUE=<decision-issue-number>
   TASK_ISSUE=<task-issue-number>
   gh issue view "$MAP_ISSUE" --comments
   gh issue view "$DECISION_ISSUE" --comments
   gh issue view "$TASK_ISSUE" --comments
   ```

   지역별 cloud 전송 허용·차단, on-device fallback, telemetry opt-out 각각에 대해 기대 결과와 실행 방법을 먼저 적는다.

3. **`uat-verify` skill로 독립 검증을 실행한다.**

   ```text
   /uat-verify
   ```

   skill에 map Issue 번호와 추출한 기준을 제공하고, 아래 기본 검증도 실행한다.

   ```bash
   cd seed && npm test && cd ..
   ./scripts/check-repo.sh
   ```

   각 기준마다 명령, 실제 출력, 통과 또는 실패를 기록한다. 그 뒤에만 구현을 읽어 실패 원인을 좁힌다.

4. **실패마다 `wf:verify` Issue를 발행한다.**

   다음 파일에는 실패한 기준 하나만 담고, 실제 재현 명령과 기대·실제 결과를 넣는다.

   ```bash
   cat > verification-failure.md <<'EOF'
   ## 실패한 수락 기준
   <decision 또는 task Issue의 기준>

   ## 재현 절차
   <복사해 실행할 수 있는 명령>

   ## 기대 결과
   <요구사항이 정한 결과>

   ## 실제 결과
   <출력 발췌>
   EOF

   gh issue create \
     --title "검증 실패: <acceptance-criterion>" \
     --label "wf:verify,phase:verification,harness:codex" \
     --body-file verification-failure.md
   ```

   경로 B라면 마지막 label을 `harness:copilot`로 바꾼다. 검증 세션에서는 코드를 수정하지 않는다.

5. **결과와 다음 행동을 인수인계 브리프로 게시한다.**

   ```bash
   MAP_ISSUE=<map-issue-number>
   cat > handoff-verification.md <<'EOF'
   ## HANDOFF
   - from/to: Codex/<selected-model>  →  Copilot/GPT-5.6 Sol
   - artifacts: <검증 결과가 기록된 Issue와 커밋된 경로>
   - done: <통과한 수락 기준과 실행 근거>
   - not done: <실패한 기준과 wf:verify Issue>
   - decisions: <근거가 된 wf:decision Issue 링크>
   - verify: cd seed && npm test && cd .. && ./scripts/check-repo.sh
   - risks: <불명확한 브리프 필드 또는 미검증 경계 조건>
   EOF

   ./scripts/handoff.sh "$MAP_ISSUE" handoff-verification.md
   ```

   경로 B에서는 `from/to`의 출발점을 `Copilot/GPT-5.6 Terra`로 바꾼다. 실패가 있으면 새 구현 세션에서 해당 Issue를 클레임하고 수정한 뒤, 다시 새 검증 세션으로 돌아온다.

## 끝난 뒤 상태

모든 수락 기준에 명령 출력이 첨부된 통과 또는 실패 판정이 있고, 실패마다 재현 가능한 열린 `wf:verify` Issue가 있으며, map Issue에 다음 세션을 위한 `## HANDOFF` 코멘트가 게시되어 있어야 한다.

## 흔한 실패

- **증상:** 검증자가 결함을 발견하고 직접 고쳤다. → **원인:** 검증과 구현의 역할을 한 세션에서 섞었다. 그것은 검증이 아니다. → **조치:** 결함을 `wf:verify` Issue로 돌려보내고 새 구현 세션에서 고친다.
- **증상:** Codex에서 `GPT-5.6 Terra`를 찾을 수 없다. → **원인:** 파트너 Codex 하네스가 그 모델을 제공하지 않는다. → **조치:** Codex가 실제 제공하는 모델을 쓰거나 경로 B로 전환한다.
- **증상:** 테스트는 통과하지만 규제 정책의 기대 결과를 설명할 수 없다. → **원인:** 구현을 먼저 읽고 현재 동작을 수락 기준으로 삼았다. → **조치:** 새 세션을 열고 decision/task Issue에서 기준을 먼저 다시 추출한다.
- **증상:** 검증을 시작할 파일이나 명령을 찾지 못한다. → **원인:** 인수인계 브리프의 `artifacts`, `decisions`, `verify` 필드가 부실하다. → **조치:** 막힌 필드를 기록하고 브리프 보완을 `wf:verify` Issue로 요청한다.
