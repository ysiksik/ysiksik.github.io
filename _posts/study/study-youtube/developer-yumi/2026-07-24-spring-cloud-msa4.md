---
layout: post
bigtitle: '스프링 클라우드 MSA'
subtitle: 스프링 클라우드 MSA 4 - Config 서버 구축
date: '2026-07-24 00:00:04 +0900'
categories:
    - developer-yumi
comments: true

---

# 스프링 클라우드 MSA 4 - Config 서버 구축
[https://youtu.be/qeQPBImEGec?si=Gw4awzhP6AEKUjcA](https://youtu.be/qeQPBImEGec?si=Gw4awzhP6AEKUjcA)

# 스프링 클라우드 MSA 4 - Config 서버 구축
* toc
{:toc}

---

## Spring Cloud Config Server 구축과 중앙 설정 관리

마이크로서비스 아키텍처에서는 회원, 주문, 결제, 배송, 알림과 같은 여러 애플리케이션이 독립적으로 실행된다.

서비스가 늘어나면 각 애플리케이션의 설정도 함께 증가한다.

```text
데이터베이스 주소
외부 API 주소
메시지 브로커 주소
로그 레벨
Timeout
Retry 횟수
Feature Flag
서비스별 Port
```

각 서비스가 자신의 프로젝트 내부에서 설정을 개별적으로 관리하면 동일한 값을 반복해서 수정해야 하고, 환경별 설정이 서로 달라지는 문제도 발생할 수 있다.

Spring Cloud Config Server는 이러한 설정 정보를 중앙에서 조회하고 각 마이크로서비스에 제공하는 역할을 한다.

전체 구조는 다음과 같다.

```mermaid
flowchart LR
    A[Git Config Repository] --> B[Spring Cloud Config Server]

    B --> C[User Service]
    B --> D[Order Service]
    B --> E[Payment Service]
    B --> F[Notification Service]
```

핵심은 다음과 같다.

> Spring Cloud Config Server는 Git과 같은 외부 저장소에서 설정 파일을 읽어 Config Client에 제공하는 설정 중계 서버다.

---

## Spring Cloud Config의 구성 요소

Spring Cloud Config는 크게 세 가지 요소로 구성된다.

```text
Config Repository
Config Server
Config Client
```

각 구성 요소의 역할은 다음과 같다.

| 구성 요소             | 역할                                   |
| ----------------- | ------------------------------------ |
| Config Repository | 실제 설정 파일 저장                          |
| Config Server     | 저장소에서 설정을 읽어 API로 제공                 |
| Config Client     | Config Server에서 설정을 조회하여 사용하는 애플리케이션 |

설정 조회 흐름은 다음과 같다.

```mermaid
sequenceDiagram
    participant C as Config Client
    participant S as Config Server
    participant G as Git Repository

    C->>S: 애플리케이션 설정 요청
    S->>G: 설정 파일 조회
    G-->>S: 설정 파일 반환
    S-->>C: 병합된 설정 반환
```

Config Server 자체가 모든 설정값을 직접 소유하는 것은 아니다.

일반적으로 실제 설정은 Git Repository에 저장하고 Config Server는 해당 저장소를 읽어 전달하는 매개체 역할을 한다.

---

## Config Server가 필요한 이유

## 설정을 중앙에서 관리할 수 있다

서비스가 많아질수록 설정 파일도 여러 프로젝트에 분산된다.

```text
user-service/application.yml
order-service/application.yml
payment-service/application.yml
delivery-service/application.yml
```

공통 설정이 변경되면 여러 저장소를 각각 수정해야 한다.

Config Repository를 사용하면 다음과 같이 한곳에서 관리할 수 있다.

```text
config-repository
├── application.yml
├── application-dev.yml
├── user-service-dev.yml
├── order-service-dev.yml
└── payment-service-dev.yml
```

---

## 변경 이력을 추적할 수 있다

Git Repository를 사용하면 설정 변경 내역이 Commit으로 기록된다.

```text
누가 변경했는가?
언제 변경했는가?
어떤 값을 변경했는가?
왜 변경했는가?
```

문제가 발생하면 이전 Commit으로 설정을 되돌릴 수도 있다.

```bash
git log
```

이 명령은 설정 저장소의 Commit 이력을 확인한다.

실행 결과 예시는 다음과 같다.

```text
commit 83e17e2
Author: backend-developer
Date: 2026-07-24

    Increase payment API timeout
```

특정 변경을 되돌릴 때는 다음 명령을 사용할 수 있다.

```bash
git revert 83e17e2
```

기존 이력을 삭제하지 않고 해당 변경을 취소하는 새로운 Commit을 만든다.

---

## 환경별 설정을 분리할 수 있다

개발, 테스트, 스테이징, 운영 환경은 서로 다른 설정을 사용한다.

```text
dev
test
stage
prod
```

Config Repository에서는 Profile에 따라 설정 파일을 나눌 수 있다.

```text
application-dev.yml
application-stage.yml
application-prod.yml

order-service-dev.yml
order-service-stage.yml
order-service-prod.yml
```

이를 통해 하나의 Config Server가 여러 환경의 설정을 제공할 수 있다.

---

## 설정 변경이 즉시 자동 반영되는가?

Config Repository의 파일을 수정하면 Config Server가 다음 요청에서 변경된 값을 읽을 수 있다.

하지만 이것이 실행 중인 모든 Config Client에 자동으로 즉시 반영된다는 뜻은 아니다.

기본 흐름은 다음과 같다.

```text
Config Repository 변경
→ Config Server가 새 설정 조회 가능
→ 실행 중인 Client 설정은 기존 값 유지
```

실행 중인 Client에 설정을 반영하려면 다음 방식 중 하나가 필요하다.

```text
애플리케이션 재시작
Actuator refresh
Spring Cloud Bus
Rolling Deployment
플랫폼 기반 재배포
```

따라서 다음 두 개념을 구분해야 한다.

```text
Config Server의 설정 조회 결과 갱신
≠
실행 중인 Config Client Bean의 자동 갱신
```

---

## Config Server 프로젝트 생성

Spring Initializr를 이용해 새로운 Spring Boot 프로젝트를 생성한다.

기본 설정 예시는 다음과 같다.

```text
Language: Java
Build Tool: Gradle
Packaging: Jar
Java: 17 이상
```

Spring Boot 3 이상에서는 Java 17 이상이 필요하다.

Config Server에 필요한 핵심 의존성은 다음과 같다.

```text
Config Server
Spring Security
Actuator
```

---

## Gradle 의존성 설정

### build.gradle

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
    implementation 'org.springframework.cloud:spring-cloud-config-server'

    implementation 'org.springframework.boot:spring-boot-starter-security'

    implementation 'org.springframework.boot:spring-boot-starter-actuator'

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

Spring Cloud는 Spring Boot와 호환되는 Release Train을 사용해야 한다.

임의로 최신 버전만 선택하면 의존성 충돌이나 애플리케이션 시작 오류가 발생할 수 있다.

---

## @EnableConfigServer 적용하기

Config Server 기능을 활성화하려면 메인 클래스에 `@EnableConfigServer`를 선언한다.

```java
package com.example.configserver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.config.server.EnableConfigServer;

@EnableConfigServer
@SpringBootApplication
public class ConfigServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(
                ConfigServerApplication.class,
                args
        );
    }
}
```

각 어노테이션의 역할은 다음과 같다.

| 어노테이션                    | 역할                    |
| ------------------------ | --------------------- |
| `@SpringBootApplication` | Spring Boot 애플리케이션 설정 |
| `@EnableConfigServer`    | Config Server 기능 활성화  |

`@EnableConfigServer`가 빠지면 일반적인 Spring Boot 애플리케이션으로만 실행되고 Config Repository 조회 API가 활성화되지 않는다.

---

## Config Repository 주소 준비

Private GitHub Repository를 사용하는 경우 SSH 주소를 사용할 수 있다.

GitHub Repository에서 다음 메뉴를 통해 확인한다.

```text
Repository
→ Code
→ SSH
```

주소 형식은 다음과 같다.

```text
git@github.com:organization/spring-cloud-config-repo.git
```

HTTPS 주소와 SSH 주소는 인증 방식이 다르다.

```text
HTTPS
→ Token 또는 사용자 인증

SSH
→ Public Key와 Private Key 인증
```

---

## SSH 키 구성 원리

Private Repository에 접근하기 위해 비대칭키를 사용할 수 있다.

```text
Public Key
→ GitHub Deploy Key로 등록

Private Key
→ Config Server에서 보관
```

Config Server가 Private Key를 이용해 GitHub에 접근하면 GitHub는 등록된 Public Key와 대응하는 키인지 검증한다.

전체 구조는 다음과 같다.

```mermaid
flowchart LR
    A[Config Server] --> B[SSH Private Key]
    B --> C[GitHub SSH 인증]
    D[GitHub Deploy Key Public Key] --> C
    C --> E[Private Config Repository]
```

Private Key는 절대 외부에 공개하면 안 된다.

---

## SSH Key 생성하기

macOS, Linux 또는 Windows Git Bash에서 다음 명령어를 사용할 수 있다.

```bash
ssh-keygen -t ed25519 -C "spring-cloud-config-server"
```

옵션의 의미는 다음과 같다.

| 옵션           | 설명              |
| ------------ | --------------- |
| `-t ed25519` | ED25519 알고리즘 사용 |
| `-C`         | 키를 구분하기 위한 설명   |

키 경로를 다음과 같이 지정할 수 있다.

```text
~/.ssh/spring_cloud_config
```

생성되는 파일은 다음과 같다.

```text
spring_cloud_config
spring_cloud_config.pub
```

각 파일의 의미는 다음과 같다.

```text
spring_cloud_config
→ Private Key

spring_cloud_config.pub
→ Public Key
```

---

## Public Key를 GitHub에 등록하기

Public Key를 확인한다.

```bash
cat ~/.ssh/spring_cloud_config.pub
```

실행 결과는 다음과 비슷하다.

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... spring-cloud-config-server
```

GitHub Repository에서 다음 경로로 이동한다.

```text
Settings
→ Deploy keys
→ Add deploy key
```

다음 정보를 입력한다.

```text
Title
→ spring-cloud-config-server

Key
→ Public Key 전체 내용
```

Config Server는 설정을 읽기만 하면 되므로 일반적으로 다음 옵션은 활성화하지 않는다.

```text
Allow write access
```

읽기 전용으로 제한하면 키가 유출되었을 때 피해 범위를 줄일 수 있다.

---

## application.yml 기본 설정

Config Server 설정은 `src/main/resources/application.yml`에 작성한다.

```yaml
server:
  port: 9000

spring:
  application:
    name: config-server

  cloud:
    config:
      server:
        git:
          uri: git@github.com:organization/spring-cloud-config-repo.git
          default-label: main
          clone-on-start: true
```

설정의 의미는 다음과 같다.

| 설정                        | 의미                     |
| ------------------------- | ---------------------- |
| `server.port`             | Config Server 실행 포트    |
| `spring.application.name` | 애플리케이션 이름              |
| `uri`                     | Config Repository 주소   |
| `default-label`           | 기본 Git Branch          |
| `clone-on-start`          | 시작할 때 Repository Clone |

Config Server의 기본 포트가 반드시 `9000`인 것은 아니다.

실무와 예제에서 `8888`을 자주 사용하지만 원하는 포트로 설정할 수 있다.

---

## Repository 내부 경로 지정

설정 파일이 Repository 루트가 아니라 특정 디렉터리에 있다면 `search-paths`를 사용한다.

Repository 구조가 다음과 같다고 가정한다.

```text
spring-cloud-config-repo
├── common
│   ├── application.yml
│   └── application-dev.yml
│
└── services
    ├── order-service-dev.yml
    └── payment-service-dev.yml
```

Config Server 설정은 다음과 같다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: git@github.com:organization/spring-cloud-config-repo.git
          default-label: main
          search-paths:
            - common
            - services
```

`search-paths`를 지정하지 않으면 Repository의 기본 경로를 기준으로 설정 파일을 탐색한다.

---

## Private Key를 설정 파일에 직접 넣는 방식

기술적으로는 Config Server의 설정에 Private Key를 넣을 수 있다.

YAML에서는 여러 줄 문자열을 `|` 문법으로 표현할 수 있다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: git@github.com:organization/spring-cloud-config-repo.git
          ignore-local-ssh-settings: true
          strict-host-key-checking: false
          private-key: |
            -----BEGIN OPENSSH PRIVATE KEY-----
            PRIVATE_KEY_CONTENT
            -----END OPENSSH PRIVATE KEY-----
```

하지만 실제 Private Key를 프로젝트 내부 `application.yml`에 직접 저장하고 Git에 Commit하면 안 된다.

다음과 같은 방식이 더 안전하다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          private-key: ${CONFIG_GIT_PRIVATE_KEY}
```

환경 변수나 Secret Store에서 값을 주입한다.

---

## application.properties에서 여러 줄 키 사용하기

`application.properties`에 Private Key를 작성할 경우 개행을 `\n`으로 표현해야 할 수 있다.

```properties
spring.cloud.config.server.git.private-key=-----BEGIN OPENSSH PRIVATE KEY-----\nPRIVATE_KEY_CONTENT\n-----END OPENSSH PRIVATE KEY-----
```

하지만 가독성과 보안 측면에서 긴 Private Key를 Properties 파일에 직접 넣는 것은 권장하지 않는다.

다음 방법을 우선 고려하는 것이 좋다.

```text
환경 변수
Secret File Mount
Kubernetes Secret
AWS Secrets Manager
Vault
Azure Key Vault
```

---

## Private Key 파일을 외부에서 주입하기

운영 환경에서는 Secret을 파일로 마운트할 수 있다.

예를 들어 다음 경로로 Private Key를 제공한다.

```text
/run/secrets/config_git_private_key
```

애플리케이션 시작 시 파일을 읽어 환경 변수 또는 설정 객체에 주입할 수 있다.

Kubernetes에서는 Secret Volume을 사용할 수 있다.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: config-git-ssh-key
type: Opaque
stringData:
  id_ed25519: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    PRIVATE_KEY_CONTENT
    -----END OPENSSH PRIVATE KEY-----
```

Deployment에서는 Secret을 마운트한다.

```yaml
volumeMounts:
  - name: config-git-key
    mountPath: /etc/config-server/ssh
    readOnly: true

volumes:
  - name: config-git-key
    secret:
      secretName: config-git-ssh-key
```

---

## SSH Host Key 검증

SSH 연결에서는 서버가 실제 GitHub인지 검증해야 한다.

다음 설정은 편리하지만 운영 환경에서는 주의해야 한다.

```yaml
strict-host-key-checking: false
```

Host Key 검증을 비활성화하면 중간자 공격에 취약해질 수 있다.

운영 환경에서는 GitHub의 공식 Host Key를 검증하고 `known_hosts`를 올바르게 구성하는 것이 좋다.

```text
GitHub SSH Host Key 확인
→ known_hosts 등록
→ Strict Host Key Checking 활성화
```

실습 환경에서 검증을 비활성화하더라도 운영 배포 전에 반드시 보안 설정을 보완해야 한다.

---

## Config Repository 연결 설정 전체 예시

```yaml
server:
  port: 9000

spring:
  application:
    name: config-server

  cloud:
    config:
      server:
        git:
          uri: git@github.com:organization/spring-cloud-config-repo.git
          default-label: main
          clone-on-start: true
          search-paths:
            - common
            - services
          ignore-local-ssh-settings: true
          strict-host-key-checking: false
          private-key: ${CONFIG_GIT_PRIVATE_KEY}

management:
  endpoints:
    web:
      exposure:
        include:
          - health
          - info
```

운영 환경에서는 `strict-host-key-checking`을 활성화하는 것이 권장된다.

---

## Config Server 보안이 필요한 이유

Config Server는 다음과 같은 민감한 설정을 제공할 수 있다.

```text
내부 API 주소
Database Username
메시지 브로커 주소
인프라 구성 정보
Feature Flag
서비스별 운영 설정
```

인증 없이 Config Server가 외부에 노출되면 공격자가 시스템 구조와 설정 정보를 조회할 수 있다.

따라서 다음 보안 요소가 필요하다.

```text
HTTPS
인증
인가
네트워크 접근 제어
Secret 외부화
감사 로그
```

---

## Spring Security 의존성

```gradle
implementation 'org.springframework.boot:spring-boot-starter-security'
```

Spring Security를 추가하면 기본적으로 모든 요청에 인증이 적용된다.

실무에서는 명시적인 `SecurityFilterChain`을 작성해 접근 정책을 관리하는 것이 좋다.

---

## SecurityFilterChain 설정

```java
package com.example.configserver.security;

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
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers(
                                "/actuator/health",
                                "/actuator/info"
                        ).permitAll()
                        .anyRequest().authenticated()
                )
                .httpBasic(Customizer.withDefaults());

        return http.build();
    }
}
```

설정의 의미는 다음과 같다.

```text
Health Check
→ 인증 없이 허용

