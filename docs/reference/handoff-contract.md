# 세션 간 인계 계약

이 과정의 역할은 모두 fresh session입니다. VS Code에서 Session Target을
바꾸는 handoff는 **full conversation history**와 누적 context를 새 harness로
전달하므로 사용하지 않습니다. 세션 사이의 문맥은 커밋된 durable artifact로만
전달하며, 그 artifact가 fresh session 복구의 기준점입니다.

발견은 discovery 문서를, prototype은 `prototype.md`, 정적 참조와 throwaway
branch ref를, 아키텍처·기획은 spec과 tickets를 남깁니다. 이 단계 전환은 해당
artifact와 `CONTEXT.md`, ADR로 복구합니다.

구현 세션은 여기에 더해 저장소 루트의 `HANDOFF`를 남깁니다. 구현 상태는
문서에 흩어져 있어 다음 세션이 어디서부터 검증해야 하는지 알 수 없기
때문입니다. 독립 검증은 구현 세션과 분리된 **fresh verifier** 세션에서
시작하며 구현 세션의 대화를 전달받지 않습니다. 권장 runtime은 Codex지만 다른
조합도 사용할 수 있습니다. 복사해 쓸 골격은
[HANDOFF 템플릿](../templates/handoff.md)에 있고, `HANDOFF`를 만들 때는 아래
7개 필드를 자체 점검합니다.

```markdown
## HANDOFF
- from/to: <실제로 사용한 호스트>/<하네스>/<모델>/<스킬> → <다음 fresh session의 권장 조합>
- artifacts: commit: <구현 SHA>; files: <변경된 개별 파일 경로. 채팅 인용 금지>
- done: <완료된 것>
- not done: <남은 것>
- decisions: <local spec/ADR 경로>
- verify: <복붙 실행 가능한 명령> (expected: green | red - 이유)
- risks: <다음 사람이 밟을 지뢰>
```

## 필드가 존재하는 이유

- `from/to`: 실제로 사용한 host, harness, model, skill과 다음 역할의 예정 조합을
  기록해 세션 분리와 재현 가능성을 확인한다.
- `artifacts`: fresh session이 채팅 없이 상태를 재구성하는 입력이다.
- `done`: 수신자가 이미 끝난 작업을 반복하지 않게 한다.
- `not done`: 남은 범위를 명시해 “거의 완료” 같은 모호한 상태를 없앤다.
- `decisions`: 구현의 근거와 열린 질문을 추적 가능한 local work item에 연결한다.
- `verify`: 수신자가 첫 5분 안에 현재 상태가 **기대와 일치하는지** 확인할 수
  있게 한다. 이 과정은 contract-first이므로 인수 시나리오 세션은 의도적으로
  실패하는 테스트를 남긴다. 따라서 `verify`는 명령만으로 부족하고 기대 결과를
  함께 적어야 한다. `expected: red`면 red가 정상이고, green이 나오면 시나리오가
  약하다는 신호다.
- `risks`: 무엇이 이미 실패했는지는 송신자만 알고 있으므로, 같은 실패를 반복하지 않게 한다.

## 나쁜 예와 좋은 예

| 필드 | 나쁜 예 | 좋은 예 |
|---|---|---|
| `artifacts` | `artifacts: 아까 만든 API` | `artifacts: commit: 9f2c1ab; files: app/api/src/consult/main.py, app/api/tests/test_consult.py` |
| `done` | `done: 거의 다 함` | `done: 근거 없음 처리와 경계값 테스트 구현` |
| `verify` | `verify: 테스트해 보기` | `verify: cd app/api && uv run --frozen pytest -q` (expected: green) |
| `verify` | `verify: npm run test:browser` | `verify: cd app/web && npm run test:browser` (expected: red - frontend 미구현, 5개 시나리오 모두 실패) |
| `risks` | `risks: 없음` | `risks: live smoke는 개인 APIM key가 있어야 실행 가능` |

나쁜 예는 채팅 문맥과 기억에 의존한다. 좋은 예는 새 세션의 수신자가 파일, 커밋, 명령만으로 상태를 재구성할 수 있다.

## 인계 전 자체 점검

1. production code, test, ticket 상태 변경을 검증하고 하나의 구현 commit으로 남깁니다.
2. `git rev-parse --short HEAD`로 구현 commit을 확정합니다.
3. 루트 `HANDOFF`를 위 7개 필드로 작성하거나 교체합니다. `verify`에는 복사 가능한
   명령과 `expected: green` 또는 `expected: red - 이유`를 적습니다.
4. `HANDOFF`만 별도 documentation commit으로 남깁니다. 구현 commit SHA를
   가리키기 위해 두 commit을 분리하고, 이전 인계는 git history에 보존합니다.
5. 다음 fresh session은 artifact와 commit이 실제 상태와 일치하는지 확인하고
   `verify`를 가장 먼저 실행합니다. 결과가 기대와 다르면 그 차이부터 해소합니다.

credential, 질문·답변 원문, provider payload는 구현 commit이나 `HANDOFF`에
포함하지 않습니다.

`artifacts`에서 `commit`과 `files`를 구분합니다. 구현 SHA는
`git rev-parse --verify <sha>^{commit}`으로 확인하며 파일 경로로 검사하지 않습니다.
`files`에는 디렉터리가 아닌 개별 파일을 적습니다. 각 파일이 현재 커밋에 존재하고
staged/unstaged 변경이 없는지 다음 명령으로 확인합니다.

```bash
git ls-tree -r --name-only HEAD -- <path> | grep -Fx <path>
git diff --quiet HEAD -- <path>
```
