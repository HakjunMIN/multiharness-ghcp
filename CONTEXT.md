# CONTEXT

이 문서는 **제품 상담 에이전트**의 공유 언어를 정의합니다. 아래 "고정 전제"만
주어진 상태이고, 나머지 섹션은 [Lab 1](docs/labs/lab1-discovery.md)에서
참가자가 발견 결과로 직접 채웁니다.

작업 규칙은 [AGENTS.md](AGENTS.md), 되돌리기 어려운 결정은
[docs/adr/](docs/adr/README.md)를 따릅니다. 실행 환경 용어(host,
harness, model, Session Target, fresh session)는
[에이전틱 개발 워크플로](docs/reference/workflow.md)에서 정의합니다.

## 고정 전제

바꾸지 않는 경계입니다.

| 용어 | 뜻 |
| --- | --- |
| 제품 상담 | 사용자의 제품 질문에 공개 웹 근거를 찾아 답하는 이 애플리케이션의 과제. |
| consult endpoint | `POST /api/consult`. 시작 request 필드는 `question`, 응답 필드는 `answer`. |
| citation | 답변이 근거로 삼은 출처. 응답에 구조화된 형태로 함께 반환한다. |
| 상담 흐름 | React 질문 입력에서 `POST /api/consult`, answer와 citations 렌더링까지 이어지는 end-to-end 동작. |
| runway | health와 개발 plumbing만 있고 상담 동작은 비어 있는 시작점. |

## 도메인 용어

Lab 1에서 채웁니다. 검색과 답변 합성 경계, 근거 없음이나 근거 상충 상태,
참가자가 합의한 이름을 여기에 씁니다.

| 용어 | 뜻 |
| --- | --- |

## 동작 규칙

Lab 1에서 채웁니다. 관찰 가능한 형태로 씁니다.

## 테스트 경계

Lab 1에서 채웁니다. network-free unit/contract test와 `e2e` marker로 분리한
APIM smoke의 책임을 씁니다.

## 관련 결정

Lab 1에서 만든 ADR을 여기에 연결합니다.
