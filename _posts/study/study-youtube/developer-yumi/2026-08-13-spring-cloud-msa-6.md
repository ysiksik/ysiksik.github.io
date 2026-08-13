---
layout: post
bigtitle: '스프링 클라우드 MSA'
subtitle: 스프링 클라우드 MSA 6 - Eureka 서버 구축
date: '2026-08-13 00:00:03 +0900'
categories:
    - developer-yumi
comments: true

---

# 스프링 클라우드 MSA 6 - Eureka 서버 구축
[https://youtu.be/OXDwOYxKvWA?si=W1CH_2FQ3GMtXYJR](https://youtu.be/OXDwOYxKvWA?si=W1CH_2FQ3GMtXYJR)

# 스프링 클라우드 MSA 6 - Eureka 서버 구축
* toc
{:toc}

---

## Spring Cloud Eureka Server 구축과 Service Discovery 이해하기

마이크로서비스 아키텍처에서는 하나의 애플리케이션이 여러 개의 독립적인 서비스로 분리된다.

예를 들어 쇼핑몰 서비스를 다음과 같이 나눌 수 있다.

```text
User Service
Product Service
Order Service
Payment Service
Notification Service
```

각 서비스가 항상 한 개의 서버에서만 동작한다면 다른 서비스나 API Gateway가 IP와 Port를 직접 알고 있어도 큰 문제가 없을 수 있다.

하지만 실제 MSA 환경에서는 하나의 서비스가 여러 인스턴스로 실행될 수 있다.

```text
ORDER-SERVICE

10.0.1.10:8080
10.0.1.11:8080
10.0.1.12:8080
```

트래픽이 증가하면 새로운 인스턴스가 추가될 수 있다.

```text
10.0.1.13:8080
10.0.1.14:8080
```

반대로 장애가 발생하거나 트래픽이 감소하면 기존 인스턴스가 사라질 수도 있다.

이렇게 서비스의 실제 위치가 계속 변하는 상황에서는 각각의 IP 주소를 직접 관리하기 어렵다.

이 문제를 해결하기 위한 대표적인 방식이 **Service Discovery**이고, Spring Cloud Netflix에서 이를 구현하는 대표적인 기술이 **Eureka**다.

Spring Cloud의 현재 공식 문서에서도 Eureka를 Service Discovery를 위한 Server와 Client 구현으로 설명하고 있으며, Eureka Server는 등록된 서비스 정보를 관리할 수 있다.

---

## Service Discovery란?

Service Discovery는 이름 그대로 실행 중인 서비스를 찾아주는 기능이다.

예를 들어 Order Service가 Payment Service를 호출한다고 가정해보자.

Payment Service가 한 대뿐이고 주소가 고정되어 있다면 다음처럼 직접 호출할 수 있다.

```text
http://10.0.1.20:8080/payments
```

하지만 Payment Service가 여러 개라면 문제가 달라진다.

```text
payment-service-1
10.0.1.20:8080

payment-service-2
10.0.1.21:8080

payment-service-3
10.0.1.22:8080
```

Order Service가 이러한 모든 IP 주소를 직접 관리하면 서비스 간 결합도가 매우 높아진다.

```text
Order Service
→ Payment Service IP 직접 보관
→ IP 변경
→ Order Service 설정 변경
→ 재배포
```

Service Discovery를 사용하면 IP 대신 논리적인 서비스 이름을 사용한다.

```text
PAYMENT-SERVICE
```

그리고 Service Registry가 현재 실행 중인 인스턴스 정보를 관리한다.

```mermaid
flowchart LR
    A[Order Service] --> B[Service Registry]
    B --> C[Payment Service 1]
    B --> D[Payment Service 2]
    B --> E[Payment Service 3]
```

Spring Cloud에서 이러한 Service Registry 역할을 Eureka Server가 수행할 수 있다.

---

## Eureka Server란?

Eureka는 Netflix에서 개발한 Service Discovery 기술이며 Spring Cloud Netflix를 통해 Spring Boot 환경에서 사용할 수 있다.

Eureka는 크게 두 가지 역할로 나뉜다.

```text
Eureka Server
Eureka Client
```

### Eureka Server

현재 실행되고 있는 서비스의 정보를 관리하는 Service Registry다.

```text
서비스 이름
IP
Port
Instance ID
상태
Metadata
```

### Eureka Client

Eureka Server에 자신의 정보를 등록하는 애플리케이션이다.

```text
User Service
Order Service
Payment Service
API Gateway
```

이러한 Spring Boot 애플리케이션들이 Eureka Client가 될 수 있다.

Spring Cloud Netflix는 현재도 Eureka Server용 `spring-cloud-starter-netflix-eureka-server`와 Eureka Client용 `spring-cloud-starter-netflix-eureka-client`를 제공한다.

---

## Eureka Server는 모니터링 서버인가?

Eureka Server를 처음 접하면 Dashboard에서 서비스 상태를 확인할 수 있기 때문에 모니터링 서버라고 이해하기 쉽다.

실제로 Eureka Dashboard에서는 다음과 같은 정보를 확인할 수 있다.

```text
등록된 서비스
실행 중인 인스턴스
서비스 이름
Instance 정보
```

하지만 Eureka의 핵심 목적은 전문적인 시스템 모니터링이 아니다.

핵심 역할은 다음과 같다.

> 실행 중인 서비스의 위치를 등록하고 다른 서비스가 해당 위치를 찾을 수 있도록 제공하는 Service Registry다.

CPU 사용량이나 메모리, 응답 시간, Error Rate 등을 분석하려면 별도의 모니터링 시스템을 사용해야 한다.

```text
Spring Boot Actuator
Prometheus
Grafana
CloudWatch
Datadog
```

따라서 다음과 같이 구분하는 것이 좋다.

```text
Eureka
→ Service Registration
→ Service Discovery

Prometheus / Grafana
→ Metrics
→ Monitoring
→ Alert
```

---

## Eureka가 필요한 이유

API Gateway가 다음 요청을 받았다고 가정해보자.

```text
GET /orders/100
```

Gateway는 해당 요청을 Order Service로 전달해야 한다.

Order Service가 한 개이고 IP가 고정되어 있다면 다음처럼 설정할 수 있다.

```text
/orders/**
→ http://10.0.1.10:8080
```

하지만 트래픽 증가로 Order Service가 세 개로 늘어나면 문제가 발생한다.

```text
10.0.1.10:8080
10.0.1.11:8080
10.0.1.12:8080
```

Gateway는 새로 생성된 인스턴스의 IP를 알지 못한다.

이때 각 Order Service 인스턴스가 Eureka Server에 자신의 위치를 등록한다.

```mermaid
flowchart TD
    A[Order Service 1] --> E[Eureka Server]
    B[Order Service 2] --> E
    C[Order Service 3] --> E

    E --> G[API Gateway]
```

Gateway는 Eureka를 통해 현재 사용할 수 있는 Order Service의 목록을 얻는다.

```text
ORDER-SERVICE

10.0.1.10:8080
10.0.1.11:8080
10.0.1.12:8080
```

그 후 Load Balancer가 여러 인스턴스 중 하나를 선택할 수 있다.

Spring Cloud에서는 `DiscoveryClient` 구현을 통해 서비스 탐색을 지원하며 Eureka 역시 그 구현 중 하나다. 현재 Spring Cloud에서는 Discovery Client 구현체가 클래스패스에 있으면 자동 등록 기능을 사용할 수 있어 일반 Client에서 `@EnableDiscoveryClient`가 반드시 필요한 것은 아니다.

---

## Eureka를 포함한 MSA 구조

전체적인 구조를 보면 Eureka의 역할을 이해하기 쉽다.

```mermaid
flowchart TD
    A[Client] --> B[Spring Cloud Gateway]

    B --> C[User Service]
    B --> D[Order Service]
    B --> E[Payment Service]

    C --> F[(User DB)]
    D --> G[(Order DB)]
    E --> H[(Payment DB)]

    C --> I[Eureka Server]
    D --> I
    E --> I

    B --> I
```

각 서비스는 Eureka에 자신을 등록한다.

```text
User Service
→ USER-SERVICE 등록

Order Service
→ ORDER-SERVICE 등록

Payment Service
→ PAYMENT-SERVICE 등록
```

Gateway 역시 Eureka에서 등록된 서비스 정보를 사용할 수 있다.

---

## Eureka Server와 Client의 관계

전체 과정은 다음과 같다.

```mermaid
sequenceDiagram
    participant O as Order Service
    participant E as Eureka Server
    participant G as Gateway

    O->>E: ORDER-SERVICE 등록
    O->>E: 상태 정보 갱신
    G->>E: ORDER-SERVICE 조회
    E-->>G: 사용 가능한 Instance 목록
    G->>O: 요청 전달
```

서비스가 증가하더라도 새로운 인스턴스가 Eureka에 등록된다면 Gateway는 서비스 이름을 기준으로 인스턴스를 찾을 수 있다.

---

## Eureka Server 프로젝트 생성

Spring Boot 기반으로 Eureka Server를 생성한다.

기본적인 프로젝트 구성은 다음과 같다.

```text
Language
→ Java

Build Tool
→ Gradle

Java
→ 17 이상

Packaging
→ Jar
```

Spring Boot 3 계열을 사용한다면 Java 17 이상이 필요하다.

Eureka Server에 필요한 핵심 의존성은 다음과 같다.

```text
Eureka Server
Spring Security
```

Spring 공식 문서에서도 Eureka Server를 구성하려면 `spring-cloud-starter-netflix-eureka-server` Starter를 사용하도록 안내한다.

---

## Gradle 의존성 추가

`build.gradle`에 Eureka Server 의존성을 추가한다.

```gradle
dependencies {
    implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-server'

    implementation 'org.springframework.boot:spring-boot-starter-security'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}
```

핵심 의존성은 다음과 같다.

```gradle
implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-server'
```

Spring Security는 Eureka Dashboard와 Eureka API를 보호하기 위해 추가할 수 있다.

---

## Spring Cloud BOM 관리

Spring Cloud를 사용할 때는 Spring Boot와 호환되는 Spring Cloud Release Train을 선택해야 한다.

```gradle
ext {
    set('springCloudVersion', "Spring Boot와 호환되는 Spring Cloud 버전")
}

dependencyManagement {
    imports {
        mavenBom "org.springframework.cloud:spring-cloud-dependencies:${springCloudVersion}"
    }
}
```

전체적인 형태는 다음과 같다.

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
    implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-server'

    implementation 'org.springframework.boot:spring-boot-starter-security'

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

Spring Cloud Netflix 공식 문서 역시 현재 사용하는 Spring Cloud Release Train에 맞게 빌드 시스템과 의존성 버전을 구성해야 한다고 안내한다.

---

## @EnableEurekaServer 설정

프로젝트를 생성한 뒤 메인 Application 클래스에 `@EnableEurekaServer`를 추가한다.

```java
package com.example.eureka;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

@EnableEurekaServer
@SpringBootApplication
public class EurekaServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(
                EurekaServerApplication.class,
                args
        );
    }
}
```

`@EnableEurekaServer`는 해당 Spring Boot 애플리케이션이 Eureka Server로 동작하도록 활성화한다.

Spring Cloud Netflix 공식 문서에서도 Eureka Server의 최소 구성으로 `spring-cloud-starter-netflix-eureka-server`와 `@EnableEurekaServer`를 사용한다.

---

## Eureka Server 기본 설정

`application.yml`에 기본 설정을 작성한다.

```yaml
server:
  port: 8761

spring:
  application:
    name: eureka-server

eureka:
  client:
    register-with-eureka: false
    fetch-registry: false
```

Properties 방식으로 작성하면 다음과 같다.

```properties
server.port=8761

spring.application.name=eureka-server

eureka.client.register-with-eureka=false
eureka.client.fetch-registry=false
```

---

## server.port

```yaml
server:
  port: 8761
```

Eureka Server 예제에서는 관례적으로 `8761` 포트를 많이 사용한다.

Eureka Client가 별도의 Server 주소를 지정하지 않았을 때 기본값으로 `http://localhost:8761`을 사용하는 구성도 Spring Cloud Netflix 문서에서 확인할 수 있다.

반드시 `8761`을 사용해야 하는 것은 아니다.

다음과 같이 변경할 수도 있다.

```yaml
server:
  port: 9001
```

이 경우 Client에서도 해당 Eureka Server 주소를 동일하게 설정해야 한다.

---

## register-with-eureka

다음 설정은 Eureka Server 자신을 다른 Eureka Server에 등록할 것인지 결정한다.

```yaml
eureka:
  client:
    register-with-eureka: false
```

기본값은 `true`다. Spring Cloud Netflix의 현재 설정 속성 문서에서도 `eureka.client.register-with-eureka` 기본값이 `true`라고 정의되어 있다.

단일 Eureka Server를 실습하는 환경에서는 자신을 다시 등록할 필요가 없으므로 `false`로 설정한다.

```text
단일 Eureka Server

register-with-eureka
→ false
```

---

## fetch-registry

다음 설정은 다른 Eureka Server로부터 Registry 정보를 가져올지 결정한다.

```yaml
eureka:
  client:
    fetch-registry: false
```

단일 Eureka Server 환경에서는 가져올 다른 Registry가 없으므로 `false`로 설정한다.

즉 다음 설정은 **단일 Eureka Server 구축을 위한 실습 설정**이라고 이해하면 된다.

```yaml
eureka:
  client:
    register-with-eureka: false
    fetch-registry: false
```

Eureka Server를 여러 개 구성하는 고가용성 환경에서는 설정 구조가 달라질 수 있다. Eureka는 여러 Server가 등록 상태를 서로 복제하는 고가용성 구성을 지원한다.

---

## Eureka Server 실행

애플리케이션을 실행한다.

```bash
./gradlew bootRun
```

이 명령은 Gradle을 사용하여 Spring Boot 애플리케이션을 실행한다.

정상적으로 실행됐다면 다음 주소로 접근할 수 있다.

```text
http://localhost:8761
```

Eureka Server는 기본적으로 Dashboard UI를 제공하며 Eureka의 일반 기능을 위한 HTTP API는 `/eureka/*` 아래에 제공된다.

Spring Security를 아직 직접 설정하지 않았다면 기본 보안 설정 때문에 자동 생성된 Password가 로그에 나타날 수 있다.

---

## Eureka Dashboard

정상적으로 Eureka Server가 실행되면 브라우저에서 Dashboard를 확인할 수 있다.

```text
http://localhost:8761
```

아직 Eureka Client를 등록하지 않았다면 등록된 인스턴스가 존재하지 않는다.

```text
Instances currently registered with Eureka

No instances available
```

이후 User Service나 Order Service를 Eureka Client로 등록하면 Dashboard에서 확인할 수 있다.

```text
Application
ORDER-SERVICE

Status
UP

Instances
order-service:8081
order-service:8082
```

---

## Spring Security 적용

Eureka Server에는 서비스의 내부 네트워크 정보가 등록된다.

```text
서비스 이름
IP
Port
Instance
Metadata
```

따라서 운영 환경에서 Eureka Server를 외부에 무방비 상태로 공개하는 것은 피하는 것이 좋다.

Spring Security를 사용하여 인증을 적용할 수 있다.

---

## PasswordEncoder 설정

비밀번호를 평문으로 비교하지 않고 암호화하기 위해 `PasswordEncoder`를 Bean으로 등록한다.

```java
package com.example.eureka.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class PasswordConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

BCrypt는 동일한 비밀번호라도 Salt를 포함한 Hash를 생성하기 때문에 사용자 비밀번호 저장에 사용할 수 있다.

---

## SecurityFilterChain 설정

Spring Security에서 HTTP 요청에 대한 보안 정책을 설정한다.

```java
package com.example.eureka.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http
    ) throws Exception {

        http
                .csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(auth -> auth
                        .anyRequest().authenticated()
                )
                .httpBasic(Customizer.withDefaults());

        return http.build();
    }
}
```

주요 설정은 다음과 같다.

```text
csrf.disable()
→ CSRF 비활성화