설정 조회 API
→ 인증 필요

로그인 방식
→ HTTP Basic
```

---

## CSRF를 비활성화하는 이유

Config Server는 일반적으로 브라우저 폼 기반 애플리케이션이 아니라 서버 간 REST 요청을 처리한다.

```text
Config Client
→ Config Server
```

세션과 브라우저 Cookie를 기반으로 요청하지 않는다면 CSRF 보호를 비활성화할 수 있다.

```java
.csrf(csrf -> csrf.disable())
```

다만 Config Server에 관리용 웹 화면이나 Cookie 기반 인증을 추가한다면 보안 정책을 다시 검토해야 한다.

---

## 인메모리 사용자 등록

실습에서는 간단하게 인메모리 계정을 사용할 수 있다.

```java
package com.example.configserver.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;

@Configuration
public class ConfigServerUserConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public UserDetailsService userDetailsService(
            PasswordEncoder passwordEncoder
    ) {
        UserDetails configClient = User.builder()
                .username("config-client")
                .password(
                        passwordEncoder.encode("change-this-password")
                )
                .roles("CONFIG_CLIENT")
                .build();

        return new InMemoryUserDetailsManager(configClient);
    }
}
```

운영 환경에서는 다음과 같은 단순 비밀번호를 사용하면 안 된다.

```text
1234
admin
password
```

계정 정보 역시 환경 변수나 Secret Store로 외부화해야 한다.

---

## 보안 계정을 설정 파일에서 주입하기

```yaml
config:
  security:
    username: ${CONFIG_SERVER_USERNAME}
    password: ${CONFIG_SERVER_PASSWORD}
