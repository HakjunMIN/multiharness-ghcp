# Lab 4 — 독립 검증 (60분)

## Runtime card

```text
Host: GitHub Copilot CLI
Agent runtime: native coding agent
Model: Claude Sonnet 5
Context: fresh session, spec과 acceptance criteria를 코드보다 먼저 읽기
```

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