anyRequest().authenticated()
→ 모든 요청에 인증 요구

httpBasic()
→ HTTP Basic 인증
```

---

## Eureka와 CSRF 설정

Eureka Client는 Eureka Server의 HTTP API를 이용하여 등록과 상태 갱신 등의 작업을 수행한다.

따라서 Spring Security를 적용할 경우 Eureka의 API 통신 정책을 고려해야 한다.

단순 실습에서는 전체 CSRF를 비활성화할 수 있다.

```java
.csrf(csrf -> csrf.disable())
```

하지만 운영 환경에서는 보안 범위를 세밀하게 설계하는 편이 좋다.

예를 들어 Eureka Endpoint만 예외 처리하는 방식도 고려할 수 있다.

```java
package com.example.eureka.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http
    ) throws Exception {

        http
                .csrf(csrf -> csrf
                        .ignoringRequestMatchers("/eureka/**")
                )
                .authorizeHttpRequests(auth -> auth
                        .anyRequest().authenticated()
                )
                .httpBasic(Customizer.withDefaults());

        return http.build();
    }
}
```

환경의 인증 방식과 Client 등록 방식에 맞게 정책을 결정해야 한다.

---

## 인메모리 사용자 생성

간단한 테스트에서는 DB를 구축하지 않고 `InMemoryUserDetailsManager`를 사용할 수 있다.

```java
package com.example.eureka.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;

