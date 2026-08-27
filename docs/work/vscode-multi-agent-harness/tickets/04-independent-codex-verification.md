# 04: Independent Codex verification

**What to build:** verifier가 구현 history를 상속하지 않는 fresh Codex +
GPT-5.6 Terra 세션에서 standards/spec review와 UAT를 수행하고 local defect를
남길 수 있게 한다.

**Blocked by:** 03: Fresh ticket implementation.

**Status:** done

- [x] 검증 세션은 handoff가 아닌 New Chat으로 시작한다.
- [x] `/code-review main`이 local spec을 기준으로 검증한다.
- [x] verifier는 production implementation을 수정하지 않는다.
- [x] 실패는 기대값, 실제값, 재현 명령을 포함한 local defect 문서로 기록된다.
