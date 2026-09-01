# Lab 4 - cold-start 복구

## 이 랩에서 배우는 것

- 채팅이 없는 새 세션에서 durable state만으로 작업을 복구한다.
- `HANDOFF`의 첫 검증 명령으로 이전 결과를 확인한다.
- 복구 실패를 문서 품질의 피드백으로 사용한다.

## 시작

New Chat으로 이전 대화를 상속하지 않는 fresh session을 엽니다. 읽을 수 있는
것은 commit된 `CONTEXT.md`, ADR, local work items, commit history,
`HANDOFF`뿐입니다. 이전 채팅 요약을 붙이지 않습니다.

`HANDOFF`의 `verify` 명령을 가장 먼저 실행한다. 현재 ticket, 완료 commit, 남은 위험을 실제 repo와 대조하고 20분 안에 다음 작업을 설명한다.

복구할 수 없으면 다음을 실행한다.

```bash
mkdir -p "$HOME/.workshop-checkpoint"
tar -xzf /path/to/workshop-checkpoint.tar.gz \
	-C "$HOME/.workshop-checkpoint"
WORKSHOP_CHECKPOINT_DIR="$HOME/.workshop-checkpoint" \
	./scripts/restore-checkpoint.sh --confirm
```

checkpoint archive는 participant bundle에 포함되지 않습니다. API와 React 상담
slice를 모두 포함한 운영자 checkpoint만 사용합니다. 20분 recovery gate를 넘긴
경우 운영자가 별도 보안 채널로 전달한 archive를 복원합니다.

어떤 durable artifact가 부족했는지 local defect 또는 UAT note에 기록합니다.

## 종료 조건

- 새 세션이 이전 채팅 없이 현재 상태를 설명한다.
- `HANDOFF`의 verify가 실행되고 결과가 기록됐다.
- 다음 ticket 또는 복구 checkpoint로 안전하게 이동했다.

## 막힐 때

- 구현 파일부터 추측해 읽지 말고 `HANDOFF`, local ticket, ADR 순서를 지킨다.
- 20분이 지나면 checkpoint를 사용하고 누락된 artifact를 기록한다.