@Configuration
public class UserConfig {

    @Bean
    public UserDetailsService userDetailsService(
            PasswordEncoder passwordEncoder
    ) {

        UserDetails admin = User.builder()
                .username("admin")
                .password(
                        passwordEncoder.encode(
                                "change-this-password"
                        )
                )
                .roles("ADMIN")
                .build();

        return new InMemoryUserDetailsManager(admin);
    }
}
```

이렇게 하면 다음 계정으로 접근할 수 있다.

```text
Username
admin

Password
change-this-password
```

---

## 계정 정보를 코드에 직접 넣지 않기

위 코드는 학습을 위한 간단한 예제다.

운영 환경에서 다음과 같은 코드를 작성하면 안 된다.

```java
.password(
    passwordEncoder.encode("1234")
)
```

Credential은 외부 환경으로 분리하는 것이 좋다.

```yaml
eureka:
  security:
    username: ${EUREKA_USERNAME}
    password: ${EUREKA_PASSWORD}
```

환경 변수는 다음과 같이 제공한다.

```text
EUREKA_USERNAME=eureka-client
EUREKA_PASSWORD=strong-password
```

Kubernetes, Docker 또는 Cloud 환경에서는 다음과 같은 Secret 저장소를 사용할 수 있다.

```text
Kubernetes Secret
AWS Secrets Manager
AWS Parameter Store
HashiCorp Vault
Azure Key Vault
CI/CD Secret
```

---

## Eureka Server Security 전체 예시

```java
package com.example.eureka.security;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public UserDetailsService userDetailsService(
            PasswordEncoder passwordEncoder,
            @Value("${eureka.security.username}")
            String username,
            @Value("${eureka.security.password}")
            String password
    ) {

        UserDetails user = User.builder()
                .username(username)
                .password(
                        passwordEncoder.encode(password)
                )
                .roles("EUREKA")
                .build();

        return new InMemoryUserDetailsManager(user);
    }

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http
    ) throws Exception {

        http
                .csrf(csrf -> csrf
                        .ignoringRequestMatchers("/eureka/**")
                )
                .authorizeHttpRequests(auth -> auth
                        .anyRequest().authenticated()
                )
                .httpBasic(Customizer.withDefaults());

        return http.build();
    }
}
```

설정 파일은 다음과 같이 작성한다.

```yaml
eureka:
  security:
    username: ${EUREKA_USERNAME}
    password: ${EUREKA_PASSWORD}
