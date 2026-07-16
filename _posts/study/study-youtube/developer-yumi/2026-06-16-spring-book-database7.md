---
layout: post
bigtitle: '스프링 부트 데이터베이스'
subtitle: 스프링 부트 데이터베이스 7 - MySQL MongoDB 다중 연결
date: '2026-06-16 00:00:03 +0900'
categories:
    - developer-yumi
comments: true

---

# 스프링 부트 데이터베이스 7 - MySQL MongoDB 다중 연결
[https://youtu.be/OSjF4sNgOq4?si=tC6165Xib6cbAmAS](https://youtu.be/OSjF4sNgOq4?si=tC6165Xib6cbAmAS)
# 스프링 부트 데이터베이스 7 - MySQL MongoDB 다중 연결
* toc
{:toc}

---

## Spring Boot에서 MySQL과 MongoDB를 동시에 연결하기

Spring Boot 애플리케이션에서는 관계형 데이터베이스인 MySQL과 문서형 NoSQL 데이터베이스인 MongoDB를 동시에 사용할 수 있다.

예를 들어 다음과 같이 데이터 특성에 따라 저장소를 분리할 수 있다.

* 회원, 주문, 결제처럼 관계와 트랜잭션이 중요한 데이터는 MySQL에 저장
* 로그, 이벤트, 비정형 문서처럼 구조가 유연한 데이터는 MongoDB에 저장

이번 글에서는 하나의 Spring Boot 프로젝트에 MySQL과 MongoDB를 함께 연결하고, 각 저장소에서 데이터를 조회하는 방법을 정리한다.

핵심은 다음과 같다.

> MySQL과 MongoDB는 서로 다른 Spring Boot 자동 설정을 사용하므로, 각각 하나씩 연결한다면 `application.properties`에 두 연결 정보를 함께 작성하는 것만으로도 사용할 수 있다.

---

## 전체 구조

이번에 구성할 애플리케이션 구조는 다음과 같다.

```mermaid
flowchart LR
    A[Spring Boot Application] --> B[Spring Data JPA]
    A --> C[Spring Data MongoDB]

    B --> D[MySQL]
    C --> E[MongoDB]

    D --> F[RDB Table]
    E --> G[MongoDB Collection]
```

애플리케이션 내부에서는 저장소마다 다른 접근 기술을 사용한다.

```text
MySQL
→ Entity
→ JpaRepository
→ JPA TransactionManager

MongoDB
→ Document
→ MongoRepository
→ MongoTransactionManager 또는 기본 비트랜잭션 접근
```

MySQL은 `DataSource`와 JPA를 사용하지만, MongoDB는 JDBC `DataSource`를 사용하지 않는다. MongoDB 연결에는 `MongoClient`, `MongoDatabaseFactory`, `MongoTemplate` 등이 사용된다.

따라서 MySQL과 MongoDB를 동시에 사용한다고 해서 반드시 두 개의 `DataSource`를 설정해야 하는 것은 아니다.

---

## 왜 MySQL과 MongoDB를 함께 사용하는가?

두 데이터베이스는 저장 방식과 강점이 다르다.

| 구분                | MySQL           | MongoDB                |
| ----------------- | --------------- | ---------------------- |
| 데이터 모델            | 테이블과 행          | Collection과 Document   |
| 스키마               | 비교적 엄격함         | 유연함                    |
| 관계 표현             | JOIN, 외래 키      | 중첩 Document, Reference |
| 트랜잭션              | 강력한 ACID 지원     | Replica Set에서 트랜잭션 지원  |
| 적합한 데이터           | 주문, 결제, 회원      | 로그, 이벤트, 콘텐츠, 비정형 데이터  |
| Spring Repository | `JpaRepository` | `MongoRepository`      |

서비스의 모든 데이터를 하나의 데이터베이스에 저장하기보다, 데이터 성격에 맞는 저장소를 선택하는 방식을 폴리글랏 퍼시스턴스라고 한다.

예를 들면 다음과 같이 나눌 수 있다.

```text
MySQL
- 회원
- 주문
- 결제
- 재고

MongoDB
- 사용자 행동 로그
- 검색 이력
- 이벤트 데이터
- 유연한 메타데이터
```

---

## 필요한 접속 정보 준비

MySQL 연결을 위해 다음 정보가 필요하다.

```text
Host
Port
Database 이름
Username
Password
```

MySQL의 기본 포트는 다음과 같다.

```text
3306
```

MongoDB 연결에는 다음 정보가 필요하다.

```text
MongoDB URI
또는
Host
Port
Database
Username
Password
```

MongoDB 기본 포트는 다음과 같다.

```text
27017
```

MongoDB Atlas를 사용한다면 일반적으로 하나의 URI를 제공받는다.

```text
mongodb+srv://사용자명:비밀번호@클러스터주소/데이터베이스명
```

---

## Spring Boot 프로젝트 의존성 구성

MySQL과 MongoDB를 함께 사용하려면 각 데이터베이스에 필요한 Spring Data 의존성을 추가해야 한다.

### build.gradle

```gradle
dependencies {
    // MySQL 및 JPA
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    runtimeOnly 'com.mysql:mysql-connector-j'

    // MongoDB
    implementation 'org.springframework.boot:spring-boot-starter-data-mongodb'

    // 웹 화면 확인
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-mustache'

    // Lombok
    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'

    // 테스트
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}
```

각 의존성의 역할은 다음과 같다.

| 의존성                                | 역할                         |
| ---------------------------------- | -------------------------- |
| `spring-boot-starter-data-jpa`     | JPA와 Hibernate 사용          |
| `mysql-connector-j`                | MySQL JDBC Driver          |
| `spring-boot-starter-data-mongodb` | MongoDB 연결 및 Repository 지원 |
| `spring-boot-starter-web`          | MVC와 Controller 사용         |
| `spring-boot-starter-mustache`     | Mustache 템플릿 렌더링           |

MongoDB Reactive 방식이 아니라 일반적인 블로킹 방식을 사용할 것이므로 `spring-boot-starter-data-mongodb-reactive`가 아닌 `spring-boot-starter-data-mongodb`를 사용한다.

---

## application.properties 설정

MySQL과 MongoDB는 서로 다른 설정 키를 사용한다.

따라서 다음처럼 하나의 설정 파일에 함께 작성할 수 있다.

```properties
# MySQL
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.url=jdbc:mysql://localhost:3306/first?serverTimezone=Asia/Seoul&characterEncoding=UTF-8
spring.datasource.username=root
spring.datasource.password=password

# JPA
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# MongoDB
spring.data.mongodb.uri=mongodb://mongoUser:mongoPassword@localhost:27017/testDB1?authSource=admin
```

MongoDB Atlas를 사용한다면 다음처럼 설정할 수 있다.

```properties
spring.data.mongodb.uri=mongodb+srv://mongoUser:mongoPassword@cluster-address/testDB1
```

Spring Boot는 다음 두 자동 설정을 각각 적용한다.

```text
spring.datasource.*
→ MySQL DataSource와 JPA 자동 설정

spring.data.mongodb.*
→ MongoClient와 MongoTemplate 자동 설정
```

설정 키와 사용하는 객체의 종류가 다르기 때문에, MySQL 하나와 MongoDB 하나를 연결하는 일반적인 구조에서는 별도의 Java Configuration 클래스가 없어도 된다.

---

## application.yml로 설정하는 방법

YAML을 사용한다면 다음과 같이 작성할 수 있다.

```yaml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/first?serverTimezone=Asia/Seoul&characterEncoding=UTF-8
    username: root
    password: password

  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        format_sql: true

  data:
    mongodb:
      uri: mongodb://mongoUser:mongoPassword@localhost:27017/testDB1?authSource=admin
```

`application.properties`와 `application.yml` 중 하나만 사용하면 된다.

---

## 프로젝트 패키지 구조

MySQL과 MongoDB의 모델 및 Repository를 명확히 구분하는 것이 좋다.

```text
com.example.multidatabase
├── controller
│   └── MainController.java
├── service
│   └── DatabaseReadService.java
├── mysql
│   ├── entity
│   │   └── FirstEntity.java
│   └── repository
│       └── FirstRepository.java
└── mongodb
    ├── document
    │   └── Table1Document.java
    └── repository
        └── Table1Repository.java
```

패키지를 분리하면 코드만 보고도 어떤 데이터베이스에 접근하는지 쉽게 알 수 있다.

---

## MySQL Entity 작성

MySQL 테이블과 매핑되는 Entity를 작성한다.

```java
package com.example.multidatabase.mysql.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "first_entity")
public class FirstEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    protected FirstEntity() {
    }

    public FirstEntity(String name) {
        this.name = name;
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }
}
```

주요 어노테이션의 역할은 다음과 같다.

| 어노테이션             | 역할            |
| ----------------- | ------------- |
| `@Entity`         | JPA Entity 선언 |
| `@Table`          | 매핑할 테이블 이름 설정 |
| `@Id`             | 기본 키 지정       |
| `@GeneratedValue` | 기본 키 자동 생성    |

---

## MySQL Repository 작성

MySQL 데이터 접근을 위해 `JpaRepository`를 상속한다.

```java
package com.example.multidatabase.mysql.repository;

import com.example.multidatabase.mysql.entity.FirstEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FirstRepository
        extends JpaRepository<FirstEntity, Long> {
}
```

이제 다음과 같은 기본 메소드를 사용할 수 있다.

```java
firstRepository.findAll();
firstRepository.findById(id);
firstRepository.save(entity);
firstRepository.deleteById(id);
```

---

## MongoDB Document 작성

MongoDB Collection과 연결되는 Document 클래스를 작성한다.

```java
package com.example.multidatabase.mongodb.document;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "table1")
public class Table1Document {

    @Id
    private String id;

    private String data;

    public String getId() {
        return id;
    }

    public String getData() {
        return data;
    }
}
```

`@Document`는 JPA의 `@Entity`와 비슷한 역할을 한다.

```text
@Entity
→ MySQL Table 매핑

@Document
→ MongoDB Collection 매핑
```

올바른 `@Document` import 경로는 다음과 같다.

```java
org.springframework.data.mongodb.core.mapping.Document
```

---

## MongoDB Repository 작성

MongoDB 접근을 위해 `MongoRepository`를 상속한다.

```java
package com.example.multidatabase.mongodb.repository;

import com.example.multidatabase.mongodb.document.Table1Document;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface Table1Repository
        extends MongoRepository<Table1Document, String> {
}
```

기본 CRUD 메소드는 JPA Repository와 유사하다.

```java
table1Repository.findAll();
table1Repository.findById(id);
table1Repository.save(document);
table1Repository.deleteById(id);
```

Repository 사용 방법은 비슷하지만 내부적으로 사용하는 데이터베이스와 저장 방식은 완전히 다르다.

---

## Service에서 두 데이터베이스 조회하기

간단한 확인을 위해 Controller에서 Repository를 직접 사용할 수도 있지만, 실제 구조에서는 Service를 거치는 것이 좋다.

```java
package com.example.multidatabase.service;

import com.example.multidatabase.mongodb.document.Table1Document;
import com.example.multidatabase.mongodb.repository.Table1Repository;
import com.example.multidatabase.mysql.entity.FirstEntity;
import com.example.multidatabase.mysql.repository.FirstRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DatabaseReadService {

    private final FirstRepository firstRepository;
    private final Table1Repository table1Repository;

    public DatabaseReadService(
            FirstRepository firstRepository,
            Table1Repository table1Repository
    ) {
        this.firstRepository = firstRepository;
        this.table1Repository = table1Repository;
    }

    public List<FirstEntity> findAllMysqlData() {
        return firstRepository.findAll();
    }

    public List<Table1Document> findAllMongoData() {
        return table1Repository.findAll();
    }
}
```

여기서는 주입받는 Repository 타입이 서로 다르기 때문에 `@Qualifier`가 필요하지 않다.

```text
FirstRepository
Table1Repository
```

Spring은 타입을 기준으로 각각의 Bean을 구분할 수 있다.

---

## Controller에서 데이터 전달하기

Service에서 조회한 데이터를 Model에 담아 화면으로 전달한다.

```java
package com.example.multidatabase.controller;

import com.example.multidatabase.service.DatabaseReadService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MainController {

    private final DatabaseReadService databaseReadService;

    public MainController(DatabaseReadService databaseReadService) {
        this.databaseReadService = databaseReadService;
    }

    @GetMapping("/")
    public String main(Model model) {
        model.addAttribute(
                "rdbData",
                databaseReadService.findAllMysqlData()
        );

        model.addAttribute(
                "mongoData",
                databaseReadService.findAllMongoData()
        );

        return "main";
    }
}
```

전체 조회 흐름은 다음과 같다.

```mermaid
flowchart TD
    A[GET 요청] --> B[MainController]
    B --> C[DatabaseReadService]
    C --> D[FirstRepository]
    C --> E[Table1Repository]
    D --> F[MySQL]
    E --> G[MongoDB]
    F --> H[Model]
    G --> H
    H --> I[Mustache View]
```

---

## Mustache에서 데이터 출력하기

다음 경로에 화면 파일을 생성한다.

```text
src/main/resources/templates/main.mustache
```

```html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>MySQL + MongoDB 조회</title>
</head>
<body>

<h1>MySQL 데이터</h1>

{{#rdbData}}
    <div>
        <p>ID: {{id}}</p>
        <p>Name: {{name}}</p>
    </div>
    <hr>
{{/rdbData}}

{{^rdbData}}
    <p>MySQL에서 조회된 데이터가 없습니다.</p>
{{/rdbData}}

<h1>MongoDB 데이터</h1>

{{#mongoData}}
    <div>
        <p>ID: {{id}}</p>
        <p>Data: {{data}}</p>
    </div>
    <hr>
{{/mongoData}}

{{^mongoData}}
    <p>MongoDB에서 조회된 데이터가 없습니다.</p>
{{/mongoData}}

</body>
</html>
```

애플리케이션을 실행한 후 다음 주소로 접근한다.

```text
http://localhost:8080
```

MySQL과 MongoDB의 데이터가 모두 출력되면 연결이 정상적으로 완료된 것이다.

---

## @Qualifier는 언제 필요한가?

`@Qualifier`는 같은 타입의 Bean이 여러 개 존재할 때 어떤 Bean을 주입할지 지정하는 어노테이션이다.

예를 들어 MySQL DataSource가 두 개라면 다음처럼 사용할 수 있다.

```java
@Bean("mainDataSource")
public DataSource mainDataSource() {
    // 메인 DB 설정
}

@Bean("logDataSource")
public DataSource logDataSource() {
    // 로그 DB 설정
}
```

특정 DataSource를 주입할 때는 다음과 같이 지정한다.

```java
public DatabaseService(
        @Qualifier("mainDataSource") DataSource dataSource
) {
    this.dataSource = dataSource;
}
```

그러나 다음 구조에서는 일반적으로 `@Qualifier`가 필요하지 않다.

```text
MySQL DataSource 1개
MongoDB MongoClient 1개
```

두 객체는 타입 자체가 다르기 때문이다.

```text
MySQL
→ javax.sql.DataSource

MongoDB
→ com.mongodb.client.MongoClient
```

따라서 “MySQL과 MongoDB를 함께 쓰기 때문에 반드시 `@Qualifier`가 필요하다”는 설명은 정확하지 않다.

---

## TransactionManager는 각각 필요한가?

MySQL과 MongoDB의 트랜잭션 방식도 다르다.

### MySQL

Spring Data JPA가 연결되면 일반적으로 `JpaTransactionManager`가 자동 구성된다.

```java
@Transactional
public void saveMysqlData() {
    firstRepository.save(...);
}
```

### MongoDB

MongoDB 트랜잭션은 Replica Set 또는 Sharded Cluster 환경에서 사용할 수 있다.

MongoDB TransactionManager가 필요하다면 다음과 같이 직접 등록할 수 있다.

```java
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.MongoDatabaseFactory;
import org.springframework.data.mongodb.MongoTransactionManager;

@Configuration
public class MongoTransactionConfig {

    @Bean
    public MongoTransactionManager mongoTransactionManager(
            MongoDatabaseFactory databaseFactory
    ) {
        return new MongoTransactionManager(databaseFactory);
    }
}
```

단일 MongoDB 서버나 트랜잭션을 사용하지 않는 단순 조회·저장에서는 반드시 등록할 필요는 없다.

---

## 여러 TransactionManager가 있을 때

JPA와 MongoDB TransactionManager를 모두 등록했다면 사용할 트랜잭션 매니저를 명시할 수 있다.

```java
@Transactional(transactionManager = "transactionManager")
public void saveMysqlData() {
    // MySQL 작업
}
```

```java
@Transactional(transactionManager = "mongoTransactionManager")
public void saveMongoData() {
    // MongoDB 작업
}
```

실제 Bean 이름은 프로젝트 설정에 맞게 관리해야 한다.

---

## MySQL과 MongoDB를 하나의 트랜잭션으로 묶을 수 있을까?

다음과 같은 로직을 생각할 수 있다.

```text
MySQL 주문 저장
+
MongoDB 이벤트 저장
```

하지만 두 데이터베이스는 서로 다른 트랜잭션 매니저를 사용한다.

따라서 일반적인 `@Transactional` 하나만으로 두 저장소를 원자적으로 묶을 수 없다.

예를 들어 MySQL 저장에는 성공하고 MongoDB 저장에는 실패할 수 있다.

```text
MySQL COMMIT 성공
MongoDB 저장 실패
```

이 경우 두 데이터베이스의 상태가 달라진다.

실무에서는 다음과 같은 전략을 고려한다.

```text
Outbox Pattern
이벤트 기반 비동기 처리
보상 트랜잭션
재시도
상태 기반 복구
Saga Pattern
```

강한 일관성이 필요하지 않다면 MySQL 트랜잭션 완료 후 이벤트를 발행하고, MongoDB에는 비동기로 반영하는 방법이 현실적이다.

---

## 설정 정보를 코드에 직접 넣지 않기

다음 정보는 Git에 커밋해서는 안 된다.

```text
MySQL 비밀번호
MongoDB 비밀번호
MongoDB Atlas URI
```

환경 변수를 사용하면 다음과 같이 분리할 수 있다.

```properties
spring.datasource.url=${MYSQL_URL}
spring.datasource.username=${MYSQL_USERNAME}
spring.datasource.password=${MYSQL_PASSWORD}

spring.data.mongodb.uri=${MONGODB_URI}
```

운영 환경에서는 다음과 같은 보안 저장소를 사용할 수 있다.

```text
AWS Secrets Manager
AWS Systems Manager Parameter Store
Kubernetes Secret
Docker Secret
CI/CD Secret Variable
```

---

## 자주 발생하는 오류

### MySQL 연결 실패

```text
Communications link failure
```

확인 항목은 다음과 같다.

```text
MySQL Host
3306 포트
보안 그룹
방화벽
DB 서버 실행 여부
```

---

### MySQL 인증 실패

```text
Access denied for user
```

Username과 Password를 확인하고, 해당 계정이 지정한 Database에 접근할 권한이 있는지 확인한다.

---

### MongoDB 연결 실패

```text
MongoSocketOpenException
```

MongoDB Host, Port, Atlas Network Access를 확인한다.

---

### MongoDB 인증 실패

```text
Authentication failed
```

MongoDB 계정과 비밀번호, `authSource` 설정을 확인한다.

```properties
spring.data.mongodb.uri=mongodb://user:password@localhost:27017/testDB1?authSource=admin
```

---

### MongoDB Atlas 비밀번호 특수문자 문제

비밀번호에 다음 문자가 포함되면 URL 인코딩이 필요할 수 있다.

```text
@
:
/
?
#
```

예를 들어:

```text
password@123
```

은 URI에서 다음과 같이 표현해야 한다.

```text
password%40123
```

---

## 실무에서의 활용

MySQL과 MongoDB를 함께 사용하는 방식은 단순히 데이터베이스를 두 개 연결하는 작업이 아니다.

핵심은 저장소마다 책임을 분리하는 것이다.

예를 들어 주문 서비스에서 다음과 같이 구성할 수 있다.

```text
MySQL
- 주문 상태
- 결제 금액
- 사용자 ID
- 재고 차감 결과

MongoDB
- 주문 변경 이력
- 외부 요청 및 응답 전문
- 사용자 행동 로그
- 가변적인 주문 메타데이터
```

단, 데이터베이스가 늘어나면 다음 복잡도도 함께 증가한다.

```text
장애 지점 증가
트랜잭션 분리
데이터 동기화 문제
백업 및 복구 전략 분리
모니터링 대상 증가
운영 비용 증가
```

따라서 단순히 MongoDB가 편리하다는 이유로 추가하기보다, RDB만으로 해결하기 어려운 명확한 요구사항이 있을 때 도입하는 것이 좋다.

---

## 정리

Spring Boot에서 MySQL과 MongoDB를 동시에 연결하는 기본 흐름은 다음과 같다.

```text
Spring Data JPA 의존성 추가
MySQL Driver 추가
Spring Data MongoDB 의존성 추가
application.properties에 MySQL 설정
application.properties에 MongoDB URI 설정
MySQL Entity와 JpaRepository 작성
MongoDB Document와 MongoRepository 작성
Service에서 각각 조회
Controller를 통해 View로 전달
```

MySQL과 MongoDB는 서로 다른 자동 설정을 사용하므로 각각 하나씩 연결하는 구조라면 별도의 다중 DataSource Configuration이 필요하지 않다.

또한 `@Qualifier`는 서로 같은 타입의 Bean이 여러 개 존재할 때 사용하는 것이며, MySQL DataSource 하나와 MongoDB 연결 하나만 있다면 일반적으로 필요하지 않다.

### 한 줄 요약

Spring Boot에서는 MySQL과 MongoDB의 설정 키와 Repository 체계가 분리되어 있으므로, 각각의 연결 정보와 의존성을 등록하면 하나의 애플리케이션에서 두 데이터베이스를 함께 사용할 수 있다.

