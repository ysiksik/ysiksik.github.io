---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 서프의 가상 스레드
date: '2026-05-07 00:00:01 +0900'
categories:
    - elegant-tekotok
comments: true

---

# 서프의 가상 스레드
[https://youtu.be/5HFW8SHG6h0?si=uNKFQYXLG7K2485z](https://youtu.be/5HFW8SHG6h0?si=uNKFQYXLG7K2485z)

# 서프의 가상 스레드
* toc
{:toc}

---

## 가상 스레드(Virtual Thread): 기존 스레드의 한계를 어떻게 극복했을까

Java의 가상 스레드(Virtual Thread)는 단순히 “더 가벼운 스레드” 정도가 아니다.

기존 Java 동시성 모델이 갖고 있던 구조적 한계를 깨기 위해 등장한 새로운 실행 모델이다.

특히 다음 문제를 해결하기 위해 등장했다.

* 처리량을 늘리려면 스레드를 계속 늘려야 한다
* 하지만 OS 커널 스레드는 너무 비싸다
* 비동기 프로그래밍은 복잡하고 디버깅이 어렵다

Project Loom은 여기서 새로운 질문을 던진다.

> “동기 코드의 단순함을 유지하면서도 높은 처리량을 만들 수 없을까?”

그리고 그 답이 바로 Virtual Thread다.

---

## 기존 Java 스레드 구조의 근본적인 한계

우리가 기존에 사용하던 Java 스레드는 정확히는 Platform Thread다.

이 Platform Thread는 OS의 Kernel Thread와 1:1로 매핑된다.

```text id="o6u9dq"
Java Thread 1 ↔ Kernel Thread 1
Java Thread 2 ↔ Kernel Thread 2
Java Thread 3 ↔ Kernel Thread 3
```

즉:

* Java 스레드 수 = 커널 스레드 수

라는 의미다.

---

## 처리량을 늘리려면 왜 스레드를 늘려야 할까

예를 들어:

* 요청 1개 처리 시간: 0.05초
* 초당 200개 요청 처리 필요

라면 동시에 최소 10개의 작업이 돌아야 한다.

초당 2000개 요청이면?

→ 100개 이상의 스레드가 필요하다.

즉:

```text id="jlwmv9"
처리량 증가 = 스레드 증가
```

하지만 문제는 여기서 시작된다.

---

## 커널 스레드는 “매우 비싸다”

OS 커널 스레드는 다음 비용이 매우 크다.

* 생성 비용
* 컨텍스트 스위칭 비용
* 메모리 비용
* 스케줄링 비용

즉:

```text id="y7fjlwm"
무한히 스레드를 늘릴 수 없다
```

이게 기존 Java 서버의 한계였다.

---

## 대부분의 서버는 사실 CPU보다 IO 대기가 더 많다

여기서 Project Loom은 중요한 사실 하나를 발견한다.

대부분의 웹 서버는 실제 CPU 계산보다 이런 작업이 많다.

* DB 호출
* 외부 API 호출
* 파일 IO
* 네트워크 대기

즉 스레드 대부분은:

```text id="h4mq1w"
"일하는 중"이 아니라 "기다리는 중"
```

이라는 것이다.

---

## 기존 해결책: 비동기 프로그래밍

이 문제를 해결하기 위해 등장한 것이:

* Reactive Programming
* Callback
* CompletableFuture
* WebFlux

같은 비동기 모델이다.

원리는 단순하다.

### 기존 방식

```text id="n7o9sa"
IO 요청 → 스레드 BLOCK
```

### 비동기 방식

```text id="czd16k"
IO 요청 → 스레드 반환 → 다른 작업 수행
```

즉 놀고 있는 스레드를 재활용한다.

---

## 하지만 비동기 방식은 너무 복잡했다

문제는 개발 난이도였다.

기존 동기 코드는:

```java
try {
    data = api.call();
    process(data);
} catch (Exception e) {
    ...
}
```

처럼 순차적이다.

하지만 비동기 모델은:

* callback chain
* reactive stream
* event loop

등으로 변한다.

결과적으로:

* 러닝 커브 증가
* 디버깅 어려움
* 흐름 추적 어려움
* 코드 가독성 저하

문제가 발생했다.

---

## Project Loom의 핵심 질문

Project Loom은 여기서 새로운 목표를 세운다.

```text id="v7l7wg"
"동기 코드처럼 작성하면서
비동기 수준의 처리량을 만들자"
```

이게 Virtual Thread의 출발점이다.

---

## 가상 스레드의 핵심 아이디어

핵심은 단 하나다.

```text id="5r7m8g"
Platform Thread ↔ Kernel Thread
1:1 매핑을 끊자
```

즉:

* 사용자 영역에 훨씬 가벼운 스레드를 만들고
* 실제 커널 스레드는 소수만 유지한다

---

## Carrier Thread라는 개념

Virtual Thread는 직접 CPU에서 실행되지 않는다.

대신 Carrier Thread 위에서 실행된다.

Carrier Thread는 사실상 기존 Platform Thread다.

구조는 이렇게 된다.

```text id="r2ifzf"
Virtual Thread 수천 개
        ↓
Carrier Thread 몇 개
        ↓
Kernel Thread
        ↓
CPU
```

Carrier Thread 수는 보통 CPU 코어 수 기반이다.

---

## 그런데 이 구조만으로는 처리량이 안 늘어난다

처음 보면 의문이 든다.

“어차피 Carrier Thread 개수는 적은데 처리량이 늘어날까?”

핵심은 바로 여기다.

---

## 처리량 증가의 핵심: Continuation

Virtual Thread의 진짜 핵심은 Continuation이다.

기존 방식:

```text id="25fh4r"
IO 요청 → Thread BLOCK
```

Virtual Thread 방식:

```text id="hrwwf6"
IO 요청 → 작업 중단(yield)
          → Carrier Thread 반환
          → 다른 작업 실행
```

즉:

* 스레드 자체가 멈추는 게 아니라
* 작업만 잠시 중단된다

---

## Continuation이란 무엇인가

Continuation은 쉽게 말하면:

```text id="3i1iw5"
"중단 가능한 실행 흐름"
```

이다.

예시 흐름:

```text id="7ayz7j"
run()
  ↓
작업 수행
  ↓
yield()
  ↓
중단
  ↓
다시 run()
  ↓
중단 지점부터 재실행
```

즉:

* 상태 저장 가능
* 이어서 실행 가능

---

## 실제 동작 흐름

### 1단계

Virtual Thread 실행

```text id="x2bn9j"
VT1 → Carrier Thread 점유
```

---

### 2단계

DB IO 요청 발생

```text id="p9l0kq"
VT1 → yield()
```

여기서 중요한 점:

Carrier Thread는 해방된다.

---

### 3단계

다른 작업 실행

```text id="0xqow5"
VT2 실행
VT3 실행
VT4 실행
```

즉:

IO 기다리는 동안 다른 작업 수행 가능.

---

### 4단계

IO 응답 도착

```text id="k9fqj0"
VT1 resume()
```

중단된 지점부터 이어서 실행된다.

---

## 왜 처리량이 증가할까

핵심은 이것이다.

기존 모델:

```text id="xmh1aj"
스레드가 IO 동안 놀고 있음
```

Virtual Thread:

```text id="ukzskv"
IO 동안 다른 작업 수행 가능
```

즉 CPU 활용률이 극적으로 증가한다.

---

## 그래서 Virtual Thread는 어떤 환경에서 강력할까

### 매우 강력한 환경

* DB 호출 많음
* 외부 API 많음
* 네트워크 대기 많음
* IO 중심 서버

예:

* 웹 서버
* API Gateway
* 채팅 서버
* 마이크로서비스

---

## 반대로 효과가 적은 환경

### CPU Bound 작업

예:

* 이미지 처리
* 머신러닝 연산
* 대규모 계산

이 경우:

* yield 발생 거의 없음
* Carrier Thread 오래 점유

즉 기존 스레드와 큰 차이 없다.

---

## Virtual Thread의 위험 요소

## 1. Carrier Thread Block 문제

Carrier Thread 자체가 block되면 심각하다.

왜냐하면:

```text id="q1ddwj"
Carrier Thread 앞 대기열 전체 정지
```

되기 때문이다.

---

## 2. 무제한 생성 문제

Virtual Thread는 매우 가볍다.

그래서 사실상 무한 생성 가능하다.

하지만 문제는 DB다.

예:

```text id="u3l00w"
Virtual Thread 10만 개
↓
DB Connection Pool 20개
```

즉:

애플리케이션은 엄청 빠른데
DB가 병목된다.

이걸 Backpressure 문제라고 볼 수 있다.

---

## 핵심 정리

Virtual Thread는 단순한 경량 스레드가 아니다.

본질은:

```text id="p7nt44"
"IO 대기 동안 스레드를 놀리지 않는 구조"
```

이다.

그리고 핵심 기술은:

* Continuation
* yield / resume
* JVM 스케줄링

이다.

---

## Virtual Thread를 반드시 고려해야 하는 상황

### 추천 환경

* IO Bound 서버
* 높은 동시성
* 전통적 동기 코드 유지 필요
* Spring MVC 기반 서비스

---

### 비추천 환경

* CPU Bound 계산 서버
* DB 병목 심한 구조
* Carrier Thread block 위험 높은 코드

---

## 마무리

Virtual Thread는 Java 동시성 역사에서 매우 큰 변화다.

왜냐하면 처음으로 Java가:

```text id="j9dbq1"
"동기 코드의 단순함"
+
"비동기의 처리량"
```

을 동시에 얻으려 시도했기 때문이다.

그리고 이 변화는 단순 성능 개선이 아니라:

* 서버 구조
* 스레드 모델
* 동시성 철학

자체를 바꾸는 흐름에 가깝다.

---