```

---

## HTTP Basic 인증 테스트

Eureka Server가 실행된 후 HTTP Basic 인증을 테스트할 수 있다.

```bash
curl \
  -u admin:change-this-password \
  http://localhost:8761
```

인증에 성공하면 Eureka Server의 응답을 받을 수 있다.

인증 정보가 잘못되면 다음 상태 코드가 반환될 수 있다.

```text
401 Unauthorized
```

---

## Eureka Client는 어떻게 등록될까?

다음 단계에서 Order Service를 Eureka에 등록한다고 가정해보자.

Order Service에는 Eureka Client 의존성을 추가한다.

```gradle
dependencies {
    implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-client'
}
```

Spring Cloud Netflix 공식 문서에서도 Client Starter로 `spring-cloud-starter-netflix-eureka-client`를 제공한다.

설정은 다음과 같이 구성할 수 있다.

```yaml
spring:
  application:
    name: order-service

server:
  port: 8081

eureka:
  client:
    service-url:
      defaultZone: http://admin:change-this-password@localhost:8761/eureka/
```

실행되면 Order Service가 Eureka에 등록되고 Dashboard에서 확인할 수 있다.

---

## @EnableEurekaClient가 반드시 필요할까?

과거 Spring Cloud 예제에서는 다음과 같은 어노테이션을 자주 사용했다.

```java
@EnableEurekaClient
```

또는 다음을 사용하기도 했다.

```java
@EnableDiscoveryClient
```

하지만 현재 Spring Cloud에서는 Discovery Client 구현이 Classpath에 존재하면 애플리케이션을 자동으로 Service Registry에 등록할 수 있으며 `@EnableDiscoveryClient`가 필수는 아니다.

따라서 현대적인 구성에서는 다음 의존성을 추가하고:

```gradle
implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-client'
```

필요한 Eureka 설정을 작성하면 된다.

이 부분은 오래된 Spring Cloud 자료를 볼 때 특히 주의해야 한다.

---

## Eureka Server에 등록되는 정보

Client가 등록되면 Eureka Server는 해당 Instance 정보를 관리한다.

대표적으로 다음 정보가 포함된다.

```text
Application Name
Instance ID
Host
IP
Port
Status
Metadata
```

예를 들어 다음과 같은 상태가 될 수 있다.

```text
ORDER-SERVICE

