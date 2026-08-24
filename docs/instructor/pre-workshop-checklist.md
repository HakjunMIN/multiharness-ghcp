# 워크샵 전날 체크리스트

아래 항목은 **행사 전날까지** 완료한다. 특히 조직 설정과 권한은 현장에서 즉시 해결하기 어려우므로 참가자 안내 전에 조직 관리자가 실제 실습 계정으로 확인한다.

| 항목 | 담당 | 실패 시 영향 |
|---|---|---|
| 조직에서 서드파티(파트너) 코딩 에이전트 활성화 | 조직 관리자 | Lab 4 경로 A 불가 |
| 클라우드 샌드박스 접근 권한 | 조직 관리자 | Lab 5 부분 불가 |
| 참가자별 실습 리포 생성 권한 | 조직 관리자 | Lab 0 전면 실패 |
| VS Code 최신 안정 버전과 AI 기능 로그인 | 참가자 | Claude/Codex session 선택 불가 |
| GitHub Copilot CLI 설치와 로그인 | 참가자 | Lab 3·경로 B 불가 |
| Claude Opus 5 모델 entitlement 확인 | 참가자 / 조직 관리자 | Lab 1~2 불가 |
| Codex 또는 GPT-5.6 Terra 검증 경로 선택 | 강사 | Lab 4 불가 |
| Node.js 22.18 이상 사전 설치 | 참가자 | Lab 0 지연 |
| `gh auth login` 사전 완료 | 참가자 | Lab 0 지연 |
| [참고 자료](../reference/sources.md)의 모델 매트릭스 재확인 — 모델 가용성은 자주 바뀐다 | 강사 | 랩 지시가 틀림 |
| 사내 프록시에서 GitHub API 접근 확인 | 참가자 / IT | 전면 실패 |
| reference checkpoint를 외부 강사 전용 위치에 복사하고 participant bundle에서 제외 확인 | 강사 | 정답 사전 노출 또는 복구 실패 |

## 전날 확인 명령

참가자는 실습에 사용할 network에서 다음을 실행한 결과를 강사에게 전달한다.

```bash
node --version
gh auth status
gh api user --jq '.login'
copilot --version
```

강사는 조직 정책 화면에서 partner coding agent와 cloud sandbox access를 확인하고, 참가자와 같은 권한의 시험 계정으로 실습 repo 생성까지 수행한다.

## 실제 쓰기 권한 smoke test

강사는 **폐기 가능한 전용 리포**에서 라벨 생성, Issue 쓰기, `addSubIssue`, frontier, HANDOFF 게시를 실제로 확인한다. 운영 리포에는 실행하지 않는다.

```bash
WORKSHOP_SMOKE_REPO=owner/disposable-workshop-smoke \
  ./scripts/instructor-smoke-test.sh --confirm
```

참가자는 VS Code에서 Claude/Claude Opus 5와 선택한 검증 경로를 각각 새 세션으로 열어 본 뒤 strict 프리플라이트를 실행한다.

```bash
export WORKSHOP_CLAUDE_OPUS5_CONFIRMED=1
export WORKSHOP_VERIFY_ROUTE=copilot-terra  # 또는 codex
export WORKSHOP_VERIFY_MODEL_CONFIRMED=1
./scripts/preflight.sh --strict
```
