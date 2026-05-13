---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 윌슨의 Event-Loop & Nginx
date: '2026-05-13 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true

---

# 윌슨의 Event-Loop & Nginx
[https://youtu.be/wAFn9oXkfms?si=I7w4mX_1zL-Knec8](https://youtu.be/wAFn9oXkfms?si=I7w4mX_1zL-Knec8)

# 윌슨의 Event-Loop & Nginx
* toc
{:toc}

---

## 이벤트 루프(Event Loop)와 Nginx의 핵심 원리 완벽 이해

백엔드 개발을 하다 보면 자주 듣는 단어가 있다.

* 이벤트 루프(Event Loop)
* 논블로킹 I/O
* epoll
* Nginx
* 리버스 프록시
* 비동기 처리

특히 Nginx를 사용할 때:

```text
"Nginx는 왜 빠를까?"
```

라는 궁금증이 생긴다.

그 핵심에는:

```text
이벤트 루프(Event Loop)
```

가 존재한다.

이번 글에서는 발표 내용을 기반으로:

* 이벤트 루프란 무엇인지
* epoll이 어떻게 동작하는지
* Nginx 내부 구조
* Nginx I/O Flow
* 왜 Nginx가 고성능인지

를 깊이 있게 정리해본다.

---

# 이벤트 루프(Event Loop)란 무엇인가

이벤트 루프는 한 문장으로 정의하면:

```text
이벤트 기반 논블로킹 작업 처리 루프
```

이다.

여기서 중요한 키워드는:

* 이벤트(Event)
* 논블로킹(Non-Blocking)
* 루프(Loop)

세 가지다.

---

# 여기서 말하는 "이벤트"란?

이벤트 루프에서 이벤트는 단순 버튼 클릭 같은 의미가 아니다.

발표에서는:

```text
소켓 상태 변화(Socket State Change)
```

를 이벤트라고 정의한다.

예를 들면:

| 상태          | 의미    |
| ----------- | ----- |
| ESTABLISHED | 연결 완료 |
| READABLE    | 읽기 가능 |
| WRITABLE    | 쓰기 가능 |

이런 상태 변화가 이벤트다.

---

# Linux의 epoll

Nginx는 Linux 기반에서 주로 동작한다.

그래서 이벤트 감지는:

```text
epoll
```

이라는 Linux 시스템 콜 기반으로 처리된다.

---

# epoll의 핵심 구성 요소

## 1. Interest List

```text
감시할 소켓 목록
```

이다.

즉:

```text
"이 소켓 상태가 변하면 알려줘"
```

라는 의미다.

---

## 2. Ready List

```text
이벤트가 발생한 소켓 목록
```

이다.

발표에서는 이해를 쉽게 하기 위해:

```text
이벤트 큐(Event Queue)
```

라고 표현한다.

---

## 3. epoll_ctl

소켓 등록/수정/삭제를 담당한다.

예:

* EPOLLIN 등록
* EPOLLOUT 변경

등을 수행한다.

---

## 4. epoll_wait

이벤트 큐에서 이벤트를 가져온다.

즉:

```text
"이벤트 생기면 깨워줘"
```

역할이다.

---

# EPOLLIN vs EPOLLOUT

## EPOLLIN

```text
읽기 가능(Read Ready)
```

상태다.

즉:

```text
소켓에서 데이터를 읽을 수 있음
```

을 의미한다.

---

## EPOLLOUT

```text
쓰기 가능(Write Ready)
```

상태다.

즉:

```text
소켓에 데이터를 쓸 수 있음
```

을 의미한다.

---

# 이벤트 루프의 전체 흐름

이벤트 루프는 대략 다음 순서로 동작한다.

```text
1. 소켓 변화 감지
2. 이벤트 발생
3. 이벤트 큐 저장
4. 이벤트 읽기
5. 작업 처리
```

---

# 서버 시작 시 일어나는 일

애플리케이션이 실행되면:

```text
서버 소켓
```

이 먼저 생성된다.

그리고:

```text
EPOLLIN 상태로 Interest List에 등록
```

된다.

의미는:

```text
새로운 사용자 연결 요청 들어오면 알려줘
```

이다.

---

# 새로운 사용자 요청이 들어오면?

사용자가 서버에 연결하면:

1. 커널이 소켓 변화 감지
2. 이벤트 생성
3. 이벤트 큐 저장
4. epoll_wait이 이벤트 획득

을 수행한다.

---

# accept() 시스템 콜

새 연결 요청이면:

```text
accept()
```

를 호출한다.

그러면:

```text
클라이언트 소켓
```

이 새로 생성된다.

이 소켓이 이후 사용자와 통신하는 실제 소켓이다.

---

# 클라이언트 소켓 등록

생성된 클라이언트 소켓은:

```text
EPOLLIN 상태로 epoll 등록
```

된다.

즉:

```text
"이 사용자가 데이터를 보내면 알려줘"
```

상태가 된다.

---

# 이벤트 루프가 중요한 이유

핵심은:

```text
하나의 스레드가 블로킹 없이 계속 순환
```

한다는 점이다.

즉:

* 요청 기다림
* 이벤트 감지
* 작업 처리
* 다음 이벤트 처리

를 반복한다.

---

# 기존 Blocking 방식 문제

전통적인 Blocking I/O에서는:

```text
요청 하나 처리 중이면 스레드가 멈춤
```

상태가 된다.

즉:

* 스레드 낭비
* 컨텍스트 스위칭 증가
* 메모리 증가

문제가 생긴다.

---

# 이벤트 루프의 핵심 철학

이벤트 루프는:

```text
"기다리지 말고 다른 작업 먼저 해"
```

철학이다.

즉:

```text
I/O 기다리는 동안
다른 요청 처리
```

가 가능하다.

---

# Nginx란 무엇인가

Nginx는 대표적인:

* 웹 서버
* 리버스 프록시
* 로드 밸런서

다.

발표에서는:

```text
고성능 이벤트 기반 웹 서버
```

로 설명한다.

---

# Nginx의 핵심 구조

Nginx는 크게:

```text
1 Master Process
+ 여러 Worker Process
```

구조다.

---

# Master Process 역할

Master는:

* 설정 파일 읽기
* Worker 생성
* Worker 생명주기 관리
* 포트 바인딩

등을 수행한다.

즉:

```text
관리자 역할
```

이다.

---

# Worker Process 역할

실제 요청 처리는:

```text
Worker Process
```

가 담당한다.

Worker 내부에는:

* 메인 스레드
* 스레드 풀

이 존재한다.

---

# Worker 메인 스레드 역할

메인 스레드는:

```text
이벤트 루프 기반 처리
```

를 수행한다.

주로:

* 리버스 프록시
* 로드 밸런싱
* 네트워크 I/O

같은 가벼운 작업을 담당한다.

---

# 스레드 풀 역할

무거운 작업은 별도 스레드 풀로 넘긴다.

예:

* 정적 파일 읽기
* 로그 파일 I/O
* 디스크 작업

등이다.

즉:

```text
무거운 Disk I/O는 비동기 위임
```

전략이다.

---

# Nginx I/O Flow 전체 과정

이제 실제 HTTP 요청 흐름을 보자.

---

# 1단계 — 사용자 요청 도착

클라이언트 요청 도착 →

서버 소켓 상태 변화 발생 →

커널이 이벤트 생성 →

이벤트 큐 저장.

---

# 2단계 — 이벤트 읽기

메인 스레드가:

```text
epoll_wait()
```

로 이벤트 획득.

그리고:

```text
새 사용자 연결
```

임을 인지한다.

---

# 3단계 — accept() 호출

accept() 호출 후:

```text
클라이언트 소켓 생성
```

된다.

그리고:

```text
EPOLLIN 등록
```

된다.

즉:

```text
HTTP 요청 들어오면 알려줘
```

상태다.

---

# 4단계 — HTTP 요청 수신

클라이언트가 실제 HTTP 요청 전송 →

클라이언트 소켓이 READABLE 상태 →

커널 이벤트 발생 →

epoll_wait으로 이벤트 획득.

---

# 5단계 — WAS 전달

Nginx는:

* URI 분석
* Header 분석
* 라우팅 판단

후 WAS로 전달한다.

예:

```text
Spring Boot
Node.js
Django
```

등.

---

# 6단계 — EPOLLOUT 변경

요청 처리 후 Nginx는:

```text
EPOLLIN → EPOLLOUT
```

으로 변경한다.

의미는:

```text
응답 쓸 준비 되면 알려줘
```

이다.

---

# 7단계 — WAS 응답

WAS 응답 도착 →

소켓 WRITABLE 상태 →

커널 이벤트 발생 →

메인 스레드가 응답 전송.

---

# 8단계 — 다시 EPOLLIN

응답 완료 후:

```text
EPOLLOUT → EPOLLIN
```

변경.

즉:

```text
다음 요청 기다림
```

상태가 된다.

---

# 왜 Nginx가 빠를까?

핵심은:

```text
적은 스레드로
엄청 많은 연결 처리 가능
```

하기 때문이다.

---

# 전통적 방식 vs Nginx

## 전통적 Thread-per-Request

```text
요청 1개 = 스레드 1개
```

문제:

* 스레드 많아짐
* 메모리 증가
* 컨텍스트 스위칭 증가

---

## Nginx 방식

```text
소수 스레드 + 이벤트 루프
```

장점:

* 메모리 효율
* 높은 동시성
* 적은 컨텍스트 스위칭
* 높은 처리량

---

# Keep-Alive와 이벤트 루프

Nginx는 Keep-Alive 연결을 유지하면서도:

```text
블로킹 없이
다른 요청 계속 처리
```

한다.

이게 엄청난 성능 차이를 만든다.

---

# 핵심 정리

## 이벤트 루프

* 논블로킹 기반
* 이벤트 중심 처리
* epoll 활용
* 적은 스레드로 높은 동시성

---

## Nginx

* Master + Worker 구조
* Worker는 이벤트 루프 기반
* 가벼운 작업은 메인 스레드
* 무거운 작업은 스레드 풀

---

# 마무리

Nginx의 핵심은 단순히:

```text
빠른 웹 서버
```

가 아니다.

진짜 핵심은:

```text
논블로킹 이벤트 기반 아키텍처
```

다.

그리고 그 중심에는:

```text
epoll + Event Loop
```

가 존재한다.

이 구조 덕분에 Nginx는:

* 높은 동시성
* 낮은 메모리 사용
* 뛰어난 처리량

을 동시에 달성할 수 있다.

---



