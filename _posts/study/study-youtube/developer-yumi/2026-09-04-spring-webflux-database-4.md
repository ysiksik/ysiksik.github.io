---
layout: post
bigtitle: '스프링 WebFlux 데이터베이스'
subtitle: 스프링 WebFlux 데이터베이스 4 - 스프링 WebFlux Reactive MongoDB 단일 연결
date: '2026-09-04 00:00:01 +0900'
categories:
    - developer-yumi
comments: true

---

# 스프링 WebFlux 데이터베이스 4 - 스프링 WebFlux Reactive MongoDB 단일 연결
[https://youtu.be/CPYkBOAptHg?si=ZYAy0ZyqbKecDlFK](https://youtu.be/CPYkBOAptHg?si=ZYAy0ZyqbKecDlFK)

# 스프링 WebFlux 데이터베이스 4 - 스프링 WebFlux Reactive MongoDB 단일 연결
* toc
{:toc}

---

## Spring WebFlux에서 Reactive MongoDB 연결하기

Spring WebFlux는 비동기·논블로킹 방식으로 요청을 처리하는 Reactive Web Stack이다.

WebFlux 애플리케이션에서 데이터베이스를 사용할 때도 요청 처리 흐름과 데이터 접근 방식을 함께 고려해야 한다.

MongoDB를 예로 들면 Spring에서는 크게 동기 방식과 Reactive 방식으로 접근할 수 있다.

```text
Spring Application
        ↓
MongoDB Client
        ↓
MongoDB
```

이때 WebFlux의 Reactive 처리 모델을 데이터베이스 접근까지 이어가고 싶다면 **Reactive MongoDB**를 사용하는 방식이 자연스럽다.

전체 구조는 다음과 같다.

```mermaid
flowchart LR
    C[Client] --> W[Spring WebFlux]
    W --> S[Service]
    S --> R[ReactiveMongoRepository]
    R --> M[(MongoDB)]
```

Repository에서 MongoDB 데이터를 조회하면 결과를 `List<T>`나 `Optional<T>`처럼 즉시 반환하는 대신 Reactor의 `Mono<T>`, `Flux<T>` 형태로 처리할 수 있다.

```text
MongoDB
   ↓
ReactiveMongoRepository
   ↓
Mono / Flux
   ↓
Service
   ↓
Controller
   ↓
Client
```

---

## MongoDB Client의 두 가지 접근 방식

Spring에서 MongoDB를 사용할 때 데이터 접근 방식을 크게 다음처럼 구분할 수 있다.

```text
동기 방식

Spring Data MongoDB
        ↓
MongoRepository
```

그리고 Reactive 방식은 다음과 같다.

```text
Reactive 방식

Spring Data Reactive MongoDB
        ↓
ReactiveMongoRepository
```

두 방식 모두 MongoDB에 접근하지만 애플리케이션의 처리 모델에서 차이가 있다.

### 동기 방식

동기 방식에서는 데이터베이스 작업이 완료될 때까지 호출 흐름이 기다리는 형태로 이해할 수 있다.

```text
Request
   ↓
MongoDB Query
   ↓
결과 대기
   ↓
Result
```

Repository 역시 다음과 같은 형태의 결과를 사용하는 경우가 많다.

```java
List<UserDocument> findAll();
```

또는:

```java
Optional<UserDocument> findById(String id);
```

### Reactive 방식

Reactive MongoDB에서는 조회 결과가 Reactive Stream으로 반환된다.

여러 건을 조회하면:

```java
Flux<UserDocument>
```

한 건을 조회하면:

```java
Mono<UserDocument>
```

형태를 사용할 수 있다.

```text
MongoDB Query
      ↓
Reactive Stream
      ↓
Flux / Mono
```

WebFlux의 요청 처리 모델과 MongoDB 데이터 접근 흐름을 Reactive 방식으로 연결할 수 있다는 것이 핵심이다.

---

## WebFlux와 Reactive MongoDB 조합

WebFlux 애플리케이션의 흐름을 다음과 같이 구성할 수 있다.

```text
WebFlux Controller
        ↓
Reactive Service
        ↓
ReactiveMongoRepository
        ↓
MongoDB
```

각 계층에서 Reactive 타입을 유지한다.

```text
Repository
→ Flux / Mono

Service
→ Flux / Mono

Controller
→ Flux / Mono
```

예를 들어 MongoDB에 저장된 전체 데이터를 조회한다면 다음과 같은 흐름이 만들어질 수 있다.

```mermaid
sequenceDiagram
    participant C as Client
    participant CT as Controller
    participant S as Service
    participant R as ReactiveMongoRepository
    participant DB as MongoDB

    C->>CT: GET /users
    CT->>S: findAll()
    S->>R: findAll()
    R->>DB: Query
    DB-->>R: Documents
    R-->>S: Flux<UserDocument>
    S-->>CT: Flux<UserDocument>
    CT-->>C: Response
```

---

## 필요한 프로젝트 의존성

WebFlux와 Reactive MongoDB를 연결하기 위해 기본적으로 다음 요소가 필요하다.

```text
Spring Reactive Web
Spring Data Reactive MongoDB
Lombok
```

각각의 역할은 다음과 같다.

| 의존성              | 역할                         |
| ---------------- | -------------------------- |
| Spring WebFlux   | Reactive HTTP 요청 및 응답 처리   |
| Reactive MongoDB | MongoDB Reactive 데이터 접근    |
| Lombok           | Getter, Setter 등의 반복 코드 감소 |

Gradle 프로젝트라면 다음과 같은 형태로 구성할 수 있다.

```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-webflux'
    implementation 'org.springframework.boot:spring-boot-starter-data-mongodb-reactive'

    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'io.projectreactor:reactor-test'
}
```

Reactive MongoDB 연결에서 핵심적인 의존성은 다음이다.

```gradle
implementation 'org.springframework.boot:spring-boot-starter-data-mongodb-reactive'
```

---

## 일반 MongoDB와 Reactive MongoDB 의존성 구분

MongoDB 관련 의존성을 선택할 때 동기 방식과 Reactive 방식을 구분해야 한다.

동기 Repository를 사용한다면 일반적인 MongoDB Starter를 사용하는 구조가 있다.

```text
Spring Data MongoDB
        ↓
MongoRepository
```

Reactive 방식에서는 다음 구조를 사용한다.

```text
Spring Data Reactive MongoDB
        ↓
ReactiveMongoRepository
```

WebFlux 기반 애플리케이션에서 MongoDB 접근까지 Reactive 방식으로 구성하려는 경우 `spring-boot-starter-data-mongodb-reactive`를 사용하는 형태로 구성할 수 있다.

---

## MongoDB 연결 정보

MongoDB에 연결하려면 일반적으로 다음 정보가 필요하다.

```text
Host
Port
Database
Username
Password
```

예를 들어 다음 환경을 사용한다고 가정하자.

```text
Host
localhost

Port
27017

Database
testdb

Username
appuser

Password
password
```

MongoDB URI는 다음과 같은 형태가 될 수 있다.

```text
mongodb://appuser:password@localhost:27017/testdb
```

Spring Boot 설정에 이 URI를 등록하면 MongoDB Connection 설정에 사용할 수 있다.

---

## application.properties에서 MongoDB 연결하기

단일 MongoDB 연결에서는 설정 파일을 이용할 수 있다.

예를 들어:

```properties
spring.data.mongodb.uri=mongodb://appuser:password@localhost:27017/testdb
```

구조를 나누면 다음과 같다.

```text
mongodb://
    ↓
username
    ↓
password
    ↓
host
    ↓
port
    ↓
database
```

Spring Boot는 설정값을 기반으로 MongoDB 연결에 필요한 구성을 생성한다.

전체 흐름은 다음과 같다.

```text
application.properties
        ↓
MongoDB Connection 설정
        ↓
Reactive MongoDB
        ↓
MongoDB
```

---

## application.yml로 설정하기

YAML 형식을 사용한다면 다음처럼 작성할 수 있다.

```yaml
spring:
  data:
    mongodb:
      uri: mongodb://appuser:password@localhost:27017/testdb
```

Connection URI 하나로 MongoDB 주소와 인증 정보를 구성할 수 있다.

---

## URI 방식의 장점

MongoDB 연결 정보를 URI로 구성하면 연결 정보를 하나의 문자열로 관리할 수 있다.

```text
mongodb://appuser:password@localhost:27017/testdb
```

이를 구조적으로 보면 다음과 같다.

```text
Protocol
mongodb://

Credential
appuser:password

Server
localhost:27017

Database
testdb
```

특히 MongoDB의 Connection Option이 추가되는 경우 URI에 Query Parameter를 포함하는 형태로 확장할 수도 있다.

---

## Credential을 소스 코드에 직접 저장하지 않기

로컬 테스트에서는 다음처럼 작성할 수 있다.

```yaml
spring:
  data:
    mongodb:
      uri: mongodb://appuser:password@localhost:27017/testdb
```

하지만 운영 환경에서 ID와 Password가 포함된 URI를 Git Repository에 그대로 저장하는 것은 피하는 것이 좋다.

환경 변수로 분리할 수 있다.

```yaml
spring:
  data:
    mongodb:
      uri: ${MONGODB_URI}
```

실행 환경에서는 다음 값을 전달한다.

```text
MONGODB_URI=mongodb://appuser:password@mongodb:27017/testdb
```

즉 다음처럼 책임을 분리한다.

```text
application.yml
→ 환경 변수 이름

Environment / Secret
→ 실제 Credential
```

---

## MongoDB Collection과 Document

관계형 데이터베이스와 MongoDB는 데이터를 표현하는 방식이 다르다.

RDB에서는 일반적으로 다음 구조를 사용한다.

```text
Database
   ↓
Table
   ↓
Row
```

MongoDB에서는 다음과 같이 생각할 수 있다.

```text
Database
   ↓
Collection
   ↓
Document
```

비교하면 다음과 같다.

| 관계형 데이터베이스  | MongoDB        |
| ----------- | -------------- |
| Table       | Collection     |
| Row         | Document       |
| Column      | Document Field |
| Primary Key | `_id`          |

예를 들어 `users` Collection에 다음 Document가 존재한다고 하자.

```json
{
  "_id": "100",
  "name": "Yunsik"
}
```

Spring 애플리케이션에서는 이 Document와 Mapping되는 Java 클래스를 작성할 수 있다.

---

## Document 클래스 작성

MongoDB Collection과 연결될 객체를 만든다.

예를 들어 다음과 같다.

```java
package com.example.mongo.document;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Document(collection = "users")
public class UserDocument {

    @Id
    private String id;

    private String name;
}
```

여기에서:

```java
@Document(collection = "users")
```

는 해당 클래스가 MongoDB의 `users` Collection과 연결된다는 의미다.

그리고:

```java
@Id
private String id;
```

는 MongoDB Document의 식별자와 연결된다.

구조를 보면 다음과 같다.

```text
MongoDB

users Collection
      ↓
UserDocument
```

---

## JPA Entity와 MongoDB Document의 차이

JPA에서는 다음과 같은 형태에 익숙할 수 있다.

```java
@Entity
@Table(name = "users")
public class UserEntity {
}
```

MongoDB에서는 관계형 테이블이 아니라 Collection과 Document를 사용한다.

따라서 다음과 같은 Mapping을 사용할 수 있다.

```java
@Document(collection = "users")
public class UserDocument {
}
```

개념 차이를 정리하면 다음과 같다.

```text
JPA

@Entity
@Table
Database Table
```

```text
MongoDB

@Document
Collection
Document
```

MongoDB는 JPA 기반 관계형 ORM과는 다른 데이터 모델을 가진다는 점을 구분해야 한다.

---

## ReactiveMongoRepository 작성

Document를 만들었다면 Repository를 정의한다.

Reactive MongoDB에서는 `ReactiveMongoRepository`를 사용할 수 있다.

```java
package com.example.mongo.repository;

import com.example.mongo.document.UserDocument;
import org.springframework.data.mongodb.repository.ReactiveMongoRepository;

public interface UserRepository
        extends ReactiveMongoRepository<UserDocument, String> {
}
```

제네릭 타입은 다음 의미를 가진다.

```text
ReactiveMongoRepository
<
    UserDocument,
    String
>
```

첫 번째 타입:

```text
UserDocument
```

는 Repository가 관리할 Document다.

두 번째 타입:

```text
String
```

은 ID 타입이다.

---

## MongoRepository와 ReactiveMongoRepository 차이

동기 방식에서는 `MongoRepository`를 사용할 수 있다.

```java
public interface UserRepository
        extends MongoRepository<UserDocument, String> {
}
```

Reactive 방식에서는 다음을 사용한다.

```java
public interface UserRepository
        extends ReactiveMongoRepository<UserDocument, String> {
}
```

반환 타입에서도 차이가 나타난다.

### MongoRepository

```text
findAll()
→ List<UserDocument>
```

### ReactiveMongoRepository

```text
findAll()
→ Flux<UserDocument>
```

단일 Document를 조회하면:

```text
findById()
→ Mono<UserDocument>
```

형태를 사용할 수 있다.

---

## Flux를 이용한 전체 데이터 조회

MongoDB Collection의 전체 데이터를 조회한다고 가정해보자.

Repository에서는 기본 `findAll()`을 사용할 수 있다.

```java
Flux<UserDocument> users =
        userRepository.findAll();
```

데이터가 다음과 같이 여러 건이라면:

```text
User 1
User 2
User 3
```

Reactive Stream은 다음과 같이 생각할 수 있다.

```text
Flux<UserDocument>

User 1
 ↓
User 2
 ↓
User 3
 ↓
Complete
```

즉 여러 개의 Document를 Reactive Stream으로 전달한다.

---

## Mono를 이용한 단일 데이터 조회

하나의 Document를 ID로 조회한다면 `Mono`를 사용할 수 있다.

```java
Mono<UserDocument> user =
        userRepository.findById("100");
```

`Mono`는 다음 상태를 표현할 수 있다.

```text
0개
또는
1개
```

따라서 단일 Document 조회에 적합하다.

---

## Service 작성

Repository를 Service 계층에서 사용한다.

```java
package com.example.mongo.service;

import com.example.mongo.document.UserDocument;
import com.example.mongo.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public Flux<UserDocument> findAll() {
        return userRepository.findAll();
    }

    public Mono<UserDocument> findById(String id) {
        return userRepository.findById(id);
    }
}
```

Reactive 타입을 그대로 유지한다.

```text
Repository
→ Flux / Mono

Service
→ Flux / Mono
```

중간에서 일반 Collection으로 변환하고 기다리는 방식을 사용하지 않는 것이 중요하다.

---

## Controller 작성

Controller에서도 Reactive 타입을 반환할 수 있다.

```java
package com.example.mongo.controller;

import com.example.mongo.document.UserDocument;
import com.example.mongo.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/users")
    public Flux<UserDocument> findAll() {
        return userService.findAll();
    }

    @GetMapping("/users/{id}")
    public Mono<UserDocument> findById(
            @PathVariable String id
    ) {
        return userService.findById(id);
    }
}
```

전체 조회:

```text
GET /users
      ↓
Flux<UserDocument>
```

단건 조회:

```text
GET /users/100
      ↓
Mono<UserDocument>
```

---

## 전체 데이터 조회 흐름

클라이언트가 다음 요청을 보낸다고 가정한다.

```text
GET /users
```

전체 흐름은 다음과 같다.

```mermaid
sequenceDiagram
    participant C as Client
    participant CT as WebFlux Controller
    participant S as Service
    participant R as ReactiveMongoRepository
    participant M as MongoDB

    C->>CT: GET /users
    CT->>S: findAll()
    S->>R: findAll()
    R->>M: Query users Collection
    M-->>R: Documents
    R-->>S: Flux<UserDocument>
    S-->>CT: Flux<UserDocument>
    CT-->>C: Response
```

결과를 반환하기까지 Reactive 흐름을 유지한다.

---

## 실행

애플리케이션을 실행한다.

```bash
./gradlew bootRun
```

Spring Boot 애플리케이션이 정상적으로 실행되면 MongoDB 연결 설정과 Repository 구성이 정상적으로 처리된 상태에서 API를 호출할 수 있다.

전체 데이터를 조회한다.

```bash
curl http://localhost:8080/users
```

MongoDB의 `users` Collection에 다음 데이터가 존재한다고 가정한다.

```json
{
  "_id": "1",
  "name": "apple"
}
```

```json
{
  "_id": "2",
  "name": "banana"
}
```

응답은 다음과 같은 형태로 확인할 수 있다.

```json
[
  {
    "id": "1",
    "name": "apple"
  },
  {
    "id": "2",
    "name": "banana"
  }
]
```

단일 데이터도 조회할 수 있다.

```bash
curl http://localhost:8080/users/1
```

---

## ReactiveMongoRepository의 Query Method

ReactiveMongoRepository에서도 Spring Data의 메서드 이름 기반 Query를 사용할 수 있다.

예를 들어 이름으로 데이터를 조회한다고 가정하자.

```java
public interface UserRepository
        extends ReactiveMongoRepository<UserDocument, String> {

    Flux<UserDocument> findByName(String name);
}
```

호출하면:

```java
userRepository.findByName("apple");
```

결과는 Reactive 타입으로 반환된다.

```text
Flux<UserDocument>
```

이처럼 기본 CRUD뿐 아니라 Query Method도 Reactive Stream 형태로 사용할 수 있다.

---

## 데이터 저장

새로운 Document를 저장할 수도 있다.

Service:

```java
public Mono<UserDocument> save(
        UserDocument user
) {
    return userRepository.save(user);
}
```

Controller:

```java
@PostMapping("/users")
public Mono<UserDocument> save(
        @RequestBody UserDocument user
) {
    return userService.save(user);
}
```

전체 흐름은 다음과 같다.

```text
POST /users
     ↓
Controller
     ↓
Service
     ↓
ReactiveMongoRepository.save()
     ↓
MongoDB
     ↓
Mono<UserDocument>
```

---

## 데이터 삭제

ID를 이용해 데이터를 삭제하는 구조도 사용할 수 있다.

```java
public Mono<Void> deleteById(String id) {
    return userRepository.deleteById(id);
}
```

Controller:

```java
@DeleteMapping("/users/{id}")
public Mono<Void> deleteById(
        @PathVariable String id
) {
    return userService.deleteById(id);
}
```

삭제는 반환할 Document가 반드시 필요하지 않으므로 `Mono<Void>` 형태로 표현할 수 있다.

---

## Reactive 흐름에서 block()을 사용하지 않기

ReactiveMongoRepository를 사용하면서 다음과 같이 작성하면 Reactive 흐름이 중간에서 Blocking으로 변경된다.

```java
UserDocument user =
        userRepository.findById("100")
                .block();
```

`block()`은 결과가 올 때까지 호출 Thread를 기다리게 만든다.

WebFlux와 Reactive MongoDB를 사용한다면 가능한 한 Reactive Operator를 이용해 흐름을 이어가는 것이 자연스럽다.

예를 들어 다음과 같이 처리할 수 있다.

```java
public Mono<String> findUserName(
        String id
) {
    return userRepository.findById(id)
            .map(UserDocument::getName);
}
```

구조는 다음과 같다.

```text
MongoDB
   ↓
Mono<UserDocument>
   ↓
map()
   ↓
Mono<String>
```

---

## 데이터가 존재하지 않는 경우

Reactive MongoDB에서도 단일 조회 결과가 없으면 Empty Stream으로 표현될 수 있다.

```text
Mono.empty()
```

예를 들어:

```java
userRepository.findById(id)
```

에서 데이터가 없을 때 Error로 변경하고 싶다면 다음과 같은 Reactive 흐름을 구성할 수 있다.

```java
return userRepository.findById(id)
        .switchIfEmpty(
                Mono.error(
                        new IllegalArgumentException(
                                "user not found"
                        )
                )
        );
```

즉 Reactive Programming에서는 결과 없음도 Stream 상태 중 하나로 다룬다.

---

## MongoDB와 R2DBC의 차이

앞에서 MySQL을 Reactive 방식으로 연결할 때 R2DBC를 사용했다.

```text
MySQL
→ R2DBC
```

MongoDB에서는 R2DBC를 사용하지 않는다.

MongoDB는 관계형 데이터베이스가 아니기 때문이다.

Reactive MongoDB 연결은 MongoDB를 위한 Reactive Driver와 Spring Data Reactive MongoDB를 이용한다.

따라서 다음처럼 구분해야 한다.

```text
관계형 DB

MySQL
PostgreSQL

       ↓

R2DBC
```

반면:

```text
MongoDB
   ↓
Reactive MongoDB Driver
   ↓
Spring Data Reactive MongoDB
```

즉 `Reactive = R2DBC`라고 이해하면 안 된다.

R2DBC는 **Reactive Relational Database Connectivity**이기 때문에 관계형 데이터베이스를 위한 기술이다.

---

## MySQL R2DBC와 Reactive MongoDB 비교

| 구분          | MySQL + R2DBC                               | Reactive MongoDB          |
| ----------- | ------------------------------------------- | ------------------------- |
| DB 유형       | 관계형 DB                                      | Document DB               |
| Reactive 접근 | R2DBC                                       | Mongo Reactive Driver     |
| Mapping     | `@Table`                                    | `@Document`               |
| Repository  | `ReactiveCrudRepository`, `R2dbcRepository` | `ReactiveMongoRepository` |
| 다건 결과       | `Flux<T>`                                   | `Flux<T>`                 |
| 단건 결과       | `Mono<T>`                                   | `Mono<T>`                 |

상위의 Reactive Programming 모델은 비슷하지만 실제 데이터베이스 Driver와 Mapping 방식은 다르다.

---

## Repository 전체 구조 비교

MySQL R2DBC에서는:

```java
public interface DataRepository
        extends ReactiveCrudRepository<DataEntity, Long> {
}
```

MongoDB에서는:

```java
public interface UserRepository
        extends ReactiveMongoRepository<UserDocument, String> {
}
```

두 Repository 모두 Reactive 타입을 사용한다.

```text
Mono
Flux
```

따라서 Service와 Controller 계층에서는 유사한 Reactive Pipeline을 구성할 수 있다.

---

## MongoDB Document 설계에서 생각할 점

MongoDB는 관계형 데이터베이스와 데이터 모델이 다르기 때문에 단순히 RDB의 Table 구조를 그대로 Collection으로 복사하는 방식이 항상 적절한 것은 아니다.

예를 들어 RDB에서는 다음과 같이 여러 Table을 JOIN할 수 있다.

```text
users
orders
order_items
```

MongoDB에서는 Document 내부에 관련 데이터를 Embedding하는 구조도 고려할 수 있다.

```json
{
  "_id": "user-1",
  "name": "Yunsik",
  "addresses": [
    {
      "city": "Seoul"
    }
  ]
}
```

따라서 MongoDB를 사용할 때는 단순 연결 방법뿐 아니라 Document 단위의 데이터 접근 패턴도 함께 고려해야 한다.

---

## Reactive MongoDB를 사용하면 무조건 성능이 좋아질까?

Reactive 방식이라는 이유만으로 모든 시스템의 성능이 자동으로 좋아지는 것은 아니다.

다음과 같은 요소가 함께 영향을 준다.

```text
Query 설계
Index
Document 크기
Connection Pool
MongoDB 서버 성능
네트워크
동시 요청량
애플리케이션 로직
```

Reactive Programming은 높은 I/O 동시성을 효율적으로 처리하기 위한 모델이지 잘못된 Query나 Index 문제까지 해결해주는 기술은 아니다.

예를 들어 Index가 필요한 조회에 Index가 없다면 Reactive MongoDB를 사용하더라도 MongoDB Query 자체가 느릴 수 있다.

---

## MongoDB Index도 중요하다

예를 들어 다음 Query를 자주 수행한다고 가정한다.

```text
findByEmail()
```

데이터가 수백만 건인데 `email`에 적절한 Index가 없다면 Collection Scan이 발생할 수 있다.

구조적으로:

```text
ReactiveMongoRepository
        ↓
MongoDB Query
        ↓
Index 없음
        ↓
느린 검색
```

이 된다.

즉 Reactive Stack을 구축하면서 데이터베이스의 Query와 Index 설계를 별도로 관리해야 한다.

---

## Docker 환경에서 MongoDB 연결

Spring Boot와 MongoDB를 각각 Container로 실행한다면 `localhost` 사용에 주의해야 한다.

예를 들어 다음 구조가 있다고 하자.

```text
Docker Network

webflux-app
mongodb
```

애플리케이션 Container에서 다음 주소를 사용하면:

```text
localhost:27017
```

자기 자신을 의미한다.

Docker Compose의 MongoDB Service 이름이 `mongodb`라면 다음처럼 구성할 수 있다.

```yaml
spring:
  data:
    mongodb:
      uri: mongodb://appuser:password@mongodb:27017/testdb
```

구조는 다음과 같다.

```mermaid
flowchart LR
    A[WebFlux Container] --> M[MongoDB Container]
    M --> D[(testdb)]
```

---

## 운영 환경에서 연결 상태 확인

애플리케이션 프로세스가 실행되고 있다고 해서 MongoDB까지 정상이라는 의미는 아니다.

```text
Spring Boot
→ UP

MongoDB
→ DOWN
```

일 수도 있다.

따라서 운영에서는 다음과 같은 항목을 관찰할 필요가 있다.

```text
MongoDB Connection 상태
Query Latency
Error Rate
Connection Pool
MongoDB CPU
MongoDB Memory
Slow Query
```

애플리케이션과 데이터베이스를 하나의 시스템으로 관찰해야 한다.

---

## Reactive MongoDB에서 Error 처리

MongoDB 연결이 끊기거나 Query가 실패하면 Reactive Stream에 Error Signal이 전달될 수 있다.

```text
onNext
onComplete
onError
```

예를 들어 다음과 같이 Logging을 연결할 수 있다.

```java
return userRepository.findAll()
        .doOnError(error -> {
            // Error Logging
        });
```

상황에 따라 다음과 같은 Operator도 사용할 수 있다.

```java
onErrorResume(...)
```

하지만 데이터베이스 장애를 무조건 빈 데이터로 바꿔버리면 장애를 숨길 수 있기 때문에 Error Handling 정책을 명확하게 설계해야 한다.

---

## ReactiveMongoTemplate이 필요한 경우

단순 CRUD나 Query Method만으로 충분하다면 `ReactiveMongoRepository`가 편리하다.

```text
ReactiveMongoRepository
→ Repository 추상화
```

하지만 더 세밀한 MongoDB Query를 직접 구성해야 하는 경우에는 `ReactiveMongoTemplate`과 같은 API를 사용하는 구조도 고려할 수 있다.

개념적으로 다음과 같이 역할을 나눌 수 있다.

```text
단순 CRUD
메서드 이름 기반 Query

→ ReactiveMongoRepository
```

```text
복잡한 동적 Query
세부적인 MongoDB Operation

→ ReactiveMongoTemplate
```

처음부터 모든 작업을 Template으로 작성할 필요는 없고 요구사항에 따라 선택하면 된다.

---

## 실무에서 Repository와 Document를 바로 Controller에서 사용해도 될까?

간단한 연결 확인만 필요하다면 Controller에서 Repository를 직접 호출할 수도 있다.

```text
Controller
    ↓
Repository
```

하지만 실제 애플리케이션에서는 일반적으로 다음과 같이 계층을 나누는 편이 관리하기 쉽다.

```text
Controller
    ↓
Service
    ↓
Repository
```

그리고 Document를 API 응답으로 그대로 공개하기보다 DTO를 분리할 수도 있다.

```text
MongoDB
   ↓
UserDocument
   ↓
Service
   ↓
UserResponse
   ↓
Client
```

예를 들어:

```java
public record UserResponse(
        String id,
        String name
) {
}
```

Service에서 변환한다.

```java
public Flux<UserResponse> findAll() {

    return userRepository.findAll()
            .map(user ->
                    new UserResponse(
                            user.getId(),
                            user.getName()
                    )
            );
}
```

---

## 전체 프로젝트 구조

기본적인 구조는 다음과 같이 구성할 수 있다.

```text
com.example.mongo
├── MongoApplication.java
│
├── controller
│   └── UserController.java
│
├── service
│   └── UserService.java
│
├── repository
│   └── UserRepository.java
│
└── document
    └── UserDocument.java
```

각 계층의 역할은 다음과 같다.

```text
Controller
→ HTTP 요청과 응답

Service
→ 애플리케이션 로직

Repository
→ Reactive MongoDB 접근

Document
→ MongoDB Collection Mapping
```

---

## 전체 코드 예제

Document:

```java
package com.example.mongo.document;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Document(collection = "users")
public class UserDocument {

    @Id
    private String id;

    private String name;
}
```

Repository:

```java
package com.example.mongo.repository;

import com.example.mongo.document.UserDocument;
import org.springframework.data.mongodb.repository.ReactiveMongoRepository;

public interface UserRepository
        extends ReactiveMongoRepository<UserDocument, String> {
}
```

Service:

```java
package com.example.mongo.service;

import com.example.mongo.document.UserDocument;
import com.example.mongo.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public Flux<UserDocument> findAll() {
        return userRepository.findAll();
    }

    public Mono<UserDocument> findById(String id) {
        return userRepository.findById(id);
    }
}
```

Controller:

```java
package com.example.mongo.controller;

import com.example.mongo.document.UserDocument;
import com.example.mongo.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/users")
    public Flux<UserDocument> findAll() {
        return userService.findAll();
    }

    @GetMapping("/users/{id}")
    public Mono<UserDocument> findById(
            @PathVariable String id
    ) {
        return userService.findById(id);
    }
}
```

설정:

```yaml
spring:
  data:
    mongodb:
      uri: ${MONGODB_URI}
```

---

## 전체 실행 구조

모든 계층을 연결하면 다음과 같다.

```mermaid
flowchart TD
    C[Client] --> CT[WebFlux Controller]

    CT --> S[Service]

    S --> R[ReactiveMongoRepository]

    R --> RM[Spring Data Reactive MongoDB]

    RM --> DB[(MongoDB)]

    DB --> RM
    RM --> R
    R --> S
    S --> CT
    CT --> C
```

Reactive 타입 기준으로 보면 다음과 같다.

```text
MongoDB
   ↓
ReactiveMongoRepository
   ↓
Mono / Flux
   ↓
Service
   ↓
Mono / Flux
   ↓
Controller
   ↓
HTTP Response
```

---

## WebFlux + R2DBC + Reactive MongoDB 관계

앞의 데이터베이스 구성과 함께 보면 Reactive 데이터 접근 기술을 다음처럼 구분할 수 있다.

```text
Spring WebFlux
      ↓

관계형 Database
→ R2DBC

MongoDB
→ Reactive MongoDB
```

두 기술 모두 Reactor의 `Mono`, `Flux`와 연결할 수 있지만 하위 Database Driver와 데이터 모델은 서로 다르다.

```mermaid
flowchart TD
    W[Spring WebFlux]

    W --> R[R2DBC]
    W --> M[Reactive MongoDB]

    R --> SQL[(MySQL)]
    M --> MDB[(MongoDB)]
```

따라서 Reactive 애플리케이션이라고 해서 모든 데이터베이스를 하나의 데이터 접근 기술로 처리하는 것이 아니라 데이터베이스 종류에 맞는 Reactive Driver와 Spring Data 모듈을 선택해야 한다.

---

## 정리

Spring WebFlux에서 MongoDB를 Reactive 방식으로 연결하려면 Spring Data Reactive MongoDB를 사용할 수 있다.

필요한 핵심 의존성은 다음과 같다.

```gradle
implementation 'org.springframework.boot:spring-boot-starter-webflux'
implementation 'org.springframework.boot:spring-boot-starter-data-mongodb-reactive'
```

단일 MongoDB Connection은 설정 파일에 URI를 등록하여 구성할 수 있다.

```yaml
spring:
  data:
    mongodb:
      uri: mongodb://appuser:password@localhost:27017/testdb
```

MongoDB Collection과 연결할 객체는 `@Document`를 이용해 정의할 수 있다.

```java
@Document(collection = "users")
public class UserDocument {

    @Id
    private String id;

    private String name;
}
```

Reactive Repository는 `ReactiveMongoRepository`를 상속하여 작성한다.

```java
public interface UserRepository
        extends ReactiveMongoRepository<UserDocument, String> {
}
```

여러 데이터 조회는 `Flux`를 사용한다.

```java
public Flux<UserDocument> findAll() {
    return userRepository.findAll();
}
```

단일 데이터 조회는 `Mono`를 사용할 수 있다.

```java
public Mono<UserDocument> findById(String id) {
    return userRepository.findById(id);
}
```

전체적으로 다음 Reactive 흐름을 만들 수 있다.

```text
Client
   ↓
Spring WebFlux
   ↓
Controller
   ↓
Service
   ↓
ReactiveMongoRepository
   ↓
MongoDB
```

앞에서 MySQL과 같은 관계형 데이터베이스를 Reactive 방식으로 처리할 때는 R2DBC를 사용했다면, MongoDB에서는 MongoDB 자체의 Reactive 접근 방식과 `ReactiveMongoRepository`를 사용한다는 차이가 있다.

### 한 줄 요약

Spring WebFlux에서 MongoDB까지 Reactive 흐름을 유지하려면 Spring Data Reactive MongoDB와 `ReactiveMongoRepository`를 사용하고, MongoDB Collection을 `@Document`로 매핑한 뒤 Repository부터 Service와 Controller까지 `Mono`와 `Flux` 기반으로 연결하면 된다.
