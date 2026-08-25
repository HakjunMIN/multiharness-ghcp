# Lab 5 — 런타임 비교 (15분)

## 이 랩에서 배우는 것

- host, agent runtime, model이 서로 다른 축임을 산출물로 확인한다.
- 조합을 바꿨을 때 드러난 숨은 가정을 언어화한다.
- 진짜 handoff가 필요한 경계와 그렇지 않은 경계를 구분한다.

## 시작 전 상태

Lab 1–4의 산출물이 리포와 Issue에 남아 있다.

## 비교

세 영속 산출물을 나란히 봅니다: Opus 설계의 `CONTEXT.md`·ADR·spec,
Sol 구현의 tests·commit, Sonnet 검증의 review·UAT report.

다음을 기록합니다.

1. Claude agent가 native agent와 다르게 제공한 도구·행동은 무엇인가?
2. 모델을 바꿨을 때 발견한 가정은 무엇인가?
3. 채팅이 사라져도 다음 세션이 재개할 수 있게 만든 primary source는 무엇인가?

다른 하네스·디렉터리·협업자로 실제 이동할 때만 `/handoff`를 사용합니다.
단순한 Matt 스킬 단계 전환에는 handoff 문서를 만들지 않습니다.

## 종료 조건

세 질문의 답이 팀 단위로 기록됐다.

## 막힐 때

관찰이 추상적이면 각 주장에 대응하는 파일이나 Issue를 하나씩 지목한다.