```

설정 클래스를 작성할 수 있다.

```java
package com.example.configserver.security;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "config.security")
public record ConfigSecurityProperties(
        String username,
        String password
) {
}
```

사용자 설정은 다음과 같이 변경할 수 있다.

```java
package com.example.configserver.security;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;

@Configuration
@EnableConfigurationProperties(
        ConfigSecurityProperties.class
)
public class ConfigServerUserConfig {

    @Bean
    public UserDetailsService userDetailsService(
            ConfigSecurityProperties properties,
            PasswordEncoder passwordEncoder
    ) {
        return new InMemoryUserDetailsManager(
                User.builder()
                        .username(properties.username())
                        .password(
                                passwordEncoder.encode(
                                        properties.password()
                                )
                        )
                        .roles("CONFIG_CLIENT")
                        .build()
        );
    }
}
```

---

## Config Server의 설정 조회 URL

Config Server는 다음 형식으로 설정 정보를 제공한다.

```text
/{application}/{profile}
/{application}/{profile}/{label}
```

각 값의 의미는 다음과 같다.

| 항목            | 의미                |
| ------------- | ----------------- |
| `application` | 애플리케이션 이름         |
| `profile`     | 실행 환경             |
| `label`       | Git Branch 또는 Tag |

예를 들어 Repository에 다음 파일이 있다고 가정한다.

```text
ms1-dev.properties
```

Config Server에서는 다음 경로로 조회한다.

```text
/ms1/dev
```

Config Server가 `9000` 포트에서 실행 중이라면 전체 주소는 다음과 같다.

```text
http://localhost:9000/ms1/dev
```

---

## HTTP Basic 인증으로 설정 조회하기

Config Server에 보안이 적용되어 있다면 사용자 이름과 비밀번호가 필요하다.

```bash
curl \
  -u config-client:change-this-password \
  http://localhost:9000/ms1/dev
