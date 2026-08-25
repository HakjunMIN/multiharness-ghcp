# Lab 3 — 티켓 구현 (75분)

## 이 랩에서 배우는 것

- 설계 대화 없이 ticket과 spec만으로 구현을 시작한다.
- `implement`가 `tdd`의 red-green loop와 구현 시점 review를 어떻게 강제하는지 본다.
- ticket마다 새 세션을 열어 문맥 오염을 막는다.
- 모호함을 만나면 코딩으로 추측하지 않고 spec으로 되돌린다.

## Runtime card

```text
Host: GitHub Copilot CLI
Agent runtime: native coding agent
Model: GPT-5.6 Sol
Context: ticket 하나마다 fresh session
```

## 시작 전 상태

- 승인된 spec Issue와 `ready-for-agent` ticket이 있다.
- Lab 1–2의 설계 세션을 종료했다.
- 기준선 테스트가 통과한다.

## 구현

frontier의 `ready-for-agent` ticket 하나를 고릅니다.

```text
/new
/model GPT-5.6 Sol
/implement #42
```

`#42`는 실제 ticket 번호로 바꿉니다. `implement`는 승인된 seam에서
`tdd`의 red-green loop를 수행하고, focused checks와 전체 suite를 거쳐
구현 시점 `code-review` 후 커밋합니다.

`known gap` 테스트의 기대값을 뒤집을 때는 이유를 커밋 메시지에 남깁니다.

트랙 검증과 리포 게이트도 에이전트가 실행하게 합니다.

```bash
(cd seed && npm test)
(cd agent-seed && uv run --frozen pytest -q)
./scripts/check-repo.sh
```

한 ticket에 red-green 근거, 전체 테스트, review, commit이 모두 있어야
닫습니다. 다음 ticket은 `/new`로 시작합니다. 설계가 모호하면 코딩으로
추측하지 않고 spec/ticket으로 되돌립니다.

## 종료 조건

- 최소 한 ticket이 red-green 근거와 함께 닫혔다.
- 두 sample suite와 리포 게이트가 통과한다.
- 기대값을 뒤집은 `known gap` 테스트에 이유가 기록됐다.
- 구현 산출물이 커밋됐다.

## 막힐 때

- 시간이 부족하면 ticket 수를 줄이되 한 ticket은 끝까지 완결한다.
- 에이전트가 seam 밖을 고치려 하면 spec의 승인된 seam으로 되돌린다.
- 테스트가 먼저 green이면 red 단계를 건너뛴 것이므로 다시 시작한다.
