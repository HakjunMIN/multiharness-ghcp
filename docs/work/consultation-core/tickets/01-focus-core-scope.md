# 01: Focus consultation core scope

**What to build:** 제품 상담 워크숍의 문서, runway 설정, checkpoint, UAT를
question-to-evidence-to-answer/citations 흐름과 no-evidence behavior에 맞춘다.

**Blocked by:** none

**Status:** done

## Acceptance criteria

- [x] `AGENTS.md`와 `README.md`가 축소된 core/full 범위를 같은 용어로 설명한다.
- [x] 모든 lab, instructor guide, template, UAT 문서가 축소된 범위를 사용한다.
- [x] `.env.example`과 `Settings`에 사용하지 않는 검색 범위 설정이 없다.
- [x] checkpoint tests가 축소된 `Settings` 계약을 사용한다.
- [x] repository contract가 제거된 요구사항의 재도입을 감지한다.

## Verification evidence

- `tests/scripts/test-usage.sh`: pass
- `(cd app/api && uv run --frozen pytest -q)`: 4 passed
- `(cd app/web && npm test && npm run build)`: 2 tests passed, build passed
- `for test in tests/scripts/test-*.sh; do "$test"; done`: pass
- `./scripts/check-repo.sh`: pass

**Implementation commit:** this ticket's commit
