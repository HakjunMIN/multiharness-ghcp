# Consultation core scope

**Status:** approved

## Problem Statement

제품 상담의 핵심 vertical slice와 독립적인 정책 작업이 discovery, runtime 설정,
UAT를 분산시켜 참가자가 공개 웹 근거와 structured citations 흐름에 집중하기
어렵습니다.

## Solution

core를 `question`에서 Foundry IQ retrieval, Agent Framework answer, structured
citations, no-evidence behavior까지로 제한합니다. full은 이 core를 그대로 포함하고
React 질문, 응답, citation, 오류 UI를 추가합니다.

## User Stories

1. 참가자로서 질문 하나의 end-to-end 흐름을 구현하고 싶다. 핵심 adapter와
   citation 계약을 한 vertical slice에서 학습하기 위해서다.
2. 참가자로서 근거가 없는 답을 꾸며내지 않게 하고 싶다. 공개 웹 근거 기반 상담의
   신뢰성을 검증하기 위해서다.
3. 강사로서 최소 runtime handout을 제공하고 싶다. 사용하지 않는 설정으로 인한
   혼동을 줄이기 위해서다.

## Implementation Decisions

- 고정 HTTP 경계의 시작 request 필드는 `question`, response 필드는 `answer`다.
- core response는 structured citations를 함께 제공한다.
- Web Knowledge Source와 APIM 연결 값은 gitignored `.env`에만 둔다.
- 참가자 애플리케이션은 별도의 검색 범위 선택이나 운영 관찰 입력을 요구하지 않는다.

## Testing Decisions

- 기본 unit/contract suite는 네트워크를 사용하지 않는다.
- recorded retrieval fixture로 answer와 citations를 검증한다.
- live APIM smoke는 `live` marker로 분리한다.
- repository contract가 제거된 정책 용어와 사용하지 않는 설정의 재도입을 막는다.

## Out of Scope

- `question` 외 request 확장
- 참가자별 검색 범위 선택
- 운영 관찰 실험
- origin credential 배포