```

명령의 의미는 다음과 같다.

```text
-u
→ HTTP Basic 사용자 이름과 비밀번호 지정

/ms1/dev
→ ms1 애플리케이션의 dev Profile 조회
```

응답 예시는 다음과 같다.

```json
{
  "name": "ms1",
  "profiles": [
    "dev"
  ],
  "label": null,
  "version": "51cde4...",
  "propertySources": [
    {
      "name": "ms1-dev.properties",
      "source": {
        "server.port": "8081",
        "a.b": "bbb"
      }
    }
  ]
}
```

---

## 설정 원본 형식으로 조회하기

Config Server는 환경 정보를 JSON으로 반환할 수 있고 원본 파일과 비슷한 형태로도 제공할 수 있다.

YAML 형식 조회:

```bash
curl \
  -u config-client:change-this-password \
  http://localhost:9000/ms1-dev.yml
```

Properties 형식 조회:

```bash
curl \
  -u config-client:change-this-password \
  http://localhost:9000/ms1-dev.properties
```

실행 결과 예시는 다음과 같다.

```properties
server.port=8081
a.b=bbb
```

---

## 공통 설정과 서비스 설정 병합

Repository에 다음 파일이 있다고 가정한다.

```text
application.yml
application-dev.yml
ms1.yml
ms1-dev.yml
```

`ms1/dev`를 요청하면 관련 설정을 함께 조회해 병합한다.

```text
application.yml
→ 전체 서비스 공통 설정

