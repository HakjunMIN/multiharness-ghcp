# 최소 경로와 복구 checkpoint

## Day 1

- runway health, API test, web test/build
- `docs/work/<feature>/discovery.md`, `CONTEXT.md`와 필요한 ADR
- local spec과 ready tracer-bullet ticket
- API -> Foundry IQ -> structured citations commit
- 다음 세션의 첫 verify를 포함한 `HANDOFF`

## Day 2

- inherited chat 없이 cold restore
- no-evidence behavior improvement
- 독립 review, UAT report, 필요한 local defect/test
- spec, tickets, ADR, commits, UAT를 연결한 PR

## 복구

설계 대화를 잃으면 commit된 domain docs와 local work items에서 Claude/Opus
세션을 시작합니다. 설계 대화는 원래 다음 세션으로 이어지지 않으므로,
복구 가능성은 discovery 문서와 spec의 품질로 결정됩니다. Day 2 cold-start가
20분 안에 안 되면 checkpoint를 사용하고 어떤 durable artifact가 부족했는지
기록합니다. 검증이 밀리면 결함을 고치지 말고 재현 가능한 local defect까지
완료합니다.

checkpoint는 participant bundle에 넣지 않습니다. 강사는 필요할 때만 별도 recovery archive를 만듭니다.

```bash
tar -C docs/instructor/checkpoint -czf workshop-checkpoint.tar.gz app
```

archive는 workshop의 보안 전달 채널로 해당 참가자에게만 제공합니다. 참가자는 workspace 밖에 풀고 [Lab 4](../labs/lab4-cold-start.md)의 `WORKSHOP_CHECKPOINT_DIR`로 그 경로를 지정합니다.
