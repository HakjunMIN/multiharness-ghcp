# Multi-harness AI Development Workshop

Matt Pocock의 agent skills를 직접 설치해 아우터 하네스를 조립하고, 같은
과제를 세 agent/model 조합으로 설계·구현·검증하는 핸즈온 리포입니다.

## 시작

Lab 0에서 다음 순서로 프로젝트 스킬을 준비합니다.

```text
!DISABLE_TELEMETRY=1 npx skills@latest add mattpocock/skills --agent github-copilot --copy
!DISABLE_TELEMETRY=1 npx skills update
/skills
/setup-matt-pocock-skills
```

필수 목록은 `scripts/required-matt-skills.txt`에 있습니다.

## Main flow

```text
/grill-with-docs → /to-spec → /to-tickets → /implement → /code-review main
```

| 역할 | Agent runtime | Model |
| --- | --- | --- |
| 발견·아키텍처·기획 | GHCP Claude agent | Claude Opus 5 |
| 구현 | GHCP native | GPT-5.6 Sol |
| 독립 검증 | GHCP native 새 세션 | Claude Sonnet 5 |

자세한 흐름은 [개발 워크플로](docs/reference/workflow.md), 조합의 의미는
[모델·하네스 매트릭스](docs/reference/model-harness-matrix.md)를 봅니다.

## Sample tracks

| 트랙 | 코드 | 검증 |
| --- | --- | --- |
| `ts` | `seed/` | `(cd seed && npm test)` |
| `agent` | `agent-seed/` | `(cd agent-seed && uv run --frozen pytest -q)` |

두 트랙 모두 지역별 프라이버시 강제와 텔레메트리 옵트아웃을 다룹니다.

## Labs

1. [Harness bootstrap](docs/labs/lab0-preflight.md)
2. [Discovery](docs/labs/lab1-discovery.md)
3. [Specification and tickets](docs/labs/lab2-architecture.md)
4. [Implementation](docs/labs/lab3-implementation.md)
5. [Independent verification](docs/labs/lab4-verification.md)
6. [Runtime comparison](docs/labs/lab5-multiruntime.md)
7. [Integration](docs/labs/lab6-integration.md)