application-dev.yml
→ dev 환경 공통 설정

ms1.yml
→ ms1 서비스 공통 설정

ms1-dev.yml
→ ms1 서비스의 dev 전용 설정
```

더 구체적인 설정이 공통 설정을 덮어쓸 수 있다.

---

## 설정 변경 확인

Repository에 다음 설정이 있다고 가정한다.

```properties
server.port=8080
a.b=aaa
```

이를 다음과 같이 변경한다.

```properties
server.port=8081
a.b=bbb
```

Commit과 Push를 수행한다.

```bash
git add ms1-dev.properties
git commit -m "Change ms1 development configuration"
git push origin main
```

Config Server 조회 API를 다시 호출한다.

```bash
curl \
  -u config-client:change-this-password \
  http://localhost:9000/ms1/dev
```

Config Server가 최신 Commit을 반영하면 변경된 값이 응답에 포함된다.

```json
{
  "server.port": "8081",
  "a.b": "bbb"
}
```

하지만 실행 중인 `ms1` 애플리케이션 내부의 Bean 값이 자동으로 바뀌는 것은 아니다.

---

## Config Client에서 설정을 갱신하는 방법

Config Client가 시작 시 설정을 가져오는 기본 구조는 다음과 같다.

```yaml
spring:
  application:
    name: ms1

  config:
    import: configserver:http://localhost:9000
