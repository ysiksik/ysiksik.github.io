---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 썬의 캐싱
date: '2022-09-15 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 썬의 캐싱
[https://youtu.be/H4J-8pPMvEU](https://youtu.be/H4J-8pPMvEU)

# 썬의 캐싱
* toc
{:toc}

## 인트로
![img.png](/assets/img/elegant-tekotok/caching.png)
+ 프로세서 성능은 매년 60%씩 증가하는 반면, 메모리 지연 시간 향상은 9% 씩 증가 
+ 이렇게 되면 아무리 프로세서가 성능이 좋아져도 메모리 처리 속도가 느리기 때문에 전체적인 프로그램 속도가 느리게 된다. 따라서 캐시등장

## 캐시(Cache)란?
+ 사전적 정의
  + 물건을 일시적으로 저장하거나 보관하기 위해 사용하는 곳
+ 컴퓨터 과학에서의 정의
  + 캐시는 데이터나 값을 미리 복사해 놓은 임시 장소
  + 미리 복사하여 데이터에 더 빠른 속도로 접근 가능

## Memory Hierarchy
![img.png](/assets/img/elegant-tekotok/caching2.png)
+ 내려갈수록 용량은 커지지만 접근하는데 드는 비용은 더 많아진다.
+ 레지스터나 캐시같은 경우에는 빠르게 접근 가능하다.
+ 메인 메모리를 넘어서 외부 장치까지 접근을 하려면 더 많은 명령주기가 실행되는 것을 확인할 수 있다.

## 캐시의 종류
+ CPU 캐시 메모리
  + ![img.png](/assets/img/elegant-tekotok/caching3.png)
  + 캐시 면적으로 봐도 캐시가 얼마나 중요한지 알 수 있다.
  + 오늘날 CPU 칩의 캐시 면적은 약 30%에서 70%가 된다고 한다.
+ 웹 캐시
  + ![img.png](/assets/img/elegant-tekotok/caching4.png)
  + 클라이언트가 서버에게 요청을하면 데이터를 응답받는 과정에서 캐싱을 통해서 서버 트래픽 비용을 줄이고 접근 시간을 줄이기 위해 캐싱을 사용한다.
  + 블라우저 캐시, 프록시 캐시, 게이트웨이 캐시가 존재한다.
+ 브라우저 캐시
  + ![img.png](/assets/img/elegant-tekotok/caching5.png)
  + 요청과 응답을 하는 과정 이후에 클라이언트 내부 디스크의 정적 파일들을 저장해 놓는 것이다. 이를 통해 다음부터는 서버까지 요청을 할 필요 없고 내부 캐시로 부터 불러올 수 있다.
+ 등등...

## 캐싱(Caching)
+ 캐싱은 이러한 캐시라는 작업을 하는 행위(행동)
+ 자주 사용하는 데이터를 저장해서 재활용하는 기술 

## Integer 캐싱
+ ![img.png](/assets/img/elegant-tekotok/caching6.png)
  + Integer 는 내부적으로 IntegerCache 라는 클래스를 가지고 있다.
  + 캐시라는 배열에다가 미리 low 부터 high 까지의 Integer 인스턴스를 생성 해둔 뒤에 저정을 하고 있다.
+ ![img_1.png](/assets/img/elegant-tekotok/caching7.png)
  + Integer 객체를 만들 때는 캐시로부터 가져오거나 범주 내에 없다면 새로운 인스턴스를 생성한다.

## Spring 에서의 캐싱

### 캐시 추상화(Cache Abstraction)
+ 스프링에서 빈의 메서드에 캐시를 적용할 수 있는 기능을 제공
+ AOP 를 이용해 메서드 내부 구현에 영향을 미치지 않고 적용
+ 특정 캐시 기술에 종속 X
+ 캐싱이 필요한 비즈니스 로직에서 EhCache, Redis 등 캐싱 종류에 의존할 필요 없다. 

### 캐시 매니저(Cache Manager)
+ 캐시 추상화에서는 캐시 기술을 지원하는 캐시 매니저 빈으로 등록해야 한다.
+ ConcurrentMapCacheManager
  + 캐시 정보 Map 타입
  + 빠르고 별다른 설정이 필요 없다.
  + 프로덕션에서는 사용하기 빈약하기 때문에 테스트 용도로 사용이 된다.
+ SimpleCacheManager
  + 기본적으로 제공하는 캐시가 아니다.
  + 사용할 캐시를 직접 등록하여 사용하기 위한 캐시 매니저
+ EhCacheCacheManager
  + 자바 프레임워크에서 유명한 EhCache 를 지원하는 캐시 매니저
+ 이외에도 CaffeineCacheManager, CompositeCacheManager, JCacheCacheManager 등이 있다.

### Spring 의 캐싱 기능을 사용하기 앞서, 필요한 설정 
![img.png](/assets/img/elegant-tekotok/caching8.png)

### 캐시 VS 비캐시 
![img.png](/assets/img/elegant-tekotok/caching9.png)
![img.png](/assets/img/elegant-tekotok/caching10.png)

## 주의할 점
+ 모든 상황에서 캐싱을 사용하는 것은 좋지 않다.
  + 캐시는 값을 저장하고 불러오기 때문에 반복적으로 동일한 결과를 반환하는 경우에 용이
  + 매번 다른 결과를 돌려줘야 하는 상황이라면 오히려 성능 저하를 야기
  + 캐시 저장 및 확인 작업에서 부하가 생김
  + 작업의 시간이 오래 걸리거나 서버에 부담을 주는 경우에 사용을 고려 
  

