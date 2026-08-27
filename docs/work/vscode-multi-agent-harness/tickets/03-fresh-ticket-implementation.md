# 03: Fresh ticket implementation

**What to build:** 구현자가 local ticket 하나를 fresh Copilot + GPT-5.6 Sol
세션에서 TDD로 완결하고 다음 세션이 재개할 durable HANDOFF를 남길 수 있게 한다.

**Blocked by:** 02: Local planning handoff.

**Status:** done

- [x] `/implement` 입력이 local ticket 경로를 사용한다.
- [x] ticket마다 fresh session을 사용한다.
- [x] ticket 상태, commit, focused/full verification 근거가 local artifact에 남는다.
- [x] HANDOFF가 파일과 실행 가능한 verify 명령을 전달한다.
