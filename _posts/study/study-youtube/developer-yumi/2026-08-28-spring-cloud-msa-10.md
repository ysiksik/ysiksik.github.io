---
layout: post
bigtitle: '스프링 클라우드 MSA'
subtitle: 스프링 클라우드 MSA 10 - 게이트웨이 Eureka 로드밸런싱
date: '2026-08-28 00:00:03 +0900'
categories:
    - developer-yumi
comments: true

---

# 스프링 클라우드 MSA 10 - 게이트웨이 Eureka 로드밸런싱
[https://youtu.be/bL7bakWi6Vg?si=3bI6t66l83h9RDZn](https://youtu.be/bL7bakWi6Vg?si=3bI6t66l83h9RDZn)

# 스프링 클라우드 MSA 10 - 게이트웨이 Eureka 로드밸런싱
* toc
{:toc}

---

## Spring Cloud Gateway와 Eureka를 연동한 로드밸런싱 구성

Spring Cloud Gateway에서 단순 Routing을 구성하면 특정 URL 요청을 원하는 마이크로서비스로 전달할 수 있다.

예를 들어 다음과 같이 설정할 수 있다.

```text
/ms1/**
→ http://localhost:8081
```

이 구조는 하나의 서버만 존재하는 환경에서는 충분히 동작한다.

하지만 MSA 환경에서는 하나의 서비스가 항상 하나의 서버로만 동작한다고 가정하기 어렵다.

트래픽이 증가하면 동일한 마이크로서비스가 여러 인스턴스로 확장될 수 있다.

```text
MS1

Instance 1
→ 8081

Instance 2
→ 8082

Instance 3
→ 8083
```

이러한 상황에서 Gateway가 특정 IP와 Port만 알고 있다면 새롭게 생성된 인스턴스로 요청을 전달할 수 없다.

```text
Gateway
    ↓
http://localhost:8081
```

`8082`, `8083` 서버가 새롭게 실행되어도 Gateway 설정에는 존재하지 않기 때문이다.

이 문제를 해결하기 위해 Spring Cloud Gateway와 Eureka Server를 연결할 수 있다.

```mermaid
flowchart TD
    C[Client] --> G[Spring Cloud Gateway]

    G --> E[Eureka Server]

    M1[MS1 Instance :8081] --> E
    M2[MS1 Instance :8082] --> E

    G --> M1
    G --> M2
```

각 마이크로서비스는 Eureka Client로 등록되어 자신의 위치를 Eureka Server에 전달한다.

Gateway 역시 Eureka와 연결하여 현재 실행 중인 서비스 인스턴스 목록을 확인하고, `lb://` 방식으로 Routing하면 여러 인스턴스에 요청을 분산할 수 있다.

---

## Gateway와 Eureka를 연동하는 이유

앞에서 Gateway Routing을 다음처럼 구성했다.

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: ms1
          uri: http://localhost:8081
          predicates:
            - Path=/ms1/**
```

이 설정의 의미는 단순하다.

```text
/ms1/** 요청
→ localhost:8081로 전달
```

문제는 `8081`이라는 특정 서버에 Gateway가 직접 의존한다는 것이다.

---

## Scale-Out이 발생하면 어떻게 될까?

MSA 환경에서는 트래픽 증가에 대응하기 위해 동일한 애플리케이션을 여러 개 실행할 수 있다.

처음에는 하나의 서버만 존재한다고 가정해보자.

```text
MS1
→ 10.0.1.10:8080
```

트래픽이 증가하면서 동일한 서비스가 추가된다.

```text
MS1

10.0.1.10:8080
10.0.1.11:8080
10.0.1.12:8080
```

하지만 Gateway Route가 다음과 같이 설정되어 있다면:

```text
http://10.0.1.10:8080
```

Gateway는 나머지 두 인스턴스를 알지 못한다.

결과적으로 Scale-Out을 했지만 실제 요청은 첫 번째 인스턴스에만 전달되는 문제가 생길 수 있다.

```mermaid
flowchart LR
    G[Gateway] --> M1[MS1 10.0.1.10]

    M2[MS1 10.0.1.11]
    M3[MS1 10.0.1.12]
```

새로운 서버를 생성해도 Gateway가 해당 주소를 모르면 트래픽 분산 효과를 얻을 수 없다.

---

## Eureka가 서비스 위치를 관리한다

각 마이크로서비스를 Eureka Client로 등록하면 실행될 때 자신의 위치를 Eureka Server에 등록한다.

예를 들어 동일한 `ms1` 서비스를 두 개 실행한다고 가정하자.

```text
MS1 Instance 1
→ localhost:8081

MS1 Instance 2
→ localhost:8082
```

두 애플리케이션의 서비스 이름은 동일하게 설정한다.

```properties
spring.application.name=ms1
```

그러면 Eureka에서는 하나의 서비스 이름 아래 여러 인스턴스를 관리하게 된다.

```text
MS1

├── localhost:8081
└── localhost:8082
```

즉 다음 관계가 만들어진다.

```text
Service
MS1

     ↓

Instance
8081
8082
```

Gateway가 Eureka와 연결되면 개별 IP를 직접 관리하는 대신 `MS1`이라는 서비스 이름을 기준으로 현재 실행 중인 인스턴스를 찾을 수 있다.

---

## Service Discovery와 Load Balancing의 관계

Gateway와 Eureka의 역할을 구분해야 한다.

Eureka는 다음 문제를 해결한다.

```text
MS1이라는 서비스는 현재 어디에 있는가?
```

예를 들어 다음 정보를 관리한다.

```text
MS1

8081
8082
```

Gateway와 Load Balancer는 이 정보를 이용하여 실제 요청 대상 인스턴스를 결정한다.

```text
Eureka
→ 사용 가능한 Instance 목록 제공

Load Balancer
→ Instance 하나 선택

Gateway
→ 선택한 Instance로 요청 전달
```

전체 흐름은 다음과 같다.

```mermaid
flowchart LR
    C[Client] --> G[Gateway]

    G --> E[Eureka]

    E --> M1[MS1 :8081]
    E --> M2[MS1 :8082]

    G --> LB[Load Balancer]

    LB --> M1
    LB --> M2
```

---

## Gateway도 Eureka Client가 된다

Gateway가 Eureka Server의 Registry 정보를 사용하려면 Gateway 프로젝트도 Eureka와 연결되어야 한다.

따라서 Spring Cloud Gateway 프로젝트에 Eureka Client 기능을 추가한다.

Gradle에서는 Eureka Client 의존성을 추가한다.

```gradle
dependencies {
    implementation 'org.springframework.cloud:spring-cloud-starter-gateway'

    implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-client'
}
```

기존 Gateway 프로젝트가 이미 존재한다면 Eureka Client 의존성만 추가한다.

```gradle
implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-client'
```

Gradle 설정을 Reload하면 필요한 라이브러리가 다운로드된다.

결과적으로 Gateway는 다음 두 가지 역할을 동시에 수행하게 된다.

```text
Spring Cloud Gateway
+
Eureka Client
```

---

## Gateway를 Eureka Server에 연결하기

Gateway 프로젝트의 설정 파일에 Eureka Server 주소를 작성한다.

Eureka Server가 다음 주소에서 실행되고 있다고 가정한다.

```text
localhost:8761
```

기본 설정은 다음과 같이 구성할 수 있다.

```yaml
spring:
  application:
    name: api-gateway

eureka:
  client:
    register-with-eureka: true
    fetch-registry: true

    service-url:
      defaultZone: http://localhost:8761/eureka/
```

의미는 다음과 같다.

```text
register-with-eureka
→ Gateway 자신을 Eureka에 등록

fetch-registry
→ Eureka Registry 정보를 가져옴

defaultZone
→ 접속할 Eureka Server 주소
```

Gateway 역시 Eureka Dashboard에 하나의 애플리케이션으로 나타날 수 있다.

---

## Spring Security가 적용된 Eureka Server 연결

Eureka Server에 HTTP Basic 인증이 적용되어 있다면 Gateway도 인증 정보를 가지고 접속해야 한다.

예를 들어 Eureka Server의 계정이 다음과 같다고 가정한다.

```text
Username
→ admin

Password
→ 1234
```

Gateway에서는 다음과 같이 설정할 수 있다.

```yaml
eureka:
  client:
    service-url:
      defaultZone: http://admin:1234@localhost:8761/eureka/
```

구조는 다음과 같다.

```text
http://username:password@host:port/eureka/
```

즉 Gateway는 Eureka Server에 Registry 정보를 요청할 때 해당 인증 정보를 함께 전달한다.

실제 운영 환경에서는 ID와 비밀번호를 설정 파일에 직접 기록하기보다 외부 설정으로 분리하는 것이 적절하다.

---

## 테스트를 위한 동일한 마이크로서비스 두 개 준비

로드밸런싱 동작을 확인하기 위해 동일한 서비스를 두 개 실행한다고 가정한다.

두 서비스 모두 같은 비즈니스 로직을 처리한다.

첫 번째 인스턴스:

```text
Port
→ 8081

Service Name
→ ms1
```

두 번째 인스턴스:

```text
Port
→ 8082

Service Name
→ ms1
```

두 애플리케이션 모두 Eureka Client로 설정한다.

```yaml
spring:
  application:
    name: ms1

eureka:
  client:
    register-with-eureka: true
    fetch-registry: true

    service-url:
      defaultZone: http://localhost:8761/eureka/
```

Port만 서로 다르게 설정한다.

첫 번째:

```yaml
server:
  port: 8081
```

두 번째:

```yaml
server:
  port: 8082
```

---

## 동일한 Service Name이 중요한 이유

두 서버는 서로 다른 Port에서 실행되지만 같은 기능을 수행하는 동일 서비스다.

따라서 Eureka에는 동일한 `spring.application.name`을 사용한다.

```text
spring.application.name=ms1
```

결과적으로 Eureka Registry에는 다음처럼 등록된다.

```text
MS1

Instance 1
→ localhost:8081

Instance 2
→ localhost:8082
```

서비스 이름과 인스턴스를 구분하면 다음과 같다.

```text
MS1
= Service

8081
= Instance 1

8082
= Instance 2
```

동일 서비스가 Scale-Out되더라도 서비스 이름은 변하지 않는다.

```text
MS1
├── Instance 1
├── Instance 2
├── Instance 3
├── Instance 4
└── ...
```

이것이 Service Discovery에서 서비스 이름을 사용하는 중요한 이유다.

---

## 테스트를 위해 응답을 다르게 만들기

실제로는 두 인스턴스가 동일한 결과를 반환해야 하지만 로드밸런싱 여부를 눈으로 확인하기 위해 서로 다른 문자열을 반환하도록 만들 수 있다.

첫 번째 서버:

```java
@RestController
public class MainController {

    @GetMapping("/ms1/first")
    public String first() {
        return "MS1 - INSTANCE 1";
    }
}
```

Port:

```yaml
server:
  port: 8081
```

두 번째 서버:

```java
@RestController
public class MainController {

    @GetMapping("/ms1/first")
    public String first() {
        return "MS1 - INSTANCE 2";
    }
}
```

Port:

```yaml
server:
  port: 8082
```

Eureka 관점에서는 둘 다 `MS1` 서비스다.

---

## 기존 Gateway Routing의 문제

앞선 Path Routing에서는 다음과 같이 URI를 직접 작성했다.

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: ms1
          uri: http://localhost:8081
          predicates:
            - Path=/ms1/**
```

이 설정에서는 항상 `8081`로만 요청이 전달된다.

```text
Gateway
   ↓
8081
```

`8082` 서버가 Eureka에 등록되어 있어도 이 Route에서는 활용되지 않는다.

---

## lb://를 이용한 Routing

Eureka와 Gateway를 연동한 뒤에는 `uri`를 변경한다.

기존:

```yaml
uri: http://localhost:8081
```

변경:

```yaml
uri: lb://MS1
```

여기서 `lb`는 Load Balancing을 의미한다.

```text
lb://MS1
```

을 단순하게 해석하면 다음과 같다.

```text
MS1이라는 서비스의
사용 가능한 Instance를 찾은 후
그중 하나로 요청을 전달한다.
```

---

## Gateway Load Balancing 설정

전체 Gateway 설정은 다음과 같은 형태가 된다.

```yaml
server:
  port: 8080

spring:
  application:
    name: api-gateway

  cloud:
    gateway:
      routes:
        - id: ms1
          uri: lb://MS1
          predicates:
            - Path=/ms1/**

eureka:
  client:
    register-with-eureka: true
    fetch-registry: true

    service-url:
      defaultZone: http://localhost:8761/eureka/
```

핵심적인 변화는 다음 한 줄이다.

```yaml
uri: lb://MS1
```

---

## http://와 lb://의 차이

기존 방식은 다음과 같다.

```text
http://localhost:8081
```

Gateway가 목적지 주소를 직접 알고 있다.

```mermaid
flowchart LR
    G[Gateway] --> M[localhost:8081]
```

`lb://` 방식에서는 서비스 이름을 사용한다.

```text
lb://MS1
```

Gateway는 `MS1`에 해당하는 실제 인스턴스를 찾는다.

```mermaid
flowchart LR
    G[Gateway] --> E[Eureka]

    E --> M1[MS1 :8081]
    E --> M2[MS1 :8082]

    G --> M1
    G --> M2
```

차이를 표로 보면 다음과 같다.

| 방식                      | 대상      | 특징             |
| ----------------------- | ------- | -------------- |
| `http://localhost:8081` | 특정 서버   | IP/Port 고정     |
| `lb://MS1`              | 논리적 서비스 | 여러 Instance 활용 |

---

## Gateway가 MS1을 찾는 과정

다음 요청이 Gateway로 들어온다고 가정한다.

```text
GET http://localhost:8080/ms1/first
```

Gateway의 Route는 다음과 같다.

```text
Path=/ms1/**
```

따라서 `MS1` Route가 선택된다.

URI는 다음과 같다.

```text
lb://MS1
```

Gateway는 Eureka Registry에서 `MS1`을 확인한다.

```text
MS1

localhost:8081
localhost:8082
```

그 후 두 인스턴스 중 하나를 선택하여 요청을 전달한다.

```mermaid
sequenceDiagram
    participant C as Client
    participant G as Gateway
    participant E as Eureka
    participant M1 as MS1 :8081
    participant M2 as MS1 :8082

    C->>G: GET /ms1/first
    G->>E: MS1 Instance 조회
    E-->>G: 8081, 8082
    G->>M1: 요청 전달
    M1-->>G: Response
    G-->>C: Response
```

다음 요청에서는 다른 인스턴스가 선택될 수 있다.

---

## Load Balancing 테스트

Gateway는 다음 Port에서 실행한다.

```text
8080
```

동일한 MS1 서비스 인스턴스 두 개가 다음 Port에 실행 중이다.

```text
8081
8082
```

Gateway로 요청한다.

```bash
curl http://localhost:8080/ms1/first
```

첫 번째 응답이 다음과 같을 수 있다.

```text
MS1 - INSTANCE 1
```

다시 요청한다.

```bash
curl http://localhost:8080/ms1/first
```

이번에는 다음 응답이 나타날 수 있다.

```text
MS1 - INSTANCE 2
```

반복적으로 요청하면 여러 인스턴스에 요청이 분배되는 것을 확인할 수 있다.

```text
Request 1
→ Instance 1

Request 2
→ Instance 2

Request 3
→ Instance 1

Request 4
→ Instance 2
```

제공된 테스트에서는 두 인스턴스 사이에서 번갈아 요청이 전달되는 형태로 확인된다.

---

## Spring Cloud LoadBalancer의 역할

여기서 중요한 점은 Eureka와 Load Balancer의 역할을 구분하는 것이다.

Eureka는 `MS1`에 어떤 서버가 등록되어 있는지 관리한다.

```text
Eureka

MS1
├── 8081
└── 8082
```

Load Balancer는 그 목록 중 실제 요청을 보낼 인스턴스를 결정한다.

```text
Available Instances

8081
8082

     ↓

하나 선택
```

Gateway는 선택된 서버로 실제 HTTP 요청을 전달한다.

```text
Eureka
→ 발견

Load Balancer
→ 선택

Gateway
→ 전달
```

---

## 전체 요청 흐름

Gateway와 Eureka, Load Balancer를 함께 사용하면 요청은 다음 순서로 처리된다.

```mermaid
flowchart TD
    A[Client Request] --> B[Spring Cloud Gateway]

    B --> C{Path Predicate}

    C -->|/ms1/**| D[Route lb://MS1]

    D --> E[Eureka Service Registry]

    E --> F[MS1 Instance List]

    F --> G[Load Balancer]

    G --> H[MS1 :8081]
    G --> I[MS1 :8082]
```

이를 단계별로 정리하면 다음과 같다.

```text
1. Client가 Gateway에 요청

2. Gateway가 Path Predicate 확인

3. Route에서 lb://MS1 확인

4. Eureka에서 MS1 인스턴스 검색

5. 현재 사용 가능한 인스턴스 목록 조회

6. Load Balancer가 Instance 선택

7. Gateway가 선택된 Instance에 요청 전달

8. 응답을 Client에 반환
```

---

## 한 Instance가 종료되면 어떻게 될까?

로드밸런싱 환경에서 중요한 상황이 하나 있다.

다음 두 Instance가 Eureka에 등록되어 있다고 하자.

```text
MS1

8081
8082
```

Gateway는 두 서버에 요청을 분배한다.

```text
Request 1
→ 8081

Request 2
→ 8082
```

여기서 `8082` 애플리케이션을 종료한다고 가정한다.

```text
8082
→ DOWN
```

Eureka Registry에서도 해당 Instance가 제거되면 사용 가능한 서비스는 하나가 된다.

```text
MS1

8081
```

Gateway에서 다시 요청하면 남아 있는 Instance로 요청이 전달된다.

```text
Request
→ MS1
→ 8081
```

즉 Gateway의 Route 설정을 직접 수정하지 않아도 서비스 Registry의 변경을 기반으로 요청 대상이 달라질 수 있다.

---

## 다시 Instance를 실행하면 어떻게 될까?

종료했던 서비스를 다시 실행한다고 하자.

```text
MS1 :8082
→ Start
```

Eureka Client는 다시 자신의 정보를 Eureka Server에 등록한다.

```text
MS1

8081
8082
```

Gateway는 다시 두 Instance를 활용할 수 있는 상태가 된다.

```text
Request 1
→ 8081

Request 2
→ 8082
```

이것이 동적 Service Discovery와 Load Balancing을 함께 사용하는 이유다.

---

## Scale-Out과 Eureka

실제 MSA에서는 개발자가 직접 다음 명령을 반복하여 서버를 실행하는 것이 목적은 아니다.

```text
8081 실행
8082 실행
8083 실행
```

트래픽 상황에 따라 인프라에서 동일한 서비스를 추가로 실행하는 상황을 생각할 수 있다.

```text
Traffic 증가

MS1 1개
   ↓
MS1 5개
```

각 Instance가 Eureka Client로 구성되어 있다면 실행 후 Eureka Registry에 등록된다.

```text
MS1

Instance 1
Instance 2
Instance 3
Instance 4
Instance 5
```

Gateway는 서비스 이름을 기준으로 Routing하므로 새로운 Instance의 IP를 Route 설정에 하나씩 추가하지 않아도 되는 구조를 만들 수 있다.

---

## 고정 Routing과 동적 Routing 비교

### 고정 Routing

```yaml
uri: http://localhost:8081
```

구조:

```text
Gateway
→ 특정 Instance
```

단점:

```text
Instance 증가 시 설정 변경 필요
Instance 주소 변경 시 설정 변경 필요
Scale-Out 대응 어려움
Gateway와 서비스 위치가 결합
```

---

### Eureka 기반 Routing

```yaml
uri: lb://MS1
```

구조:

```text
Gateway
→ MS1
→ Eureka
→ 현재 Instance 목록
→ Load Balancer
```

장점:

```text
동적인 Instance 탐색
Scale-Out 대응
서비스 이름 기반 Routing
Instance 장애 대응
Gateway와 실제 서버 주소 분리
```

---

## Gateway 설정에서 서비스 이름이 중요한 이유

다음 URI를 사용한다.

```yaml
uri: lb://MS1
```

여기서 `MS1`은 Eureka에 등록된 서비스 이름과 일치해야 한다.

Eureka Client에서 다음과 같이 설정했다고 가정한다.

```yaml
spring:
  application:
    name: ms1
```

Gateway에서는 동일한 서비스 식별자를 기준으로 Routing해야 한다.

```yaml
uri: lb://MS1
```

서비스 이름이 맞지 않는다면 Gateway가 Eureka Registry에서 대상을 찾지 못하게 된다.

따라서 MSA에서는 서비스 Naming 규칙을 일관성 있게 관리하는 것이 중요하다.

예를 들어 다음과 같이 정할 수 있다.

```text
user-service
order-service
payment-service
notification-service
```

Gateway도 같은 이름을 기준으로 Routing한다.

---

## 실제 서비스 구조 예제

쇼핑몰 MSA라면 다음과 같이 확장할 수 있다.

```text
USER-SERVICE

Instance 1
Instance 2


ORDER-SERVICE

Instance 1
Instance 2
Instance 3


PAYMENT-SERVICE

Instance 1
```

Gateway Routing은 서비스 이름을 사용한다.

```yaml
spring:
  cloud:
    gateway:
      routes:

        - id: user-service
          uri: lb://USER-SERVICE
          predicates:
            - Path=/users/**

        - id: order-service
          uri: lb://ORDER-SERVICE
          predicates:
            - Path=/orders/**

        - id: payment-service
          uri: lb://PAYMENT-SERVICE
          predicates:
            - Path=/payments/**
```

Client는 실제 서버가 몇 개인지 알 필요가 없다.

```text
/users/**
→ USER-SERVICE

/orders/**
→ ORDER-SERVICE

/payments/**
→ PAYMENT-SERVICE
```

---

## Properties 방식으로 작성한다면

같은 Routing을 `application.properties`로 작성할 수도 있다.

```properties
server.port=8080

spring.cloud.gateway.routes[0].id=ms1
spring.cloud.gateway.routes[0].predicates[0]=Path=/ms1/**
spring.cloud.gateway.routes[0].uri=lb://MS1
```

Eureka 연결 설정도 추가한다.

```properties
spring.application.name=api-gateway

eureka.client.register-with-eureka=true
eureka.client.fetch-registry=true

eureka.client.service-url.defaultZone=http://localhost:8761/eureka/
```

HTTP Basic 인증이 적용된 경우 다음처럼 구성할 수 있다.

```properties
eureka.client.service-url.defaultZone=http://admin:1234@localhost:8761/eureka/
```

---

## Gateway가 Eureka Dashboard에 등록되는 이유

Gateway 역시 Eureka Client로 구성했기 때문에 Eureka Dashboard에 나타날 수 있다.

예를 들어 Registry가 다음처럼 표시될 수 있다.

```text
API-GATEWAY
→ 8080

MS1
→ 8081
→ 8082
```

여기서 중요한 것은 Gateway가 Eureka에 등록되어 있는 것 자체와 Gateway가 다른 서비스의 Registry를 조회하는 기능을 구분하는 것이다.

Gateway에서 특히 필요한 기능은 다음과 같다.

```text
fetch-registry=true
```

Gateway가 Eureka Server에 등록된 `MS1` 인스턴스 목록을 가져와 Routing에 활용하기 때문이다.

---

## Load Balancing과 Auto Scaling은 같은 기능이 아니다

제공된 흐름에서는 Auto Scaling으로 Instance가 증가하고 Gateway가 새로운 Instance를 활용하는 상황을 설명한다.

이때 두 개념을 분리해 이해하는 것이 중요하다.

```text
Auto Scaling

서비스 Instance를
늘리거나 줄이는 역할
```

```text
Service Discovery

새롭게 생성된 Instance의
위치를 발견하는 역할
```

```text
Load Balancing

발견된 여러 Instance에
요청을 분산하는 역할
```

즉 다음 세 작업은 서로 연결되어 있지만 다른 책임이다.

```mermaid
flowchart LR
    A[Auto Scaling] --> B[Instance 증가]

    B --> C[Eureka Registration]

    C --> D[Service Discovery]

    D --> E[Load Balancing]

    E --> F[Gateway Routing]
```

---

## Auto Scaling이 Eureka가 제공하는 기능은 아니다

Eureka는 서버를 직접 생성하지 않는다.

Eureka의 역할은 이미 생성된 서비스 인스턴스가 등록되었을 때 그 정보를 Registry에서 관리하는 것이다.

개념적인 역할은 다음과 같다.

```text
Auto Scaling System
→ Instance 생성

Eureka Client
→ 자신을 등록

Eureka Server
→ Instance 정보 관리

Gateway
→ Registry 활용

Load Balancer
→ 요청 분산
```

따라서 Scale-Out 자체와 Service Discovery를 구분해서 이해하면 전체 MSA 구조를 훨씬 명확하게 볼 수 있다.

---

## Instance 종료가 즉시 반영되지 않을 수도 있다

개발 환경에서 애플리케이션을 종료했는데 Eureka Dashboard에 잠시 남아 있는 상황이 발생할 수 있다.

Eureka는 Client의 등록 상태와 주기적인 통신을 기반으로 Registry를 관리하기 때문이다.

따라서 다음처럼 단순하게 생각하면 안 된다.

```text
프로세스 종료
→ 같은 순간 즉시 Registry 삭제
```

대신 개념적으로 다음 흐름이 존재한다.

```text
Client 상태 변경
→ Eureka가 상태 확인
→ Registry 정보 갱신
→ Gateway가 변경된 Registry 활용
```

따라서 실제 분산 환경에서는 일정한 반영 시간이 존재할 수 있다는 점을 고려해야 한다.

---

## Load Balancing 확인용 테스트 Controller

두 Instance가 동일한 서비스인지 확인하면서 어느 서버가 응답했는지도 보고 싶다면 Port를 응답하도록 만들 수 있다.

예를 들어 다음처럼 구성할 수 있다.

```java
@RestController
public class InstanceController {

    @Value("${server.port}")
    private String serverPort;

    @GetMapping("/ms1/first")
    public String first() {
        return "response from port: " + serverPort;
    }
}
```

첫 번째 Instance를 `8081`에서 실행하면:

```text
response from port: 8081
```

두 번째 Instance를 `8082`에서 실행하면:

```text
response from port: 8082
```

Gateway를 통해 반복 호출한다.

```bash
curl http://localhost:8080/ms1/first
```

응답을 통해 어떤 Instance가 선택되었는지 확인할 수 있다.

---

## Docker 환경에서의 구조

마이크로서비스를 Docker로 실행한다면 다음과 같은 구조가 될 수 있다.

```text
eureka-server
gateway
ms1-1
ms1-2
```

각 MS1 Container는 Eureka에 자신을 등록한다.

```mermaid
flowchart TD
    M1[ms1-1] --> E[eureka-server]
    M2[ms1-2] --> E

    G[gateway] --> E

    G --> M1
    G --> M2
```

Gateway Route는 개별 Container 주소가 아니라 Service ID를 사용한다.

```yaml
uri: lb://MS1
```

따라서 Gateway가 다음 주소를 모두 직접 알고 있을 필요가 없다.

```text
ms1-1
ms1-2
ms1-3
...
```

---

## Gateway + Eureka 구조의 장점

### 서비스 위치와 Routing 분리

Gateway에서는 다음만 알고 있다.

```text
MS1
```

실제 서버 주소는 Eureka가 관리한다.

```text
8081
8082
8083
```

---

### Scale-Out 대응

Instance가 증가한다.

```text
MS1

2개
→ 5개
```

각 Client가 Eureka에 등록되면 Gateway에서 새로운 인스턴스를 활용할 수 있는 구조가 된다.

---

### 장애 Instance 제외

한 Instance가 정상적인 서비스 대상으로 유지되지 않게 되면 Registry가 갱신되고 남은 Instance를 활용할 수 있다.

---

### Gateway 설정 단순화

다음처럼 여러 서버를 직접 작성하는 대신:

```text
8081
8082
8083
8084
```

서비스 이름 하나를 사용할 수 있다.

```yaml
uri: lb://MS1
```

---

## Gateway + Eureka 구조에서 주의할 점

Eureka와 Load Balancer를 연결했다고 해서 모든 장애 문제가 해결되는 것은 아니다.

예를 들어 다음 상황도 고려해야 한다.

```text
Eureka Server 장애
Registry 갱신 지연
서비스가 등록됐지만 실제 API 장애
Gateway Timeout
서비스 처리 지연
Gateway 자체 장애
```

따라서 실제 운영에서는 다음과 같은 요소도 함께 필요할 수 있다.

```text
Health Check
Timeout
Retry
Circuit Breaker
Gateway 다중화
Eureka 다중화
Monitoring
Distributed Tracing
```

Service Discovery와 Load Balancing은 MSA의 중요한 구성 요소지만 전체 장애 대응 전략 중 일부라고 볼 수 있다.

---

## Gateway 자체도 여러 개 운영할 수 있다

Gateway가 모든 외부 요청을 받는다면 Gateway 한 대가 장애 지점이 될 수 있다.

```text
Client
   ↓
Gateway 1대
   ↓
Microservices
```

Gateway가 중단되면 내부 서비스가 정상이어도 사용자가 접근할 수 없다.

따라서 실제 구조에서는 다음처럼 Gateway도 여러 개 운영할 수 있다.

```mermaid
flowchart TD
    C[Client] --> L[External Load Balancer]

    L --> G1[Gateway 1]
    L --> G2[Gateway 2]

    G1 --> E[Eureka]
    G2 --> E

    E --> M1[MS1 Instance 1]
    E --> M2[MS1 Instance 2]
```

여기에는 두 종류의 Load Balancing이 존재한다.

```text
외부 Load Balancer

Client
→ Gateway Instance 분산
```

그리고:

```text
Spring Cloud LoadBalancer

Gateway
→ Microservice Instance 분산
```

둘의 역할을 구분해야 한다.

---

## 전체 Spring Cloud MSA 구조

Config Server까지 포함하면 전체 구조는 다음과 같이 확장된다.

```mermaid
flowchart TD
    C[Client]

    C --> L[External Load Balancer]

    L --> G1[Gateway 1]
    L --> G2[Gateway 2]

    G1 --> E[Eureka Server]
    G2 --> E

    U1[User Service 1] --> E
    U2[User Service 2] --> E

    O1[Order Service 1] --> E
    O2[Order Service 2] --> E

    G1 --> U1
    G1 --> U2
    G1 --> O1
    G1 --> O2

    CR[Config Repository] --> CS[Config Server]

    CS --> G1
    CS --> G2
    CS --> U1
    CS --> U2
    CS --> O1
    CS --> O2
```

각 구성 요소의 역할을 다시 구분하면 다음과 같다.

| 구성 요소             | 역할               |
| ----------------- | ---------------- |
| Config Repository | 설정 저장            |
| Config Server     | 설정 제공            |
| Eureka Server     | Service Registry |
| Eureka Client     | 서비스 등록           |
| Gateway           | 외부 요청 Routing    |
| Load Balancer     | Instance 선택      |
| Microservice      | 비즈니스 로직 수행       |

---

## 전체 요청 처리 과정

클라이언트가 다음 요청을 전송한다고 가정한다.

```text
GET /ms1/first
```

전체 과정은 다음과 같다.

```mermaid
sequenceDiagram
    participant C as Client
    participant G as Gateway
    participant E as Eureka
    participant L as Load Balancer
    participant M1 as MS1 :8081
    participant M2 as MS1 :8082

    C->>G: GET /ms1/first

    G->>G: Path=/ms1/** Route Match

    G->>E: MS1 Instance 조회

    E-->>G: 8081, 8082

    G->>L: Instance 선택 요청

    L-->>G: 8081 선택

    G->>M1: GET /ms1/first

    M1-->>G: Response

    G-->>C: Response
```

다음 요청에서는 다른 Instance가 선택될 수 있다.

---

## 동적 Scale-Out 상황

서비스가 처음에는 두 개라고 가정한다.

```text
MS1

8081
8082
```

트래픽 증가로 새로운 Instance가 추가된다.

```text
MS1

8081
8082
8083
```

새로운 Instance 역시 Eureka Client로 등록된다.

```text
8083
→ Eureka Registration
```

Registry가 변경된다.

```text
MS1
├── 8081
├── 8082
└── 8083
```

Gateway Route는 변경하지 않는다.

```yaml
uri: lb://MS1
```

이 구조가 고정 IP Routing과 비교했을 때 Eureka 기반 Routing이 가지는 가장 큰 의미다.

---

## 동적 Scale-In 상황

반대로 트래픽이 감소하면 Instance 하나가 종료될 수 있다.

```text
기존

MS1
8081
8082
8083
```

```text
변경

MS1
8081
8082
```

Eureka Registry가 변경된 상태를 반영하면 Gateway는 남은 서비스 인스턴스를 대상으로 Routing할 수 있다.

Gateway의 Route 설정은 역시 동일하다.

```yaml
uri: lb://MS1
```

즉 Gateway는 **서비스가 몇 개의 인스턴스로 실행되고 있는지 자체 Routing 설정에서 관리하지 않는다.**

---

## 실무에서 기억해야 할 핵심

이 구조를 이해할 때 가장 중요한 것은 다음 네 가지 역할을 분리하는 것이다.

```text
Auto Scaling
→ 서버의 수를 늘리고 줄임

Eureka
→ 어떤 서버가 존재하는지 관리

Load Balancer
→ 서버 중 하나를 선택

Gateway
→ 외부 요청을 해당 서버로 전달
```

전체 연결 관계는 다음과 같다.

```text
Auto Scaling
      ↓
새 Instance 생성
      ↓
Eureka Client 등록
      ↓
Eureka Registry 갱신
      ↓
Gateway가 Service Discovery
      ↓
Load Balancer가 Instance 선택
      ↓
Gateway가 요청 전달
```

이 구조가 만들어지면 Gateway가 각 마이크로서비스의 실제 IP와 Port를 직접 관리할 필요를 크게 줄일 수 있다.

---

## 정리

Spring Cloud Gateway와 Eureka를 연동하는 핵심 이유는 동적으로 생성되고 제거되는 마이크로서비스의 위치를 Gateway가 직접 관리하지 않도록 만들기 위해서다.

기존 Routing은 다음처럼 고정 주소를 사용했다.

```yaml
uri: http://localhost:8081
```

이 방식에서는 Gateway가 특정 Instance에 직접 의존한다.

Eureka를 연동하면 다음과 같이 서비스 이름 기반의 Routing을 사용할 수 있다.

```yaml
uri: lb://MS1
```

`MS1` 서비스가 Eureka에 다음과 같이 등록되어 있다면:

```text
MS1

8081
8082
```

Gateway는 Eureka Registry에서 현재 사용 가능한 Instance 목록을 확인하고 Load Balancer를 통해 그중 하나로 요청을 전달할 수 있다.

```text
Request
    ↓
Gateway
    ↓
Path Route
    ↓
lb://MS1
    ↓
Eureka
    ↓
Instance 목록
    ↓
Load Balancer
    ↓
8081 또는 8082
```

동일한 서비스를 추가로 실행하면 Eureka Registry에 새로운 Instance가 등록되고, 기존 Instance가 종료되면 Registry에서도 변경된 상태를 관리할 수 있다.

따라서 Gateway Route에 새로운 IP를 계속 추가하는 방식보다 동적인 MSA 환경에 적합한 구조를 만들 수 있다.

그리고 이 과정에서 각 구성 요소의 역할을 명확히 구분해야 한다.

```text
Eureka
→ 서비스 위치 관리

Load Balancer
→ Instance 선택

Gateway
→ 요청 Routing

Auto Scaling
→ Instance 개수 조절
```

### 한 줄 요약

Spring Cloud Gateway에서 `uri: lb://서비스이름`을 사용하고 Eureka와 연동하면 Gateway가 고정 IP 대신 Eureka에 등록된 서비스 인스턴스를 동적으로 발견하고 여러 인스턴스에 요청을 분산하는 로드밸런싱 구조를 만들 수 있다.