order-service:8081
UP
10.0.1.10

order-service:8082
UP
10.0.1.11
```

Gateway와 다른 서비스는 `ORDER-SERVICE`라는 논리적인 이름을 기준으로 서비스를 탐색할 수 있다.

---

## Eureka와 Load Balancer

Eureka 자체가 요청을 실제 서비스로 전달하는 API Gateway는 아니다.

Eureka는 사용 가능한 서비스 목록을 제공한다.

```text
Eureka
→ 어디에 서비스가 있는가?
```

Load Balancer는 그 목록에서 실제 요청 대상 하나를 선택한다.

```text
Load Balancer
→ 어느 Instance에 요청할 것인가?
```

Gateway는 최종적으로 선택된 Instance에 요청을 전달한다.

```mermaid
flowchart LR
    A[Client] --> B[Gateway]
    B --> C[Eureka]
    C --> B
    B --> D[Load Balancer]

    D --> E[Order 1]
    D --> F[Order 2]
    D --> G[Order 3]
```

이를 역할별로 정리하면 다음과 같다.

| 구성 요소                     | 역할               |
| ------------------------- | ---------------- |
| Eureka                    | Service Registry |
| Spring Cloud LoadBalancer | Instance 선택      |
| Spring Cloud Gateway      | 요청 라우팅           |
| Config Server             | 외부 설정 제공         |

---

## Eureka Client Heartbeat

서비스가 한 번 등록되었다고 해서 Eureka Server가 영원히 해당 서비스를 정상 상태로 판단하는 것은 아니다.

Client는 Eureka Server와 주기적으로 통신하면서 자신의 상태를 갱신한다.

```text
Client 등록
→ Heartbeat
→ Heartbeat
→ Heartbeat
```

Eureka Server는 이러한 정보를 기반으로 Registry를 관리한다.

Client가 장시간 상태를 갱신하지 못하면 해당 Instance가 더 이상 정상적으로 서비스할 수 없는 것으로 판단될 수 있다.

따라서 Eureka는 단순히 시작할 때 한 번 IP를 저장하는 정적인 저장소가 아니다.

---

## Eureka Client의 Registry 갱신

Eureka Client는 Eureka Server의 Registry 정보를 주기적으로 가져올 수 있다.

현재 Spring Cloud Netflix 설정 속성에는 Registry Fetch Interval의 기본값이 30초로 정의되어 있다.

```text
Gateway
→ Eureka Registry 조회

