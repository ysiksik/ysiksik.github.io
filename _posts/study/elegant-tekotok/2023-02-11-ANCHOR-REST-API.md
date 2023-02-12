---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 정의 REST API
date: '2023-02-11 00:00:02 +0900'
categories:
    - study
    - elegant-tekotok
comments: true
---

# 정의 REST API
[https://youtu.be/Nxi8Ur89Akw](https://youtu.be/Nxi8Ur89Akw)

# 정의 REST API
* toc
{:toc}

## REST API 란? - 일반적인 인식
+ URI를 통해 자원을 지정
+ HTTP 메서드: 자원에 대한 행위 표현 
+ 로이 필딩
  + 내 논문 어디에도 CRUD에 대한 내용은 없다
  + HTTP 메서드는 REST가 아니라 웹 아키텍쳐 스타일의 일부다
  + HTTP에서 정의한 방식대로만 잘 쓴다면 REST는 딱히 할 말이 없다 

## Fielding의 REST API란?
+ REST 아키텍쳐 스타일에 부합하는 API  
  1. Client-Server
  2. Stateless
  3. Cache 
  4. Uniform Interface
  5. Layered System
  6. Code-On-Demand

## REST : Uniform Interface
1. identification of resources 자원의 식별
2. manipulation of resources through representations 표현을 통한 자원의 조작
3. self-descriptive messages 자기 서술적인 메시지 
4. HATEOAS (hypermedia as the engine of application state)

### 자원에 대한 식별
+ 자원
  + 이름을 지닐 수 있는 모든 정보
  + 개념적인 대상
  + ex) 문서, 이미지, 자원들의 집합, 실존하는 대상 등
+ 자원은 객체
  + 상태는 변화가능 -> 변하지 않는 식별자 필요
+ URI를 통해 자원을 식별해야 한다

## 표현을 통한 자원에 대한 조작 
+ 표현: 특정한 상태의 자원에 대한 표현
  + 자원은 다양한 방식으로 표현가능
  + 예: 문서, 파일, HTTP 메시지 엔티티 등 
+ REpresentational State Transfer
  + 표현된 (자원의) 상태
    + 자원의 현재 상태
    + 자원의 기대되는 상태 

## 자기 서술적 메시지
+ 메시지는 스스로에 대해 설명해야 한다
+ 클라이언트와 서버 사이의 컴포넌트들은 메시지의 내용을 참고하여 적절한 작업 수행 
+ Host 헤더에 도메인 명 기재 필요 
  + 도메인명 정보의 필요성
    + 가상호스트 문제
      + 하나의 IP 주소에 복수의 도메인명 존재 가능
      + IP 주소만으로는 요청 대상을 찾아낼 수 없다 
+ 캐쉬
  + 캐쉬 관련 헤더를 통한 캐쉬 전략 지정 

## HATEOAS
+ 하이퍼미디어를 통한 앱 상태 변경

## REST API여야 하는가
+ 시스템을 통제할 수 있다고 생각한다면 REST에 시간을 낭비하지 말라
+ Uniform Interface 제약조건은 비효율적
+ 애플리케이션에 필요한 정보가 아니라, 표준화된 형식으로 데이터 전달
+ 상황에 따라 최적이 아닐 수 있다

## API 설계의 방향성
1. 진짜 REST API 만들기 
2. REST 스타일의 API 만들기
3. 다른 API 표준 선택하기

+ REST 스타일의 API 만들기
  + REST 제약조건 부분적으로 준수
  + HTTP 스펙 적절하게 활용
  + API 설계에 관한 커벤션 참고 

