# 에이전트 작업 규칙

이 파일이 **정본**입니다. Copilot · Claude · Codex 어느 하네스에서 작업하든 여기 적힌 규칙을 따릅니다.

## 이 리포는 무엇인가

멀티 하네스 · 멀티 모델 AI 개발 워크샵의 실습 리포입니다. `seed/`는 온디바이스 AI 기능 게이팅 SDK이며, 워크샵 참가자가 하나의 과제를 여러 하네스와 모델에 걸쳐 인수인계하며 완성하는 출발점입니다.

과제는 하나입니다: **지역별 프라이버시 규제에 따라 추론 라우팅을 강제하고, 텔레메트리 옵트아웃을 지원하라.**

## 절대 규칙

1. **의존성을 추가하지 않습니다.** `seed/package.json`에 `dependencies` · `devDependencies`를 넣지 마세요. `npm install` 없이 동작해야 합니다.
2. **`seed/tests/`의 기존 테스트를 삭제하지 않습니다.** 동작이 바뀌면 테스트를 지우는 대신 **기대값을 뒤집고, 그 이유를 커밋 메시지에 적습니다.** 이름이 `known gap:` 으로 시작하는 테스트가 그 대상입니다.
3. **결정은 이슈에 기록합니다.** 채팅에만 남긴 결정은 하네스가 바뀌는 순간 사라집니다.
4. **각 단계는 검증으로 끝납니다.** 아래 두 명령이 통과하지 않은 상태로 인계하지 마세요.

## 검증 명령

```bash
cd seed && npm test && cd ..
./scripts/check-repo.sh
```

환경 점검:

```bash
./scripts/preflight.sh
```

## 인수인계 규약

작업을 다음 하네스로 넘길 때는 `## HANDOFF` 브리프를 이슈 코멘트로 게시합니다. 형식과 각 필드의 존재 이유는 `docs/reference/handoff-contract.md`에 있습니다.

```
## HANDOFF
- from/to: <하네스>/<모델>  →  <하네스>/<모델>
- artifacts: <커밋된 레포 경로 목록. 채팅 인용 금지>
- done: <완료된 것>
- not done: <남은 것>
- decisions: <결정 이슈 링크>
- verify: <복붙 실행 가능한 명령>
- risks: <다음 사람이 밟을 지뢰>
```

게시는 `./scripts/handoff.sh <이슈번호> <브리프파일>`로 합니다. 이 스크립트는 필수 필드가 빠진 브리프를 거부합니다.

`artifacts`에 적은 모든 경로는 커밋되어 있어야 합니다:

```bash
git ls-files --error-unmatch <path>
```

## 이슈 규약

맵 이슈 하나 아래에 결정 · 작업 · 검증 자식 이슈를 답니다. 라벨 · 계층 · frontier 정의 · GraphQL 호출 예시는 `docs/reference/issue-conventions.md`에 있습니다.

- 착수 전에 **자신을 assignee로 지정해 클레임**합니다. assignee가 곧 락입니다.
- 다음에 할 일은 `./scripts/frontier.sh <맵이슈번호>`로 찾습니다.
- **이슈 하나 = 세션 하나.** 이슈가 바뀌면 세션을 새로 엽니다.

## 하지 말 것

- `seed/src/router.ts`의 설계 부채를 워크샵 진행 전에 미리 고치지 마세요. 그 부채는 Lab 1의 교보재입니다.
- 고객사를 식별할 수 있는 정보를 쓰지 마세요. `./scripts/check-repo.sh`가 이를 검사합니다.
- `git push --force`를 쓰지 마세요.
- 검증 단계에서 구현 코드를 고치지 마세요. 결함은 이슈로 돌려보냅니다.