```

인증 정보가 필요하다면 다음과 같이 설정할 수 있다.

```yaml
spring:
  config:
    import: configserver:http://config-client:change-this-password@localhost:9000
```

다만 URL에 비밀번호를 직접 포함하면 로그나 설정 파일에 노출될 수 있으므로 환경 변수로 분리하는 것이 좋다.

```yaml
spring:
  config:
    import: configserver:${CONFIG_SERVER_URL}

  cloud:
    config:
      username: ${CONFIG_SERVER_USERNAME}
      password: ${CONFIG_SERVER_PASSWORD}
```

---

## Actuator refresh 적용

Client에 Actuator와 Config Client 의존성을 추가한다.

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

변경 대상 Bean에 `@RefreshScope`를 적용한다.

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
            @Value("${a.b}")
            String message
    ) {
        this.message = message;
    }

    public String getMessage() {
        return message;
    }
}
```

Config Repository를 수정한 뒤 다음 요청을 호출한다.

```bash
curl -X POST http://localhost:8081/actuator/refresh
```

설정된 보안 정책에 따라 인증 정보가 필요할 수 있다.

이 요청은 변경된 설정 키 목록을 반환한다.

---

## Spring Cloud Bus 활용

서비스 인스턴스가 수십 개라면 각 인스턴스의 `/actuator/refresh`를 직접 호출하기 어렵다.

Spring Cloud Bus를 사용하면 메시지 브로커를 통해 갱신 이벤트를 여러 인스턴스에 전달할 수 있다.

```mermaid
flowchart LR
    A[Config Repository 변경] --> B[Refresh 요청]
    B --> C[Spring Cloud Bus]
    C --> D[User Service 1]
    C --> E[User Service 2]
    C --> F[Order Service 1]
    C --> G[Payment Service 1]
```

메시지 브로커로 다음 기술을 사용할 수 있다.

```text
RabbitMQ
Kafka
```

Spring Cloud Bus 역시 설정 변경을 완전히 자동으로 감지하는 기능과는 구분해야 한다.

Git 변경 이벤트를 자동화하려면 Webhook, CI/CD Pipeline 또는 별도의 배포 흐름을 구성해야 한다.

---

## Config Server가 시작되지 않을 때

### Repository 인증 오류

```text
Auth fail
Permission denied publickey
```

확인할 항목은 다음과 같다.

```text
Private Key와 Public Key가 한 쌍인지
Deploy Key가 올바른 Repository에 등록되었는지
Repository URI가 SSH 형식인지
Private Key 형식이 지원되는지
Key 파일 권한이 적절한지
```

---

### Repository를 찾을 수 없는 오류

```text
Repository not found
```

확인할 항목은 다음과 같다.

```text
Organization 이름
Repository 이름
대소문자
Repository 접근 권한
SSH 주소
```

---

### 기본 Branch 오류

Repository의 기본 Branch가 `main`인데 Config Server가 `master`를 조회하면 실패할 수 있다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          default-label: main
```

실제 Branch 이름과 일치시켜야 한다.

---

### Private Key Parsing 오류

```text
PrivateKeyIsValid
Invalid private key
```

사용하는 Spring Cloud Config와 JGit 버전이 해당 키 형식을 지원하는지 확인해야 한다.

환경에 따라 PEM 형식의 RSA 키가 필요할 수도 있다.

```bash
ssh-keygen \
  -t rsa \
  -b 4096 \
  -m PEM \
  -C "spring-cloud-config-server"
```

기존 키를 무조건 다시 만들기보다 현재 라이브러리와 키 형식의 호환성을 먼저 확인하는 것이 좋다.

---

### 설정 파일을 찾을 수 없는 경우

Config Server는 실행되지만 `propertySources`가 비어 있을 수 있다.

확인할 항목은 다음과 같다.

```text
application 이름
Profile 이름
파일명
파일 확장자
search-paths
Git Branch
Commit과 Push 여부
```

요청 경로가 다음과 같다면:

```text
/ms1/dev
```

파일 이름은 다음과 같은 규칙을 따라야 한다.

```text
ms1.yml
ms1-dev.yml
ms1.properties
ms1-dev.properties
```

---

## Config Server Health Check

Actuator를 통해 서버 상태를 확인할 수 있다.

```bash
curl http://localhost:9000/actuator/health
```

응답 예시는 다음과 같다.

```json
{
  "status": "UP"
}
```

Health Endpoint만 공개하고 설정 조회 API는 인증이 필요하도록 분리하는 것이 좋다.

---

## Config Server 모니터링

운영 환경에서는 다음 항목을 모니터링해야 한다.

```text
Config Server 응답 시간
설정 조회 실패율
Git Clone 또는 Pull 실패
인증 실패
Repository 연결 상태
JVM Memory
GC
Thread Pool
```

Config Server가 응답하지 않으면 신규 배포되는 Config Client가 시작하지 못할 수 있다.

따라서 단순한 보조 서버가 아니라 중요한 인프라 컴포넌트로 관리해야 한다.

---

## Config Server 고가용성

Config Server를 하나만 운영하면 단일 장애점이 될 수 있다.

```text
Config Server 장애
→ 신규 Client 시작 실패
→ 설정 조회 실패
```

운영 환경에서는 여러 Config Server 인스턴스를 구성할 수 있다.

```mermaid
flowchart LR
    A[Config Client] --> B[Load Balancer]
    B --> C[Config Server 1]
    B --> D[Config Server 2]
    B --> E[Config Server 3]

    C --> F[Git Repository]
    D --> F
    E --> F
