# Lab 3 — 티켓 구현 (90분)

## Runtime card

```text
Host: GitHub Copilot CLI
Agent runtime: native coding agent
Model: GPT-5.6 Sol
Context: ticket 하나마다 fresh session
```

frontier의 `ready-for-agent` ticket 하나를 고릅니다.

```text
/new
/model GPT-5.6 Sol
/implement #42
```

`#42`는 실제 ticket 번호로 바꿉니다. `implement`는 승인된 seam에서
`tdd`의 red-green loop를 수행하고, focused checks와 전체 suite를 거쳐
구현 시점 `code-review` 후 커밋합니다.

트랙 검증과 리포 게이트도 에이전트가 실행하게 합니다.

```bash
(cd seed && npm test)
(cd agent-seed && uv run --frozen pytest -q)
./scripts/check-repo.sh
```

한 ticket에 red-green 근거, 전체 테스트, review, commit이 모두 있어야
닫습니다. 다음 ticket은 `/new`로 시작합니다. 설계가 모호하면 코딩으로
추측하지 않고 spec/ticket으로 되돌립니다.