일정 시간이 지나면
→ Registry 갱신
```

따라서 새로운 Instance가 등록되었다고 해서 시스템 전체에 같은 순간 즉시 반영된다고 단순화해서 생각해서는 안 된다.

등록, Heartbeat, Registry Fetch, Load Balancer Cache 등의 요소를 함께 이해해야 한다.

---

## Eureka Server 고가용성

Eureka Server 하나만 운영한다면 Eureka 자체가 Single Point of Failure가 될 수 있다.

```text
Eureka Server 장애
→ 새로운 Service Discovery에 문제 발생
```

따라서 실제 운영 환경에서는 Eureka Server를 여러 개 구성할 수 있다.

```mermaid
flowchart TD
    A[Eureka Server 1] <--> B[Eureka Server 2]
    B <--> C[Eureka Server 3]
    C <--> A

    D[User Service] --> A
    E[Order Service] --> B
    F[Payment Service] --> C
```

Spring Cloud Netflix 공식 문서에서도 Eureka Server를 고가용성으로 배포할 수 있고 Server들 사이에서 등록 상태를 복제할 수 있다고 설명한다.

이 경우 앞서 단일 서버에서 사용했던 다음 설정을 그대로 사용하는 구조와는 차이가 있다.

```yaml
register-with-eureka: false
fetch-registry: false
```

고가용성 Eureka에서는 Peer Eureka Server와 Registry를 공유하는 구성을 별도로 설계해야 한다.

---

## Eureka Server 장애가 나면 모든 서비스가 즉시 중단될까?

반드시 그렇지는 않다.

Eureka Client와 Gateway는 이미 받아둔 Registry 정보를 일정 기간 활용할 수 있기 때문이다.

따라서 Eureka Server가 잠시 중단되었다고 해서 기존의 모든 서비스 간 호출이 즉시 동시에 중단되는 구조로 단순화할 수는 없다.

하지만 다음 문제가 발생할 수 있다.

```text
신규 Instance 등록 실패
신규 Instance 탐색 실패
오래된 Registry 정보 사용
장애 Instance 제거 반영 지연
```

따라서 Eureka Server 역시 중요한 인프라 구성 요소로 관리해야 한다.

---

## Eureka Server 모니터링

Eureka Server 자체도 모니터링 대상이다.

확인하면 좋은 항목은 다음과 같다.

```text
등록된 서비스 수
Instance 상태
Heap Memory
GC
CPU
응답 시간
등록 실패
Heartbeat 실패
Registry 조회 실패
```

Spring Boot Actuator를 추가할 수 있다.

```gradle
implementation 'org.springframework.boot:spring-boot-starter-actuator'
```

설정을 추가한다.

```yaml
management:
  endpoints:
    web:
      exposure:
        include:
          - health
          - info
          - metrics
```

Health를 확인한다.

```bash
curl http://localhost:8761/actuator/health
```

응답 예시는 다음과 같다.

```json
{
  "status": "UP"
}
```

운영 환경에서는 Health Endpoint의 인증·인가 정책도 함께 설계해야 한다.

---

## Eureka와 Kubernetes

Eureka는 Spring Cloud 기반 MSA에서 매우 유용한 Service Discovery 방식이지만 모든 MSA 환경에서 반드시 필요한 것은 아니다.

특히 Kubernetes는 자체적으로 다음 기능을 제공한다.

```text
Service
DNS
Endpoint 관리
Pod Discovery
Load Balancing
```

예를 들어 Kubernetes에서는 다음 이름으로 Order Service를 찾을 수 있다.

```text
order-service
```

내부적으로는 Kubernetes DNS가 해당 Service를 찾아준다.

```text
order-service.default.svc.cluster.local
```

따라서 구조는 환경에 따라 달라질 수 있다.

```text
VM / EC2 기반 Spring Cloud MSA
→ Eureka 활용 가능

