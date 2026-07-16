---
layout: post
bigtitle: '스프링 부트 데이터베이스'
subtitle: 스프링 부트 데이터베이스 8 - MongoDB 다중 연결
date: '2026-06-16 00:00:11 +0900'
categories:
    - developer-yumi
comments: true

---

# 스프링 부트 데이터베이스 8 - MongoDB 다중 연결
[https://youtu.be/T6MXQvvcShA?si=dFLoXNorAmpfb_Tv](https://youtu.be/T6MXQvvcShA?si=dFLoXNorAmpfb_Tv)
# 스프링 부트 데이터베이스 8 - MongoDB 다중 연결
* toc
{:toc}

---
## Spring Boot에서 여러 MongoDB 연결하기

Spring Boot는 하나의 MongoDB를 사용할 때 `application.properties` 또는 `application.yml`에 연결 정보를 작성하면 자동으로 `MongoClient`, `MongoDatabaseFactory`, `MongoTemplate` 등을 구성한다.

하지만 하나의 애플리케이션에서 두 개 이상의 MongoDB 데이터베이스를 사용하려면 기본 자동 설정만으로는 각 Repository가 어느 데이터베이스를 사용해야 하는지 구분하기 어렵다.

따라서 데이터베이스별로 다음 객체를 각각 구성해야 한다.

```text
MongoClient
MongoDatabaseFactory
MongoTemplate
MongoRepository 패키지
```

핵심은 다음과 같다.

> 각 MongoDB에 독립적인 MongoTemplate을 생성하고, `@EnableMongoRepositories`의 `basePackages`와 `mongoTemplateRef`를 이용해 Repository와 데이터베이스의 연결 관계를 명확하게 지정한다.

---

## 다중 MongoDB 연결이란?

다중 MongoDB 연결은 하나의 Spring Boot 애플리케이션에서 두 개 이상의 MongoDB 데이터베이스에 접근하는 구조를 의미한다.

예를 들어 다음과 같이 데이터베이스를 분리할 수 있다.

```text
first_db
- 회원 활동 데이터
- 사용자 설정
- 개인화 정보

second_db
- 시스템 로그
- 감사 기록
- 통계 데이터
```

두 데이터베이스가 동일한 MongoDB Atlas Cluster 안에 있을 수도 있고, 서로 다른 MongoDB 서버 또는 Cluster에 있을 수도 있다.

전체 구조는 다음과 같다.

```mermaid
flowchart LR
    A[Spring Boot Application]

    A --> B[FirstMongoTemplate]
    A --> C[SecondMongoTemplate]

    B --> D[first_db Repository]
    C --> E[second_db Repository]

    D --> F[MongoDB test_db1]
    E --> G[MongoDB test_db2]
```

---

## 단일 연결과 다중 연결의 차이

단일 MongoDB 연결은 다음 설정만으로 구성할 수 있다.

```properties
spring.data.mongodb.uri=mongodb://user:password@localhost:27017/test_db1
```

Spring Boot가 이 설정을 읽고 하나의 MongoDB 연결을 자동 구성한다.

하지만 다음처럼 같은 설정 키를 두 번 작성할 수는 없다.

```properties
spring.data.mongodb.uri=mongodb://user:password@localhost:27017/test_db1
spring.data.mongodb.uri=mongodb://user:password@localhost:27017/test_db2
```

동일한 프로퍼티 키를 중복 작성하면 마지막 값으로 덮어써지므로 두 데이터베이스가 연결되지 않는다.

다중 MongoDB 연결에서는 데이터베이스마다 별도의 설정 클래스를 작성해야 한다.

| 구분            | 단일 MongoDB | 다중 MongoDB               |
| ------------- | ---------- | ------------------------ |
| 연결 설정         | 자동 설정      | 직접 Configuration 작성      |
| MongoTemplate | 1개         | DB별로 생성                  |
| Repository 스캔 | 전체 자동 스캔   | DB별 패키지 지정               |
| 기본 연결 지정      | 불필요        | `@Primary` 고려            |
| Bean 구분       | 불필요        | Bean 이름과 `@Qualifier` 사용 |

---

## 활용 사례

다중 MongoDB 연결은 다음과 같은 환경에서 활용할 수 있다.

### 서비스 데이터와 로그 데이터 분리

```text
Main MongoDB
- 서비스 Document
- 사용자 데이터
- 콘텐츠 데이터

Log MongoDB
- 요청 로그
- 사용자 행동 이벤트
- 감사 데이터
```

### 지역별 데이터 분리

```text
Korea MongoDB
Japan MongoDB
Global MongoDB
```

### 레거시 데이터베이스와 신규 데이터베이스 병행

마이그레이션 기간에 기존 MongoDB와 신규 MongoDB를 동시에 연결하여 데이터를 점진적으로 이전할 수 있다.

### 고객별 데이터베이스 분리

고객사마다 별도의 MongoDB를 사용하는 멀티테넌시 구조의 기반으로 활용할 수 있다.

---

## 프로젝트 의존성 구성

MongoDB 연결을 위해 Spring Data MongoDB 의존성을 추가한다.

### build.gradle

```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-data-mongodb'

    implementation 'org.springframework.boot:spring-boot-starter-web'

    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}
```

Reactive 방식이 아니라 일반적인 블로킹 방식을 사용하므로 다음 의존성을 사용한다.

```gradle
implementation 'org.springframework.boot:spring-boot-starter-data-mongodb'
```

Reactive MongoDB를 사용하는 경우에는 설정 객체와 Repository 타입이 달라지므로 이번 구성과 혼합하지 않아야 한다.

---

## 패키지 구조 설계

MongoDB별 Repository와 Document를 확실하게 분리한다.

```text
com.example.multimongo
├── config
│   ├── FirstMongoConfig.java
│   └── SecondMongoConfig.java
│
├── firstdb
│   ├── document
│   │   └── FirstUserDocument.java
│   └── repository
│       └── FirstUserRepository.java
│
└── seconddb
    ├── document
    │   └── SecondProductDocument.java
    └── repository
        └── SecondProductRepository.java
```

가장 중요한 것은 Repository 패키지가 서로 겹치지 않는 것이다.

```text
firstdb.repository
→ 첫 번째 MongoTemplate 사용

seconddb.repository
→ 두 번째 MongoTemplate 사용
```

---

## MongoDB 연결 정보를 설정 파일로 분리하기

MongoDB URI를 Configuration 클래스에 직접 작성하면 계정 정보가 소스 코드에 노출된다.

다음과 같은 하드코딩은 피해야 한다.

```java
private static final String URL =
        "mongodb://user:password@host:27017";
```

대신 `application.yml`에 연결 정보를 분리한다.

```yaml
mongodb:
  first:
    uri: mongodb://first-user:first-password@localhost:27017
    database: test_db1

  second:
    uri: mongodb://second-user:second-password@localhost:27017
    database: test_db2
```

MongoDB Atlas를 사용하는 경우에는 다음과 같이 설정할 수 있다.

```yaml
mongodb:
  first:
    uri: mongodb+srv://first-user:first-password@first-cluster.mongodb.net
    database: test_db1

  second:
    uri: mongodb+srv://second-user:second-password@second-cluster.mongodb.net
    database: test_db2
```

운영 환경에서는 실제 값 대신 환경 변수를 사용하는 것이 안전하다.

```yaml
mongodb:
  first:
    uri: ${FIRST_MONGODB_URI}
    database: ${FIRST_MONGODB_DATABASE}

  second:
    uri: ${SECOND_MONGODB_URI}
    database: ${SECOND_MONGODB_DATABASE}
```

---

## ConfigurationProperties 클래스 구성하기

각 데이터베이스 연결 정보를 타입 안전하게 관리하기 위해 `@ConfigurationProperties`를 사용할 수 있다.

```java
package com.example.multimongo.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "mongodb.first")
public record FirstMongoProperties(
        String uri,
        String database
) {
}
```

두 번째 MongoDB 설정도 작성한다.

```java
package com.example.multimongo.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "mongodb.second")
public record SecondMongoProperties(
        String uri,
        String database
) {
}
```

`record`를 사용하면 변경 불가능한 설정 객체를 간단하게 구성할 수 있다.

---

## 첫 번째 MongoDB Configuration 작성하기

첫 번째 MongoDB 설정에서는 다음 세 가지 객체를 Bean으로 등록한다.

```text
firstMongoClient
firstMongoDatabaseFactory
firstMongoTemplate
```

그리고 `firstdb.repository` 패키지의 Repository가 `firstMongoTemplate`을 사용하도록 연결한다.

```java
package com.example.multimongo.config;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.data.mongodb.MongoDatabaseFactory;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.SimpleMongoClientDatabaseFactory;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

@Configuration
@EnableConfigurationProperties(FirstMongoProperties.class)
@EnableMongoRepositories(
        basePackages = "com.example.multimongo.firstdb.repository",
        mongoTemplateRef = "firstMongoTemplate"
)
public class FirstMongoConfig {

    private final FirstMongoProperties properties;

    public FirstMongoConfig(FirstMongoProperties properties) {
        this.properties = properties;
    }

    @Primary
    @Bean(name = "firstMongoClient")
    public MongoClient firstMongoClient() {
        return MongoClients.create(properties.uri());
    }

    @Primary
    @Bean(name = "firstMongoDatabaseFactory")
    public MongoDatabaseFactory firstMongoDatabaseFactory() {
        return new SimpleMongoClientDatabaseFactory(
                firstMongoClient(),
                properties.database()
        );
    }

    @Primary
    @Bean(name = "firstMongoTemplate")
    public MongoTemplate firstMongoTemplate() {
        return new MongoTemplate(
                firstMongoDatabaseFactory()
        );
    }
}
```

---

## FirstMongoConfig 코드 분석

### @EnableMongoRepositories

```java
@EnableMongoRepositories(
        basePackages = "com.example.multimongo.firstdb.repository",
        mongoTemplateRef = "firstMongoTemplate"
)
```

두 설정이 핵심이다.

| 설정                 | 역할                                    |
| ------------------ | ------------------------------------- |
| `basePackages`     | 첫 번째 DB를 사용할 Repository 패키지           |
| `mongoTemplateRef` | 해당 Repository가 사용할 MongoTemplate Bean |

`basePackages`에는 상위 패키지 전체보다 Repository 패키지를 정확히 지정하는 것이 좋다.

```text
권장
com.example.multimongo.firstdb.repository

지양
com.example.multimongo
```

스캔 범위가 겹치면 동일한 Repository가 여러 설정에서 중복 등록될 수 있다.

---

### MongoClient

```java
@Bean(name = "firstMongoClient")
public MongoClient firstMongoClient() {
    return MongoClients.create(properties.uri());
}
```

`MongoClient`는 MongoDB 서버 또는 Cluster와 연결을 관리한다.

내부적으로 Connection Pool을 사용하므로 요청마다 새로 생성하면 안 된다. Spring Singleton Bean으로 한 번만 생성해야 한다.

---

### MongoDatabaseFactory

```java
@Bean(name = "firstMongoDatabaseFactory")
public MongoDatabaseFactory firstMongoDatabaseFactory() {
    return new SimpleMongoClientDatabaseFactory(
            firstMongoClient(),
            properties.database()
    );
}
```

`MongoDatabaseFactory`는 사용할 `MongoClient`와 데이터베이스 이름을 결합한다.

```text
MongoClient
+
test_db1
=
firstMongoDatabaseFactory
```

MongoDB URI에 데이터베이스 이름이 포함되어 있더라도 설정에서 명시적으로 분리하면 연결 대상이 더 명확해진다.

---

### MongoTemplate

```java
@Bean(name = "firstMongoTemplate")
public MongoTemplate firstMongoTemplate() {
    return new MongoTemplate(
            firstMongoDatabaseFactory()
    );
}
```

`MongoTemplate`은 MongoDB 연산을 추상화한 핵심 객체다.

다음과 같은 작업을 수행할 수 있다.

```java
mongoTemplate.findAll(DocumentClass.class);
mongoTemplate.save(document);
mongoTemplate.remove(query, DocumentClass.class);
mongoTemplate.updateFirst(query, update, DocumentClass.class);
```

`MongoRepository` 역시 내부적으로 지정된 `MongoTemplate`을 사용한다.

---

## 두 번째 MongoDB Configuration 작성하기

두 번째 DB는 첫 번째 설정과 동일한 구조이지만 Bean 이름, Repository 패키지, 프로퍼티가 달라야 한다.

```java
package com.example.multimongo.config;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.MongoDatabaseFactory;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.SimpleMongoClientDatabaseFactory;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

@Configuration
@EnableConfigurationProperties(SecondMongoProperties.class)
@EnableMongoRepositories(
        basePackages = "com.example.multimongo.seconddb.repository",
        mongoTemplateRef = "secondMongoTemplate"
)
public class SecondMongoConfig {

    private final SecondMongoProperties properties;

    public SecondMongoConfig(SecondMongoProperties properties) {
        this.properties = properties;
    }

    @Bean(name = "secondMongoClient")
    public MongoClient secondMongoClient() {
        return MongoClients.create(properties.uri());
    }

    @Bean(name = "secondMongoDatabaseFactory")
    public MongoDatabaseFactory secondMongoDatabaseFactory() {
        return new SimpleMongoClientDatabaseFactory(
                secondMongoClient(),
                properties.database()
        );
    }

    @Bean(name = "secondMongoTemplate")
    public MongoTemplate secondMongoTemplate() {
        return new MongoTemplate(
                secondMongoDatabaseFactory()
        );
    }
}
```

---

## @Primary는 어디에 적용해야 할까?

`MongoClient`, `MongoDatabaseFactory`, `MongoTemplate` 타입의 Bean이 각각 두 개씩 존재한다.

Spring이 타입만으로 Bean을 주입해야 하는 상황에서는 어떤 객체를 사용할지 결정하지 못할 수 있다.

```text
firstMongoTemplate
secondMongoTemplate
```

이때 기본으로 사용할 Bean에 `@Primary`를 지정한다.

```java
@Primary
@Bean(name = "firstMongoTemplate")
public MongoTemplate firstMongoTemplate() {
    return new MongoTemplate(firstMongoDatabaseFactory());
}
```

다만 모든 Bean에 무조건 `@Primary`를 붙여야 하는 것은 아니다.

Repository는 `mongoTemplateRef`로 사용할 Template을 명시했기 때문에 `@Primary` 없이도 구분할 수 있다.

`@Primary`는 다음과 같이 타입으로 직접 주입받는 코드가 있을 때 기본 Bean을 결정하는 용도로 사용한다.

```java
public SomeService(MongoTemplate mongoTemplate) {
    this.mongoTemplate = mongoTemplate;
}
```

실무에서는 기본값에 의존하기보다 `@Qualifier`를 사용해 대상 DB를 명시하는 방법이 더 분명하다.

---

## @Qualifier로 MongoTemplate 선택하기

첫 번째 MongoTemplate을 직접 사용하려면 다음과 같이 작성한다.

```java
package com.example.multimongo.firstdb.service;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;

@Service
public class FirstMongoService {

    private final MongoTemplate mongoTemplate;

    public FirstMongoService(
            @Qualifier("firstMongoTemplate")
            MongoTemplate mongoTemplate
    ) {
        this.mongoTemplate = mongoTemplate;
    }
}
```

두 번째 MongoTemplate은 다음과 같이 지정한다.

```java
package com.example.multimongo.seconddb.service;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;

@Service
public class SecondMongoService {

    private final MongoTemplate mongoTemplate;

    public SecondMongoService(
            @Qualifier("secondMongoTemplate")
            MongoTemplate mongoTemplate
    ) {
        this.mongoTemplate = mongoTemplate;
    }
}
```

이 방식은 코드만 보아도 어떤 DB를 사용하는지 알 수 있다는 장점이 있다.

---

## 첫 번째 MongoDB Document 작성하기

첫 번째 데이터베이스에 저장할 사용자 Document를 작성한다.

```java
package com.example.multimongo.firstdb.document;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "users")
public class FirstUserDocument {

    @Id
    private String id;

    private String name;

    protected FirstUserDocument() {
    }

    public FirstUserDocument(String name) {
        this.name = name;
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }
}
```

---

## 첫 번째 MongoDB Repository 작성하기

```java
package com.example.multimongo.firstdb.repository;

import com.example.multimongo.firstdb.document.FirstUserDocument;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface FirstUserRepository
        extends MongoRepository<FirstUserDocument, String> {
}
```

이 Repository는 다음 설정에 의해 첫 번째 MongoDB와 연결된다.

```java
@EnableMongoRepositories(
        basePackages = "com.example.multimongo.firstdb.repository",
        mongoTemplateRef = "firstMongoTemplate"
)
```

---

## 두 번째 MongoDB Document 작성하기

```java
package com.example.multimongo.seconddb.document;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "products")
public class SecondProductDocument {

    @Id
    private String id;

    private String name;

    protected SecondProductDocument() {
    }

    public SecondProductDocument(String name) {
        this.name = name;
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }
}
```

---

## 두 번째 MongoDB Repository 작성하기

```java
package com.example.multimongo.seconddb.repository;

import com.example.multimongo.seconddb.document.SecondProductDocument;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface SecondProductRepository
        extends MongoRepository<SecondProductDocument, String> {
}
```

이 Repository는 `secondMongoTemplate`을 사용한다.

---

## 서비스에서 각 데이터베이스 사용하기

```java
package com.example.multimongo.service;

import com.example.multimongo.firstdb.document.FirstUserDocument;
import com.example.multimongo.firstdb.repository.FirstUserRepository;
import com.example.multimongo.seconddb.document.SecondProductDocument;
import com.example.multimongo.seconddb.repository.SecondProductRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MultiMongoService {

    private final FirstUserRepository firstUserRepository;
    private final SecondProductRepository secondProductRepository;

    public MultiMongoService(
            FirstUserRepository firstUserRepository,
            SecondProductRepository secondProductRepository
    ) {
        this.firstUserRepository = firstUserRepository;
        this.secondProductRepository = secondProductRepository;
    }

    public FirstUserDocument saveUser(String name) {
        return firstUserRepository.save(
                new FirstUserDocument(name)
        );
    }

    public SecondProductDocument saveProduct(String name) {
        return secondProductRepository.save(
                new SecondProductDocument(name)
        );
    }

    public List<FirstUserDocument> findAllUsers() {
        return firstUserRepository.findAll();
    }

    public List<SecondProductDocument> findAllProducts() {
        return secondProductRepository.findAll();
    }
}
```

Repository 타입 자체가 다르기 때문에 주입 시 `@Qualifier`는 필요하지 않다.

각 Repository가 어느 MongoDB를 사용하는지는 Configuration의 `basePackages`와 `mongoTemplateRef`가 결정한다.

---

## 연결 테스트하기

애플리케이션이 오류 없이 실행되는 것만으로 MongoDB 설정 객체가 생성되었는지는 확인할 수 있다.

하지만 실제 연결을 검증하려면 두 데이터베이스에 각각 명령을 실행해보는 것이 좋다.

### CommandLineRunner 테스트

```java
package com.example.multimongo;

import com.example.multimongo.service.MultiMongoService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class MongoConnectionRunner implements CommandLineRunner {

    private final MultiMongoService multiMongoService;

    public MongoConnectionRunner(
            MultiMongoService multiMongoService
    ) {
        this.multiMongoService = multiMongoService;
    }

    @Override
    public void run(String... args) {
        multiMongoService.saveUser("first database user");
        multiMongoService.saveProduct("second database product");

        System.out.println(
                multiMongoService.findAllUsers()
        );

        System.out.println(
                multiMongoService.findAllProducts()
        );
    }
}
```

실행 후 다음 결과를 확인한다.

```text
test_db1.users
→ first database user 저장

test_db2.products
→ second database product 저장
```

MongoDB Driver는 실제 쿼리가 실행될 때 연결을 생성하는 지연 연결 방식을 사용할 수 있다. 따라서 애플리케이션 시작 성공만으로 네트워크와 인증이 완전히 검증되었다고 단정하지 말고 실제 조회 또는 저장을 실행해야 한다.

---

## MongoTemplate으로 연결 상태 확인하기

MongoDB의 `ping` 명령을 실행하면 연결 상태를 직접 확인할 수 있다.

```java
package com.example.multimongo.health;

import org.bson.Document;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Component;

@Component
public class MongoConnectionChecker {

    private final MongoTemplate firstMongoTemplate;
    private final MongoTemplate secondMongoTemplate;

    public MongoConnectionChecker(
            @Qualifier("firstMongoTemplate")
            MongoTemplate firstMongoTemplate,
            @Qualifier("secondMongoTemplate")
            MongoTemplate secondMongoTemplate
    ) {
        this.firstMongoTemplate = firstMongoTemplate;
        this.secondMongoTemplate = secondMongoTemplate;
    }

    public boolean pingFirst() {
        Document result = firstMongoTemplate.executeCommand(
                new Document("ping", 1)
        );

        return result.getDouble("ok") == 1.0;
    }

    public boolean pingSecond() {
        Document result = secondMongoTemplate.executeCommand(
                new Document("ping", 1)
        );

        return result.getDouble("ok") == 1.0;
    }
}
```

---

## 설정 클래스 전체 흐름

각 MongoDB Configuration의 내부 흐름은 다음과 같다.

```mermaid
flowchart TD
    A[MongoDB URI] --> B[MongoClient]
    B --> C[MongoDatabaseFactory]
    D[Database Name] --> C
    C --> E[MongoTemplate]
    E --> F[MongoRepository]
    F --> G[Document CRUD]
```

DB마다 이 구조를 하나씩 구성한다.

```text
첫 번째 DB
firstMongoClient
→ firstMongoDatabaseFactory
→ firstMongoTemplate
→ firstdb.repository

두 번째 DB
secondMongoClient
→ secondMongoDatabaseFactory
→ secondMongoTemplate
→ seconddb.repository
```

---

## 자주 발생하는 오류

### MongoTemplate Bean을 찾을 수 없는 오류

```text
No qualifying bean of type 'MongoTemplate' available
```

주요 원인은 다음과 같다.

```text
mongoTemplateRef 이름 불일치
@Bean 이름 오타
Configuration 클래스 스캔 누락
```

다음 두 이름이 정확히 일치해야 한다.

```java
@EnableMongoRepositories(
        mongoTemplateRef = "firstMongoTemplate"
)
```

```java
@Bean(name = "firstMongoTemplate")
public MongoTemplate firstMongoTemplate() {
    // ...
}
```

---

### Repository 중복 등록 오류

여러 Configuration의 `basePackages` 범위가 겹치면 동일한 Repository를 두 번 등록하려고 할 수 있다.

```text
The bean could not be registered
A bean with that name has already been defined
```

잘못된 예시는 다음과 같다.

```java
@EnableMongoRepositories(
        basePackages = "com.example.multimongo"
)
```

각 Config에서 상위 패키지 전체를 스캔하면 두 설정 모두 같은 Repository를 발견할 수 있다.

정확한 Repository 패키지를 지정한다.

```java
basePackages =
        "com.example.multimongo.firstdb.repository"
```

```java
basePackages =
        "com.example.multimongo.seconddb.repository"
```

---

### Bean 이름 충돌

두 설정 클래스에서 같은 메소드 이름을 사용하면 기본 Bean 이름도 같아질 수 있다.

```java
@Bean
public MongoClient mongoClient() {
    // ...
}
```

두 Config에 같은 이름이 존재하면 충돌할 수 있다.

다음처럼 DB별 이름을 명확하게 구분한다.

```text
firstMongoClient
secondMongoClient

firstMongoDatabaseFactory
secondMongoDatabaseFactory

firstMongoTemplate
secondMongoTemplate
```

---

### MongoTemplate 주입 모호성

```text
NoUniqueBeanDefinitionException
```

`MongoTemplate`이 두 개 존재하는데 이름을 지정하지 않고 주입하면 발생할 수 있다.

```java
public SomeService(MongoTemplate mongoTemplate) {
    // 어떤 MongoTemplate인지 알 수 없음
}
```

`@Qualifier`를 사용한다.

```java
public SomeService(
        @Qualifier("secondMongoTemplate")
        MongoTemplate mongoTemplate
) {
    this.mongoTemplate = mongoTemplate;
}
```

또는 기본 Bean 하나에 `@Primary`를 지정한다.

---

### 인증 오류

```text
Authentication failed
```

다음 항목을 확인한다.

```text
Username
Password
authSource
Database User 권한
비밀번호 URL Encoding
```

로컬 MongoDB에서 인증 DB가 `admin`이라면 URI에 `authSource`를 추가할 수 있다.

```yaml
mongodb:
  first:
    uri: mongodb://first-user:first-password@localhost:27017/?authSource=admin
    database: test_db1
```

---

### MongoDB Atlas 연결 실패

Atlas를 사용할 때는 다음 설정도 확인해야 한다.

```text
Database Access의 사용자 계정
Network Access의 IP 허용
Cluster 상태
URI 주소
TLS 연결
```

개발 PC의 현재 공인 IP가 Atlas Network Access에 등록되어 있지 않으면 연결되지 않는다.

---

## 트랜잭션 사용 시 주의사항

MongoDB 트랜잭션은 Replica Set 또는 Sharded Cluster에서 사용할 수 있다.

트랜잭션이 필요하다면 데이터베이스별로 `MongoTransactionManager`를 등록할 수 있다.

```java
@Bean(name = "firstMongoTransactionManager")
public MongoTransactionManager firstMongoTransactionManager(
        @Qualifier("firstMongoDatabaseFactory")
        MongoDatabaseFactory factory
) {
    return new MongoTransactionManager(factory);
}
```

두 번째 DB도 별도로 등록한다.

```java
@Bean(name = "secondMongoTransactionManager")
public MongoTransactionManager secondMongoTransactionManager(
        @Qualifier("secondMongoDatabaseFactory")
        MongoDatabaseFactory factory
) {
    return new MongoTransactionManager(factory);
}
```

서비스에서는 사용할 트랜잭션 매니저를 명시한다.

```java
@Transactional(
        transactionManager = "firstMongoTransactionManager"
)
public void saveFirstDatabaseData() {
    // first MongoDB 작업
}
```

```java
@Transactional(
        transactionManager = "secondMongoTransactionManager"
)
public void saveSecondDatabaseData() {
    // second MongoDB 작업
}
```

---

## 두 MongoDB 작업을 하나의 트랜잭션으로 묶을 수 있을까?

서로 다른 MongoDB Cluster나 독립적인 연결에 대한 작업은 일반적인 `@Transactional` 하나로 원자성을 보장하기 어렵다.

다음과 같은 상황이 발생할 수 있다.

```text
first DB 저장 성공
second DB 저장 실패
```

데이터 정합성이 중요하다면 다음 전략을 고려해야 한다.

```text
재시도
보상 작업
이벤트 기반 동기화
Outbox Pattern
Saga Pattern
상태 기반 복구
```

같은 Cluster 내부의 여러 데이터베이스를 사용하더라도 트랜잭션 경계와 세션 공유 여부를 정확히 검토해야 한다.

---

## 운영 환경에서의 개선 사항

### 비밀번호 외부화

MongoDB URI에는 계정과 비밀번호가 포함된다.

```text
mongodb://username:password@host
```

다음과 같은 저장소에 분리하는 것이 좋다.

```text
AWS Secrets Manager
AWS Systems Manager Parameter Store
Kubernetes Secret
Docker Secret
CI/CD Secret Variable
```

---

### Connection Pool 설정

MongoDB URI에 연결 풀 옵션을 지정할 수 있다.

```yaml
mongodb:
  first:
    uri: mongodb://user:password@localhost:27017/?maxPoolSize=50&minPoolSize=5&connectTimeoutMS=3000
    database: test_db1
```

주요 옵션은 다음과 같다.

| 옵션                         | 의미                 |
| -------------------------- | ------------------ |
| `maxPoolSize`              | 최대 Connection 수    |
| `minPoolSize`              | 최소 유지 Connection 수 |
| `connectTimeoutMS`         | 연결 제한 시간           |
| `serverSelectionTimeoutMS` | 서버 탐색 제한 시간        |
| `socketTimeoutMS`          | 소켓 응답 제한 시간        |

DB마다 트래픽 특성이 다르다면 Connection Pool도 각각 다르게 설정할 수 있다.

---

### Health Check 구성

Spring Boot Actuator를 추가하면 데이터베이스 상태를 운영 중에 확인할 수 있다.

```gradle
implementation 'org.springframework.boot:spring-boot-starter-actuator'
```

다중 MongoDB 환경에서는 각 `MongoTemplate`에 대해 별도의 HealthIndicator를 구성하면 어느 DB에 장애가 발생했는지 명확하게 구분할 수 있다.

---

### 로그에 접속 URI 출력 금지

MongoDB URI에는 비밀번호가 포함될 수 있으므로 다음 정보를 로그로 남기지 않아야 한다.

```text
전체 MongoDB URI
비밀번호
인증 Token
```

로그에는 DB 별칭과 연결 성공 여부 정도만 기록하는 것이 안전하다.

---

## 다중 MongoDB 설계 시 고려할 점

다중 DB 연결은 기술적으로 가능하지만 복잡도도 증가한다.

```text
연결 설정 증가
Repository 관리 복잡도 증가
트랜잭션 분리
데이터 동기화 문제
장애 지점 증가
모니터링 대상 증가
백업 정책 분리
```

따라서 단순히 Collection을 분리하기 위한 목적이라면 하나의 MongoDB 데이터베이스 안에서 Collection을 분리하는 것으로 충분할 수 있다.

별도 MongoDB 연결은 다음과 같은 명확한 이유가 있을 때 적합하다.

```text
물리적인 Cluster 분리
보안 경계 분리
고객별 Database 분리
지역별 데이터 저장
독립적인 백업 및 복구
트래픽과 리소스 격리
```

---

## 정리

Spring Boot에서 여러 MongoDB를 연결하려면 데이터베이스마다 독립적인 설정 객체를 구성해야 한다.

전체 구성 순서는 다음과 같다.

```text
MongoDB별 연결 정보 작성
→ MongoClient Bean 생성
→ MongoDatabaseFactory Bean 생성
→ MongoTemplate Bean 생성
→ Repository 패키지 분리
→ @EnableMongoRepositories 설정
→ mongoTemplateRef 연결
→ 필요 시 @Primary와 @Qualifier 적용
```

가장 중요한 설정은 다음 두 가지다.

```java
basePackages =
        "각 데이터베이스의 Repository 패키지"
```

```java
mongoTemplateRef =
        "해당 데이터베이스의 MongoTemplate Bean 이름"
```

이를 통해 각 Repository가 지정된 MongoDB에만 접근하도록 연결할 수 있다.

### 한 줄 요약

다중 MongoDB 연결은 데이터베이스마다 `MongoClient`, `MongoDatabaseFactory`, `MongoTemplate`을 독립적으로 생성하고, Repository 패키지와 `mongoTemplateRef`를 연결하는 것이 핵심이다.


