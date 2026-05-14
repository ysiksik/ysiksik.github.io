---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 레몬의 MCP 알아보기
date: '2026-05-13 00:00:60 +0900'
categories:
    - elegant-tekotok
comments: true

---

# 레몬의 MCP 알아보기
[https://youtu.be/BIFlrU-Fs1E?si=2uXfF_Ws0q-1edeR](https://youtu.be/BIFlrU-Fs1E?si=2uXfF_Ws0q-1edeR)

# 레몬의 MCP 알아보기
* toc
{:toc}

---


## MCP란 무엇인가: LLM이 외부 도구를 사용하는 표준 프로토콜

MCP는 **Model Context Protocol**의 약자다.
쉽게 말하면 **LLM이 외부 데이터나 도구에 접근하고 활용할 수 있도록 만든 표준화된 연결 방식**이다. 개발자가 외부 API를 호출해 다른 서비스를 사용하는 것처럼, AI 모델도 MCP를 통해 Slack, GitHub, DB, 파일 시스템 같은 외부 도구를 사용할 수 있다.

## 왜 MCP가 필요할까

과거 LLM은 주어진 지식 안에서 답변하는 수동적인 도구에 가까웠다.

예를 들어 이런 요청을 한다고 해보자.

```text
개발 뉴스를 크롤링해서 요약한 뒤 Slack 개발 뉴스 채널에 올려줘
```

기존 LLM은 이 요청을 이해할 수는 있어도 직접 실행하기는 어려웠다.
하지만 AI Agent는 다르다. 필요한 도구를 선택하고, 검색하고, 결과를 정리하고, Slack에 올리는 작업까지 수행할 수 있다.

즉 LLM은 이제 단순 답변기가 아니라 **외부 도구를 활용해 문제를 해결하는 실행 주체**로 발전하고 있다.

## AI Agent와 MCP의 관계

AI Agent는 보통 다음 요소로 구성된다.

```text
LLM
+ Tools
+ ReAct Framework
```

여기서 ReAct는 **Reasoning + Act**의 조합이다.

흐름은 다음과 같다.

```text
질문 이해
→ 필요한 도구 선택
→ 도구 실행
→ 결과 확인
→ 필요하면 반복
→ 최종 답변 또는 실행
```

이때 핵심이 바로 **Tools**다.
그리고 MCP는 이 Tools를 AI Agent가 표준 방식으로 사용할 수 있게 해준다.

## MCP 등장 전의 문제

MCP 이전에는 각 프레임워크마다 도구 연동 방식이 달랐다.

예를 들어 LangChain에서 Slack 도구를 쓰려면 LangChain 방식에 맞춰야 하고, 다른 프레임워크에서 쓰려면 또 다른 방식으로 구현해야 했다.

문제는 두 가지였다.

첫째, 도구를 쓰기 위해 프레임워크 자체를 깊게 배워야 했다.
둘째, 서비스를 도구로 제공하려면 프레임워크별로 API를 따로 감싸야 했다.

```text
Framework A용 API
Framework B용 API
Framework C용 API
```

같은 기능인데도 여러 번 구현해야 했고, API가 바뀌면 각각 수정해야 했다.

## MCP의 핵심 아이디어

MCP의 핵심은 간단하다.

```text
도구 연동 방식을 표준화하자
```

개발자가 MCP 표준에 맞춰 도구를 만들면, 어떤 AI Agent든 그 도구를 사용할 수 있다.

즉 MCP는 AI 도구 생태계의 **USB-C 포트** 같은 역할을 한다.

기기가 USB-C를 지원하면 충전기, 허브, 모니터, 외장 SSD를 쉽게 연결할 수 있듯이, AI Agent가 MCP를 지원하면 다양한 MCP Server를 연결해 사용할 수 있다.

## MCP 구조

MCP는 크게 세 가지로 구성된다.

```text
MCP Host
MCP Client
MCP Server
```

## MCP Host

MCP Host는 AI 애플리케이션 자체다.

예를 들면:

```text
Claude Desktop
Cursor
AI Agent Application
```

같은 것이 Host가 될 수 있다.

## MCP Client

MCP Client는 Host 안에서 MCP Server와 1:1로 연결되는 중간 연결자다.

예를 들어:

```text
Slack MCP Client → Slack MCP Server
Gmail MCP Client → Gmail MCP Server
GitHub MCP Client → GitHub MCP Server
```

처럼 각각의 서버와 연결된다.

## MCP Server

MCP Server는 실제 도구를 제공하는 쪽이다.

예를 들면:

* Slack 메시지 전송
* GitHub Issue 조회
* DB 조회
* 파일 읽기
* 코드 실행
* 브라우저 조작

같은 기능을 MCP 표준에 맞춰 노출한다.

## MCP의 가장 큰 장점

MCP의 장점은 **프레임워크 종속성을 줄인다**는 점이다.

기존에는 특정 프레임워크에 맞춰 도구를 만들어야 했다면, MCP에서는 한 번 MCP Server를 만들면 여러 AI Agent가 사용할 수 있다.

```text
한 번 구현
→ 여러 Agent에서 재사용
```

이 구조가 개발 생산성을 크게 높인다.

## Java 진영에서도 MCP를 사용할 수 있을까

가능하다.

자료에 따르면 MCP 공개 이후 Java 진영에서도 빠르게 MCP 지원을 발표했고, Java SDK도 구현되었다. 즉 Java 기반 애플리케이션에서도 MCP Client와 MCP Server를 만들 수 있다.

특히 중요한 점은 MCP가 특정 언어에 묶이지 않는다는 것이다.

```text
Java MCP Client → Python MCP Server
JavaScript MCP Client → Java MCP Server
Python Agent → Java MCP Server
```

처럼 언어가 달라도 프로토콜만 맞으면 연결할 수 있다.

## MCP 연결 방식: STDIO와 SSE

자료에서는 MCP 연결 방식으로 두 가지를 소개한다.

## STDIO 방식

로컬 환경에서 실행되는 프로그램이나 로컬 리소스를 연결할 때 사용한다.

예를 들면:

```text
로컬 파일 시스템
로컬 CLI 도구
로컬 스크립트
```

같은 도구를 AI Agent와 연결할 때 적합하다.

## SSE 방식

웹 기반으로 MCP Server와 연결하는 방식이다.

원격 서버에서 제공하는 도구를 AI Agent가 사용할 때 활용할 수 있다.

## 왜 Cursor가 MCP 확산에 중요했을까

MCP가 처음 등장했을 때는 큰 관심을 받지 못했다.
이미 여러 AI 플랫폼이 자체 도구 연동 방식을 가지고 있었기 때문이다.

하지만 Cursor AI가 MCP를 도구 연동 표준으로 채택하면서 분위기가 바뀌었다. Cursor는 MCP를 통해 코드 분석, 코드 수정, 터미널 명령 실행 같은 강력한 기능을 보여줬고, MCP가 실제 개발 생산성을 높일 수 있음을 증명했다.

즉 MCP는 단순한 이론적 표준이 아니라, 개발자가 체감할 수 있는 생산성 도구로 자리 잡기 시작했다.

## 서비스 개발자 입장에서 MCP가 중요한 이유

서비스 개발자에게 가장 중요한 것은 사용자다.

현재 많은 사용자는 ChatGPT, Claude, Gemini, Cursor 같은 AI 도구를 통해 작업한다.
이때 내 서비스가 MCP Server를 제공한다면, 사용자는 자신이 쓰는 AI 도구 안에서 내 서비스를 직접 사용할 수 있다.

즉 MCP는 단순한 기술 연동이 아니라 **새로운 사용자 접점**이 될 수 있다.

```text
기존: 사용자가 직접 서비스에 접속
MCP 이후: AI Agent가 사용자를 대신해 서비스 사용
```

이 변화는 꽤 크다.

앞으로는 “웹 UI를 잘 만드는 것”뿐 아니라, “AI Agent가 잘 사용할 수 있는 도구 인터페이스를 제공하는 것”도 중요한 경쟁력이 될 수 있다.

## MCP가 바꾸는 개발 방식

MCP가 확산되면 개발 방식도 바뀐다.

기존에는 사람이 직접:

```text
브라우저 접속
→ 데이터 조회
→ 복사
→ 가공
→ Slack 전송
```

같은 작업을 했다.

MCP 기반 Agent는 이를 다음처럼 처리할 수 있다.

```text
도구 선택
→ 데이터 조회
→ 요약
→ Slack 전송
```

즉 반복 업무 자동화, 코드 작업, 운영 업무, 데이터 조회 같은 영역에서 개발자의 생산성을 크게 높일 수 있다.

## MCP를 바라보는 핵심 관점

MCP를 단순히 “AI 플러그인 비슷한 것”으로 보면 부족하다.

더 정확히 보면 MCP는 다음에 가깝다.

```text
AI Agent 시대의 도구 연동 표준
```

API가 웹 서비스 간 통신의 표준이었다면, MCP는 AI Agent와 도구 사이의 표준 인터페이스가 될 가능성이 있다.

## 마무리

MCP는 LLM이 외부 도구와 소통하기 위한 표준 프로토콜이다.
AI Agent는 문제를 해결하기 위해 도구를 사용해야 하고, MCP는 그 도구 연동 방식을 표준화한다.

정리하면 핵심은 이렇다.

```text
LLM은 답변을 생성한다
AI Agent는 문제를 해결한다
MCP는 Agent가 도구를 쓰게 해준다
```

MCP의 진짜 가치는 특정 프레임워크에 종속되지 않고, 다양한 도구와 AI Agent를 연결할 수 있다는 점이다. 그리고 서비스 개발자 입장에서는 자신의 서비스를 AI 플랫폼 사용자들에게 노출할 수 있는 새로운 기회가 될 수 있다.

결국 MCP는 단순한 AI 기술이 아니라, 앞으로의 서비스와 AI Agent를 연결하는 **새로운 인터페이스 표준**으로 볼 수 있다.
