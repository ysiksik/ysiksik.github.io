---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 루키의 Spring WebSocket과 STOMP를 활용한 실시간 통신 구조
date: '2026-04-21 00:00:05 +0900'
categories:
    - elegant-tekotok
comments: true

---

# 루키의 Spring WebSocket과 STOMP를 활용한 실시간 통신 구조
[https://youtu.be/ckxmMbwmn98?si=HhbJK3EH4S4_sfkQ](https://youtu.be/ckxmMbwmn98?si=HhbJK3EH4S4_sfkQ)

# 루키의 Spring WebSocket과 STOMP를 활용한 실시간 통신 구조 
* toc
{:toc}

---

## Spring WebSocket + STOMP: 실시간 통신을 제대로 설계하는 방법

실시간 채팅, 알림, 협업 툴 같은 기능을 만들 때 가장 먼저 마주치는 문제는 이것이다.

**“HTTP로 실시간을 만들 수 있을까?”**

결론부터 말하면 가능은 하지만 비효율적이다. 이 문제를 해결하기 위해 등장한 것이 **WebSocket**, 그리고 그 위에서 구조를 만들어주는 **STOMP**다.

이 글에서는
HTTP의 한계 → WebSocket → STOMP → Spring 내부 흐름
순서로 실무 관점에서 정리한다.

---

## HTTP는 왜 실시간 통신에 부적합할까

HTTP는 기본적으로 **요청 → 응답** 구조다.

즉, 클라이언트가 요청해야만 서버가 응답할 수 있다.

채팅을 예로 보면 흐름은 이렇게 된다.

1. 사용자가 메시지 전송
2. 일정 시간 후 서버에 “새 메시지 있나요?” 요청
3. 없으면 “없음” 응답
4. 다시 요청 반복

이 구조의 핵심 문제는 이것이다.

* 계속 요청해야 한다 (Polling)
* 불필요한 트래픽 발생
* 응답 지연 발생

발표에서도 이 방식을 “주기적으로 서버에 물어봐야 하는 매우 비효율적인 방식”이라고 설명한다.

---

## WebSocket: 연결을 유지하는 통신 방식

WebSocket은 이 문제를 근본적으로 해결한다.

핵심 개념은 하나다.

**“연결을 끊지 않는다”**

HTTP는 요청마다 연결을 열고 닫지만,
WebSocket은 한 번 연결하면 계속 유지된다.

비유하면 이렇다.

* HTTP → 문자 보내기
* WebSocket → 전화 연결

즉, 서버가 언제든지 클라이언트에게 메시지를 보낼 수 있다.

### WebSocket의 핵심 장점

* 양방향 통신 가능
* 실시간 데이터 전달
* 불필요한 요청 제거

---

## WebSocket 연결 과정 (핵심 포인트)

WebSocket은 처음부터 WebSocket이 아니다.

**HTTP로 시작해서 WebSocket으로 업그레이드된다.**

### 1. 클라이언트 요청

```http
Connection: Upgrade
Upgrade: websocket
```

이 헤더는 “연결 방식을 WebSocket으로 바꿔달라”는 의미다.

### 2. 서버 응답

* WebSocket으로 전환 승인
* 연결 유지 시작

이 순간부터 HTTP가 아닌 **지속적인 연결**이 만들어진다.

---

## WebSocket의 한계: “형식이 없다”

여기서 중요한 문제가 하나 발생한다.

WebSocket은 **데이터만 보낼 뿐, 형식을 정의하지 않는다.**

즉, 이런 상황이 된다.

```text
"hello"
```

이 메시지를 서버는 어떻게 해석해야 할까?

* 채팅 메시지?
* 알림?
* 명령어?

구분할 수 없다.

발표에서도 이 문제를 명확히 지적한다.

**“WebSocket은 메시지 형식을 제공하지 않는다”**

---

## STOMP: 메시지에 구조를 입히다

이 문제를 해결하는 것이 **STOMP(Simple Text Oriented Messaging Protocol)**다.

STOMP는 쉽게 말하면

**“WebSocket 위에서 동작하는 메시지 규칙”**

이다.

---

## STOMP 메시지 구조

STOMP 메시지는 3가지로 구성된다.

### 1. Command (무엇을 할 것인가)

* CONNECT
* SEND
* SUBSCRIBE
* DISCONNECT

### 2. Header (추가 정보)

* destination (어디로 보낼지)
* content-type

### 3. Body (실제 데이터)

* 메시지 내용

발표에서도 STOMP 메시지는 “명령어, 헤더, 바디 3가지로 구성된다”고 설명한다.

---

## STOMP의 핵심: Pub/Sub 모델

STOMP의 진짜 핵심은 메시지 구조가 아니라
**Pub/Sub (발행/구독 모델)**이다.

### 구성 요소

* Publisher → 메시지 보내는 사람
* Subscriber → 메시지 받는 사람
* Topic → 메시지 경로

---

## 채팅 예시로 이해하기

1번 채팅방이 있다고 가정해보자.

```text
/topic/room/1
```

### 메시지 흐름

1. 사용자가 메시지 전송 (Publisher)
2. Topic으로 메시지 전달
3. 해당 Topic 구독자 모두 수신 (Subscriber)

즉, 한 번 보내면 여러 명이 동시에 받는다.

발표에서도 이 구조를 “하나의 메시지를 여러 사용자에게 동시에 전달”한다고 설명한다.

---

## STOMP 메시지 예시

```text
destination: /topic/1
body: 안녕 친구들
```

이 의미는 단순하다.

**“1번 채팅방에 메시지를 보낸다”**

---

## Spring 내부 처리 흐름

Spring은 WebSocket + STOMP를 조합해서
꽤 정교한 메시지 처리 구조를 제공한다.

흐름을 단계별로 보면 다음과 같다.

---

## 1. 메시지 수신 (Inbound Channel)

클라이언트 → WebSocket → 서버

* 텍스트 메시지 수신
* Inbound Channel로 전달
* STOMP 형식으로 파싱

---

## 2. 메시지 라우팅 (Message Handler)

* destination 확인
* 해당 핸들러로 전달

이 핸들러는 사실상

**“WebSocket용 Controller”**

라고 보면 된다.

여기서 우리가 작성한 비즈니스 로직이 실행된다.

---

## 3. 메시지 브로커 (Broker Channel)

핸들러가 결과 메시지를 반환하면:

* Broker Channel로 전달
* 구독자 확인
* 해당 Topic 구독자에게 전파

---

## 4. 클라이언트 응답 (Outbound Channel)

* Outbound Channel에서 메시지 전달
* 구독된 클라이언트에게 전송

---

## 전체 흐름 정리

```text
Client
 → WebSocket
 → Inbound Channel
 → Message Handler (비즈니스 로직)
 → Broker Channel
 → Outbound Channel
 → Client
```

---

## 이 구조가 중요한 이유

이 구조는 단순 채팅 구현을 넘어서
**확장 가능한 실시간 시스템 구조**다.

예를 들어:

* 실시간 알림 시스템
* 주식/코인 시세
* 협업 문서
* 게임 상태 동기화

모두 동일한 구조로 확장 가능하다.

---

## 핵심 정리

Spring WebSocket + STOMP 구조의 본질은 이렇다.

### 1. WebSocket

* 지속 연결
* 양방향 통신
* HTTP 비효율 제거

### 2. STOMP

* 메시지 구조 제공
* Pub/Sub 모델 지원

### 3. Spring

* 메시지 라우팅 자동화
* 브로커 기반 전파
* 컨트롤러처럼 개발 가능

---

## 한 줄 핵심

**“WebSocket은 연결을 만들고, STOMP는 의미를 만든다.”**

---

## 실무 관점에서 중요한 포인트

### 1. HTTP → WebSocket 업그레이드 이해

→ LB / Proxy 설정 시 필수

### 2. Topic 설계

→ `/topic/chat/room/{id}` 구조

### 3. 브로커 선택

* SimpleBroker (기본)
* RabbitMQ / Kafka (확장)

### 4. 인증 처리

→ WebSocket은 HTTP처럼 stateless 아님
→ 별도 인증 처리 필요

---

## 마무리

Spring WebSocket + STOMP는 단순 기술이 아니라
**실시간 시스템 설계의 기본 패턴**이다.

정리하면:

* HTTP는 요청 기반이라 비효율적
* WebSocket은 연결 기반으로 해결
* STOMP는 메시지 구조를 제공
* Spring은 이를 자동으로 연결

그리고 결국 핵심은 하나다.

**“실시간 시스템은 연결 + 메시지 구조 + 라우팅으로 완성된다.”**

---
