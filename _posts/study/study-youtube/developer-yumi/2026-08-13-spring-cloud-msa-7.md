---
layout: post
bigtitle: '스프링 클라우드 MSA'
subtitle: 스프링 클라우드 MSA 7 - Eureka 클라이언트 설정 방법
date: '2026-08-13 00:00:04 +0900'
categories:
    - developer-yumi
comments: true

---

# 스프링 클라우드 MSA 7 - Eureka 클라이언트 설정 방법
[https://youtu.be/h1c3Rqt26kQ?si=fL713fu7tkk-n_rH](https://youtu.be/h1c3Rqt26kQ?si=fL713fu7tkk-n_rH)

# 스프링 클라우드 MSA 7 - Eureka 클라이언트 설정 방법
* toc
{:toc}

---

## Spring Cloud Eureka Client 설정과 Service Registration 이해하기

MSA 환경에서 Eureka Server를 구축했다면 다음 단계는 실제 비즈니스 로직을 수행하는 각각의 Spring Boot 애플리케이션을 **Eureka Client로 등록하는 것**이다.

예를 들어 다음과 같은 서비스가 있다고 가정해보자.

```text
User Service
Order Service
Payment Service
Config Server
```

각 애플리케이션을 Eureka Client로 구성하면 실행 시 Eureka Server에 자신의 정보를 등록할 수 있다.

```mermaid
flowchart TD
    U[User Service] --> E[Eureka Server]
    O[Order Service] --> E
    P[Payment Service] --> E
    C[Config Server] --> E
```

Eureka Server는 등록된 서비스들의 정보를 관리하고, Gateway나 다른 서비스가 필요한 서비스를 찾을 수 있도록 Registry 정보를 제공한다.

따라서 Eureka Client 설정의 핵심은 단순히 Eureka Dashboard에 서비스를 표시하는 것이 아니다.

**동적으로 생성되고 사라지는 서비스 인스턴스를 Service Registry에 등록하여 서비스 이름을 기반으로 서로를 발견할 수 있도록 만드는 것**이 핵심이다.

---

## Eureka Client란?

Eureka Client는 Eureka Server에 자신의 서비스 정보를 등록하고 필요하다면 다른 서비스들의 Registry 정보를 조회하는 애플리케이션이다.

일반적으로 MSA를 구성하는 각각의 Spring Boot 애플리케이션이 Eureka Client가 될 수 있다.

```text
Eureka Server
    ↑
    │ Registration
    │
├── USER-SERVICE
├── ORDER-SERVICE
├── PAYMENT-SERVICE
└── CONFIG-SERVER
```

서비스가 실행되면 Eureka Server에 자신의 정보를 등록한다.

대표적으로 다음과 같은 정보가 관리된다.

```text
Application Name
Instance ID
Hostname
IP Address
Port
Status
Metadata
```

예를 들어 Order Service가 다음과 같이 실행되었다고 생각해보자.

```text
spring.application.name=order-service
server.port=8081
```

Eureka에는 논리적으로 다음과 같은 정보가 등록된다.

```text
ORDER-SERVICE

Host     localhost
Port     8081
Status   UP
```

동일한 서비스를 여러 개 실행한다면 하나의 서비스 이름 아래 여러 Instance가 등록될 수 있다.

```text
ORDER-SERVICE

├── order-service:8081
├── order-service:8082
└── order-service:8083
```

이 구조가 MSA의 Scale-Out 환경에서 중요하다.

---

## 왜 Eureka Client가 필요한가?

MSA에서는 하나의 서비스를 여러 인스턴스로 실행할 수 있다.

예를 들어 트래픽이 증가하여 Payment Service가 Scale-Out되었다고 생각해보자.

기존에는 하나였다.

```text
PAYMENT-SERVICE

10.0.1.10:8080
```

트래픽 증가 후 다음과 같이 세 개가 되었다.

```text
PAYMENT-SERVICE

10.0.1.10:8080
10.0.1.11:8080
10.0.1.12:8080
```

Gateway나 다른 서비스가 IP 주소를 직접 관리한다면 새롭게 생성된 Instance를 즉시 알기 어렵다.

```text
Gateway

/payment/**
    ↓
http://10.0.1.10:8080
```

이러한 방식은 동적으로 서버가 생성되고 제거되는 MSA 환경과 잘 맞지 않는다.

Eureka Client를 사용하면 각각의 Instance가 실행되면서 자신의 정보를 Eureka Server에 등록한다.

```mermaid
flowchart LR
    P1[Payment 8081] --> E[Eureka Server]
    P2[Payment 8082] --> E
    P3[Payment 8083] --> E

    E --> G[Gateway]
```

Gateway는 특정 IP를 직접 관리하는 대신 Eureka Registry에서 `PAYMENT-SERVICE`에 해당하는 Instance 목록을 활용할 수 있다.

---

## Eureka Client의 핵심 역할

Eureka Client의 역할은 크게 두 가지로 이해할 수 있다.

### 자신의 정보를 Eureka Server에 등록

첫 번째 역할은 **Service Registration**이다.

```text
ORDER-SERVICE
        ↓
Eureka Server
        ↓
Registry 등록
```

애플리케이션이 실행되면 자신의 정보를 Eureka Server에 전달한다.

---

### 다른 서비스의 정보를 가져오기

두 번째는 **Service Discovery**를 위해 Registry 정보를 가져오는 것이다.

```text
Order Service
     ↓
Eureka Server
     ↓
PAYMENT-SERVICE Instance 목록
```

이를 통해 다른 서비스의 IP와 Port를 코드에 직접 하드코딩하지 않는 구조를 만들 수 있다.

---

## Eureka Client 구성 과정

기존 Spring Boot 애플리케이션을 Eureka Client로 만드는 전체 과정은 크게 다음과 같다.

```text
1. Eureka Client 의존성 추가

2. Spring Cloud BOM 설정

3. Eureka Client 활성화

4. spring.application.name 설정

5. Eureka Server 주소 설정

6. Eureka Server 실행

7. Eureka Client 실행

8. Eureka Dashboard에서 등록 확인
```

각 과정을 자세히 살펴보자.

---

## Eureka Client 의존성 추가

기존 Spring Boot 애플리케이션에 Eureka Client 의존성을 추가한다.

Gradle을 사용한다면 다음 의존성이 핵심이다.

```gradle
dependencies {
    implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-client'
}
```

Spring Initializr에서는 일반적으로 **Eureka Discovery Client**를 선택하여 동일한 의존성을 추가할 수 있다.

기존 프로젝트에 직접 추가한다면 `build.gradle`에 의존성을 추가하고 Gradle 프로젝트를 다시 로드한다.

---

## Spring Cloud BOM 설정

Eureka는 Spring Cloud 프로젝트에 포함되므로 Spring Boot 버전과 Spring Cloud 버전의 호환성을 관리해야 한다.

일반적으로 Spring Cloud BOM을 사용한다.

```gradle
ext {
    set('springCloudVersion', "사용 중인 Spring Boot와 호환되는 버전")
}

dependencyManagement {
    imports {
        mavenBom "org.springframework.cloud:spring-cloud-dependencies:${springCloudVersion}"
    }
}
```

전체적인 구조는 다음과 같다.

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

    implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-client'

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

여기서 중요한 것은 Spring Cloud 버전을 임의로 선택하지 않고 **Spring Boot와 호환되는 Release Train을 사용해야 한다는 것**이다.

---

## Eureka Client 활성화

과거의 Eureka 예제에서는 메인 Application 클래스에 `@EnableEurekaClient` 또는 `@EnableDiscoveryClient`를 추가하는 방식을 많이 사용했다.

예를 들면 다음과 같다.

```java
@SpringBootApplication
@EnableDiscoveryClient
public class OrderApplication {

    public static void main(String[] args) {
        SpringApplication.run(
                OrderApplication.class,
                args
        );
    }
}
```

자료에서도 Eureka Client를 활성화하기 위한 어노테이션을 메인 클래스에 등록하는 방식으로 설명한다.

하지만 이 부분은 Spring Cloud 버전에 따라 차이가 있기 때문에 구분해서 이해할 필요가 있다.

현재 Spring Cloud 기반에서는 Eureka Client Starter가 Classpath에 존재하면 자동 설정을 통해 Discovery Client로 동작할 수 있으므로 일반적인 구성에서는 별도의 활성화 어노테이션이 반드시 필요한 것은 아니다.

즉 핵심은 다음 의존성이다.

```gradle
implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-client'
```

따라서 최신 Spring Cloud 환경에서는 다음처럼 구성할 수도 있다.

```java
@SpringBootApplication
public class OrderApplication {

    public static void main(String[] args) {
        SpringApplication.run(
                OrderApplication.class,
                args
        );
    }
}
```

과거 자료를 볼 때 다음과 같이 이해하면 좋다.

| 방식                       | 의미                                      |
| ------------------------ | --------------------------------------- |
| `@EnableEurekaClient`    | Eureka 전용 Client 활성화 방식으로 과거 예제에서 많이 사용 |
| `@EnableDiscoveryClient` | Service Discovery 추상화를 사용하는 방식          |
| 별도 어노테이션 없음              | 최신 자동 설정을 활용하는 일반적인 방식                  |

따라서 특정 어노테이션 자체보다 **Eureka Client Starter가 존재하고 필요한 설정이 올바르게 구성되어 있는지**가 더 중요하다.

---

## spring.application.name 설정

Eureka에서 매우 중요한 설정 중 하나가 `spring.application.name`이다.

```yaml
spring:
  application:
    name: order-service
```

Properties로 작성하면 다음과 같다.

```properties
spring.application.name=order-service
```

이 값은 Eureka Server에서 해당 서비스를 식별하는 **Service ID**의 기준이 된다.

예를 들어 다음과 같이 설정했다고 가정해보자.

```yaml
spring:
  application:
    name: ms1
```

Eureka Dashboard에서는 해당 애플리케이션이 `MS1`이라는 서비스로 나타날 수 있다.

여러 개의 애플리케이션을 다음과 같이 구성할 수도 있다.

```text
USER-SERVICE
ORDER-SERVICE
PAYMENT-SERVICE
NOTIFICATION-SERVICE
```

다른 서비스나 Gateway 역시 이러한 논리적인 서비스 이름을 기준으로 서비스를 찾을 수 있다.

---

## Eureka Client 기본 설정

Eureka Client에서 대표적으로 사용하는 설정은 다음과 같다.

```yaml
eureka:
  client:
    register-with-eureka: true
    fetch-registry: true

    service-url:
      defaultZone: http://localhost:8761/eureka/
```

Properties를 사용한다면 다음과 같이 작성할 수 있다.

```properties
eureka.client.register-with-eureka=true
eureka.client.fetch-registry=true
eureka.client.service-url.defaultZone=http://localhost:8761/eureka/
```

각각의 설정이 어떤 의미인지 살펴보자.

---

## register-with-eureka

```yaml
eureka:
  client:
    register-with-eureka: true
```

현재 애플리케이션을 Eureka Server에 등록할 것인지 결정한다.

```text
true

현재 Application
      ↓
Eureka Server
      ↓
Service Registry 등록
```

일반적인 Eureka Client라면 자신을 Registry에 등록해야 하므로 `true`를 사용한다.

자료에서도 Client를 Eureka Server에 등록하기 위해 해당 값을 `true`로 설정한다.

---

## fetch-registry

```yaml
eureka:
  client:
    fetch-registry: true
```

Eureka Server가 가지고 있는 Service Registry 정보를 가져올 것인지 결정한다.

예를 들어 Eureka Server에 다음 서비스가 있다고 가정해보자.

```text
USER-SERVICE
ORDER-SERVICE
PAYMENT-SERVICE
```

`fetch-registry`를 활성화한 Client는 이러한 Registry 정보를 가져와 Service Discovery에 활용할 수 있다.

개념적으로 다음과 같다.

```text
Eureka Server
      ↓
Service Registry
      ↓
Eureka Client
```

따라서 일반적인 서비스 간 Discovery가 필요한 Client라면 `true`로 설정할 수 있다.

---

## register-with-eureka와 fetch-registry 차이

두 설정은 비슷해 보이지만 방향이 완전히 다르다.

| 설정                     | 방향              | 역할           |
| ---------------------- | --------------- | ------------ |
| `register-with-eureka` | Client → Server | 자기 자신 등록     |
| `fetch-registry`       | Server → Client | 다른 서비스 정보 조회 |

쉽게 기억하면 다음과 같다.

```text
register
= 나를 알려준다.

fetch
= 다른 서비스를 가져온다.
```

이 차이는 Eureka를 이해할 때 매우 중요하다.

---

## Eureka Server 주소 설정

Client가 어느 Eureka Server에 접속해야 하는지를 설정해야 한다.

```yaml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

여기서 중요한 부분은 다음 주소다.

```text
http://localhost:8761/eureka/
```

구조를 분해하면 다음과 같다.

```text
http://
    ↓
Protocol

localhost
    ↓
Eureka Server Host

8761
    ↓
Eureka Server Port

/eureka/
    ↓
Eureka Endpoint
```

Client는 이 주소를 이용하여 Eureka Server와 통신한다.

---

## defaultZone의 의미

설정에서 조금 특이한 부분이 있다.

```yaml
service-url:
  defaultZone:
```

`defaultZone`은 Eureka Client가 사용할 기본 Eureka Server 위치를 지정한다.

따라서 Client와 Eureka Server를 연결할 때 가장 중요한 설정 중 하나다.

```text
Eureka Client
       ↓
defaultZone
       ↓
Eureka Server
```

Server 주소가 잘못되어 있다면 Client가 정상적으로 실행되더라도 Eureka Server에 등록되지 않을 수 있다.

---

## Spring Security가 적용된 Eureka Server 연결

앞서 Eureka Server에 Spring Security를 적용했다면 Client도 인증 정보를 가지고 접근해야 한다.

예를 들어 Eureka Server의 계정이 다음과 같다고 가정해보자.

```text
Username
eureka

Password
1234
```

HTTP Basic 인증을 사용하는 경우 Client 설정에 인증 정보를 포함할 수 있다.

```yaml
eureka:
  client:
    service-url:
      defaultZone: http://eureka:1234@localhost:8761/eureka/
```

구조는 다음과 같다.

```text
http://username:password@host:port/eureka/
```

즉 다음과 같다.

```text
username
    ↓
eureka

password
    ↓
1234

host
    ↓
localhost

port
    ↓
8761
```

이렇게 하면 Eureka Client가 Eureka Server와 통신할 때 HTTP Basic 인증 정보를 함께 전달할 수 있다.

---

## Credential을 코드에 직접 작성하지 않기

실습에서는 다음처럼 작성할 수 있다.

```yaml
defaultZone: http://eureka:1234@localhost:8761/eureka/
```

하지만 실제 운영 환경에서는 ID와 Password를 Git Repository에 그대로 저장하면 안 된다.

다음과 같이 환경 변수로 분리하는 것이 좋다.

```yaml
eureka:
  client:
    service-url:
      defaultZone: http://${EUREKA_USERNAME}:${EUREKA_PASSWORD}@eureka-server:8761/eureka/
```

그리고 실행 환경에서 값을 주입한다.

```text
EUREKA_USERNAME=eureka
EUREKA_PASSWORD=strong-password
```

Docker Compose, Kubernetes, CI/CD 환경에서는 Secret 관리 방식과 함께 사용할 수 있다.

---

## Eureka Client 전체 application.yml

전체 설정을 조합하면 다음과 같은 구조가 된다.

```yaml
server:
  port: 8081

spring:
  application:
    name: order-service

eureka:
  client:
    register-with-eureka: true
    fetch-registry: true

    service-url:
      defaultZone: http://localhost:8761/eureka/
```

Spring Security가 적용되어 있다면 다음처럼 구성할 수 있다.

```yaml
server:
  port: 8081

spring:
  application:
    name: order-service

eureka:
  client:
    register-with-eureka: true
    fetch-registry: true

    service-url:
      defaultZone: http://${EUREKA_USERNAME}:${EUREKA_PASSWORD}@localhost:8761/eureka/
```

---

## Eureka Server와 Client 실행 순서

테스트할 때는 Eureka Server를 먼저 실행하는 것이 이해하기 쉽다.

```text
1. Eureka Server 실행

localhost:8761

        ↓

2. Eureka Client 실행

localhost:8081

        ↓

3. Client Registration

        ↓

4. Eureka Dashboard 확인
```

Eureka Server가 실행되면 Dashboard에 처음에는 등록된 Instance가 없을 수 있다.

```text
No instances available
```

이후 Eureka Client를 실행하면 서비스가 등록된다.

```text
Instances currently registered with Eureka

Application
ORDER-SERVICE

Status
UP
```

---

## Eureka Client 등록 과정

조금 더 내부적인 흐름으로 보면 다음과 같다.

```mermaid
sequenceDiagram
    participant C as Order Service
    participant E as Eureka Server

    C->>C: Spring Boot 시작
    C->>C: Eureka Client 초기화
    C->>E: Instance 등록
    E->>E: Registry 저장
    E-->>C: 등록 처리
    C->>E: 주기적인 상태 갱신
```

Client가 실행되면 Eureka Server에 자신의 Instance 정보를 등록한다.

이후 Client는 Server와 계속 통신하면서 자신이 동작 중이라는 정보를 갱신한다.

---

## 하나의 서비스를 여러 개 실행하면 어떻게 될까?

Eureka의 중요한 장점은 동일한 서비스를 여러 Instance로 실행할 수 있다는 것이다.

예를 들어 다음 애플리케이션이 있다고 하자.

```yaml
spring:
  application:
    name: order-service
```

이를 서로 다른 Port에서 세 개 실행한다.

```text
8081
8082
8083
```

Eureka에서는 논리적으로 다음처럼 관리할 수 있다.

```text
ORDER-SERVICE

├── order-service:8081
├── order-service:8082
└── order-service:8083
```

서비스 이름은 동일하지만 실제 Instance는 여러 개다.

```mermaid
flowchart TD
    E[Eureka Server]

    O1[Order Service : 8081] --> E
    O2[Order Service : 8082] --> E
    O3[Order Service : 8083] --> E
```

이 구조가 이후 Gateway와 Load Balancer를 연결했을 때 중요해진다.

---

## Service와 Instance의 차이

Eureka를 이해할 때 **Service와 Instance를 구분하는 것**이 중요하다.

예를 들어 다음 서비스가 있다고 하자.

```text
ORDER-SERVICE
```

이것은 논리적인 서비스다.

실제로 실행되는 프로세스는 다음처럼 여러 개일 수 있다.

```text
ORDER-SERVICE

Instance 1
10.0.1.10:8080

Instance 2
10.0.1.11:8080

Instance 3
10.0.1.12:8080
```

따라서 관계는 다음과 같다.

```text
Service
    ↓
1 : N
    ↓
Instances
```

이 개념을 이해하면 MSA의 Scale-Out 구조도 자연스럽게 이해할 수 있다.

---

## Client가 종료되면 어떻게 될까?

Eureka Client가 종료되면 해당 Instance는 더 이상 정상적인 서비스 대상으로 유지되어서는 안 된다.

정상적인 종료 과정에서는 Client가 자신의 종료 상태를 Eureka Server에 알릴 수 있다.

하지만 프로세스 강제 종료, 네트워크 단절, 서버 장애처럼 정상적인 종료 절차를 수행할 수 없는 상황도 존재한다.

```text
Client 장애

    X

종료 정보를 Eureka Server에
정상적으로 전달하지 못함
```

따라서 Eureka는 단순히 종료 요청만을 기준으로 Instance를 관리하는 것이 아니라 Client의 주기적인 상태 갱신과 Lease 정보를 기반으로 Registry를 관리한다.

이 때문에 로컬 개발 환경에서 애플리케이션을 강제로 종료했을 때 Dashboard에서 Instance가 즉시 사라지지 않는 것처럼 보일 수도 있다.

---

## Eureka Client와 Heartbeat

Eureka Client는 등록 이후 Eureka Server와 주기적으로 통신한다.

개념적으로 다음과 같다.

```text
Client
  │
  ├── Registration
  │
  ├── Heartbeat
  │
  ├── Heartbeat
  │
  └── Heartbeat
  ↓
Eureka Server
```

이 과정을 통해 Eureka Server는 Client가 계속 동작하고 있는지 판단할 수 있다.

따라서 Eureka의 서비스 상태 관리는 다음 두 과정으로 이해하면 좋다.

```text
Registration
+
Heartbeat / Lease
```

---

## 왜 종료된 서비스가 Dashboard에 잠시 남아 있을까?

개발 중 자주 볼 수 있는 현상이다.

IntelliJ에서 애플리케이션을 강제로 종료했는데 Eureka Dashboard에 서비스가 잠시 남아 있을 수 있다.

이것은 Eureka가 분산 시스템 환경에서 네트워크 단절과 일시적인 장애를 고려하기 때문이다.

```text
Client 응답 없음

        ↓

즉시 삭제?
        ↓
X

일정 기간 상태 확인
        ↓
Instance 제거 판단
```

네트워크가 잠깐 끊겼다는 이유만으로 서비스를 즉시 제거한다면 오히려 Registry가 지나치게 불안정해질 수 있다.

따라서 등록과 제거가 완전히 실시간으로 이루어진다고 생각하기보다는 **Lease와 상태 갱신을 기반으로 관리된다**고 이해하는 것이 좋다.

---

## Eureka Client와 Gateway의 관계

Eureka Client를 등록하는 가장 중요한 이유 중 하나가 Gateway의 동적 Routing이다.

예를 들어 다음 세 개의 Order Service Instance가 있다고 하자.

```text
ORDER-SERVICE

10.0.1.10:8080
10.0.1.11:8080
10.0.1.12:8080
```

모든 Instance가 Eureka에 등록된다.

```mermaid
flowchart TD
    O1[Order 1] --> E[Eureka Server]
    O2[Order 2] --> E
    O3[Order 3] --> E

    E --> G[Spring Cloud Gateway]
```

Gateway는 Eureka Registry를 기반으로 `ORDER-SERVICE`를 찾을 수 있다.

이후 Load Balancer를 이용하여 실제 Instance를 선택한다.

```text
Client Request

      ↓

Spring Cloud Gateway

      ↓

ORDER-SERVICE

      ↓

Service Discovery

      ↓

10.0.1.11:8080
```

따라서 Gateway에 다음과 같이 IP를 일일이 하드코딩할 필요를 줄일 수 있다.

```text
10.0.1.10
10.0.1.11
10.0.1.12
```

대신 논리적인 서비스 이름을 중심으로 시스템을 구성할 수 있다.

---

## Eureka Client와 Load Balancing

Eureka 자체가 직접 요청을 분산시키는 것은 아니다.

역할을 구분해야 한다.

```text
Eureka
→ 사용할 수 있는 Instance를 찾는다.

Load Balancer
→ Instance 중 하나를 선택한다.

Gateway
→ 실제 요청을 전달한다.
```

예를 들어 Eureka가 다음 Instance 목록을 제공했다고 하자.

```text
ORDER-SERVICE

Instance A
Instance B
Instance C
```

Spring Cloud LoadBalancer가 이 중 하나를 선택할 수 있다.

```text
Request 1 → Instance A
Request 2 → Instance B
Request 3 → Instance C
```

따라서 Eureka와 Load Balancer는 서로 다른 역할을 담당하지만 MSA에서는 함께 사용되는 경우가 많다.

---

## Config Server도 Eureka Client가 될 수 있을까?

가능하다.

Eureka Client는 반드시 비즈니스 API 서버일 필요는 없다.

예를 들어 다음과 같은 구성 요소들도 필요에 따라 Eureka Client로 등록할 수 있다.

```text
User Service
Order Service
Payment Service
Config Server
Gateway
```

Config Server 역시 Spring Boot 애플리케이션이므로 Eureka Client 의존성과 설정을 추가하면 Registry에 등록할 수 있다.

전체 구조는 다음처럼 구성할 수 있다.

```mermaid
flowchart TD
    CR[Config Repository] --> CS[Config Server]

    CS --> E[Eureka Server]

    U[User Service] --> E
    O[Order Service] --> E
    P[Payment Service] --> E

    G[Gateway] --> E

    CS --> U
    CS --> O
    CS --> P
```

다만 모든 인프라 서비스를 무조건 Eureka에 등록해야 하는 것은 아니다.

어떤 구성 요소를 Discovery 대상으로 만들지는 실제 호출 구조와 운영 방식에 따라 결정해야 한다.

---

## Config Client와 Eureka Client 비교

앞서 살펴본 Config Client와 Eureka Client는 역할이 다르다.

| 구분     | Config Client     | Eureka Client          |
| ------ | ----------------- | ---------------------- |
| 목적     | 외부 설정 조회          | 서비스 등록 및 탐색            |
| 연결 대상  | Config Server     | Eureka Server          |
| 핵심 데이터 | 환경 설정             | Instance 정보            |
| 대표 정보  | DB URL, Timeout 등 | IP, Port, Service Name |
| 주요 역할  | Configuration     | Service Discovery      |

하나의 Spring Boot 애플리케이션이 두 Client 역할을 동시에 수행할 수도 있다.

```mermaid
flowchart LR
    C[Config Server] --> A[Order Service]
    A --> E[Eureka Server]
```

Order Service 입장에서 보면 다음과 같다.

```text
Config Server
      ↓
설정 가져오기
      ↓
Order Service
      ↓
자신의 위치 등록
      ↓
Eureka Server
```

---

## Eureka Server와 Client 설정 비교

Server와 Client의 설정을 비교하면 더욱 이해하기 쉽다.

### Eureka Server

```yaml
eureka:
  client:
    register-with-eureka: false
    fetch-registry: false
```

단일 Server는 자기 자신을 등록하거나 다른 Registry를 가져올 필요가 없기 때문에 이렇게 설정할 수 있다.

### Eureka Client

```yaml
eureka:
  client:
    register-with-eureka: true
    fetch-registry: true

    service-url:
      defaultZone: http://localhost:8761/eureka/
```

Client는 자신의 정보를 등록하고 다른 서비스 정보를 가져올 수 있도록 구성한다.

따라서 차이를 단순하게 기억하면 다음과 같다.

```text
Eureka Server

등록 받는 쪽
Registry 관리


Eureka Client

자신을 등록하는 쪽
Registry를 사용하는 쪽
```

---

## 여러 Eureka Server 연결

고가용성을 위해 Eureka Server를 여러 개 운영한다면 Client가 여러 Server 주소를 알고 있도록 구성할 수 있다.

개념적으로는 다음과 같다.

```text
Eureka Client

     ↓

├── Eureka Server 1
├── Eureka Server 2
└── Eureka Server 3
```

이러한 구조를 통해 하나의 Eureka Server에 문제가 발생했을 때 Discovery 인프라 전체가 하나의 서버에만 의존하지 않도록 구성할 수 있다.

실제 운영에서는 Eureka Server 자체도 중요한 인프라이기 때문에 단일 장애 지점이 되지 않도록 고려해야 한다.

---

## Docker 환경에서 주의할 점

로컬에서는 다음 설정이 정상적으로 동작한다.

```yaml
defaultZone: http://localhost:8761/eureka/
```

하지만 Eureka Client와 Eureka Server를 각각 다른 Docker Container에서 실행하면 의미가 달라진다.

Container 내부에서 `localhost`는 호스트 컴퓨터가 아니라 **현재 Container 자신**을 의미하기 때문이다.

다음 구조라고 생각해보자.

```text
Docker Network

eureka-server
order-service
payment-service
```

Order Service에서 다음 주소를 사용하면 문제가 발생할 수 있다.

```text
http://localhost:8761/eureka/
```

Order Container 입장에서 localhost는 Order Container 자신이기 때문이다.

Docker Compose 환경에서는 서비스 이름을 이용할 수 있다.

```yaml
eureka:
  client:
    service-url:
      defaultZone: http://eureka-server:8761/eureka/
```

구조는 다음과 같다.

```mermaid
flowchart LR
    O[order-service] --> E[eureka-server:8761]
    P[payment-service] --> E
```

MSA를 Docker 환경에서 구성할 때 매우 자주 발생하는 문제이므로 반드시 기억할 필요가 있다.

---

## 운영 환경에서 IP 설정 고려

Eureka Client는 자신의 Host나 IP 정보를 Registry에 등록한다.

환경에 따라 Hostname 대신 IP 기반 등록이 필요할 수도 있다.

예를 들어 다음과 같은 설정을 사용할 수 있다.

```yaml
eureka:
  instance:
    prefer-ip-address: true
```

이 경우 서비스 Discovery 환경에서 Hostname보다 IP 주소를 우선적으로 사용할 수 있다.

하지만 무조건 `true`가 좋은 것은 아니다.

```text
VM 환경
Docker 환경
Kubernetes 환경
사내 DNS 환경
Cloud 환경
```

각 환경의 네트워크 구조에 따라 어떤 주소가 다른 서비스에서 실제로 접근 가능한지를 기준으로 결정해야 한다.

---

## Eureka Client 등록이 안 될 때 확인할 사항

Eureka Client를 설정했는데 Dashboard에 나타나지 않는다면 다음 순서로 확인하는 것이 좋다.

```text
1. Eureka Server가 실행 중인가?

2. Eureka Client 의존성이 존재하는가?

3. Spring Boot와 Spring Cloud 버전이 호환되는가?

4. defaultZone 주소가 정확한가?

5. /eureka/ 경로가 올바른가?

6. Spring Security 인증 정보가 정확한가?

7. Docker 환경에서 localhost를 사용하고 있지 않은가?

8. 네트워크 또는 Firewall 문제가 없는가?

9. spring.application.name이 설정되어 있는가?

10. Client 로그에 등록 실패가 발생하고 있지 않은가?
```

특히 다음 오류는 Eureka Server 연결 실패와 관련된 경우가 많다.

```text
Connection refused
```

이 경우 먼저 Server 주소와 Port를 확인한다.

```text
Cannot execute request on any known server
```

이 경우 Eureka Client가 등록 가능한 Eureka Server를 찾지 못하고 있을 가능성을 확인한다.

```text
401 Unauthorized
```

Spring Security를 적용했다면 인증 정보를 확인한다.

---

## Eureka Client 전체 구조

지금까지의 내용을 하나의 구조로 정리하면 다음과 같다.

```mermaid
flowchart TD
    C[Client]

    C --> G[Spring Cloud Gateway]

    G --> E[Eureka Server]

    U1[User Service 1] --> E
    U2[User Service 2] --> E

    O1[Order Service 1] --> E
    O2[Order Service 2] --> E

    P1[Payment Service] --> E

    G --> U1
    G --> U2
    G --> O1
    G --> O2
    G --> P1
```

각 Spring Boot 서비스가 Eureka Client가 된다.

```text
서비스 시작

      ↓

Eureka Client 활성화

      ↓

Eureka Server에 등록

      ↓

Registry 관리

      ↓

Gateway / 다른 서비스가 조회

      ↓

Load Balancer가 Instance 선택

      ↓

실제 요청 전달
```

---

## 실무에서의 활용

Eureka Client를 사용하는 핵심 목적은 **IP와 Port 중심의 시스템을 서비스 이름 중심의 시스템으로 변경하는 것**이라고 볼 수 있다.

Eureka가 없다면 다음처럼 구성할 가능성이 있다.

```text
Order Service

PAYMENT_URL=http://10.0.1.20:8080
```

Payment Service 주소가 변경되면 설정 역시 변경해야 한다.

```text
10.0.1.20
      ↓
10.0.2.35
```

Service Discovery를 적용하면 호출자가 논리적인 서비스 이름을 기준으로 대상을 찾을 수 있는 구조를 만들 수 있다.

```text
PAYMENT-SERVICE
```

실제 Instance는 여러 개일 수 있다.

```text
PAYMENT-SERVICE

├── 10.0.1.20:8080
├── 10.0.1.21:8080
└── 10.0.1.22:8080
```

그리고 이 목록을 Eureka Registry가 관리한다.

결과적으로 다음과 같은 구조가 가능해진다.

```text
Service Name
      ↓
Service Discovery
      ↓
Instance 목록
      ↓
Load Balancing
      ↓
실제 Instance 호출
```

이것이 Eureka Client를 단순히 "Dashboard에 서버를 띄우는 설정"으로 이해해서는 안 되는 이유다.

---

## 정리

Eureka Client는 MSA를 구성하는 각각의 Spring Boot 애플리케이션을 Eureka Server의 Service Registry에 등록하기 위한 구성 요소다.

기본적인 설정은 다음과 같다.

```gradle
implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-client'
```

그리고 애플리케이션 이름을 지정한다.

```yaml
spring:
  application:
    name: order-service
```

Eureka Server 주소를 설정한다.

```yaml
eureka:
  client:
    register-with-eureka: true
    fetch-registry: true

    service-url:
      defaultZone: http://localhost:8761/eureka/
```

여기서 각각의 역할은 다음과 같다.

```text
spring.application.name
→ Eureka에서 사용할 Service Name

register-with-eureka
→ 자기 자신을 Eureka에 등록

fetch-registry
→ Eureka Registry 정보 조회

service-url.defaultZone
→ 접속할 Eureka Server 주소
```

자료에서는 Eureka Client 활성화를 위해 어노테이션을 추가하는 방식을 설명하고 있지만, Spring Cloud 버전에 따라 별도의 `@EnableEurekaClient` 또는 `@EnableDiscoveryClient` 없이 Starter와 자동 설정만으로 동작하는 구성도 사용할 수 있다.

Client가 정상적으로 실행되면 Eureka Server에 Instance 정보가 등록되고 이후 주기적인 상태 갱신을 통해 Registry가 관리된다.

같은 `spring.application.name`을 가진 애플리케이션을 여러 개 실행하면 하나의 Service 아래 여러 Instance가 등록될 수 있으며, 이를 통해 Scale-Out 환경에서도 서비스의 실제 위치를 동적으로 관리할 수 있다.

결국 Eureka Client의 핵심은 다음 흐름이다.

```text
Spring Boot Application
        ↓
Eureka Client
        ↓
Service Registration
        ↓
Eureka Registry
        ↓
Service Discovery
        ↓
Load Balancing
        ↓
Instance 호출
```

### 한 줄 요약

Eureka Client는 각각의 Spring Boot 서비스를 Eureka Server에 등록하여 IP와 Port를 직접 관리하지 않고 `ORDER-SERVICE`, `PAYMENT-SERVICE`와 같은 논리적인 서비스 이름을 기반으로 동적으로 서비스를 발견하고 호출할 수 있도록 만드는 Service Discovery의 핵심 구성 요소다.

