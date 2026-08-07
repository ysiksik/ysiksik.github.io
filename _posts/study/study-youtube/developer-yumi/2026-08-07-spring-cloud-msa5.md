---
layout: post
bigtitle: '스프링 클라우드 MSA'
subtitle: 스프링 클라우드 MSA 5 - Config 클라이언트 설정
date: '2026-08-07 00:00:02 +0900'
categories:
    - developer-yumi
comments: true

---

# 스프링 클라우드 MSA 5 - Config 클라이언트 설정
[https://youtu.be/EQ31GAYxqSk?si=Yshf_X2QcAi6_tDY](https://youtu.be/EQ31GAYxqSk?si=Yshf_X2QcAi6_tDY)

# 스프링 클라우드 MSA 5 - Config 클라이언트 설정
* toc
{:toc}

---

## Spring Cloud Config Client 구성과 외부 설정 적용 방법

Spring Cloud Config Client는 Config Server에서 제공하는 외부 설정을 가져와 사용하는 Spring Boot 애플리케이션이다.

별도의 특수한 서버를 새로 만드는 것이 아니라, 회원·주문·결제 같은 비즈니스 로직을 수행하는 기존 Spring Boot 애플리케이션에 Config Client 의존성과 연결 설정을 추가하는 방식으로 구성한다.

전체 구조는 다음과 같다.

```mermaid
flowchart LR
    A[Git Config Repository] --> B[Spring Cloud Config Server]
    B --> C[Config Client]
    C --> D[Spring Boot 비즈니스 로직]
```

Config Client의 핵심 역할은 다음과 같다.

```text
애플리케이션 시작
→ Config Server에 설정 요청
→ 서비스 이름과 Profile에 맞는 설정 조회
→ 외부 설정을 Spring Environment에 등록
→ 등록된 설정으로 애플리케이션 실행
```

Spring Boot 2.4 이후에는 `spring.config.import` 속성을 이용하여 Config Server의 설정을 불러오는 방식이 기본적으로 사용된다.

---

## Config Client가 필요한 이유

MSA 환경에서는 여러 개의 Spring Boot 애플리케이션이 독립적으로 실행된다.

```text
user-service
product-service
order-service
payment-service
notification-service
```

각 서비스는 다음과 같은 설정을 가진다.

```text
서버 Port
Database URL
Database Username
외부 API 주소
Redis 주소
Kafka Broker 주소
Timeout
Retry 횟수
로그 레벨
Feature Flag
```

각 프로젝트가 자신의 설정 파일을 직접 관리하면 동일한 값을 여러 저장소에서 반복해서 수정해야 한다.

예를 들어 Redis 주소가 변경되었다면 다음 프로젝트들을 각각 수정해야 할 수 있다.

```text
user-service/application.yml
order-service/application.yml
payment-service/application.yml
notification-service/application.yml
```

Config Client를 적용하면 각 서비스는 필요한 설정을 Config Server에서 가져온다.

```text
Git Config Repository
→ Config Server
→ 각 Config Client
```

이를 통해 코드와 환경 설정을 분리하고, 서비스별·환경별 설정을 중앙에서 관리할 수 있다.

---

## Config Client는 별도의 서버인가?

Config Client는 Config Server처럼 별도의 인프라 애플리케이션을 의미하지 않는다.

다음과 같은 일반 Spring Boot 애플리케이션이 Config Client가 된다.

```text
회원 API 서버
주문 API 서버
결제 API 서버
배송 처리 서버
배치 애플리케이션
```

기존 애플리케이션에 다음 두 가지를 추가하면 된다.

```text
Spring Cloud Config Client 의존성
Config Server 연결 설정
```

즉, 다음 구조가 Config Client다.

```text
기존 Spring Boot 애플리케이션
+
spring-cloud-starter-config
+
Config Server 연결 정보
```

---

## Config Repository 파일과 Client 설정의 관계

Config Repository에 다음 파일이 있다고 가정한다.

```text
application.yml
application-dev.yml
ms1.yml
ms1-dev.properties
ms1-prod.properties
```

`ms1` 애플리케이션이 `dev` Profile로 실행되면 다음 설정을 대상으로 조회한다.

```text
application.yml
application-dev.yml
ms1.yml
ms1-dev.properties
```

Config Client에서 지정한 다음 값이 파일 선택 기준이 된다.

```text
spring.application.name
spring.profiles.active
```

예를 들어 다음과 같이 설정한다.

```properties
spring.application.name=ms1
spring.profiles.active=dev
```

이 값은 Config Repository의 다음 파일과 연결된다.

```text
ms1-dev.properties
```

관계를 정리하면 다음과 같다.

```text
spring.application.name=ms1
                         ↓
파일명의 application 부분

spring.profiles.active=dev
                       ↓
파일명의 profile 부분

최종 대상
→ ms1-dev.properties
```

---

## 프로젝트 의존성 추가

기존 Spring Boot 애플리케이션에 Spring Cloud Config Client 의존성을 추가한다.

### build.gradle

```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'

    implementation 'org.springframework.cloud:spring-cloud-starter-config'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}
```

Config Client의 핵심 의존성은 다음과 같다.

```gradle
implementation 'org.springframework.cloud:spring-cloud-starter-config'
```

이 의존성이 추가되면 Spring Boot는 Config Server에서 외부 설정을 가져오기 위한 기능을 구성한다.

---

## Spring Cloud BOM 설정

Spring Cloud 의존성은 Spring Boot와 호환되는 버전을 사용해야 한다.

### build.gradle 전체 예시

```gradle
plugins {
    id 'java'
    id 'org.springframework.boot' version '사용 중인 Spring Boot 버전'
    id 'io.spring.dependency-management' version '사용 중인 버전'
}

group = 'com.example'
version = '0.0.1-SNAPSHOT'

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }
}

ext {
    set('springCloudVersion', "Spring Boot와 호환되는 Spring Cloud 버전")
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'

    implementation 'org.springframework.cloud:spring-cloud-starter-config'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

dependencyManagement {
    imports {
        mavenBom "org.springframework.cloud:spring-cloud-dependencies:${springCloudVersion}"
    }
}

tasks.named('test') {
    useJUnitPlatform()
}
```

Spring Boot 버전과 Spring Cloud Release Train이 호환되지 않으면 애플리케이션 시작 오류나 의존성 충돌이 발생할 수 있다.

따라서 임의로 각각의 최신 버전을 선택하기보다 호환되는 조합을 사용해야 한다.

---

## Config Server 연결 설정

Config Client는 `application.properties` 또는 `application.yml`에서 Config Server 주소를 설정한다.

현재 권장되는 기본 방식은 `spring.config.import`다.

### application.properties

```properties
spring.application.name=ms1
spring.profiles.active=dev

spring.config.import=configserver:http://localhost:9000
```

Config Server가 HTTP Basic 인증을 사용한다면 다음 설정을 추가할 수 있다.

```properties
spring.application.name=ms1
spring.profiles.active=dev

spring.config.import=configserver:http://localhost:9000

spring.cloud.config.username=config-client
spring.cloud.config.password=change-this-password
```

각 설정의 역할은 다음과 같다.

| 설정                             | 역할                    |
| ------------------------------ | --------------------- |
| `spring.application.name`      | 조회할 서비스 이름            |
| `spring.profiles.active`       | 적용할 환경 Profile        |
| `spring.config.import`         | Config Server 주소      |
| `spring.cloud.config.username` | Config Server 인증 계정   |
| `spring.cloud.config.password` | Config Server 인증 비밀번호 |

---

## application.yml 방식

```yaml
spring:
  application:
    name: ms1

  profiles:
    active: dev

  config:
    import: configserver:http://localhost:9000

  cloud:
    config:
      username: ${CONFIG_SERVER_USERNAME}
      password: ${CONFIG_SERVER_PASSWORD}
```

비밀번호를 설정 파일에 직접 작성하지 않고 환경 변수로 분리한다.

```text
CONFIG_SERVER_USERNAME=config-client
CONFIG_SERVER_PASSWORD=strong-password
```

---

## optional:configserver 의미

Config Server 연결을 선택 사항으로 만들 수 있다.

```properties
spring.config.import=optional:configserver:http://localhost:9000
```

`optional:` 사용 여부에 따른 차이는 다음과 같다.

| 설정                       | Config Server 연결 실패 시 |
| ------------------------ | --------------------- |
| `configserver:`          | 애플리케이션 시작 실패 가능       |
| `optional:configserver:` | 외부 설정 없이 계속 시작 가능     |

DB 주소나 인증키처럼 필수 설정을 Config Server에서 가져온다면 `optional:` 사용에 신중해야 한다.

예를 들어 Config Server가 중단되었는데 애플리케이션이 기본값으로 실행되면 잘못된 DB나 외부 API에 연결될 수 있다.

핵심 설정이 외부에 있다면 연결 실패 시 애플리케이션을 시작하지 않는 Fail-Fast 전략이 더 안전할 수 있다.

---

## Config Server 인증 정보 관리

다음처럼 URL에 계정과 비밀번호를 포함하는 방식도 기술적으로 가능하다.

```properties
spring.config.import=configserver:http://user:password@localhost:9000
```

하지만 이 방식은 다음 위치에 인증 정보가 노출될 수 있다.

```text
설정 파일
애플리케이션 로그
오류 메시지
모니터링 정보
프로세스 정보
```

따라서 인증 정보는 별도 속성과 환경 변수로 관리하는 것이 좋다.

```properties
spring.config.import=configserver:${CONFIG_SERVER_URL}

spring.cloud.config.username=${CONFIG_SERVER_USERNAME}
spring.cloud.config.password=${CONFIG_SERVER_PASSWORD}
```

운영 환경에서는 다음 보안 저장소를 사용할 수 있다.

```text
AWS Secrets Manager
AWS Systems Manager Parameter Store
HashiCorp Vault
Kubernetes Secret
Azure Key Vault
CI/CD Secret
```

---

## Config Client 실행 순서

Config Client가 시작되면 일반적으로 다음 순서로 동작한다.

```mermaid
sequenceDiagram
    participant C as Config Client
    participant S as Config Server
    participant G as Git Config Repository

    C->>S: ms1/dev 설정 요청
    S->>G: 관련 설정 파일 조회
    G-->>S: 설정 데이터 반환
    S-->>C: 병합한 설정 반환
    C->>C: Spring Environment에 등록
    C->>C: Bean 생성 및 서버 실행
```

Config Server에 대한 요청은 다음 형태와 연결된다.

```text
/{application}/{profile}
```

현재 설정이 다음과 같다면:

```properties
spring.application.name=ms1
spring.profiles.active=dev
```

논리적으로 다음 설정을 요청한다.

```text
/ms1/dev
```

Config Server는 Config Repository에서 관련 설정 파일을 찾아 병합해 반환한다.

---

## 외부 설정으로 서버 Port 변경하기

Config Repository의 `ms1-dev.properties`에 다음 설정이 있다고 가정한다.

```properties
server.port=8081
custom.message=Config Server에서 가져온 메시지입니다.
```

Config Client의 로컬 `application.properties`에는 다음 설정만 작성한다.

```properties
spring.application.name=ms1
spring.profiles.active=dev
spring.config.import=configserver:http://localhost:9000
```

애플리케이션을 실행하면 Config Server로부터 다음 값을 가져온다.

```properties
server.port=8081
```

따라서 애플리케이션은 `8080`이 아니라 `8081` 포트에서 실행된다.

```text
http://localhost:8081
```

실행 로그에서도 포트를 확인할 수 있다.

```text
Tomcat started on port 8081
```

---

## 전체 실행 순서

Config Client를 테스트할 때는 일반적으로 다음 순서로 실행한다.

```text
1. Git Config Repository 준비
2. Config Server 실행
3. Config Server 설정 조회 API 확인
4. Config Client 실행
5. 외부 설정 적용 여부 확인
```

Config Server가 `9000` 포트에서 실행되고 있다고 가정한다.

먼저 Config Server의 설정 조회를 확인한다.

```bash
curl \
  -u config-client:change-this-password \
  http://localhost:9000/ms1/dev
```

정상적으로 설정이 반환되면 Config Client를 실행한다.

```bash
./gradlew bootRun
```

실행 결과에서 외부 설정이 적용되었는지 확인한다.

```text
Tomcat started on port 8081
```

---

## 외부 설정값을 코드에서 사용하는 방법

Config Repository의 `ms1-dev.properties`에 다음 값을 추가한다.

```properties
custom.message=외부 설정으로 전달된 메시지
custom.timeout=3000
```

Spring Boot에서는 `@Value`를 사용해 값을 받을 수 있다.

```java
package com.example.ms1.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ConfigController {

    private final String message;
    private final int timeout;

    public ConfigController(
            @Value("${custom.message}")
            String message,
            @Value("${custom.timeout}")
            int timeout
    ) {
        this.message = message;
        this.timeout = timeout;
    }

    @GetMapping("/config")
    public String config() {
        return "message=" + message
                + ", timeout=" + timeout;
    }
}
```

다음 주소로 접근한다.

```text
http://localhost:8081/config
```

결과는 다음과 같다.

```text
message=외부 설정으로 전달된 메시지, timeout=3000
```

---

## @ConfigurationProperties 활용

설정 항목이 여러 개라면 `@Value`를 반복하는 것보다 `@ConfigurationProperties`를 사용하는 것이 좋다.

Config Repository의 설정은 다음과 같다.

```yaml
custom:
  api:
    base-url: https://api.example.com
    connect-timeout: 1000
    read-timeout: 3000
    retry-count: 2
```

설정 클래스를 작성한다.

```java
package com.example.ms1.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "custom.api")
public record CustomApiProperties(
        String baseUrl,
        int connectTimeout,
        int readTimeout,
        int retryCount
) {
}
```

메인 클래스에 설정 스캔을 활성화한다.

```java
package com.example.ms1;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@ConfigurationPropertiesScan
@SpringBootApplication
public class Ms1Application {

    public static void main(String[] args) {
        SpringApplication.run(Ms1Application.class, args);
    }
}
```

서비스에서 설정 객체를 주입받는다.

```java
package com.example.ms1.service;

import com.example.ms1.config.CustomApiProperties;
import org.springframework.stereotype.Service;

@Service
public class ExternalApiService {

    private final CustomApiProperties properties;

    public ExternalApiService(
            CustomApiProperties properties
    ) {
        this.properties = properties;
    }

    public String getApiInformation() {
        return "baseUrl=" + properties.baseUrl()
                + ", readTimeout="
                + properties.readTimeout();
    }
}
```

`@ConfigurationProperties`는 관련 설정을 하나의 객체로 묶을 수 있고 타입 변환과 구조적인 관리에 유리하다.

---

## 로컬 설정과 외부 설정의 관계

Config Client는 로컬 설정과 Config Server 설정을 함께 사용한다.

로컬 설정에는 Config Server를 찾기 위한 최소 정보가 필요하다.

```properties
spring.application.name=ms1
spring.profiles.active=dev
spring.config.import=configserver:http://localhost:9000
```

외부 저장소에는 애플리케이션이 실제로 사용할 환경 설정을 둔다.

```properties
server.port=8081
spring.datasource.url=jdbc:mysql://db-server:3306/ms1
custom.timeout=3000
```

역할을 구분하면 다음과 같다.

```text
로컬 application.yml
→ Config Server를 찾기 위한 초기 설정

Config Repository
→ 서비스가 실제 사용할 운영 설정
```

Config Server 주소 자체를 Config Server에서 가져올 수는 없다.

Config Client가 외부 설정을 요청하려면 먼저 Config Server의 위치를 알아야 하기 때문이다.

---

## 설정 우선순위 이해하기

Spring Boot는 여러 위치에서 설정을 읽는다.

```text
Config Repository
application.yml
Profile 설정
환경 변수
명령행 인자
테스트 설정
```

동일한 키가 여러 위치에 존재하면 우선순위에 따라 최종 값이 결정된다.

예를 들어 Config Repository에 다음 값이 있다.

```properties
custom.timeout=3000
```

실행 시 명령행 인자로 다음 값을 전달할 수 있다.

```bash
java -jar ms1.jar --custom.timeout=5000
```

일반적으로 명령행 인자의 우선순위가 높으므로 최종 값은 `5000`이 될 수 있다.

Spring Boot는 외부화 설정과 `spring.config.import`를 통해 추가 설정 데이터를 가져오는 기능을 제공한다.

운영 장애를 방지하려면 같은 설정을 여러 위치에서 중복 정의하지 않는 것이 좋다.

---

## Git 설정을 변경하면 Client에 즉시 반영될까?

Config Repository의 설정을 변경하면 Config Server의 다음 조회 결과에는 새로운 값이 나타날 수 있다.

하지만 이미 실행 중인 Config Client의 설정이 자동으로 즉시 변경되는 것은 아니다.

예를 들어 Repository의 Port를 다음과 같이 변경했다고 가정한다.

```properties
server.port=8081
```

다음 값으로 변경한다.

```properties
server.port=8082
```

Config Client를 재시작하면 새로운 설정을 다시 받아 `8082` 포트로 실행된다.

```text
기존 실행
→ 8081

설정 변경 후 재시작
→ 8082
```

`server.port`처럼 서버 시작 단계에서 사용되는 설정은 일반적인 Refresh 요청만으로 안전하게 변경하기 어렵다.

이러한 설정은 애플리케이션 재시작이나 Rolling Deployment로 반영하는 것이 적절하다.

---

## 설정 갱신 방법

외부 설정 변경을 실행 중인 애플리케이션에 적용하는 방법은 크게 세 가지다.

```text
애플리케이션 재시작
Actuator Refresh
Spring Cloud Bus
```

---

## 애플리케이션 재시작

가장 명확하고 안전한 방법이다.

```text
Config Repository 수정
→ Commit 및 Push
→ Config Server 조회 확인
→ 기존 Client 종료
→ Client 재시작
→ 새로운 설정 적용
```

컨테이너 환경에서는 새로운 설정으로 이미지를 다시 만드는 것이 아니라, 동일한 애플리케이션 이미지를 새로운 설정으로 재실행할 수 있다.

```text
기존 컨테이너 종료
→ 새 컨테이너 시작
→ Config Server에서 최신 설정 조회
```

Kubernetes에서는 Rolling Update를 통해 순차적으로 재시작할 수 있다.

---

## Actuator Refresh

일부 설정은 애플리케이션을 완전히 재시작하지 않고 갱신할 수 있다.

의존성을 추가한다.

```gradle
dependencies {
    implementation 'org.springframework.cloud:spring-cloud-starter-config'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
}
```

Refresh 엔드포인트를 노출한다.

```yaml
management:
  endpoints:
    web:
      exposure:
        include:
          - health
          - info
          - refresh
```

동적으로 다시 생성해야 하는 Bean에는 `@RefreshScope`를 적용한다.

```java
package com.example.ms1.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.stereotype.Component;

@RefreshScope
@Component
public class DynamicMessageProperties {

    private final String message;

    public DynamicMessageProperties(
            @Value("${custom.message}")
            String message
    ) {
        this.message = message;
    }

    public String getMessage() {
        return message;
    }
}
```

Refresh 요청을 호출한다.

```bash
curl -X POST \
  http://localhost:8081/actuator/refresh
```

`RefreshScope`는 갱신 대상 Bean의 캐시를 비우고, 다음 사용 시 새로운 설정으로 Bean이 다시 생성되도록 지원한다. `/refresh` 엔드포인트를 사용하려면 해당 Actuator 엔드포인트를 명시적으로 노출해야 한다.

---

## @RefreshScope 동작 방식

`@RefreshScope`가 붙은 Bean은 일반 Singleton Bean과 다르게 Proxy 형태로 관리된다.

```text
애플리케이션 시작
→ RefreshScope Proxy 생성
→ 실제 Bean 생성 및 캐시

Refresh 요청
→ 기존 Bean 캐시 제거

다음 Bean 사용
→ 변경된 설정으로 새 Bean 생성
```

구조는 다음과 같다.

```mermaid
flowchart TD
    A[Config Repository 변경] --> B[Actuator Refresh 호출]
    B --> C[최신 설정 다시 조회]
    C --> D[RefreshScope Bean 캐시 제거]
    D --> E[다음 호출 시 Bean 재생성]
    E --> F[새 설정 적용]
```

모든 Bean이 자동으로 재생성되는 것은 아니다.

동적으로 변경해야 하는 Bean을 명시적으로 갱신 대상으로 관리해야 한다.

---

## Refresh가 적합한 설정

다음과 같은 값은 동적 갱신을 검토할 수 있다.

```text
화면 메시지
Feature Flag
일부 외부 API Timeout
일부 Retry 횟수
비즈니스 임계값
기능 활성 여부
```

예시는 다음과 같다.

```yaml
feature:
  new-order-page-enabled: true

external-api:
  timeout: 3000
```

---

## Refresh에 적합하지 않은 설정

다음 설정은 애플리케이션 시작 구조와 밀접하게 연결되어 있어 재시작이 더 안전하다.

```text
server.port
Database Driver
JPA Entity 스캔 경로
Spring Bean 구조
Security Filter Chain 구조
Message Listener 개수
스레드 풀의 핵심 구조
Repository 활성화 여부
```

특히 `server.port`를 실행 중 Refresh한다고 해서 이미 시작된 웹 서버가 새로운 포트로 자동 이동하는 것은 아니다.

이 값은 재시작을 통해 반영해야 한다.

---

## HikariDataSource 갱신 주의사항

모든 객체가 Refresh 가능한 것은 아니다.

Spring Cloud Commons 문서에서는 기본 Hikari DataSource가 갱신 불가능한 대상 목록에 포함될 수 있음을 설명한다.

따라서 다음 설정을 동적으로 바꾸는 것은 신중해야 한다.

```text
Database URL
Database Username
Connection Pool
Driver 설정
```

데이터베이스 연결 정보가 변경되었다면 Rolling Restart를 통해 안전하게 새 연결을 구성하는 것이 일반적이다.

---

## Spring Cloud Bus

서비스 인스턴스가 많아지면 각 인스턴스의 `/actuator/refresh`를 직접 호출하기 어렵다.

```text
order-service 10대
payment-service 5대
notification-service 8대
```

Spring Cloud Bus는 메시지 브로커를 통해 설정 갱신 이벤트를 여러 인스턴스에 전달할 수 있다.

```mermaid
flowchart LR
    A[Refresh 이벤트] --> B[Message Broker]
    B --> C[Order Service 1]
    B --> D[Order Service 2]
    B --> E[Payment Service 1]
    B --> F[Notification Service 1]
```

메시지 브로커로 다음 기술을 사용할 수 있다.

```text
RabbitMQ
Kafka
```

Spring Cloud Bus를 사용하더라도 Config Repository의 Commit을 자동으로 감지하고 항상 갱신하는 전체 과정은 별도로 구성해야 한다.

Git Webhook, CI/CD Pipeline 또는 운영 자동화와 함께 설계할 수 있다.

---

## Config Client 연결 실패 처리

Config Client가 시작될 때 Config Server에 연결하지 못할 수 있다.

대표적인 원인은 다음과 같다.

```text
Config Server 미실행
잘못된 URL
인증 실패
네트워크 장애
Config Repository 장애
잘못된 application 이름
존재하지 않는 Profile
```

---

## Config Server 미실행

다음 오류가 발생할 수 있다.

```text
Connection refused
Could not locate PropertySource
```

확인 항목은 다음과 같다.

```text
Config Server 실행 여부
IP 주소
Port 번호
방화벽
보안 그룹
컨테이너 네트워크
```

로컬 테스트에서는 Config Server를 먼저 실행한 후 Config Client를 실행한다.

---

## 인증 실패

Config Server에 Spring Security가 적용되어 있다면 계정 정보가 필요하다.

```text
401 Unauthorized
```

다음 설정을 확인한다.

```properties
spring.cloud.config.username=config-client
spring.cloud.config.password=change-this-password
```

Config Server의 실제 사용자 정보와 일치해야 한다.

---

## 설정 파일을 찾지 못하는 경우

애플리케이션은 실행되지만 외부 설정이 적용되지 않을 수 있다.

확인 항목은 다음과 같다.

```text
spring.application.name
spring.profiles.active
Config Repository 파일명
Git Branch
Config Server search-paths
Commit과 Push 여부
```

다음 Client 설정이 있다면:

```properties
spring.application.name=ms1
spring.profiles.active=dev
```

Repository에는 다음과 같은 이름의 파일이 필요하다.

```text
ms1.yml
ms1-dev.yml
ms1.properties
ms1-dev.properties
```

---

## 로그에서 Config Server 연결 확인

Config Client 실행 시 Config Server 연결 로그를 확인할 수 있다.

로그에서는 다음 항목을 확인한다.

```text
Config Server 주소
조회한 애플리케이션 이름
활성 Profile
설정 조회 성공 여부
Git Commit Version
```

예시는 다음과 같다.

```text
Fetching config from server at: http://localhost:9000
Located environment: name=ms1, profiles=[dev]
```

이 로그를 통해 Config Client가 어떤 이름과 Profile로 외부 설정을 요청했는지 확인할 수 있다.

---

## 로컬 개발 환경의 대체 설정

개발자가 Config Server 없이도 애플리케이션을 실행해야 하는 경우 로컬 Profile을 별도로 운영할 수 있다.

```text
application-local.yml
```

예시는 다음과 같다.

```yaml
spring:
  config:
    import: optional:configserver:http://localhost:9000

custom:
  message: 로컬 기본 메시지
```

다만 운영 환경에서는 외부 설정을 가져오지 못했는데 기본값으로 조용히 실행되는 상황이 위험할 수 있다.

개발 환경과 운영 환경의 Fail-Fast 정책을 분리하는 것이 좋다.

---

## Profile별 연결 전략

로컬 환경에서는 Config Server를 선택적으로 사용할 수 있다.

### application-local.yml

```yaml
spring:
  config:
    import: optional:configserver:http://localhost:9000
```

운영 환경에서는 Config Server 연결을 필수로 구성할 수 있다.

### application-prod.yml

```yaml
spring:
  config:
    import: configserver:${CONFIG_SERVER_URL}

  cloud:
    config:
      username: ${CONFIG_SERVER_USERNAME}
      password: ${CONFIG_SERVER_PASSWORD}
```

Spring Profile은 환경별 설정을 분리하는 기능을 제공한다.

---

## Config Client 보안

Config Server는 내부 설정 정보를 제공하기 때문에 Client와 Server 사이의 통신을 보호해야 한다.

실무에서는 다음 항목을 고려한다.

```text
HTTPS
Private Network
HTTP Basic 또는 Service 인증
mTLS
Firewall
Security Group
Kubernetes NetworkPolicy
Secret 외부화
접근 감사 로그
```

Config Server를 외부 인터넷에 직접 공개하는 방식은 피하는 것이 좋다.

```text
권장 구조

Config Client
→ 내부 네트워크
→ Config Server
```

---

## 설정값 로그 출력 주의

다음 설정은 로그로 출력하면 안 된다.

```text
Database Password
JWT Secret
API Key
OAuth Client Secret
Cloud Access Key
인증서 Private Key
```

설정 확인용 API를 만들 때도 전체 Environment를 그대로 반환하지 않아야 한다.

다음처럼 필요한 비민감 설정만 제한적으로 확인한다.

```java
@GetMapping("/config/message")
public String message() {
    return properties.getMessage();
}
```

---

## Config Client 테스트용 Controller

외부 설정값이 정상적으로 적용되었는지 확인하기 위한 간단한 Controller를 작성할 수 있다.

```java
package com.example.ms1.controller;

import com.example.ms1.config.CustomApiProperties;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ConfigTestController {

    private final CustomApiProperties properties;

    public ConfigTestController(
            CustomApiProperties properties
    ) {
        this.properties = properties;
    }

    @GetMapping("/config")
    public ConfigResponse config() {
        return new ConfigResponse(
                properties.baseUrl(),
                properties.connectTimeout(),
                properties.readTimeout(),
                properties.retryCount()
        );
    }

    public record ConfigResponse(
            String baseUrl,
            int connectTimeout,
            int readTimeout,
            int retryCount
    ) {
    }
}
```

다음 주소로 확인한다.

```text
GET http://localhost:8081/config
```

응답 예시는 다음과 같다.

```json
{
  "baseUrl": "https://api.example.com",
  "connectTimeout": 1000,
  "readTimeout": 3000,
  "retryCount": 2
}
```

---

## 운영 환경의 설정 변경 절차

설정값 변경은 코드 변경만큼 큰 장애를 발생시킬 수 있다.

권장 절차는 다음과 같다.

```text
1. Config Repository Branch 생성
2. 설정 수정
3. YAML 또는 Properties 문법 검증
4. Pull Request 생성
5. 리뷰와 승인
6. Main Branch Merge
7. Config Server 조회 결과 확인
8. Client Rolling Restart 또는 Refresh
9. 주요 지표 모니터링
10. 문제 발생 시 Git Revert
```

특히 다음 설정은 변경 전에 영향도를 검토해야 한다.

```text
Database URL
Timeout
Retry 횟수
Connection Pool
Thread Pool
Kafka Broker
Redis 주소
Feature Flag
```

---

## Config Client와 컨테이너 운영

Config Client를 Docker로 실행하면 설정 변경 후 컨테이너를 재생성할 수 있다.

```bash
docker compose up -d --force-recreate ms1
```

이 명령은 `ms1` 컨테이너를 다시 생성한다.

새로 시작된 애플리케이션은 Config Server에서 최신 설정을 가져온다.

Kubernetes에서는 다음과 같이 Rolling Restart를 수행할 수 있다.

```bash
kubectl rollout restart deployment/ms1
```

실행 결과 예시는 다음과 같다.

```text
deployment.apps/ms1 restarted
```

Rolling Update를 사용하면 여러 인스턴스를 순차적으로 교체하여 전체 중단을 줄일 수 있다.

---

## 전체 동작 흐름

```mermaid
sequenceDiagram
    participant G as Git Config Repository
    participant S as Config Server
    participant C as Config Client
    participant A as Application

    C->>S: ms1/dev 설정 요청
    S->>G: 설정 파일 조회
    G-->>S: 설정 반환
    S-->>C: 병합된 설정 반환
    C->>A: 설정값 등록
    A->>A: 설정 기반으로 실행

    G->>G: 설정 변경 및 Commit
    Note over C,A: 재시작 또는 Refresh 전까지 기존 값 유지
    C->>S: 재시작 또는 Refresh 시 최신 설정 요청
    S->>G: 최신 설정 조회
    G-->>S: 변경된 설정
    S-->>C: 최신 설정 반환
```

---

## 구축 순서 정리

Spring Cloud Config Client 구성 순서는 다음과 같다.

```text
1. 기존 Spring Boot 애플리케이션 준비
2. spring-cloud-starter-config 의존성 추가
3. Spring Cloud BOM 설정
4. spring.application.name 지정
5. spring.profiles.active 지정
6. spring.config.import에 Config Server 주소 작성
7. Config Server 인증 정보 설정
8. Config Server 먼저 실행
9. Config Client 실행
10. 외부 설정 적용 확인
11. 필요 시 Actuator Refresh 구성
```

---

## 실무에서 중요한 구분

Config Client를 이해할 때 다음 세 가지를 분리해야 한다.

### 설정 중앙 관리

```text
여러 서비스의 설정을 Git Repository에서 관리
```

### 애플리케이션 시작 시 외부 설정 로드

```text
Config Client 시작
→ Config Server에서 설정 조회
→ 외부 설정으로 애플리케이션 실행
```

### 실행 중 동적 설정 갱신

```text
Repository 변경
→ 별도의 Refresh 또는 재시작 필요
```

Config Repository에서 값을 수정했다고 해서 모든 Config Client가 자동으로 즉시 변경되는 것은 아니다.

---

## 정리

Spring Cloud Config Client는 별도의 특수한 서버가 아니라, Config Server에서 외부 설정을 가져오도록 구성한 일반 Spring Boot 애플리케이션이다.

기본 구성은 다음과 같다.

```text
spring-cloud-starter-config 의존성
spring.application.name
spring.profiles.active
spring.config.import
Config Server 인증 정보
```

가장 핵심적인 설정은 다음과 같다.

```properties
spring.application.name=ms1
spring.profiles.active=dev
spring.config.import=configserver:http://localhost:9000
```

이 설정을 기반으로 Config Client는 논리적으로 다음 경로의 설정을 요청한다.

```text
/ms1/dev
```

Config Repository에 `ms1-dev.properties`가 있고 해당 파일에 다음 값이 있다면:

```properties
server.port=8081
```

Config Client는 외부 설정을 적용해 `8081` 포트에서 실행될 수 있다.

Config Repository의 값이 변경되면 Config Server는 새로운 설정을 반환할 수 있지만, 실행 중인 Client에 자동으로 즉시 반영되는 것은 아니다.

변경 내용을 적용하려면 다음 중 하나가 필요하다.

```text
애플리케이션 재시작
Rolling Deployment
Actuator Refresh
Spring Cloud Bus
```

서버 Port, DataSource, 보안 구조와 같은 시작 단계 설정은 재시작 방식이 더 안전하고, 메시지나 Feature Flag 같은 일부 값은 `@RefreshScope`를 통한 동적 갱신을 검토할 수 있다.

### 한 줄 요약

Spring Cloud Config Client는 `spring.application.name`, Profile, `spring.config.import`를 이용해 Config Server에서 서비스별 외부 설정을 가져오며, 실행 중 변경 반영에는 별도의 Refresh 또는 재시작 과정이 필요하다.


