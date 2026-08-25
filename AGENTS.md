# 에이전트 작업 규칙

이 파일이 모든 하네스의 정본입니다.

## 과제

`seed/`와 `agent-seed/` 중 한 트랙에서 지역별 프라이버시 규제에 따라
외부 추론 또는 웹검색을 제한하고 텔레메트리 옵트아웃을 지원합니다.

## 절대 규칙

1. `seed/package.json`에 의존성을 추가하지 않습니다.
2. 기존 테스트를 삭제하지 않습니다. `known gap` 테스트는 동작을 고칠 때
   기대값을 뒤집고 이유를 커밋 메시지에 기록합니다.
3. 결정은 GitHub Issue, `CONTEXT.md`, ADR에 남깁니다. 채팅만 믿지 않습니다.
4. 검증자는 구현 코드를 고치지 않고 결함 Issue를 만듭니다.
5. 고객사를 식별할 수 있는 이름과 `git push --force`를 금지합니다.

## Main development flow

Matt Pocock 스킬이 개발 워크플로입니다.

1. `/grill-with-docs`
2. `/to-spec`
3. `/to-tickets`
4. 티켓별 새 세션에서 `/implement`
5. 독립 세션에서 `/code-review main`과 UAT

## Runtime selection

| 역할 | Agent runtime | Model | 스킬 |
| --- | --- | --- | --- |
| 발견·아키텍처·기획 | GHCP 안의 Claude agent | Claude Opus 5 | `grill-with-docs`, `domain-modeling`, `codebase-design`, `to-spec`, `to-tickets` |
| 구현 | GHCP native | GPT-5.6 Sol | `implement`, `tdd` |
| 독립 검증 | GHCP native 새 세션 | Claude Sonnet 5 | `code-review` + UAT |

호스트, agent runtime, model은 서로 다른 축입니다.

## Durable state

- `CONTEXT.md`: 공유 용어
- `docs/adr/`: 되돌리기 어려운 결정
- `docs/agents/`: tracker와 domain 설정
- GitHub Issues: spec, tracer-bullet ticket, blocking edge, 결함
- Git commit: 구현 산출물

## Verification commands

```bash
(cd seed && npm test)
(cd agent-seed && uv run --frozen pytest -q)
./scripts/check-repo.sh
```

## Session boundaries

`grill-with-docs`부터 `to-tickets`까지는 한 설계 세션을 유지합니다. 구현은
티켓 하나마다 새 세션에서 하고, 검증은 구현 문맥을 상속하지 않는 새
세션에서 시작합니다.

`seed/src/router.ts`와 `agent-seed/`의 알려진 설계 부채는 참가자의
교보재이므로 워크샵 전에 고치지 않습니다.
