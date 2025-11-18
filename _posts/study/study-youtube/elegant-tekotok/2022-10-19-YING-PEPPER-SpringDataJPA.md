---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 잉, 페퍼의Spring Data JPA 삽질일지
date: '2022-10-19 00:00:01 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 잉, 페퍼의Spring Data JPA 삽질일지
[https://youtu.be/kJexMyaeHDs](https://youtu.be/kJexMyaeHDs)

# 잉, 페퍼의Spring Data JPA 삽질일지
* toc
{:toc}

## Entity 생명주기
+ ![img.png](/assets/img/elegant-tekotok/EntityLifeCicle.png)
+ ![img.png](/assets/img/elegant-tekotok/EntityLifeCicle2.png)

## save() 분기처리
+ ![img.png](/assets/img/elegant-tekotok/JpaSave.png)
  + 처음에 들어온 Entity 객체와 merge 를 통해 리턴된 Entity 객체가 명백하게 두 개가 다르다. 
  + merge 명령을 통해서 들어가면 새로운 id 값으로 새로운 Entity 가 생성이 되는데 영속성 컨텍스트에서 독립성 보장은 두 아이디 값으로 비교하기 때문에 두 Entity 는 명백히 다른 엔티티이다.  

## 삭제된 엔티티란 뭘까? 
+ 삭제 상태의 엔티티는 ID값이 있고 영속성 컨텍스트와 연결되어 있으며 DB에서 제거되도록 예약되어 있습니다.


## 1차 캐시
+ ![img_1.png](/assets/img/elegant-tekotok/oneStepCash.png)
+ 해당 엔티티를 DB에 저장해줘라는 명령이 들어왔을 때 이것이 바로 DB에 찍히는 것이 아니라 1차 캐시에 먼저 저장이 된다. 
+ 여기서 ID 값이 없는 엔티티가 들어갈 때는 아이디 값을 모르기 때문에 바로 DB에서 ID를 가져오고 그 다음에 1차 캐시에 넣어주게 된다. 

## 쓰기 지연 
+ ![img.png](/assets/img/elegant-tekotok/WriteDelay.png)
+ ID 값이 있는 경우는 1차 캐시에 넣은 다음에 해당 되는 쿼리를 쓰기 지연 저장소에 적재한다. 
+ 쓰기 지연 저장소에 적재된 쿼리들은 DB에 flush() 명령을 통해서 반영 된다. 

## deleteAll()
+ ![img.png](/assets/img/elegant-tekotok/deleteAll.png)
  + findAll 호출 후 각각 delete() 진행한다. 
+ ![img.png](/assets/img/elegant-tekotok/deleteAll2.png)
  + deleteAll 명령이 호출 되면 findAll 을 통해 모든 엔티티를 1차 캐시에 넣는다 그리고 1차 캐시에서 이 아이디 값들을 통해 쓰기 지연 저장소에 쿼리들을 적재한다.

## flush 는 언제 발생 할까?
1. 강제로 flush 명령을 할 때
   + 테스트나 특정한 상황이 아니면은 많이 사용하지 않는다. 
2. JPQL 쿼리가 실행 될 때
   + JPQL 쿼리를 사용하면 쓰기 지연 저장소에 들어있던 것들이 다 flush 먼저 되고 그다음에 JPQL 쿼리가 나가게 된다. 
3. 트랜잭션 커밋 시 
   + ![img.png](/assets/img/elegant-tekotok/flush.png)

## 변경 감지 
+ ![img.png](/assets/img/elegant-tekotok/ChangeDetection.png)
  + 엔티티를 저장할때 아이디 값이 없으니깐 DB에서 얻어오고 그것을 1차 캐시에 저장되는데 이 때 스냅샷으로 저장된 시점에 엔티티를 함께 저장을 하게 된다. 그러면 이제 변경 감지를 통해 쓰기 지연을 위해서 
  엔티티 수정시 바로 데이터베이스에 쿼리가 실행되는게 아니라 1차 캐시에서 변경이 되고 쓰기 지연 저장소에 쿼리가 생긴다. 해당 쿼리는 findAll 같이 데이터베이스를 직접 찌르닌 메서드들이 호출될 때
  쿼리들이 실행된다. 이 때 flush 가 사용되고 쿼리가 실행되고 그 다음에 findAll 로 데이터베이스에서 데이터를 조회해오는 것이다.
+ flush 가 JPQL 쿼리가 발생하면 무조건 발생하지 않는다. JPQL 쿼리에서 연관되 엔티티들 중에서 쓰지 지연 저장소에 있는 엔티티만 보여준다.
+ 스프링에서는 Modifying 어노테이션에 clearAutomatically 옵션으로 flush 랑 clear 를 잘 관리를 해주게 된다.   

## Proxy
+ ![img.png](/assets/img/elegant-tekotok/jpaProxy.png)
  + 팀을 지연 로딩을 사용해서 ManyToOne 로 연관 관계를 맺어주었는데 이 때 팀은 프록시 객체이다. 
    + 프록시 객체는 진짜 객체가 아니라 앤티티를 상속받은 가짜 객체이다. 그래서 바로 조회가 되는 것이 아니라 실제 엔티티에 있는 값을 꺼내올때 그 때 값을 가져오게 된다. 
+ ![img.png](/assets/img/elegant-tekotok/jpaProxy2.png)
+ 주의할 점 
  + ![img.png](/assets/img/elegant-tekotok/jpaProxy3.png)
  + 프록시를 사용하게 되면은 프록시랑 진짜 엔티티는 독립성 보장이 되지 않기 때문에 equals, hashCode 를 그대로 오버라이드르 하면 오류가 발생한다. 
  + 그렇기 때문에 getClass, 클래스가 같다는 부분만 업애주고 구현하면 오류를 조금 덜 만날 수 있다. 
