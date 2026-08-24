---
name: handoff-brief
description: 다음 단계로 넘긴다, 핸드오프, 인계 요청이 나오면 커밋된 산출물과 검증 절차를 이슈에 게시한다
---

# Handoff Brief

## 절차

1. 방금 한 일을 다음 `## HANDOFF` 6필드 형식으로 요약한다.

```text
## HANDOFF
- from/to: <하네스>/<모델>  →  <하네스>/<모델>
- artifacts: <커밋된 레포 경로 목록. 채팅 인용 금지>
- done: <완료된 것>
- not done: <남은 것>
- decisions: <결정 이슈 링크>
- verify: <복붙 실행 가능한 명령>
- risks: <다음 사람이 밟을 지뢰>
```

2. `artifacts`에는 커밋된 레포 경로만 적는다. 채팅 인용은 금지한다.
3. `verify`에는 복사해 바로 실행할 수 있는 명령만 적는다.
4. `/tmp/handoff.md`에 저장한다.
5. 다음 명령으로 이슈 코멘트에 게시한다.

```bash
./scripts/handoff.sh <issue> /tmp/handoff.md
```

6. 게시된 코멘트 URL을 사용자에게 보고한다.

## 필수 자체 점검

`artifacts`의 모든 경로는 `git ls-files --error-unmatch <path>`를 만족해야 한다.

```bash
for p in seed/src/policy.ts seed/tests/policy.test.ts; do
  git ls-files --error-unmatch "$p" >/dev/null || echo "미커밋 파일: $p"
done
```

커밋되지 않은 파일을 인계하는 것이 이 워크숍에서 가장 흔한 실패다.

## 금지

- 커밋되지 않은 파일, 채팅 내용, 로컬 전용 경로를 `artifacts`에 적지 않는다.
- 실행할 수 없는 설명문을 `verify`에 적지 않는다.
- 코멘트 URL 확인 없이 인계를 완료했다고 보고하지 않는다.

