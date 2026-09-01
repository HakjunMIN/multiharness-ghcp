# ADR 0002: 제품 상담 실습의 핵심 동작에 집중

## Status

Accepted

## Context

제품 상담의 첫 vertical slice와 별개인 추가 정책 축은 request 필드, runtime 설정,
별도 검증 장치를 요구합니다. 이 범위는 공개 웹 근거 검색, Agent Framework 답변
합성, structured citations라는 실습의 핵심 흐름을 학습하는 데 필요하지 않으며
제한된 랩 시간에 독립적인 설계 논의를 늘립니다.

## Decision

- core는 질문을 받아 공개 웹 근거와 structured citations를 반환하고, 근거가
  없을 때 답을 꾸며내지 않는 동작까지 포함합니다.
- `POST /api/consult`의 시작 request는 `question`만 요구합니다.
- Web Knowledge Source 구성은 강사 인프라 준비에 속하며 참가자 request나
  애플리케이션 설정으로 검색 범위를 바꾸지 않습니다.
- 추가 운영 관찰 정책은 이 워크숍의 구현과 UAT 범위에 포함하지 않습니다.

## Alternatives considered

### 추가 정책을 선택 과제로 유지

선택지는 늘어나지만 spec, ticket, fixture, UAT가 서로 다른 범위를 가리키기 쉽고
full 범위의 React 흐름까지 완주할 시간이 줄어듭니다.

### core 완료 후 강사 데모로만 설명

제품 코드 부담은 줄지만 참가자 산출물과 무관한 설명이 랩의 초점을 흐립니다.

## Consequences

- core와 full 모두 동일한 질문, answer, citations 계약을 사용합니다.
- discovery, ticket, UAT가 evidence와 no-evidence behavior에 집중합니다.
- runtime handout과 runway 설정에서 사용하지 않는 정책 입력이 사라집니다.