```

고가용성 구성 시 고려할 사항은 다음과 같다.

```text
Config Server 다중 인스턴스
Load Balancer
Repository 접근 장애 대응
Health Check
Client Retry
마지막 정상 설정 활용
```

---

## Client의 Config Server 장애 대응

Config Client 설정에서 Config Server 연결이 실패했을 때 애플리케이션 시작을 중단할지 결정할 수 있다.

필수 설정이라면 Config Server 연결 실패 시 시작을 중단하는 것이 안전할 수 있다.

```yaml
spring:
  config:
    import: configserver:http://localhost:9000
```

Config Server가 선택 사항이라면 `optional:`을 사용할 수 있다.

```yaml
spring:
  config:
    import: optional:configserver:http://localhost:9000
```

차이는 다음과 같다.

| 방식                       | Config Server 장애 시 |
| ------------------------ | ------------------ |
| `configserver:`          | 애플리케이션 시작 실패 가능    |
| `optional:configserver:` | 외부 설정 없이 시작 가능     |

DB 주소나 인증 설정처럼 반드시 필요한 값이라면 무조건 `optional`로 처리하는 것이 적절하지 않을 수 있다.

---

## Config Server 보안 강화

실무에서는 HTTP Basic만으로 충분하지 않을 수 있다.

다음 보안 구성을 고려한다.

```text
HTTPS 적용
내부망 또는 Private Network 배치
API Gateway 외부 노출 차단
mTLS
OAuth2 또는 서비스 인증
Firewall
Security Group
NetworkPolicy
Secret 외부화
접근 감사 로그
```

Config Server는 일반 사용자가 브라우저로 접근하는 서버가 아니라 내부 서비스가 접근하는 인프라 서버로 운영하는 것이 좋다.

---

## 민감 정보 관리

Private Git Repository라도 다음 값을 평문으로 저장하는 것은 피해야 한다.

```text
Database Password
JWT Secret
OAuth Client Secret
Cloud Access Key
인증서 Private Key
외부 API Key
```

Config Repository는 접근 권한 오류, 개발자 PC 탈취, Clone 복사본, CI 로그 등을 통해 유출될 수 있다.

민감 정보는 다음 저장소를 사용할 수 있다.

```text
HashiCorp Vault
AWS Secrets Manager
AWS Parameter Store
Azure Key Vault
Google Secret Manager
Kubernetes Secret
```

Config Repository에는 환경 변수 참조만 작성할 수 있다.

```yaml
spring:
  datasource:
    password: ${ORDER_DB_PASSWORD}
```

---

## 설정 변경 시 주의사항

설정 변경은 코드 변경만큼 위험할 수 있다.

다음 값이 잘못 변경되면 즉시 장애가 발생할 수 있다.

```text
Database URL
Connection Pool
Timeout
Retry
Thread Pool
메시지 브로커 주소
Feature Flag
```

설정 변경에도 검토와 배포 절차가 필요하다.

```text
Branch 생성
→ 설정 변경
→ YAML 검증
→ Pull Request
→ 리뷰
→ Merge
→ Config Server 조회 확인
→ Client 반영
→ 모니터링
```

---

## 동적 갱신에 적합하지 않은 설정

모든 설정을 런타임 중 변경하는 것이 안전한 것은 아니다.

다음 설정은 재시작이 더 안전할 수 있다.

```text
server.port
Database Driver
Spring Bean 생성 구조
보안 Filter Chain 구조
Thread Pool 핵심 크기
메시지 Listener 구조
Repository 활성화 여부
```

반면 다음 설정은 동적 변경 후보가 될 수 있다.

```text
Feature Flag
일부 Timeout
화면 메시지
외부 API 활성 여부
일부 Retry 횟수
비즈니스 임계값
```

설정이 변경 가능한지 여부를 설계 단계에서 구분해야 한다.

---

## @RefreshScope 사용 시 주의사항

`@RefreshScope`가 붙은 Bean은 Refresh 시 다시 생성될 수 있다.

따라서 다음 사항을 주의해야 한다.

```text
무거운 초기화 작업
외부 연결 생성
공유 상태 보유
Thread 실행
리소스 정리
```

모든 Bean에 무분별하게 적용하지 말고 동적으로 바뀌어야 하는 설정을 사용하는 Bean에만 제한적으로 적용하는 것이 좋다.

단순 설정 묶음에는 `@ConfigurationProperties`를 활용할 수 있다.

```java
package com.example.ms1.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.stereotype.Component;

