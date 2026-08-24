# 하네스 간 인계 계약

하네스를 바꾸면 대화가 아니라 저장소가 작업의 기준점이 된다. 다음 형식을 GitHub Issue나 인계 문서에 그대로 사용한다.

```markdown
## HANDOFF
- from/to: <하네스>/<모델>  →  <하네스>/<모델>
- artifacts: <커밋된 레포 경로 목록. 채팅 인용 금지>
- done: <완료된 것>
- not done: <남은 것>
- decisions: <결정 이슈 링크>
- verify: <복붙 실행 가능한 명령>
- risks: <다음 사람이 밟을 지뢰>
```

## 필드가 존재하는 이유

- `from/to`: 송신자와 수신자의 하네스·모델 축이 실제로 달라졌는지 확인한다.
- `artifacts`: 하네스가 바뀐 뒤에는 채팅 기록을 신뢰할 수 없으며, 세션을 넘어 전달되는 것은 커밋된 파일뿐이다.
- `done`: 수신자가 이미 끝난 작업을 반복하지 않게 한다.
- `not done`: 남은 범위를 명시해 “거의 완료” 같은 모호한 상태를 없앤다.
- `decisions`: 구현의 근거와 열린 질문을 추적 가능한 Issue에 연결한다.
- `verify`: 수신자가 첫 5분 안에 현재 상태가 정상인지 확인할 수 있게 한다.
- `risks`: 무엇이 이미 실패했는지는 송신자만 알고 있으므로, 같은 실패를 반복하지 않게 한다.

## 나쁜 예와 좋은 예

| 필드 | 나쁜 예 | 좋은 예 |
|---|---|---|
| `artifacts` | `artifacts: 아까 만든 라우터` | `artifacts: seed/src/policy.ts, seed/tests/policy.test.ts (커밋 a1b2c3d)` |
| `done` | `done: 거의 다 함` | `done: 정책 평가 함수와 경계값 테스트 구현` |
| `verify` | `verify: 테스트해 보기` | `verify: npm test -- seed/tests/policy.test.ts` |
| `risks` | `risks: 없음` | `risks: Node.js 20 미만에서는 테스트 러너가 시작되지 않음` |

나쁜 예는 채팅 문맥과 기억에 의존한다. 좋은 예는 새 세션의 수신자가 파일, 커밋, 명령만으로 상태를 재구성할 수 있다.

## 인계 전 자체 점검

`artifacts`에 적은 모든 경로는 Git이 추적하는 커밋 대상이어야 한다. 각 경로에 다음 명령을 실행하고 하나라도 실패하면 인계하지 않는다.

```bash
git ls-files --error-unmatch <path>
```
