---
layout: post
bigtitle: '더 자바, Java 8'
subtitle: Date 와 Time API
date: '2022-08-22 00:00:00 +0900'
categories:
    - study
    - inflearn
    - the-java8
comments: true
---

# Date 와 Time API

# Date 와 Time API
* toc
{:toc}


## Date 와 Time API 소개

### 자바 8에 새로운 날짜와 시간 API 가 생긴 이유
+ 그전까지 사용하던 java.util.Date 클래스는 mutable 하기 때문에 thread safe 하지 않다.
+ 클래스 이름이 명확하지 않다. Date 인데 시간까지 다룬다.
+ 버그 발생할 여지가 많다. (타입 안정성이 없고, 월이 0 부터 시작한다.)
+ 날짜 시간 처리가 복잡한 애플리케이션에서는 보통 Joda Time 을 쓰곤 했다.\

### 자바 8 에서 제공하는 Date-Time API  
+ JSR-310 스팩의 구현체를 제공한다.
+ 디자인 철학
  + Clear(맑다)
  + Fluent(유창한)
  + Immutable(불변의)
  + Extensible(확장)

### 주요 API
+ 기계용 시간(machine time)과 인류용 시간(human time)으로 나눌 수 있다.
+ 기계용 시간은 EPOCK(1970년 1월 1일 0시 0분 0초)부터 현재까지의 타임 스탬프를 표현한다.
+ 인류용 시간은 우리가 흔히 사용하는 연,월,일,시,분,초 등을 표현한다.
+ 타임스탬프는 Istant 를 사용한다.
+ 기간을 표현할 때는 Duration(시간 기반)과 Period(날짜 기반)를 사용할 수 있다.
+ DateTimeFormatter 를 사용해서 일시를 특정한 문자열로 포매팅할 수 있다.