@RefreshScope
@Component
@ConfigurationProperties(prefix = "order.api")
public class OrderApiProperties {

    private int timeout;
    private int retryCount;

    public int getTimeout() {
        return timeout;
    }

    public void setTimeout(int timeout) {
        this.timeout = timeout;
    }

    public int getRetryCount() {
        return retryCount;
    }

    public void setRetryCount(int retryCount) {
        this.retryCount = retryCount;
    }
}
```

---

## Config Server 전체 동작 흐름

```mermaid
sequenceDiagram
    participant G as Git Repository
    participant S as Config Server
    participant C as Config Client
    participant A as Application Bean

    C->>S: ms1/dev 설정 요청
    S->>G: 관련 설정 파일 조회
    G-->>S: application.yml + ms1-dev.yml
    S-->>C: 병합 설정 반환
    C->>A: 설정값으로 Bean 생성

    G->>G: 설정 변경 및 Commit
    C->>C: Refresh 요청 수신
    C->>S: 최신 설정 재요청
    S->>G: 최신 설정 조회
    G-->>S: 변경된 설정 반환
    S-->>C: 새로운 설정 반환
    C->>A: RefreshScope Bean 재생성
```

---

## 구축 순서 정리

Spring Cloud Config Server 구축 순서는 다음과 같다.

```text
1. Config Repository 준비
2. Private Repository 접근용 SSH Key 준비
3. Public Key를 GitHub Deploy Key로 등록
4. Config Server 프로젝트 생성
5. Config Server 의존성 추가
6. @EnableConfigServer 적용
7. Git Repository URI 설정
8. Private Key 외부 주입
9. Spring Security 적용
10. Config Server 실행
11. /{application}/{profile} 경로 테스트
12. Client 연결과 Refresh 구성
```

---

## 실무에서 개선해야 할 부분

간단한 실습에서는 다음과 같이 구성할 수 있다.

```text
Config Server 1대
HTTP Basic 인증
Private Key를 로컬 설정으로 제공
수동 Refresh
```

운영 환경에서는 다음과 같이 개선하는 것이 좋다.

```text
Config Server 다중화
HTTPS 또는 내부망 통신
Secret Manager 사용
Git 변경 Pull Request 검토
Host Key 검증
중앙 로그와 모니터링
Client Retry
Spring Cloud Bus 또는 배포 자동화
설정 변경 감사 로그
```

---

## 정리

Spring Cloud Config Server는 여러 마이크로서비스의 설정을 중앙에서 제공하는 인프라 애플리케이션이다.

기본 동작 구조는 다음과 같다.

```text
Git Config Repository
→ Config Server
→ Config Client
```

Config Server 구축에 필요한 핵심 요소는 다음과 같다.

```text
spring-cloud-config-server 의존성
@EnableConfigServer
Git Repository URI
Private Repository 인증
Spring Security
설정 조회 URL
```

설정 조회 URL은 다음 규칙을 사용한다.

```text
/{application}/{profile}
/{application}/{profile}/{label}
```

예를 들어 `ms1-dev.properties`를 조회하려면 다음 경로를 사용할 수 있다.

```text
/ms1/dev
```

Git Repository의 설정을 수정하면 Config Server의 다음 조회 결과에는 새로운 값이 나타날 수 있다.

하지만 실행 중인 Config Client에 변경 내용이 즉시 자동 반영되는 것은 아니다. Client 재시작, Actuator Refresh, Spring Cloud Bus 또는 별도의 배포 자동화 과정이 필요하다.

또한 Private Key와 DB 비밀번호 같은 민감 정보는 소스 코드나 Config Repository에 직접 저장하지 말고 환경 변수, Vault, Secret Manager 등의 외부 보안 저장소에서 주입해야 한다.

### 한 줄 요약

Spring Cloud Config Server는 Git Repository의 설정을 중앙 API로 제공하며, 안전한 운영을 위해 Repository 인증, Config Server 보안, Client 갱신 방식과 설정 변경 절차까지 함께 설계해야 한다.

