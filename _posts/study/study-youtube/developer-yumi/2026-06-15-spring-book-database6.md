---
layout: post
bigtitle: '스프링 부트 데이터베이스'
subtitle: 스프링 부트 데이터베이스 6 - MongoDB 단일 연결
date: '2026-06-15 00:00:01 +0900'
categories:
    - developer-yumi
comments: true

---

# 스프링 부트 데이터베이스 6 - MongoDB 단일 연결
[https://youtu.be/OwQ0lSuie1Q?si=WgvXQv2PlqUyp7dS](https://youtu.be/OwQ0lSuie1Q?si=WgvXQv2PlqUyp7dS)

# 스프링 부트 데이터베이스 6 - MongoDB 단일 연결
* toc
{:toc}

---

## Spring Boot에서 MongoDB 단일 연결 설정하기

이번 글에서는 Spring Boot 프로젝트에서 MongoDB를 단일 연결 방식으로 설정하고, 실제 컬렉션 데이터를 조회하여 화면에 출력하는 과정까지 정리한다.

핵심은 다음과 같다.

> **하나의 MongoDB를 연결하는 경우, application.properties에 MongoDB URI를 설정하는 것만으로 Spring Boot가 연결에 필요한 객체를 자동 구성한다.**

별도의 Configuration 클래스를 작성하지 않아도 되기 때문에 초기 개발이나 간단한 서비스에서 빠르게 MongoDB 연동을 구성할 수 있다.

---

## 1. MongoDB 단일 연결이란?

MongoDB 단일 연결은 하나의 Spring Boot 애플리케이션이 하나의 MongoDB 데이터베이스에 연결되는 구조를 의미한다.

전체 구조는 다음과 같다.

```text
Spring Boot
    ↓
MongoDB Database
    ↓
Collection
    ↓
Document
```

Spring Boot는 단일 MongoDB 연결에 대해 자동 설정을 제공한다.

따라서 다음과 같은 설정 파일에 연결 정보만 등록하면 된다.

```text
application.properties
application.yml
```

두 개 이상의 MongoDB를 연결하는 경우에는 별도의 Configuration 클래스가 필요하지만, 하나만 연결할 때는 설정 파일만으로 충분하다.

---

## 2. RDB와 MongoDB의 구조 차이

MongoDB를 사용하기 전에 RDB와 구조가 어떻게 다른지 이해할 필요가 있다.

| RDB           | MongoDB         |
| ------------- | --------------- |
| Database      | Database        |
| Table         | Collection      |
| Row           | Document        |
| Column        | Field           |
| Entity        | Document 클래스    |
| JpaRepository | MongoRepository |

MySQL에서는 테이블과 Entity를 연결했다면, MongoDB에서는 Collection과 Document 클래스를 연결한다.

MongoDB 데이터 예시는 다음과 같다.

```json
{
  "_id": "64e1234abcd",
  "data": "MongoDB 데이터"
}
```

MongoDB는 JSON과 유사한 BSON 구조로 데이터를 저장한다.

---

## 3. MongoDB 연결에 필요한 정보

MongoDB 연결을 위해 다음 정보가 필요하다.

```text
MongoDB 서버 주소
Port
Database 이름
Username
Password
```

연결 정보를 설정하는 방법은 크게 두 가지다.

---

## 4. MongoDB URI 방식

MongoDB Atlas와 같은 클라우드 서비스를 사용한다면 일반적으로 URI 방식으로 연결한다.

```properties
spring.data.mongodb.uri=mongodb+srv://사용자명:비밀번호@클러스터주소/데이터베이스명
```

예시는 다음과 같다.

```properties
spring.data.mongodb.uri=mongodb+srv://myUser:myPassword@myCluster.mongodb.net/testDB1
```

URI 구조를 나누어 보면 다음과 같다.

```text
mongodb+srv://
사용자명:비밀번호
@
MongoDB 서버 주소
/
데이터베이스 이름
```

각 항목의 의미는 다음과 같다.

| 항목               | 설명                  |
| ---------------- | ------------------- |
| `mongodb+srv://` | MongoDB SRV 연결 프로토콜 |
| 사용자명             | MongoDB 접속 계정       |
| 비밀번호             | 계정 비밀번호             |
| 클러스터 주소          | MongoDB Atlas 서버 주소 |
| 데이터베이스명          | 연결할 Database        |

---

## 5. 개별 변수 방식

직접 설치한 MongoDB를 사용하는 경우 각 연결 정보를 나누어 설정할 수도 있다.

```properties
spring.data.mongodb.host=localhost
spring.data.mongodb.port=27017
spring.data.mongodb.username=myUser
spring.data.mongodb.password=myPassword
spring.data.mongodb.database=testDB1
```

MongoDB 기본 포트는 다음과 같다.

```text
27017
```

URI 방식과 개별 변수 방식 중 하나만 사용하면 된다.

두 방식을 동시에 설정하면 어떤 설정을 사용할지 혼동이 생길 수 있으므로 한 가지 방식으로 통일하는 것이 좋다.

---

## 6. Spring Boot 프로젝트 생성

Spring Initializr 또는 IntelliJ의 Spring Initializr 기능을 이용해 프로젝트를 생성한다.

기본 설정 예시는 다음과 같다.

| 설정          | 값      |
| ----------- | ------ |
| Language    | Java   |
| Build Tool  | Gradle |
| Packaging   | Jar    |
| Java        | 17 이상  |
| Spring Boot | 3.x    |

Spring Boot 3 이상에서는 Java 17 이상이 필요하다.

---

## 7. MongoDB 의존성 추가

MongoDB 연결을 위한 핵심 의존성은 Spring Data MongoDB다.

```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-data-mongodb'
}
```

웹 화면까지 구현하려면 다음 의존성을 추가할 수 있다.

```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-data-mongodb'
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-mustache'

    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'
}
```

---

## 8. 일반 MongoDB와 Reactive MongoDB 차이

Spring Initializr에서 MongoDB를 검색하면 일반 방식과 Reactive 방식이 함께 표시될 수 있다.

일반 MongoDB 의존성은 다음과 같다.

```text
Spring Data MongoDB
```

Reactive 방식은 다음 의존성을 사용한다.

```text
Spring Data Reactive MongoDB
```

차이는 다음과 같다.

| 방식               | 특징                     |
| ---------------- | ---------------------- |
| 일반 MongoDB       | 블로킹 방식                 |
| Reactive MongoDB | 논블로킹 방식                |
| 일반 MongoDB       | Spring MVC와 자연스럽게 사용   |
| Reactive MongoDB | WebFlux 기반 서비스에서 주로 사용 |

이번 실습에서는 일반적인 Spring MVC 구조를 사용하므로 `Spring Data MongoDB`를 선택한다.

---

## 9. application.properties 설정

설정 파일은 다음 경로에 있다.

```text
src/main/resources/application.properties
```

MongoDB Atlas를 사용하는 경우 다음과 같이 설정한다.

```properties
spring.data.mongodb.uri=mongodb+srv://myUser:myPassword@myCluster.mongodb.net/testDB1
```

직접 설치한 MongoDB라면 다음과 같이 작성할 수 있다.

```properties
spring.data.mongodb.host=localhost
spring.data.mongodb.port=27017
spring.data.mongodb.username=myUser
spring.data.mongodb.password=myPassword
spring.data.mongodb.database=testDB1
```

설정이 끝난 뒤 애플리케이션을 실행한다.

MongoDB 연결 정보가 올바르고 접근 권한에 문제가 없다면 애플리케이션이 오류 없이 실행된다.

---

## 10. MongoDB Atlas 사용 시 추가 확인 사항

MongoDB Atlas는 URI만 정확히 입력했다고 해서 항상 연결되는 것은 아니다.

Atlas에서 다음 항목도 확인해야 한다.

### Database User

애플리케이션에서 사용할 계정이 생성되어 있어야 한다.

```text
Database Access
→ Add New Database User
```

### Network Access

Spring Boot가 실행되는 IP 주소가 허용되어 있어야 한다.

```text
Network Access
→ Add IP Address
```

개발 과정에서 전체 IP를 임시 허용할 수 있지만, 운영 환경에서는 애플리케이션 서버의 IP 대역만 허용하는 것이 안전하다.

### 특수문자 비밀번호

비밀번호에 다음과 같은 특수문자가 포함되어 있다면 URI 인코딩이 필요할 수 있다.

```text
@
:
/
?
#
```

예를 들어 비밀번호가 다음과 같다면:

```text
pass@123
```

`@` 문자를 URL 인코딩해야 한다.

```text
pass%40123
```

---

## 11. Document 클래스 생성

MongoDB Collection 데이터를 Java 객체로 받으려면 Document 클래스를 생성해야 한다.

예를 들어 MongoDB에 다음 Collection이 있다고 가정한다.

```text
table1
```

데이터 구조는 다음과 같다.

```json
{
  "_id": "1",
  "data": "첫 번째 데이터"
}
```

Document 클래스는 다음과 같이 작성한다.

```java
package com.example.demo.document;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Getter
@Setter
@Document(collection = "table1")
public class Table1Document {

    @Id
    private String id;

    private String data;
}
```

---

## 12. @Document 어노테이션

MongoDB에서 사용하는 핵심 어노테이션은 다음과 같다.

```java
@Document(collection = "table1")
```

이 어노테이션은 해당 Java 클래스가 MongoDB Collection과 매핑되는 객체임을 의미한다.

RDB에서의 `@Entity`와 비슷한 역할을 한다.

```text
@Entity
→ RDB Table 매핑

@Document
→ MongoDB Collection 매핑
```

`@Document` import 경로가 잘못되면 정상적으로 매핑되지 않을 수 있으므로 다음 클래스를 사용해야 한다.

```java
org.springframework.data.mongodb.core.mapping.Document
```

---

## 13. @Id 어노테이션

MongoDB의 기본 식별자 필드는 `_id`다.

Java 클래스에서는 다음과 같이 선언한다.

```java
@Id
private String id;
```

Spring Data MongoDB가 Java의 `id` 필드와 MongoDB의 `_id`를 자동으로 연결한다.

MongoDB의 ID가 `ObjectId`라 하더라도 일반적인 조회에서는 `String`으로 받을 수 있다.

---

## 14. MongoRepository 생성

MongoDB Collection에 접근하려면 `MongoRepository`를 상속받는 Repository를 만든다.

```java
package com.example.demo.repository;

import com.example.demo.document.Table1Document;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface Table1Repository
        extends MongoRepository<Table1Document, String> {
}
```

제네릭 타입의 의미는 다음과 같다.

```text
MongoRepository<Document 클래스, ID 타입>
```

현재 예시에서는:

```text
Document 클래스: Table1Document
ID 타입: String
```

이다.

---

## 15. MongoRepository가 제공하는 기능

`MongoRepository`를 상속하면 기본 CRUD 메소드를 사용할 수 있다.

| 메소드            | 기능          |
| -------------- | ----------- |
| `findAll()`    | 전체 데이터 조회   |
| `findById()`   | ID 기준 단건 조회 |
| `save()`       | 데이터 저장 및 수정 |
| `deleteById()` | ID 기준 삭제    |
| `count()`      | 전체 개수 조회    |

직접 MongoDB 쿼리를 작성하지 않아도 기본적인 데이터 접근이 가능하다.

---

## 16. Controller에서 데이터 조회하기

간단한 연결 테스트를 위해 Controller에서 Repository를 직접 호출해본다.

```java
package com.example.demo.controller;

import com.example.demo.document.Table1Document;
import com.example.demo.repository.Table1Repository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class MainController {

    private final Table1Repository table1Repository;

    public MainController(Table1Repository table1Repository) {
        this.table1Repository = table1Repository;
    }

    @GetMapping("/")
    public String main(Model model) {

        List<Table1Document> data =
                table1Repository.findAll();

        model.addAttribute("data", data);

        return "main";
    }
}
```

---

## 17. Controller 동작 흐름

전체 조회 흐름은 다음과 같다.

```text
GET /
   ↓
MainController
   ↓
Table1Repository.findAll()
   ↓
MongoDB table1 Collection 조회
   ↓
List<Table1Document> 반환
   ↓
Model에 데이터 저장
   ↓
main.mustache 렌더링
```

핵심 코드는 다음이다.

```java
table1Repository.findAll();
```

MongoDB의 `table1` Collection에 저장된 모든 Document를 가져온다.

---

## 18. Mustache 화면 출력

`main.mustache` 파일을 생성한다.

경로는 다음과 같다.

```text
src/main/resources/templates/main.mustache
```

간단하게 전체 객체를 출력하려면 다음과 같이 작성할 수 있다.

```html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>MongoDB 테스트</title>
</head>
<body>

<h1>MongoDB 데이터</h1>

{{#data}}
    <div>
        <p>ID: {{id}}</p>
        <p>Data: {{data}}</p>
    </div>
    <hr>
{{/data}}

{{^data}}
    <p>조회된 데이터가 없습니다.</p>
{{/data}}

</body>
</html>
```

---

## 19. 실행 결과 확인

애플리케이션 실행 후 다음 주소로 접근한다.

```text
http://localhost:8080
```

MongoDB `table1` Collection에 다음 데이터가 저장되어 있다고 가정한다.

```json
[
  {
    "_id": "1",
    "data": "MongoDB 첫 번째 데이터"
  },
  {
    "_id": "2",
    "data": "MongoDB 두 번째 데이터"
  }
]
```

화면에는 다음과 같이 표시된다.

```text
ID: 1
Data: MongoDB 첫 번째 데이터

ID: 2
Data: MongoDB 두 번째 데이터
```

이 결과가 정상적으로 출력된다면 MongoDB 연결과 Document 매핑, Repository 조회까지 정상적으로 동작한 것이다.

---

## 20. 테스트 코드에서 Service를 생략한 이유

이번 예제에서는 연결 확인이 목적이기 때문에 Controller에서 Repository를 직접 호출했다.

```text
Controller
→ Repository
```

하지만 실무에서는 다음과 같은 구조가 일반적이다.

```text
Controller
→ Service
→ Repository
→ MongoDB
```

Service 계층을 두는 이유는 다음과 같다.

* 비즈니스 로직 분리
* 트랜잭션 관리
* 코드 재사용
* 테스트 용이성
* Controller 복잡도 감소

실제 서비스 코드에서는 Repository를 Service 계층에 주입하는 방식이 좋다.

---

## 21. 실무형 Service 구조 예시

```java
package com.example.demo.service;

import com.example.demo.document.Table1Document;
import com.example.demo.repository.Table1Repository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class Table1Service {

    private final Table1Repository table1Repository;

    public Table1Service(Table1Repository table1Repository) {
        this.table1Repository = table1Repository;
    }

    public List<Table1Document> findAll() {
        return table1Repository.findAll();
    }
}
```

Controller는 Service만 호출한다.

```java
@Controller
public class MainController {

    private final Table1Service table1Service;

    public MainController(Table1Service table1Service) {
        this.table1Service = table1Service;
    }

    @GetMapping("/")
    public String main(Model model) {
        model.addAttribute("data", table1Service.findAll());
        return "main";
    }
}
```

---

## 22. 자주 발생하는 오류

### MongoSocketOpenException

```text
MongoSocketOpenException
```

MongoDB 서버 주소나 포트가 잘못되었거나 네트워크 접근이 막힌 경우 발생한다.

확인 항목:

```text
MongoDB 서버 주소
27017 포트
Atlas Network Access
방화벽
```

---

### Authentication failed

```text
Authentication failed
```

계정명이나 비밀번호가 잘못되었을 가능성이 높다.

MongoDB Atlas에서는 Database Access에 등록된 계정을 사용해야 한다.

---

### Database 이름 오류

URI 마지막에 연결할 데이터베이스 이름이 정확히 들어가야 한다.

```properties
spring.data.mongodb.uri=mongodb+srv://user:password@cluster.mongodb.net/testDB1
```

여기서 `testDB1`이 실제 사용할 Database 이름이다.

---

### Collection 이름 불일치

Document에서 선언한 Collection 이름과 MongoDB 실제 이름이 다르면 조회 결과가 비어 있을 수 있다.

```java
@Document(collection = "table1")
```

대소문자까지 정확히 맞추는 것이 좋다.

---

### 잘못된 @Document import

다음 import를 사용해야 한다.

```java
import org.springframework.data.mongodb.core.mapping.Document;
```

다른 패키지의 `Document`를 import하면 MongoDB Collection 매핑이 동작하지 않는다.

---

## 23. 보안 설정 시 주의할 점

MongoDB URI에는 계정과 비밀번호가 포함될 수 있다.

```properties
spring.data.mongodb.uri=mongodb+srv://user:password@cluster.mongodb.net/testDB1
```

따라서 이 값을 GitHub에 그대로 업로드하면 안 된다.

실무에서는 다음 방법을 사용한다.

```text
환경 변수
AWS Secrets Manager
Kubernetes Secret
Docker Secret
CI/CD Secret Variable
```

환경 변수를 적용하면 다음과 같이 작성할 수 있다.

```properties
spring.data.mongodb.uri=${MONGODB_URI}
```

운영 서버에는 다음 환경 변수를 등록한다.

```text
MONGODB_URI=mongodb+srv://user:password@cluster.mongodb.net/testDB1
```

---

## 24. URI 방식과 개별 설정 방식 비교

| 구분         | URI 방식     | 개별 변수 방식 |
| ---------- | ---------- | -------- |
| 설정 길이      | 짧음         | 비교적 김    |
| Atlas 사용   | 적합         | 상대적으로 불편 |
| 로컬 MongoDB | 가능         | 적합       |
| 계정 정보 관리   | URI 내부 포함  | 항목별 분리   |
| 복제본 설정     | URI로 쉽게 표현 | 별도 설정 필요 |

MongoDB Atlas를 사용한다면 URI 방식이 가장 편리하다.

직접 설치한 단일 MongoDB 서버라면 개별 변수 방식도 이해하기 쉽다.

---

## 25. RDB Repository와 MongoRepository 비교

JPA에서는 다음 인터페이스를 사용했다.

```java
JpaRepository<Entity, ID>
```

MongoDB에서는 다음 인터페이스를 사용한다.

```java
MongoRepository<Document, ID>
```

구조는 비슷하지만 저장 대상이 다르다.

```text
JpaRepository
→ RDB Table

MongoRepository
→ MongoDB Collection
```

따라서 Spring Data 경험이 있다면 MongoDB Repository도 비교적 쉽게 사용할 수 있다.

---

## 정리

이번 글에서는 Spring Boot에서 MongoDB를 단일 연결 방식으로 설정하고, 실제 데이터를 조회해 화면에 출력하는 과정까지 정리했다.

핵심 흐름은 다음과 같다.

```text
Spring Data MongoDB 의존성 추가
→ application.properties에 URI 설정
→ @Document 클래스 작성
→ MongoRepository 생성
→ findAll()로 데이터 조회
→ Model을 통해 화면으로 전달
```

가장 중요한 설정은 다음 한 줄이다.

```properties
spring.data.mongodb.uri=mongodb+srv://사용자명:비밀번호@클러스터주소/데이터베이스명
```

단일 MongoDB 연결에서는 별도의 Configuration 클래스를 작성하지 않아도 Spring Boot 자동 설정을 통해 빠르게 연결할 수 있다.

다만 운영 환경에서는 URI에 포함된 계정 정보를 외부 설정으로 분리하고, Atlas의 IP 접근 범위를 최소화하여 관리하는 것이 중요하다.

