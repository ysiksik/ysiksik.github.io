---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 마루의 데이터베이스 Lock
date: '2022-10-17 00:00:00 +0900'
categories:
    - study
    - inflearn
    - elegant-tekotok
comments: true
---

# 마루의 데이터베이스 Lock
[https://youtu.be/ZXV6ZqMyJLg](https://youtu.be/ZXV6ZqMyJLg)

# 마루의 데이터베이스 Lock
* toc
{:toc}

## 동시성 제어
+ 트랜잭션들이 동시에 수행될 때, 일관성을 해치지 않도록 데이터 접근을 제어하는 DBMS의 기능 

### 동시성 제어는 어떻게 할까?
+ Lock 을 이용하는 것 이다. 
  + Optimistic Lock - 낙관적 잠금
    + 데이터 갱신 시 경합이 발생하지 않을 것이라고 봄
    + 한 사용자가 업데이트를 완료하면, 동시 업데이트 확약을 시도하는 다른 사용자들에게 충돌이 있음을 알림
    + 동시 업데이트가 거의 없는 경우 사용하면 좋다.
      + 롤백을 할 가능성이 많고 빈번하게 일어날 수 있기 때문이다. 
  + Pessimistic Lock - 비관적 잠금
    + 동일한 데이터를 동시에 수정 할 가능성이 높다라고 봄
    + 다른 사용자는 먼저 시도한 사용자가 변경을 확약해서 레코드 잠금을 릴리스할 때까지 대기해야함
    + 동시 업데이트가 빈번한 경우, 롤백을 하기 힘든 외부 시스템과 연동한 경우 사용하면 좋다.

## Pessimistic Lock 연산의 종류
+ 공용(shared) lock
  + read 연산 실행 가능, write 연산 실행 불가능
  + 데이터에 대한 사용관을 여러 트랜잭션이 함께 가질 수 있다.
  + ![img.png](/assets/img/elegant-tekotok/sharedLock.png)
+ 배타(exclusive) lock
  + read 연산과 write 연산을 모두 실행 가능
  + 베타 lock 연산을 실행한 트랜젝션만 해당 데이터에 대한 독점권을 가진다. 
  + ![img.png](/assets/img/elegant-tekotok/exclusiveLock.png)

## Lock 연산의 양립성

|                        | 공용 lock (read) | 배타 lock (read, write) |
|------------------------|----------------|-----------------------|
| 공용 lock (read)         | 가능             | 불가능                   |
| 배타 lock (read, write)  | 불가능            | 불가능                   |

## Lock 단위
+ ![img.png](/assets/img/elegant-tekotok/lockUnit.png)
  +  데이터 베이스 종류마다 다르다. 

## LOCK 을 큰단위로 하나 걸거나, 작은 단위로 여기저기 걸어버리면 안되나요?
+ 문제점 - Blocking
  + Lock 들의 경합이 발생하여 특정 세션이 작업을 진행하지 못하고 멈춰선 상태
    + Why?
      + 데이터에 대해서 하나의 트랜잭션이 베타 lock 을 걸면 다른 트랜잭션들은 어떤한 lock 도 걸지 못하고 대기해야 하기 때문
    + 블로킹이 풀리는 시점은?
      + 트랜젝션이 commit 혹은 rollback 을 할 때 
  + 해결 방안
    + 트랜젝션을 짧게 정의
    + 같은 데이터를 갱신하는 트랜잭션이 동시에 수행되지 않도록 설계
    + LOCK TIMEOUT 을 이용하여 잠금해제 시간을 조절 
+ 문제점 - DeadLock 교착상태
  + ![img.png](/assets/img/elegant-tekotok/DeadLock.png)
  + 해결방안
    + 트랜잭션 진행방향을 같은 방향으로 처리 
    + 트랜잭션 처리속도를 최소화
    + LOCK TIMEOUT 을 이용하여 잠금해제 시간을 조절
  
  


