---
layout: post
bigtitle: '스프링 부트 데이터베이스'
subtitle: 스프링 부트 데이터베이스 4 - DataSource Config 클래스 연결
date: '2026-06-04 00:00:01 +0900'
categories:
    - developer-yumi
comments: true

---

# 스프링 부트 데이터베이스 4 - DataSource Config 클래스 연결
[https://youtu.be/zVBTyhVvxfE?si=3m-YXlpzLIhu0EHw](https://youtu.be/zVBTyhVvxfE?si=3m-YXlpzLIhu0EHw)

# 스프링 부트 데이터베이스 4 - DataSource Config 클래스 연결
* toc
{:toc}

---

## Spring Boot에서 Configuration 클래스로 DataSource 설정하기

이번 글에서는 Spring Boot에서 데이터베이스 연결 정보를 `application.properties`에만 작성하는 방식이 아니라,
직접 **Java Configuration 클래스**를 만들어 `DataSource`를 Bean으로 등록하는 방법을 정리한다.

핵심은 다음이다.

> **@Configuration 클래스 안에서 @Bean 메소드로 DataSource 객체를 생성하면 Spring Boot가 해당 DataSource를 사용해 DB 연결을 관리한다.**

이 방식은 단일 DB 연결뿐 아니라, 이후 다중 DB 연결을 구성할 때도 기본이 되는 중요한 개념이다.

---

## 1. 기존 application.properties 방식 복습

이전 방식에서는 `application.properties`에 다음과 같이 DB 연결 정보를 작성했다.

```properties
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.url=jdbc:mysql://localhost:3306/testdb
spring.datasource.username=root
spring.datasource.password=1234
```

이렇게 작성하면 Spring Boot가 자동으로 `DataSource`를 생성하고 DB 연결을 처리한다.

하지만 이번 글에서는 이 설정을 제거하고, 직접 Java 코드로 `DataSource`를 등록한다.

---

## 2. Configuration 클래스 방식이란?

Spring Boot에서는 특정 객체를 직접 생성해서 Spring Container에 등록할 수 있다.

이때 사용하는 대표 어노테이션이 두 가지다.

```java
@Configuration
```

```java
@Bean
```

각 역할은 다음과 같다.

| 어노테이션            | 역할                             |
| ---------------- | ------------------------------ |
| `@Configuration` | 이 클래스가 설정 클래스임을 의미             |
| `@Bean`          | 메소드가 반환하는 객체를 Spring Bean으로 등록 |

즉, `DataSource` 객체를 `@Bean`으로 등록하면 Spring Boot는 이 객체를 이용해 DB 연결을 수행한다.

---

## 3. Config 패키지 생성

먼저 설정 클래스를 관리할 패키지를 만든다.

```text
src/main/java
 └── config
      └── DBConfig.java
```

클래스 이름은 자유롭게 정할 수 있지만, 보통 다음과 같이 사용한다.

```text
DBConfig
DatabaseConfig
DataSourceConfig
```

---

## 4. DBConfig 클래스 생성

기본 구조는 다음과 같다.

```java
import org.springframework.context.annotation.Configuration;

@Configuration
public class DBConfig {
}
```

`@Configuration`을 붙이면 Spring Boot가 이 클래스를 설정 클래스로 인식한다.

---

## 5. DataSource Bean 등록하기

이제 클래스 내부에 `DataSource`를 반환하는 메소드를 작성한다.

```java
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

@Configuration
public class DBConfig {

    @Bean
    public DataSource getDataSource() {
        return DataSourceBuilder.create()
                .driverClassName("com.mysql.cj.jdbc.Driver")
                .url("jdbc:mysql://localhost:3306/testdb")
                .username("root")
                .password("1234")
                .build();
    }
}
```

---

## 6. 코드 설명

### DataSourceBuilder

```java
DataSourceBuilder.create()
```

`DataSource` 객체를 쉽게 생성할 수 있도록 도와주는 Builder 클래스다.

---

### driverClassName

```java
.driverClassName("com.mysql.cj.jdbc.Driver")
```

MySQL Driver를 지정한다.

Oracle DB라면 Oracle Driver 클래스를 지정하면 된다.

---

### url

```java
.url("jdbc:mysql://localhost:3306/testdb")
```

DB 접속 주소를 지정한다.

구조는 다음과 같다.

```text
jdbc:mysql://호스트:포트/데이터베이스명
```

---

### username / password

```java
.username("root")
.password("1234")
```

DB 접속 계정과 비밀번호를 지정한다.

---

### build

```java
.build()
```

최종적으로 `DataSource` 객체를 생성한다.

---

## 7. application.properties 설정 제거

기존에 아래 설정이 있었다면 제거한다.

```properties
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.url=jdbc:mysql://localhost:3306/testdb
spring.datasource.username=root
spring.datasource.password=1234
```

이제 DB 연결은 `DBConfig` 클래스에서 직접 등록한 `DataSource` Bean을 통해 처리된다.

---

## 8. 실행 결과 확인

애플리케이션을 실행했을 때 오류 없이 실행되면 DB 연결이 성공한 것이다.

정상적으로 연결되면 내부적으로 HikariCP가 동작하면서 DataSource가 초기화된다.

```text
HikariPool-1 - Starting...
HikariPool-1 - Start completed.
```

이런 로그가 보이면 DB Connection Pool이 정상적으로 생성된 것이다.

제공된 정리 자료에서도 `DataSourceBuilder`를 통해 driver, url, username, password를 지정하고 `build()`로 DataSource를 생성하는 흐름을 설명한다.

---

## 9. 오류 발생 시 확인할 것

### 1) MySQL Driver 의존성 누락

`build.gradle`에 MySQL Driver가 없으면 연결할 수 없다.

```gradle
runtimeOnly 'com.mysql:mysql-connector-j'
```

---

### 2) Spring Data JPA 의존성 누락

JPA를 사용할 경우 아래 의존성이 필요하다.

```gradle
implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
```

---

### 3) application.properties 설정과 충돌

기존 `spring.datasource.*` 설정이 남아 있으면 혼동이 생길 수 있다.

이번 방식에서는 DB 연결 정보를 `DBConfig`에서 관리하므로, 기존 설정은 제거하는 것이 좋다.

---

### 4) 자동 설정 충돌

특정 상황에서 Spring Boot의 자동 DataSource 설정과 직접 등록한 Config가 충돌할 수 있다.

이 경우 자동 설정을 제외할 수 있다.

```properties
spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration
```

단, 일반적인 단일 DB 설정에서는 보통 직접 제외하지 않아도 된다.
자동 설정 제외는 충돌이 발생할 때만 사용한다.

---

## 10. 이 방식의 장점

### 1) 설정을 Java 코드로 명확하게 제어 가능

`application.properties`보다 더 직접적으로 DB 연결 객체를 구성할 수 있다.

---

### 2) 다중 DB 연결로 확장 가능

단일 연결에서는 설정 파일 방식이 더 간단하지만,
여러 개의 DB를 연결해야 할 경우 Configuration 클래스 방식이 필요하다.

예를 들어:

```text
mainDataSource
subDataSource
logDataSource
```

처럼 여러 DataSource를 Bean으로 등록할 수 있다.

---

### 3) 세부 설정 커스터마이징 가능

HikariCP, 트랜잭션 매니저, EntityManagerFactory 등을 직접 연결해야 할 때 유용하다.

---

## 11. application.properties 방식과 Config 방식 비교

| 구분     | application.properties 방식 | Configuration 클래스 방식 |
| ------ | ------------------------- | -------------------- |
| 난이도    | 쉬움                        | 상대적으로 복잡             |
| 단일 DB  | 적합                        | 가능                   |
| 다중 DB  | 부적합                       | 적합                   |
| 커스터마이징 | 제한적                       | 유연함                  |
| 코드 관리  | 설정 파일 중심                  | Java 코드 중심           |

---

## 12. 실무 관점에서의 선택 기준

단일 DB만 사용하는 일반적인 프로젝트라면:

```text
application.properties 방식
```

이 더 간단하다.

하지만 다음과 같은 상황이라면 Configuration 클래스 방식이 적합하다.

```text
여러 DB 연결
Read DB / Write DB 분리
운영 DB / 로그 DB 분리
동적 DataSource 구성
Connection Pool 세부 설정
```

즉, 이번 방식은 단순 연결보다는 **확장 가능한 DB 연결 구조의 출발점**으로 이해하는 것이 좋다.

---

## 정리

이번 글에서는 Spring Boot에서 Java Configuration 클래스를 사용해
`DataSource`를 직접 Bean으로 등록하는 방법을 정리했다.

핵심 흐름은 다음과 같다.

```text
DBConfig 클래스 생성
→ @Configuration 선언
→ @Bean 메소드 작성
→ DataSourceBuilder로 DataSource 생성
→ Spring Boot가 해당 DataSource 사용
```

단일 DB 연결만 필요하다면 `application.properties` 방식이 더 간단하지만,
다중 DB 연결이나 세부 설정이 필요한 경우에는 Configuration 클래스 방식이 훨씬 유리하다.
