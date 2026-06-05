---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 한다의 캡슐화를 지키는 JDBC 트랜잭션 관리
date: '2026-06-04 00:00:30 +0900'
categories:
    - elegant-tekotok
comments: true

---

# 한다의 캡슐화를 지키는 JDBC 트랜잭션 관리
[https://youtu.be/Frv2c_ZK7rU?si=mLFoRniF9OFQeKFG](https://youtu.be/Frv2c_ZK7rU?si=mLFoRniF9OFQeKFG)

# 한다의 캡슐화를 지키는 JDBC 트랜잭션 관리
* toc
{:toc}

---

## JDBC 트랜잭션 관리와 캡슐화: 서비스는 비즈니스 로직에만 집중해야 한다

JDBC로 직접 트랜잭션을 다루다 보면 가장 먼저 마주치는 문제가 있다.

```text
같은 트랜잭션으로 묶으려면
같은 Connection을 써야 한다
```

그래서 처음에는 서비스 계층에서 직접 커넥션을 만들고, 여러 Repository에 파라미터로 넘기는 방식으로 구현하기 쉽다.

```java
Connection connection = dataSource.getConnection();

repositoryA.save(connection, data);
repositoryB.save(connection, data);

connection.commit();
```

이 방식은 동작은 한다.
하지만 구조적으로는 문제가 있다.

서비스가 비즈니스 로직뿐만 아니라 JDBC 커넥션 생성, 커밋, 롤백, 종료까지 직접 관리하게 되기 때문이다.

---

## 왜 Connection을 Repository에 넘기면 캡슐화가 깨질까

Repository의 역할은 데이터 접근이다.

서비스 입장에서는 다음 정도만 알면 충분하다.

```text
repository.save(data)
repository.findById(id)
```

그런데 Repository 메서드에 `Connection`이 드러나면 어떻게 될까?

```java
repository.save(connection, data);
```

이 순간 서비스는 Repository 내부 구현이 JDBC 기반이라는 사실을 알게 된다.

즉, 추상화가 깨진다.

서비스는 비즈니스 로직을 담당해야 하는데, 실제로는 다음 책임까지 떠안는다.

```text
Connection 생성
Connection 전달
commit
rollback
close
```

결과적으로 서비스 계층이 데이터 접근 기술에 강하게 결합된다.

---

## 트랜잭션은 왜 같은 Connection을 써야 할까

트랜잭션은 커넥션 단위로 관리된다.

예를 들어 은행 송금 로직을 생각해보자.

```text
A 계좌 출금
B 계좌 입금
```

이 두 작업은 반드시 하나의 트랜잭션으로 묶여야 한다.

출금은 성공했는데 입금이 실패하면 안 된다.

그래서 두 Repository 작업은 같은 Connection 위에서 실행되어야 한다.

```text
같은 Connection
= 같은 트랜잭션 경계
```

문제는 이 Connection을 서비스가 직접 넘기면 캡슐화가 깨진다는 점이다.

---

## 목표: Connection을 숨기면서 같은 트랜잭션 유지하기

해결해야 할 목표는 두 가지다.

```text
1. Repository 인터페이스에 Connection을 드러내지 않는다
2. 여러 Repository가 같은 트랜잭션 Connection을 사용한다
```

이 두 가지를 동시에 만족하려면 트랜잭션 관리 책임을 서비스 밖으로 분리해야 한다.

---

## 해결책 1: Transaction Manager 도입

첫 번째 해결책은 **트랜잭션 매니저(Transaction Manager)** 를 만드는 것이다.

트랜잭션 매니저는 다음 책임을 담당한다.

```text
Connection 생성
Transaction 시작
비즈니스 로직 실행
commit
rollback
Connection 정리
```

서비스는 더 이상 Connection을 직접 다루지 않는다.

서비스는 단지 이렇게 말하면 된다.

```text
이 비즈니스 로직을 트랜잭션 안에서 실행해줘
```

---

## Transaction Manager 적용 전

적용 전 서비스 코드는 이런 구조가 된다.

```java
Connection connection = dataSource.getConnection();

try {
    repositoryA.save(connection, dataA);
    repositoryB.save(connection, dataB);

    connection.commit();
} catch (Exception e) {
    connection.rollback();
    throw e;
} finally {
    connection.close();
}
```

문제는 서비스 코드가 너무 많은 것을 알고 있다는 점이다.

```text
JDBC
Connection
commit
rollback
close
```

서비스가 인프라 세부사항에 오염된다.

---

## Transaction Manager 적용 후

트랜잭션 매니저를 도입하면 서비스 코드는 이렇게 바뀐다.

```java
transactionManager.execute(() -> {
    repositoryA.save(dataA);
    repositoryB.save(dataB);
});
```

이제 서비스는 비즈니스 흐름만 표현한다.

```text
A 저장
B 저장
```

트랜잭션 시작, 커밋, 롤백, 커넥션 정리는 트랜잭션 매니저가 담당한다.

---

## 그런데 Repository는 Connection을 어떻게 얻을까?

여기서 중요한 문제가 남는다.

서비스가 더 이상 Connection을 넘기지 않는다면, Repository는 어떻게 같은 Connection을 사용할까?

단순히 트랜잭션 매니저가 어딘가에 Connection을 저장해두고 Repository가 꺼내 쓰면 될 것처럼 보인다.

하지만 웹 서버 환경에서는 문제가 생긴다.

웹 서버는 요청마다 다른 스레드가 처리한다.

```text
요청 A → Thread A
요청 B → Thread B
```

만약 모든 요청이 하나의 공용 보관함에서 Connection을 꺼내 쓴다면, 서로 다른 요청의 Connection이 뒤섞일 수 있다.

즉, 스레드별로 독립적인 저장 공간이 필요하다.

---

## 해결책 2: ThreadLocal

이 문제를 해결하는 도구가 **ThreadLocal**이다.

ThreadLocal은 스레드마다 독립적인 값을 저장할 수 있는 공간이다.

```text
Thread A → Connection A
Thread B → Connection B
Thread C → Connection C
```

각 스레드는 자기 보관함만 볼 수 있다.

그래서 동시에 여러 요청이 들어와도 Connection이 섞이지 않는다.

---

## ThreadLocal을 활용한 트랜잭션 흐름

전체 흐름은 다음과 같다.

```text
1. 서비스가 Transaction Manager에 실행 요청
2. Transaction Manager가 Connection 생성
3. Connection을 ThreadLocal에 저장
4. Repository는 ThreadLocal에서 Connection 조회
5. Repository 작업 수행
6. Transaction Manager가 commit 또는 rollback
7. ThreadLocal에서 Connection 제거
8. Connection close
```

핵심은 Repository 인터페이스에는 Connection이 드러나지 않는다는 점이다.

```java
repository.save(data);
```

하지만 내부 구현체는 현재 스레드의 ThreadLocal에서 Connection을 꺼내 사용한다.

---

## ThreadLocal 사용 시 중요한 주의점

ThreadLocal은 반드시 정리해야 한다.

웹 서버는 스레드 풀을 사용한다.
즉, 요청이 끝나도 스레드가 사라지지 않고 재사용된다.

만약 ThreadLocal 값을 제거하지 않으면 다음 요청에서 이전 요청의 Connection이 남아 있을 수 있다.

그래서 트랜잭션이 끝나면 반드시 제거해야 한다.

```java
threadLocal.remove();
```

정리하지 않으면 다음 문제가 생길 수 있다.

```text
Connection 누수
이전 요청 데이터 참조
트랜잭션 꼬임
메모리 누수
```

---

## 이 구조가 Spring의 @Transactional과 닮은 이유

이 구조는 Spring의 `@Transactional` 내부 동작과 매우 비슷하다.

Spring도 트랜잭션을 시작할 때 현재 스레드에 Connection을 바인딩한다.

그리고 Repository나 JDBC Template은 직접 Connection을 전달받지 않아도 현재 스레드에 묶인 Connection을 사용한다.

Spring 내부에서는 `TransactionSynchronizationManager`가 이런 역할을 한다.

즉, 우리가 `@Transactional`을 사용할 때 다음 코드만 작성해도 된다.

```java
@Transactional
public void createOrder() {
    orderRepository.save(order);
    paymentRepository.save(payment);
}
```

서비스는 Connection을 모른다.
Repository도 인터페이스에서는 Connection을 드러내지 않는다.
하지만 내부적으로는 같은 트랜잭션 Connection이 유지된다.

---

## 캡슐화 관점에서 얻는 이점

이 구조의 가장 큰 장점은 책임 분리다.

## 서비스 계층

서비스는 비즈니스 로직만 담당한다.

```text
주문 생성
결제 생성
재고 차감
```

## 트랜잭션 매니저

트랜잭션 매니저는 트랜잭션 경계를 담당한다.

```text
begin
commit
rollback
close
```

## Repository

Repository는 데이터 접근만 담당한다.

```text
SQL 실행
데이터 저장
데이터 조회
```

각 계층의 책임이 분리되면서 코드가 훨씬 깔끔해진다.

---

## 적용 전후 비교

## 적용 전

```text
Service
- 비즈니스 로직
- Connection 생성
- Connection 전달
- commit
- rollback
- close
```

서비스가 너무 많은 책임을 가진다.

## 적용 후

```text
Service
- 비즈니스 로직

Transaction Manager
- Connection 생성
- commit
- rollback
- close

ThreadLocal
- 현재 스레드의 Connection 보관

Repository
- 현재 트랜잭션 Connection 사용
```

책임이 명확히 분리된다.

---

## 이 방식의 핵심 인사이트

이 문제의 본질은 단순히 JDBC 사용법이 아니다.

핵심은 이것이다.

```text
트랜잭션을 유지하려면 같은 Connection이 필요하다
하지만 Connection을 서비스와 Repository 인터페이스에 노출하면 캡슐화가 깨진다
그래서 Connection 전달을 외부에서 관리해야 한다
```

이를 해결하는 조합이 바로 다음 두 가지다.

```text
Transaction Manager
+
ThreadLocal
```

---

## 마무리

JDBC에서 트랜잭션을 직접 관리할 때 서비스가 Connection을 직접 만들고 Repository에 넘기는 방식은 쉽게 떠올릴 수 있다. 하지만 이 방식은 서비스가 JDBC 세부사항을 알게 만들고, Repository 인터페이스에 Connection을 노출시켜 캡슐화를 깨뜨린다.

이를 해결하려면 트랜잭션 관리 책임을 서비스 밖으로 분리해야 한다.

```text
서비스는 비즈니스 로직만 담당한다
트랜잭션 매니저가 커넥션과 트랜잭션 경계를 관리한다
ThreadLocal이 스레드별 Connection을 안전하게 보관한다
Repository는 Connection을 파라미터로 받지 않아도 같은 트랜잭션을 사용할 수 있다
```

결국 이 구조는 Spring의 `@Transactional`이 내부적으로 제공하는 편리함의 원리와 맞닿아 있다.

우리가 프레임워크를 사용할 때는 단순히 “마법처럼 된다”고 느끼지만, 그 안에는 명확한 설계 이유가 있다.

```text
캡슐화를 지키기 위해
트랜잭션 경계를 분리하고
스레드별 자원을 안전하게 관리한다
```

이 원리를 이해하면 `@Transactional`을 더 신뢰하고, 직접 JDBC를 다룰 때도 더 안전한 구조를 설계할 수 있다.

