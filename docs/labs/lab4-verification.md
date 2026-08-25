# Lab 4 — 독립 검증 (50분)

## 이 랩에서 배우는 것

- 구현 문맥을 상속하지 않은 세션에서 수락 기준을 복원한다.
- 구현과 다른 모델로 Standards와 Spec 두 축을 나눠 검토한다.
- 검증자는 코드를 고치지 않고 재현 가능한 결함 Issue를 만든다.
- 자동 리뷰와 행동 검증(UAT)이 서로를 대체하지 못함을 확인한다.

## Runtime card

```text
Host: GitHub Copilot CLI
Agent runtime: native coding agent
Model: Claude Sonnet 5
Context: fresh session, spec과 acceptance criteria를 코드보다 먼저 읽기
```

## 시작 전 상태

- Lab 3의 구현 세션을 종료했다.
- 대상 ticket이 닫혔고 구현이 커밋됐다.
- 구현 diff를 읽기 전에 spec과 ticket을 먼저 읽는다.

## 두 축 review

```text
/new
/model Claude Sonnet 5
/code-review main
```

Matt `code-review`의 Standards와 Spec 결과를 분리해 기록합니다. 이는
Sol 구현 세션이 commit 전에 수행한 review와 별개의 독립 검증입니다.

## 행동 검증

선택한 트랙의 UAT를 실행하게 합니다.

```bash
node --disable-warning=ExperimentalWarning --test docs/uat/acceptance.test.ts
```

또는:

```bash
(cd agent-seed && uv run --frozen pytest ../docs/uat/acceptance_agent_test.py)
```

그 뒤 전체 sample suite와 `./scripts/check-repo.sh`를 실행하고
`docs/templates/uat-report.md`로 `docs/uat/report.md`를 작성합니다.

실패마다 기대값, 실제값, 재현 명령, Standards/Spec 축을 담은 GitHub
defect Issue를 만듭니다. 검증 세션에서는 구현 코드를 고치지 않습니다.

## 종료 조건

- `docs/uat/acceptance-matrix.md`의 모든 항목이 판정됐다.
- `docs/uat/report.md`가 작성됐다.
- 실패마다 재현 가능한 defect Issue가 있다.
- 검증 세션에서 구현 코드를 수정하지 않았다.

## 막힐 때

- 검증자가 구현 의도를 이미 안다면 문맥이 샌 것이므로 `/new`로 다시 시작한다.
- UAT가 전부 실패하면 먼저 트랙 선택과 실행 경로를 확인한다.
- 시간이 부족하면 defect를 고치지 말고 Issue 기록까지만 끝낸다.
