# Greenfield Product Consultation Agent Workshop

Microsoft Agent Framework Python backend와 React frontend로 공개 웹 근거 기반 제품 상담 app을 만드는 2일 hands-on workshop입니다. Foundry IQ retrieval과 model endpoint는 instructor APIM 뒤에 있으며, 참가자는 origin credentials를 받지 않습니다.

## 범위

- `core`: API에서 질문을 받아 answer와 structured citations를 반환하고 region domain policy와 telemetry opt-out을 적용
- `full`: core 전체에 React 상담 UI와 citation/error states 추가

full은 별도 출발점이 아니라 core의 strict superset입니다.

## 시작

```bash
./scripts/preflight.sh
cp .env.example .env
./scripts/dev.sh
```

강사가 전달한 다섯 runtime 값은 `.env`에만 둡니다. 커밋된 예시는 non-routable입니다.

## Main flow

```text
/grill-with-docs -> /to-spec -> /to-tickets -> /implement -> /code-review main
```

| 역할 | Agent runtime | Model |
| --- | --- | --- |
| 발견, 아키텍처, 기획 | GHCP Claude agent | Claude Opus 5 |
| 구현 | GHCP native | GPT-5.6 Sol |
| 독립 검증 | GHCP native 새 세션 | Claude Sonnet 5 |

자세한 흐름은 [개발 워크플로](docs/reference/workflow.md), 조합의 의미는 [모델 하네스 매트릭스](docs/reference/model-harness-matrix.md)를 봅니다.

## Labs

1. [Runway preflight](docs/labs/lab0-preflight.md)
2. [Discovery](docs/labs/lab1-discovery.md)
3. [Spec and tickets](docs/labs/lab2-spec-tickets.md)
4. [Tracer bullet](docs/labs/lab3-tracer-bullet.md)
5. [Cold-start recovery](docs/labs/lab4-cold-start.md)
6. [Policy and full improvement](docs/labs/lab5-improvement.md)
7. [Independent verification](docs/labs/lab6-verification.md)
8. [Runtime comparison](docs/labs/lab7-runtime-comparison.md)
9. [Integration](docs/labs/lab8-integration.md)

## 검증

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/web && npm test && npm run build)
./scripts/check-repo.sh
```
