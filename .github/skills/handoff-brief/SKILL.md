---
name: handoff-brief
description: 다음 단계로 넘긴다, 핸드오프, 인계 요청이 나오면 커밋된 산출물과 검증 절차를 이슈에 게시한다
---

# Handoff Brief

## 절차

1. 방금 한 일을 다음 `## HANDOFF` 7필드 형식으로 요약한다.

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

2. `artifacts`에는 커밋된 개별 파일 경로만 적는다. 디렉터리와 채팅 인용은 금지한다.
3. `verify`에는 복사해 바로 실행할 수 있는 명령만 적는다.
4. `/tmp/handoff.md`에 저장한다. 모든 필드가 비어 있지 않고 템플릿 표기가 남지 않았는지 확인한다.
5. 다음 명령으로 이슈 코멘트에 게시한다.

```bash
./scripts/handoff.sh <issue> /tmp/handoff.md
```

6. 게시된 코멘트 URL을 사용자에게 보고한다.

## 필수 자체 점검

`artifacts`의 모든 경로는 현재 `HEAD`에 존재하고 커밋 이후 변경이 없어야 한다.

```bash
for p in seed/src/policy.ts seed/tests/policy.test.ts; do
  git ls-tree -r --name-only HEAD -- "$p" | grep -Fxq "$p" ||
    echo "현재 커밋에 없는 파일: $p"
  git diff --quiet HEAD -- "$p" || echo "커밋 이후 변경된 파일: $p"
done
```

커밋되지 않은 파일을 인계하는 것이 이 워크숍에서 가장 흔한 실패다.

`done`, `not done`, `decisions`, `risks`도 필수다. 해당 사항이 없으면 왜 없는지 구체적으로 기록하며 빈 값이나 `없음` 한 단어로 통과시키지 않는다.

## 금지

- 커밋되지 않은 파일, 채팅 내용, 로컬 전용 경로를 `artifacts`에 적지 않는다.
- 실행할 수 없는 설명문을 `verify`에 적지 않는다.
- 코멘트 URL 확인 없이 인계를 완료했다고 보고하지 않는다.