Kubernetes 기반 MSA
→ Kubernetes Service Discovery 활용 가능
```

Spring Cloud 자체도 Eureka 외에 다양한 `DiscoveryClient` 구현을 지원한다.

따라서 Eureka를 MSA의 필수 구성 요소라기보다 **Service Discovery를 구현하는 하나의 선택지**로 이해하는 것이 정확하다.

---

## Eureka를 사용하는 구조가 적합한 경우

다음과 같은 환경에서 활용을 검토할 수 있다.

```text
Spring Boot 중심 MSA
VM 또는 EC2 기반 배포
컨테이너를 직접 관리하는 환경
Spring Cloud Gateway 사용
동적 서비스 인스턴스 관리 필요
Spring Cloud 생태계를 적극 활용
```

반대로 Kubernetes 자체 Service Discovery를 이미 충분히 활용하고 있다면 별도의 Eureka 운영이 중복이 될 수 있다.

---

## Eureka Server 전체 구성

최소 Eureka Server 구조를 정리하면 다음과 같다.

### build.gradle

```gradle
dependencies {
    implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-server'

    implementation 'org.springframework.boot:spring-boot-starter-security'

    implementation 'org.springframework.boot:spring-boot-starter-actuator'
}
```

### EurekaServerApplication.java

```java
package com.example.eureka;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

@EnableEurekaServer
@SpringBootApplication
public class EurekaServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(
                EurekaServerApplication.class,
                args
        );
    }
}
```

### application.yml

```yaml
server:
  port: 8761

spring:
  application:
    name: eureka-server

eureka:
  client:
    register-with-eureka: false
    fetch-registry: false

management:
  endpoints:
    web:
      exposure:
        include:
          - health
          - info
```

이 구성만으로 기본적인 단일 Eureka Server를 실행할 수 있다.

---

## 전체 동작 과정

```mermaid
sequenceDiagram
    participant O1 as Order Service 1
    participant O2 as Order Service 2
    participant E as Eureka Server
    participant G as Gateway
    participant C as Client

    O1->>E: ORDER-SERVICE 등록
    O2->>E: ORDER-SERVICE 등록

    O1->>E: Heartbeat
    O2->>E: Heartbeat

    C->>G: GET /orders/100
    G->>E: ORDER-SERVICE Instance 조회
    E-->>G: Instance 목록
    G->>O1: 요청 전달
    O1-->>G: 주문 응답
    G-->>C: 응답
```

핵심은 Gateway가 특정 IP를 하드코딩하지 않아도 된다는 것이다.

```text
잘못된 방향

Gateway
→ 10.0.1.10:8080
```

서비스 이름을 중심으로 구성할 수 있다.

```text
Gateway
→ ORDER-SERVICE
→ Service Discovery
→ 실제 Instance
```

---

## 구축 순서 정리

Eureka Server를 구축하는 과정은 다음과 같다.

```text
1. Spring Boot 프로젝트 생성

2. Eureka Server 의존성 추가

3. Spring Cloud BOM 구성

4. @EnableEurekaServer 추가

5. server.port 설정

6. register-with-eureka=false 설정

7. fetch-registry=false 설정

8. 애플리케이션 실행

9. Eureka Dashboard 접속

10. 필요 시 Spring Security 적용

11. Eureka Client 등록

12. Gateway와 Service Discovery 연동
```

---

## 자주 발생하는 오류

### Eureka Dashboard에 접근할 수 없는 경우

다음 항목을 확인한다.

```text
Eureka Server 실행 여부
server.port
Spring Security
Firewall
Docker Port
AWS Security Group
```

---

### 서버 실행 시 Eureka 자신에게 연결을 시도하는 경우

단일 Eureka Server라면 다음 설정을 확인한다.

```yaml
eureka:
  client:
    register-with-eureka: false
    fetch-registry: false
```

설정을 하지 않으면 Eureka Server 애플리케이션도 Eureka Client 구성의 영향을 받아 Registry 등록이나 조회를 시도할 수 있다.

---

### Client가 Dashboard에 나타나지 않는 경우

다음 항목을 확인한다.

```text
Eureka Client 의존성
spring.application.name
defaultZone
Eureka Server 주소
인증 정보
네트워크
Client 실행 상태
```

Client 설정 예시는 다음과 같다.

```yaml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

