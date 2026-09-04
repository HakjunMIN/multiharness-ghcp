# Lab 7 - Frontend 구현과 backend 통합

## 이 랩에서 배우는 것

- 선택된 prototype을 production React 화면으로 이식한다.
- 검증된 `POST /api/consult` contract와 frontend를 연결한다.
- 기능과 시각 일치를 서로 다른 근거로 확인한다.

## Runtime card

```text
Host: VS Code
Recommended agent runtime: Copilot harness (New Chat → Session Target: Copilot)
Recommended model: GPT-5.6 Sol
Context: frontend ticket 하나의 fresh session
```

## 구현

backend `HANDOFF`의 verify를 가장 먼저 실행합니다. 이어서 `prototype.md`,
`prototype/tokens.md`, 선택된 HTML/CSS와 상태별 스크린샷, spec, frontend
ticket을 읽습니다.

```text
/implement docs/work/<feature>/tickets/<frontend-ticket>.md
```

질문 입력, loading, answer와 citations, no-evidence, 오류 상태를 구현합니다.
domain behavior는 `POST /api/consult`만 사용합니다. `tokens.md`의 CSS 변수와
나눔고딕 본문 서체를 `app/web/src/styles.css`로 옮기고 상태별 landmark와
접근성 이름을 유지합니다. React test는 token과 landmark를 assert합니다.

서체 파일은 Google Fonts CDN에서 받아옵니다. 이는 "domain behavior는
`POST /api/consult`만 사용한다"는 규칙의 명시적 예외이며, 오프라인에서는
`--font-body` fallback으로 OS 기본 한글 서체가 쓰입니다. 서체 로딩 여부를
test나 인수 기준으로 삼지 않습니다.

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/web && npm test && npm run build && npm run test:browser)
./scripts/check-repo.sh
```

구현 화면의 다섯 상태를 prototype의 상태별 스크린샷과 육안 비교합니다. pixel
diff baseline은 만들지 않습니다. 일치 여부와 의도적인 차이는 루트 `HANDOFF`의
`done` 또는 `risks`에 기록합니다.

production code, tests, ticket 상태를 구현 commit으로 남긴 뒤 구현 SHA와 개별
artifact 경로를 담은 `HANDOFF`를 별도 commit으로 남깁니다.

## 종료 조건

- React가 backend contract를 소비해 다섯 상태를 표시한다.
- component test, build, deterministic Playwright와 API 기본 suite가 green이다.
- `tokens.md`의 token과 landmark가 test로 고정됐다.
- 스크린샷 육안 비교 결과가 `HANDOFF`에 있고 두 commit이 분리됐다.

## 막힐 때

- prototype과 구현이 다르면 임의 재설계보다 선택 시안의 token과 구조를 이식한다.
- backend contract가 다르면 frontend에서 보정하지 말고 defect로 기록한다.
- flaky pixel 비교를 추가하지 말고 상태별 육안 비교와 semantic assert를 유지한다.
