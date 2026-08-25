# GitHub Issue 규약

`setup-matt-pocock-skills`에서 GitHub Issues와 기본 triage vocabulary를
선택합니다.

## Labels

- `needs-triage`
- `needs-info`
- `ready-for-agent`
- `ready-for-human`
- `wontfix`

## Spec과 tickets

`to-spec`은 문제, 해결책, user stories, 구현·테스트 결정, 범위 밖 항목을
담은 spec Issue를 만듭니다. `to-tickets`는 이를 한 세션에 들어가는
tracer-bullet tickets로 나눕니다.

각 ticket은 사용자 관점의 완결된 동작, 수락 기준, blocking edges를
가집니다. 선행 ticket이 모두 끝난 frontier만 구현합니다. GitHub가
제공하는 native blocking 관계를 사용하고 ticket에 `ready-for-agent`를
붙입니다.

독립 검증 실패는 기대값, 실제값, 재현 명령, Standards/Spec review 축을
담은 새 결함 Issue로 기록합니다. 검증 세션은 구현을 직접 고치지 않습니다.
