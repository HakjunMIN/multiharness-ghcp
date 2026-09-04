# HANDOFF 템플릿

저장소 루트의 `HANDOFF` 파일을 이 골격으로 작성합니다. 필드 정의와 자체
점검 절차는 [세션 간 인계 계약](../reference/handoff-contract.md)을 따릅니다.

구현 commit을 먼저 남기고, `HANDOFF`는 그 commit SHA를 가리키는 별도의
documentation commit으로 남깁니다.

```markdown
## HANDOFF
- from/to: <실제로 사용한 호스트>/<하네스>/<모델>/<스킬> → <다음 fresh session의 권장 조합>
- artifacts: <구현 commit SHA와 변경된 개별 파일 경로. 디렉터리 금지>
- done: <완료한 ticket과 관찰 가능한 동작>
- not done: <다음 ticket 또는 남은 범위>
- decisions: <spec, ticket, CONTEXT.md, ADR 경로>
- verify: <복사 가능한 명령> (expected: green | red - 이유)
- risks: <실패한 시도, 외부 의존성, e2e gate 등 남은 위험>
```

## 작성 예시

```markdown
## HANDOFF
- from/to: VS Code/Copilot/GPT-5.6 Sol/implement → VS Code/Copilot/GPT-5.6 Sol/implement
- artifacts: 9f2c1ab, app/api/src/consult/main.py, app/api/tests/test_consult.py, docs/work/consult/tickets/02-consult-endpoint.md
- done: 02-consult-endpoint. POST /api/consult가 answer와 citations envelope를 반환한다
- not done: 03-browser-acceptance. React UI는 아직 runway 상태다
- decisions: docs/work/consult/spec.md, docs/adr/0002-retrieval-boundary.md
- verify: (cd app/api && uv run --frozen pytest -q) (expected: green)
- verify: (cd app/web && npm run test:browser) (expected: red - frontend 미구현)
- risks: 실제 APIM smoke는 운영자 gate와 개인 .env가 있어야 실행 가능
```

credential, 질문·답변 원문과 provider payload는 `HANDOFF`에 포함하지 않습니다.
