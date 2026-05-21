---
layout: post
bigtitle: '스프링 부트 데이터베이스'
subtitle: 스프링 부트 데이터베이스 2 - MySQL RDB 단일 연결
date: '2026-05-21 00:00:01 +0900'
categories:
    - developer-yumi
comments: true

---

# 스프링 부트 데이터베이스 2 - MySQL RDB 단일 연결
[https://youtu.be/7dhbaMWaJ3Y?si=iU6KeGwaumOyTziW](https://youtu.be/7dhbaMWaJ3Y?si=iU6KeGwaumOyTziW)

# 스프링 부트 데이터베이스 2 - MySQL RDB 단일 연결
* toc
{:toc}

---

## Spring Boot에서 MySQL RDB 단일 연결(Single Connection) 설정하기

이번 글에서는
Spring Boot 프로젝트에서 MySQL 데이터베이스를
가장 간단하게 연결하는 방법인:

```text
단일 연결(Single Connection)
```

설정을 정리한다.

Spring Boot는 기본적으로:

* JDBC Driver
* DataSource
* JPA 연결

등을 자동 구성(Auto Configuration) 해주기 때문에
설정 파일만 작성해도 MySQL 연결이 가능하다.

---

# 1. Spring Boot에서 MySQL 연결 방식

Spring Boot에서 MySQL을 연결하는 방법은 크게 두 가지다.

| 방식    | 설명          |
| ----- | ----------- |
| 단일 연결 | 하나의 DB만 연결  |
| 다중 연결 | 여러 DB 동시 연결 |

---

# 2. 단일 연결(Single Connection)이란?

단일 연결은:

```text
Spring Boot 프로젝트에
하나의 MySQL 데이터베이스만 연결하는 방식
```

이다.

---

## 특징

Spring Boot가 내부적으로:

* Driver 생성
* DataSource 생성
* Connection 설정

등을 자동 처리한다.

즉:

```text
Configuration 클래스 직접 작성 불필요
```

하다.

---

# 3. 단일 연결의 장점

---

## 1) 설정이 매우 간단함

```properties
application.properties
```

설정만으로 연결 가능

---

## 2) 개발 속도 빠름

초기 프로젝트 구성에 매우 유리

---

## 3) 테스트 환경 구축 쉬움

로컬 개발 환경에서 자주 사용

---

# 4. 단일 연결 시 필요한 정보

MySQL 연결에는 아래 정보가 필요하다.

| 항목          | 설명       |
| ----------- | -------- |
| IP 주소       | DB 서버 주소 |
| Port        | MySQL 포트 |
| Database 이름 | 사용할 DB   |
| Username    | DB 계정    |
| Password    | 비밀번호     |

---

# 5. MySQL 기본 포트

기본 MySQL 포트는:

```text
3306
```

이다.

---

# 6. Spring Boot 프로젝트 생성

---

## Spring Initializr 설정

예시:

| 항목          | 값      |
| ----------- | ------ |
| Language    | Java   |
| Build Tool  | Gradle |
| Spring Boot | 3.x    |
| Java        | 17 이상  |

---

# 7. 필수 의존성 추가

MySQL 연결에는 아래 두 개가 핵심이다.

---

## 1) Spring Data JPA

```text
spring-boot-starter-data-jpa
```

ORM 사용

---

## 2) MySQL Driver

```text
mysql-connector-j
```

DB 연결 Driver

---

# 8. build.gradle 예시

```gradle
dependencies {

    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'

    runtimeOnly 'com.mysql:mysql-connector-j'

}
```

---

# 9. application.properties 위치

경로:

```text
src/main/resources/application.properties
```

---

# 10. MySQL 연결 핵심 설정

---

## 기본 설정 예시

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/testdb

spring.datasource.username=root

spring.datasource.password=1234
```

---

# 11. 각 설정 의미 분석

---

## 1) URL

```properties
spring.datasource.url
```

DB 주소 설정

---

## 구조

```text
jdbc:mysql://IP:PORT/DB이름
```

---

## 예시

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/testdb
```

| 값         | 의미        |
| --------- | --------- |
| localhost | DB 서버 주소  |
| 3306      | MySQL 포트  |
| testdb    | 데이터베이스 이름 |

---

# 12. Username 설정

```properties
spring.datasource.username=root
```

MySQL 접속 계정

---

# 13. Password 설정

```properties
spring.datasource.password=1234
```

DB 비밀번호

---

# 14. Driver 설정 추가

실무에서는 명시적으로 작성하기도 한다.

```properties
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
```

---

# 15. 전체 설정 예시

```properties
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

spring.datasource.url=jdbc:mysql://localhost:3306/testdb

spring.datasource.username=root

spring.datasource.password=1234
```

---

# 16. AWS RDS 연결 예시

로컬 MySQL이 아니라 AWS RDS를 사용하는 경우:

```properties
spring.datasource.url=jdbc:mysql://rds주소:3306/testdb
```

형태 사용

---

# 17. 추가 URL 옵션

실무에서는 보통 아래 옵션도 추가한다.

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/testdb?serverTimezone=Asia/Seoul&characterEncoding=UTF-8
```

---

# 18. 왜 옵션을 추가할까?

---

## serverTimezone

시간대 문제 방지

---

## characterEncoding=UTF-8

한글 깨짐 방지

---

# 19. Spring Boot 자동 연결 원리

Spring Boot는:

```text
spring.datasource.*
```

설정을 읽으면 내부적으로:

* HikariCP 생성
* DataSource 생성
* JDBC 연결

자동 수행

---

# 20. 실행 후 성공 여부 확인

정상 연결되면:

```text
애플리케이션이 오류 없이 실행
```

된다.

---

# 21. 연결 실패 시 대표 오류

---

## Access denied

```text
아이디/비밀번호 오류
```

---

## Communications link failure

```text
IP 또는 포트 문제
```

---

## Unknown database

```text
DB 이름 없음
```

---

## Driver 오류

```text
mysql-connector-j 의존성 누락
```

---

# 22. JPA DDL 자동 생성 설정

Spring Boot는 Entity 기반으로 테이블 생성 가능하다.

---

## 설정 예시

```properties
spring.jpa.hibernate.ddl-auto=create
```

---

# 23. ddl-auto 옵션 종류

| 옵션       | 설명            |
| -------- | ------------- |
| create   | 실행 시 테이블 새 생성 |
| update   | 변경된 부분만 반영    |
| validate | 검증만 수행        |
| none     | 아무 작업 안함      |

---

# 24. 실무 추천 설정

---

## 개발 환경

```properties
spring.jpa.hibernate.ddl-auto=update
```

---

## 운영 환경

```properties
spring.jpa.hibernate.ddl-auto=none
```

실무에서는 운영 DB 자동 변경을 매우 조심한다.

---

# 25. SQL 로그 출력 설정

매우 유용한 옵션

```properties
spring.jpa.show-sql=true
```

---

## 결과

실행되는 SQL 확인 가능

---

# 26. 네이밍 전략 설정

Entity 변수명을 DB 컬럼명 그대로 사용 가능

```properties
spring.jpa.hibernate.naming.physical-strategy=org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
```

---

# 27. 기본 동작 차이

설정 없으면:

```text
userName
→ user_name
```

스네이크 케이스 변환

---

## 설정 적용 시

```text
userName
→ userName
```

그대로 사용

---

# 28. 실무에서 가장 중요한 포인트

Spring Boot는:

```text
Auto Configuration
```

덕분에 매우 간단하게 DB 연결 가능하다.

즉:

```text
설정만 하면
Spring Boot가 내부 객체를 자동 생성
```

한다.

---

# 29. 단일 연결 vs 다중 연결 차이

---

## 단일 연결

```text
application.properties
```

만으로 가능

---

## 다중 연결

직접:

* DataSource
* EntityManager
* TransactionManager

설정 필요

복잡도 급상승

---

# 30. 추천 개발 흐름

실무 초반에는:

```text
단일 연결
```

로 시작 후

서비스가 커지면:

```text
다중 DB 구조
```

확장하는 경우 많다.

---

# 31. 이번 글 핵심 정리

---

## 핵심 설정

```properties
spring.datasource.url

spring.datasource.username

spring.datasource.password
```

---

## 필수 의존성

* Spring Data JPA
* MySQL Driver

---

## 장점

* 설정 단순
* 빠른 개발 가능
* Auto Configuration 활용

---

# 마무리

Spring Boot의 가장 큰 장점 중 하나는:

```text
복잡한 JDBC 설정을 자동화해준다는 것
```

이다.

특히 단일 DB 연결은:

```text
application.properties
```

설정만으로 거의 모든 연결 작업이 끝나기 때문에
빠른 개발과 테스트 환경 구축에 매우 유리하다. 


