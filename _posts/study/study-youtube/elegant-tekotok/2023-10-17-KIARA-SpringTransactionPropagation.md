---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 키아라의 스프링 트랜잭션 전파
date: '2023-10-17 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 키아라의 스프링 트랜잭션 전파
[https://youtu.be/b0s9RzKyHN0?si=GWTQjN9bw-Kj4C0g](https://youtu.be/b0s9RzKyHN0?si=GWTQjN9bw-Kj4C0g)

# 키아라의 스프링 트랜잭션 전파
* toc
{:toc}

## 용어 정리
+ 두 가지 개념이 중요하다 트랜잭션 전파 속성과 타입 그리고 물리 트랜잭션, 논리 트랜잭션

### 트랜잭션 전파 속성
+ 트랜잭션 전파는 전파 속성으로 결정된다 
+ 전파 속성은 트랜잭션이 진행 중일 때 추가 트랜잭션의 진행을 어떻게 할지 결정 하는 것을 의미한다 
+ ![img.png](../../../assets/img/elegant-tekotok/KIARA-SpringTransactionPropagation.png)
  + 트랜잭셔널 어노테이션에 프로퍼게이션 속성을 사용한다
  + 디폴트 타입으로 Required 타입
+ ![img_1.png](../../../assets/img/elegant-tekotok/KIARA-SpringTransactionPropagation1.png)

### 물리 트랜잭션, 논리 트랜잭션
+ ![img_2.png](../../../assets/img/elegant-tekotok/KIARA-SpringTransactionPropagation2.png)
+ 기존의 트랜잭션이 진행 중일 때 새로운 트랜잭션이 시작되면 분류하기 위해 외부 트랜잭션과 내부 트랜잭션으로 구분한다 외부 트랜잭션이 상대적으로 바깥에 있기 때문이다
+ 스프링에서는 이 둘을 하나의 트랜잭션으로 묶어준다 이걸 내부 트랜잭션이 외부 트랜잭션에 참여한다 라고 표현한다
+ ![img_3.png](../../../assets/img/elegant-tekotok/KIARA-SpringTransactionPropagation3.png)
+ 스프링은 이해를 돕기 위해 논리 트랜잭션과 물리 트랜잭션 이라는 개념을 사용하는데 여러 논리 트랜잭션을 하나의 물리 트랜잭션으로 묶는다라고 이해하면 된다 
+ 물리 트랜잭션이란 실제 데이터베이스에 적용되는 트랜잭션이다 실제 커넥션을 통해서 시작하고 커밋과 롤백을 하는 단위이다
+ 논리 트랜잭션도 커밋과 롤백을 요청할 수 있지만 실제 데이터베이스에 적용되진 않는다 


## 스프링 트랜잭션 전파 핵심 원리 
+ 만약에 한 논리 트랜잭션에서 롤백이 된다면 나머지 논리 트랜잭션이나 이 전체를 아우르는 물리 트랜잭션에는 어떤 영향을 미칠까?
  + 모든 논리 트랜잭션이 커밋되야 물리 트랜잭션이 커밋된다 즉 하나의 논리 트랜잭션이라도 롤백 되면 물리 트랜잭션은 롤백된다
  + 신규 트랜잭션만이 물리 트랜잭션을 커밋, 롤백 할 수 있다

## 스프링 트랜잭션 전파 절망 편
+ 요구 사항
  + ![img_4.png](../../../assets/img/elegant-tekotok/KIARA-SpringTransactionPropagation4.png)
+ 로그 저장 성공, 영화 예매 성공
  + ![img_5.png](../../../assets/img/elegant-tekotok/KIARA-SpringTransactionPropagation5.png)
+ 로그 저장 실패, 영화 예매 성공
  + ![img_6.png](../../../assets/img/elegant-tekotok/KIARA-SpringTransactionPropagation6.png)
  + 비즈니스 오류: 사용자는 로그 저장에 실패했든 성공했든 상관없이 오직 영화 예매가 성공한 것만 관심 있다

## 해결 : REQUIRES_NEW
+ ![img_7.png](../../../assets/img/elegant-tekotok/KIARA-SpringTransactionPropagation7.png)
  + requires_new라는 타입을 지정 하면 물리 트랜잭션이 완전히 분리
  + 분리되면 각각의 커밋과 롤백은 서로에게 영향을 미치지 않는다
  + ![img_8.png](../../../assets/img/elegant-tekotok/KIARA-SpringTransactionPropagation8.png)

## 정리
+ 논리 트랜잭션이 하나라도 롤백되면 관련된 물리 트랜잭션은 롤백된다 이를 해결하기 위해서 requires_new 전파 타입을 사용해서 트랜잭션을 분리
+ 주의할 점이 있는데 requires_new를 사용한 만큼 트랜잭션 수도 늘어난다 그래서 하나의 웹 요청에 트랜잭션의 수만큼 DB 커넥션 생성되기 때문에 만약에 성능이 중요한 상황에서라면 조심해서 사용할 필요가 있다
