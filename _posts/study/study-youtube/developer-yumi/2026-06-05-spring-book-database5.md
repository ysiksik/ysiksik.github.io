---
layout: post
bigtitle: '스프링 부트 데이터베이스'
subtitle: 스프링 부트 데이터베이스 5 - 다중 DB 연결 (DB 2개 연결)
date: '2026-06-05 00:00:00 +0900'
categories:
    - developer-yumi
comments: true

---

# 스프링 부트 데이터베이스 5 - 다중 DB 연결 (DB 2개 연결)
[https://youtu.be/kr1qSddBygk?si=TMk5O8_OZkdvD3IK](https://youtu.be/kr1qSddBygk?si=TMk5O8_OZkdvD3IK)

# 스프링 부트 데이터베이스 5 - 다중 DB 연결 (DB 2개 연결)
* toc
{:toc}

---

## Spring Boot에서 다중 데이터베이스(Multi DB) 연결하기

이번 글에서는 하나의 Spring Boot 프로젝트에서 **두 개 이상의 데이터베이스를 연결하는 방법**을 정리한다.

Spring Boot는 기본적으로 `application.properties` 또는 `application.yml`에 설정된 **하나의 DataSource만 자동 구성(Auto Configuration)** 해준다.

하지만 실무에서는 다음과 같은 경우가 존재한다.

* 회원 DB + 로그 DB
* 서비스 DB + 통계 DB
* MySQL + Oracle
* 운영 DB + 읽기 전용(Read Replica) DB

이런 경우에는 개발자가 직접 Configuration 클래스를 작성해야 한다.

---

# 1. 다중 데이터베이스란?

다중 데이터베이스(Multi Database)란 하나의 Spring Boot 애플리케이션이 여러 개의 DB와 동시에 연결되는 구조를 말한다.

예를 들면 다음과 같다.

```text
Spring Boot

├── First DB (회원)
│    ├── UserEntity
│    └── UserRepository
│
└── Second DB (로그)
     ├── LogEntity
     └── LogRepository
```

각 DB는 서로 다른 Entity와 Repository를 사용한다.

영상에서도 Spring Boot는 기본적으로 하나의 DB만 자동 연결하며, 두 개 이상 연결 시에는 별도의 Configuration 클래스 작성이 필요하다고 설명한다.

---

# 2. 프로젝트 구조 설계

예제에서는 MySQL 서버 내부에 다음 두 개의 DB를 생성한다.

```sql
CREATE DATABASE first;
CREATE DATABASE second;
```

확인

```sql
SHOW DATABASES;
```

결과

```text
first
second
```

---

## 패키지 구조

```text
com.example.multidb

├── config
│   ├── FirstDatabaseConfig
│   └── SecondDatabaseConfig
│
├── firstdb
│   ├── entity
│   └── repository
│
└── seconddb
    ├── entity
    └── repository
```

---

# 3. 필요한 의존성

## Gradle

```gradle
dependencies {

    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'

    runtimeOnly 'com.mysql:mysql-connector-j'

    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'
}
```

필수

```text
Spring Data JPA
MySQL Driver
```

---

# 4. First DB Config 작성

---

## @Configuration 등록

```java
@Configuration
@EnableJpaRepositories(
        basePackages = "com.example.firstdb.repository",
        entityManagerFactoryRef = "firstEntityManagerFactory",
        transactionManagerRef = "firstTransactionManager"
)
public class FirstDatabaseConfig {
}
```

### 설명

| 옵션                      | 설명                         |
| ----------------------- | -------------------------- |
| basePackages            | First DB Repository 위치     |
| entityManagerFactoryRef | EntityManager Bean 이름      |
| transactionManagerRef   | TransactionManager Bean 이름 |

---

# 5. First DataSource 등록

```java
@Bean
@Primary
public DataSource firstDataSource() {

    return DataSourceBuilder.create()
            .driverClassName("com.mysql.cj.jdbc.Driver")
            .url("jdbc:mysql://localhost:3306/first")
            .username("root")
            .password("1234")
            .build();
}
```

---

## 역할

```text
First DB 연결
```

즉

```java
jdbc:mysql://localhost:3306/first
```

를 통해 first DB와 연결된다.

---

# 6. First EntityManagerFactory 등록

```java
@Bean
@Primary
public LocalContainerEntityManagerFactoryBean firstEntityManagerFactory() {

    LocalContainerEntityManagerFactoryBean em
            = new LocalContainerEntityManagerFactoryBean();

    em.setDataSource(firstDataSource());

    em.setPackagesToScan(
            "com.example.firstdb.entity"
    );

    em.setJpaVendorAdapter(
            new HibernateJpaVendorAdapter()
    );

    Map<String, Object> properties = new HashMap<>();

    properties.put(
            "hibernate.hbm2ddl.auto",
            "update"
    );

    em.setJpaPropertyMap(properties);

    return em;
}
```

---

## 역할

Entity 스캔

```java
em.setPackagesToScan(
        "com.example.firstdb.entity"
);
```

즉

```text
firstdb/entity
```

패키지 내부 Entity만 관리한다.

---

## DDL 자동 생성

```java
hibernate.hbm2ddl.auto=update
```

설정 효과

```text
Entity 생성
↓
Hibernate 감지
↓
테이블 자동 생성
```

---

# 7. First TransactionManager 등록

```java
@Bean
@Primary
public PlatformTransactionManager firstTransactionManager() {

    JpaTransactionManager tm =
            new JpaTransactionManager();

    tm.setEntityManagerFactory(
            firstEntityManagerFactory().getObject()
    );

    return tm;
}
```

---

## 역할

트랜잭션 처리

```java
@Transactional
```

사용 시

```text
First DB 트랜잭션 담당
```

---

# 8. Second DB Config 작성

거의 동일하다.

---

## Configuration

```java
@Configuration
@EnableJpaRepositories(
        basePackages = "com.example.seconddb.repository",
        entityManagerFactoryRef = "secondEntityManagerFactory",
        transactionManagerRef = "secondTransactionManager"
)
public class SecondDatabaseConfig {
}
```

---

## DataSource

```java
@Bean
public DataSource secondDataSource() {

    return DataSourceBuilder.create()
            .driverClassName("com.mysql.cj.jdbc.Driver")
            .url("jdbc:mysql://localhost:3306/second")
            .username("root")
            .password("1234")
            .build();
}
```

---

## EntityManager

```java
@Bean
public LocalContainerEntityManagerFactoryBean secondEntityManagerFactory() {

    LocalContainerEntityManagerFactoryBean em
            = new LocalContainerEntityManagerFactoryBean();

    em.setDataSource(secondDataSource());

    em.setPackagesToScan(
            "com.example.seconddb.entity"
    );

    em.setJpaVendorAdapter(
            new HibernateJpaVendorAdapter()
    );

    Map<String, Object> properties = new HashMap<>();

    properties.put(
            "hibernate.hbm2ddl.auto",
            "update"
    );

    em.setJpaPropertyMap(properties);

    return em;
}
```

---

## TransactionManager

```java
@Bean
public PlatformTransactionManager secondTransactionManager() {

    JpaTransactionManager tm =
            new JpaTransactionManager();

    tm.setEntityManagerFactory(
            secondEntityManagerFactory().getObject()
    );

    return tm;
}
```

---

# 9. @Primary가 필요한 이유

가장 많이 발생하는 오류이다.

Spring은 동일 타입 Bean이 여러 개 있으면 어떤 Bean을 사용할지 모른다.

예를 들어

```java
DataSource
```

가 두 개 존재한다.

```java
firstDataSource
secondDataSource
```

Spring 입장에서는

```text
어느 DataSource를 기본으로 사용할까?
```

를 결정할 수 없다.

그래서 하나를 기본으로 지정해야 한다.

```java
@Primary
@Bean
public DataSource firstDataSource() {
}
```

영상에서도 첫 번째 Config의 Bean들에 `@Primary`를 지정하여 우선순위를 부여해야 한다고 설명한다.

---

# 10. 실행 결과

정상 실행되면 로그에 Hikari Pool이 두 개 생성된다.

```text
HikariPool-1 - Start completed.
HikariPool-2 - Start completed.
```

즉

```text
DB 1 연결 성공
DB 2 연결 성공
```

을 의미한다.

---

# 11. 테스트용 Entity 생성

Second DB 테스트

```java
@Entity
public class SecondEntity {

    @Id
    @GeneratedValue
    private Long id;

    private String name;
}
```

---

Repository

```java
public interface SecondRepository
        extends JpaRepository<SecondEntity, Long> {
}
```

---

애플리케이션 실행

```text
hibernate.hbm2ddl.auto=update
```

설정에 의해

```sql
CREATE TABLE second_entity ...
```

가 자동 실행된다.

영상에서도 SecondEntity와 Repository를 생성한 뒤 실행하면 second DB에 테이블이 자동 생성되는 것을 확인한다.

---

# 12. 실무에서 자주 사용하는 구조

## 1. Master / Slave

```text
Master DB
 └─ INSERT
 └─ UPDATE
 └─ DELETE

Slave DB
 └─ SELECT
```

조회와 쓰기 분리

---

## 2. 서비스 분리

```text
회원 DB
결제 DB
로그 DB
통계 DB
```

---

## 3. 이기종 DB

```text
MySQL
Oracle
MongoDB
Redis
```

하나의 서비스에서 동시에 사용

---

# 정리

다중 DB 연결의 핵심 구조는 다음과 같다.

```text
DB마다

1. DataSource 생성
2. EntityManagerFactory 생성
3. TransactionManager 생성
4. Repository 패키지 연결
5. Entity 패키지 연결
```

즉 Spring Boot의 Multi DB 설정은

```text
DataSource
↓
EntityManagerFactory
↓
TransactionManager
↓
Repository
```

를 DB 개수만큼 각각 구성하는 것이 핵심이다.

이번 내용은 단순히 "DB를 2개 붙이는 방법"이 아니라, 이후 **Master/Slave 분리, Read Replica 구성, CQRS, 멀티 테넌시 구조**를 이해하는 기초가 되는 매우 중요한 설정이다.