---

### 401 Unauthorized가 발생하는 경우

Spring Security를 적용했다면 Client에도 인증 정보가 필요하다.

```yaml
eureka:
  client:
    service-url:
      defaultZone: http://${EUREKA_USERNAME}:${EUREKA_PASSWORD}@localhost:8761/eureka/
```

Credential은 소스 코드에 직접 저장하지 않고 외부에서 주입하는 것이 좋다.

---

### Client는 등록되었지만 호출되지 않는 경우

Eureka 등록 자체와 실제 Load Balancing은 별개의 문제다.

```text
Eureka
→ Service Discovery

LoadBalancer
→ Instance 선택

Gateway
→ Routing
```

따라서 Gateway와 Spring Cloud LoadBalancer 설정도 함께 확인해야 한다.

---

## 실무에서 기억해야 하는 핵심

Eureka를 단순히 다음처럼 이해하면 부족하다.

```text
Eureka
= 서비스가 살아있는지 보여주는 Dashboard
```

더 정확한 이해는 다음과 같다.

```text
Eureka
= Service Registry
```

즉 Eureka Server는 다음 데이터를 관리한다.

```text
현재 어떤 서비스가 있는가?
각 서비스는 어디에서 실행되고 있는가?
사용 가능한 Instance가 몇 개인가?
어떤 Instance가 Registry에 등록되어 있는가?
```

그리고 Gateway나 다른 서비스가 해당 Registry 정보를 이용할 수 있도록 한다.

---

## Config Server와 Eureka Server 비교

이전까지 구성한 Config Server와 Eureka Server는 서로 완전히 다른 문제를 해결한다.

| 구분     | Config Server  | Eureka Server          |
| ------ | -------------- | ---------------------- |
| 핵심 목적  | 설정 관리          | 서비스 탐색                 |
| 관리 대상  | 환경 설정          | Service Instance       |
| 저장 정보  | URL, Timeout 등 | IP, Port, Service Name |
| Client | Config Client  | Eureka Client          |
| 중앙 역할  | 설정 제공          | Service Registry       |

두 시스템을 함께 사용하면 다음과 같은 구조가 된다.

```mermaid
flowchart TD
    A[Config Repository] --> B[Config Server]

    B --> C[Order Service]
    B --> D[Payment Service]

    C --> E[Eureka Server]
    D --> E

    F[Gateway] --> E

    F --> C
    F --> D
```

Config Server는 **서비스가 어떤 설정으로 실행될 것인가**를 관리한다.

Eureka Server는 **실행된 서비스가 어디에 존재하는가**를 관리한다.

이 차이를 이해하면 Spring Cloud MSA의 구조가 훨씬 명확해진다.

---

## 정리

Eureka Server는 Spring Cloud 기반 MSA에서 Service Discovery를 구현하기 위해 사용할 수 있는 Service Registry다.

각 Eureka Client는 실행될 때 자신의 정보를 Eureka Server에 등록하고, Eureka Server는 등록된 서비스의 위치 정보를 관리한다.

```text
Eureka Client
→ 서비스 등록

Eureka Server
→ Registry 관리

Gateway / 다른 Service
→ Registry 조회

Load Balancer
→ Instance 선택
```

기본적인 Eureka Server 구성에는 다음 요소가 필요하다.

```text
spring-cloud-starter-netflix-eureka-server
@EnableEurekaServer
server.port=8761
register-with-eureka=false
fetch-registry=false
```

단일 Eureka Server에서는 자신의 정보를 등록하거나 다른 Registry 정보를 가져올 필요가 없기 때문에 `register-with-eureka`와 `fetch-registry`를 `false`로 구성할 수 있다.

Eureka Dashboard를 통해 등록된 Instance를 확인할 수 있지만 Eureka를 전문 모니터링 시스템으로 이해해서는 안 된다. Eureka의 핵심 목적은 **Service Registration과 Service Discovery**다.

또한 운영 환경에서는 Eureka Server 자체의 보안, 고가용성, 모니터링을 함께 설계해야 한다.

마지막으로 Kubernetes처럼 자체적인 Service Discovery를 제공하는 플랫폼을 사용한다면 Eureka가 반드시 필요한 것은 아니다. 사용하는 인프라와 배포 환경을 기준으로 Service Discovery 방식을 선택하는 것이 중요하다.

### 한 줄 요약

Eureka Server는 동적으로 생성되고 사라지는 마이크로서비스의 이름과 위치를 중앙 Registry에 관리하여 Gateway와 다른 서비스가 IP를 직접 알지 않고도 필요한 Service Instance를 찾을 수 있게 해주는 Service Discovery 서버다.
