---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 시지프의 타입스크립트 도약하기
date: '2022-10-23 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 시지프의 타입스크립트 도약하기 
[https://youtu.be/kMuJz6N-Grw](https://youtu.be/kMuJz6N-Grw)

# 시지프의 타입스크립트 도약하기
* toc
{:toc}

## 타입스크립트의 역할
+ 런타임에서 발생할 오류를 컴파일 단계에서 표시해준다. 
+ 의도와 다르게 작성된 코드에 에러를 표시한다.
  + 런타임에서 오류를 발생시키지 않더라도 

## 타입스크립트의 타입시스템 딥다이브
+ 구조적 서브 타이핑(structural sub typing)
+ 잉여 속성 체크(excess property check)
+ any 

### 구조적 서브 타이핑 
+ 타입스크립트에서 타입 호환성이라는 것은 구조적 서브 타이핑에 기반하고 있다. 
  + 구조적 서브 타이핑 === 프로퍼티 베이스 타이핑 (속성 기반 타이핑)
+ 타입 이름이 달라도 같은 타입으로 인식될 수 있다
+ 같은 속성을 가지기만 하면 같은 타입으로 인식될 수 있다.
+ Super type 에 Sub type 이 들어갈 수 있는 타입시스템
+ 타입을 집합 관전ㅁ에서 바라보아야 한다.
+ 타입은 곧 할당 가능한 값들의 집합이다.
+ 집합 중 가장 작은 집합은?
  + ![img.png](/assets/img/elegant-tekotok/TypeScript.png)
+ 집합의 원소가 1개인 타입은?
  + ![img.png](/assets/img/elegant-tekotok/TypeScript2.png)
+ 집합의 원소가 2개인 타입은?
  + ![img.png](/assets/img/elegant-tekotok/TypeScript3.png)
+ 모든 타입의 상위 집합인 타입은 
  + unknown
  + ![img.png](/assets/img/elegant-tekotok/TypeScript4.png)

### 잉여 속성 체크
+ 정의한 속성 이외에 추가적인(잉여) 속성이 있는지 체크하고, 있다면 에러를 띄운다.
+ 왜 구조적 서브 타이핑을 거스르는 잉여 속성 체크를 설계했는가? 
  + 속성 이름의 오타 같은 실수를 잡아 주기 위해 
+ 어떤 경우에 구조적 서브 타이핑이 적용되지 않고, 잉여 속성 체크를 수행하는가?
  + 객체 리터럴을 사용할 때 
  + ![img.png](/assets/img/elegant-tekotok/TypeScript5.png)
+ Type A is not assignable to Type B
  + 구조적 서브 타이핑에 의한 타입 에러 => Type A가 Type B의 Sub type이 아니다.
  + 잉여 속성 체크에 의한 타입 에러 => Type A에 잉여 속성이 있다. 

### any
+ ![img.png](/assets/img/elegant-tekotok/TypeScript6.png)
  + any는 모든 타입에 할당 가능하다.
    + any는 최하위 집합이다.
  + 모든 타입이 any에 할당 가능하다
    + any는 최상위 집합이다.
  + any는 기본적으로 타입 시스템을 따르지 않는다. 
+ 어떤 타입이 들어올지 모를 경우, 모든 타입이 들어올 수 있을 경우 any가 아닌 unknown을 사용하는 것이 적절하다.

## 더 나은 타이핑을 위한 액션 아이템
+ 함수의 반환타입을 명시하여 의도를 표기하기
  + ![img.png](/assets/img/elegant-tekotok/TypeScript7.png)
  + 타입 추론에 의존하지 않고, 의도를 타입으로 명시한다.
+ 구별된 유니온 사용하기
  + Discriminated Union
  + 유니온의 인터페이스 보다는 인터페이스의 유니온을 사용하는 것이 적절하다.
+ any 잘 쓰는 방법
  + 함수 안으로 any를 감추고, 반환 타입만 잘 명시해두면 any가 전파되지 않는다.

