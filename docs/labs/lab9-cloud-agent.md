# Lab 9 (선택) - VS Code에서 클라우드 에이전트

이 랩은 선택입니다. 라이선스와 정책이 갖춰진 참가자만 진행하고, Lab 0~8의
평가 경로에는 포함하지 않습니다.

## 이 랩에서 배우는 것

- local session과 cloud session이 서로 다른 실행 환경임을 구분한다.
- VS Code에서 Copilot cloud agent와 cloud partner agent(Claude, Codex)를 시작한다.
- 비밀 값을 받지 못하는 실행 환경에 맞게 위임할 작업 범위를 좁힌다.

## 전제 조건

cloud session은 local harness와 자격 요건이 다릅니다. 시작 전에 다음을
확인합니다.

| 경로 | 필요한 것 |
| --- | --- |
| Copilot cloud agent | 유료 Copilot plan. Copilot Business/Enterprise는 관리자가 정책을 켜야 하고, 저장소 소유자가 해당 저장소를 제외하지 않아야 한다. |
| Cloud partner agent (Claude, Codex) | Copilot 계정에서 third-party coding agents가 활성화되어야 한다. provider extension은 필요 없다. public preview 기능이다. |
| Local partner agent (Claude, Codex) | Lab 0의 경로. Codex는 extension과 Copilot Pro+가 필요하다. |

Copilot cloud agent는 GitHub Actions minutes와 AI credits를 사용합니다. 조직
계정으로 실습한다면 운영자에게 정책과 사용량 한도를 먼저 확인합니다. 조건이
갖춰지지 않으면 이 랩을 건너뛰고 Lab 0~8을 그대로 진행합니다.

## Runtime card

```text
Host: VS Code
Session type: Cloud (New Chat → Session Target/Session Type → Cloud)
Partner agent: Claude 또는 Codex (Partner Agent 드롭다운)
Execution: GitHub의 원격 환경. 로컬 worktree와 `.env`를 사용하지 않는다.
Context: 다른 역할 세션을 상속하지 않는 fresh session
```

Copilot cloud agent를 쓰려면 Session Target에서 Cloud를 고른 뒤 partner agent
없이 Copilot 경로로 위임합니다. 결과는 브랜치와 세션 로그로 남고, 준비되면
pull request로 올립니다.

## 실행

1. Chat view에서 **New Chat**을 연다.
2. Session Target(문서 표기로는 Session Type)에서 **Cloud**를 고른다.
3. partner agent를 쓸 경우 **Partner Agent** 드롭다운에서 Claude 또는 Codex를 고른다.
4. 로컬 비밀이 필요 없는 bounded task 하나만 위임한다.

먼저 파일을 바꾸지 않는 계획 프롬프트로 시작합니다.

```text
Inspect the current branch and propose a plan for one small refactor. Do not edit files yet.
```

계획이 타당하면 같은 세션에서 범위를 좁힌 변경 하나를 요청하고, 원격 브랜치의
diff를 리뷰합니다. local Claude session에서는 chat 입력의 permission mode를
`Plan`, `Request approval`, `Edit automatically` 중에서 작업 위험도에 맞게
고릅니다. `github.copilot.chat.claudeAgent.allowDangerouslySkipPermissions`는
인터넷이 차단된 샌드박스 밖에서 켜지 않습니다.

## 위임할 작업을 고르는 기준

cloud 실행 환경은 운영자가 준 APIM 값이 담긴 gitignored `.env`를 받지
않습니다. 따라서 live retrieval이 필요한 consultation 동작은 cloud로 위임하지
않습니다. 대신 네트워크가 필요 없는 작업만 넘깁니다.

- 문서와 `CONTEXT.md` 정리
- 네트워크를 쓰지 않는 unit/contract test 보강
- 이미 합의된 spec 범위 안의 작은 리팩터링

`live` marker가 붙은 테스트, APIM key, 고객 식별 정보는 cloud session의
프롬프트와 로그에 넣지 않습니다. 이 규칙은 `AGENTS.md`의 절대 규칙과 같습니다.

## local session과 비교

같은 bounded prompt를 local harness와 cloud session에서 각각 한 번씩
실행하고 결과를 비교합니다. 비교 결과는 아래 표에 evidence와 함께 남깁니다.

| 항목 | local session | cloud session |
| --- | --- | --- |
| Session type / partner agent | 기록 | 기록 |
| acceptance 통과 | 기록 | 기록 |
| 사람 개입 횟수와 승인 지점 | 기록 | 기록 |
| durable artifacts | 기록 | 기록 |
| 검증 실행 위치 | 기록 | 기록 |

## 종료 조건

- cloud session을 시작했고 사용한 session type과 partner agent를 기록했다.
- 비밀 값이 필요 없는 bounded task 하나만 위임했고 diff를 직접 리뷰했다.
- local session과의 비교 결과를 evidence와 함께 남겼다.
- APIM key와 고객 식별 정보가 cloud 프롬프트, 커밋, 로그에 없다.

## 막힐 때

- Session Target에 Cloud가 없으면 VS Code 버전과 Copilot 로그인을 먼저 확인한다.
- Cloud는 있는데 Partner Agent 목록이 비어 있으면 계정의 third-party coding agents 활성화 여부를 확인한다.
- 조직 정책이나 저장소 제외 설정으로 막히면 우회하지 말고 이 선택 랩을 건너뛴다.
- cloud 변경이 로컬 검증에서 실패하면 브랜치를 fetch해 로컬에서 검증 명령을 다시 실행한다.

## 참고 자료

- [Using third-party agents in VS Code](https://code.visualstudio.com/learn/agents/4-using-third-party-agents-in-vs-code)
- [About GitHub Copilot cloud agent](https://docs.github.com/en/copilot/concepts/agents/cloud-agent/about-cloud-agent)
