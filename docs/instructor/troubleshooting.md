# Troubleshooting

| 증상 | 조치 |
| --- | --- |
| Matt skill이 `/skills`에 없다 | project scope와 GitHub Copilot 대상을 확인하고 `npx skills update` 후 새 세션을 연다 |
| Claude agent가 없다 | 계정 정책을 확인하고 강사에게 알린다. native로 대체하지 않는다 |
| 필수 model이 없다 | Lab 0에서 중단하고 entitlement를 확인한다 |
| 설계 대화를 일찍 지웠다 | `CONTEXT.md`, ADR, Issues를 읽는 새 Claude/Opus 세션을 연다 |
| update가 로컬 skill과 충돌한다 | diff를 보존하고 upstream과 로컬 의도를 비교한다 |
| verifier가 구현 문맥을 안다 | `/new` 후 Sonnet 5를 선택하고 spec부터 다시 읽는다 |
