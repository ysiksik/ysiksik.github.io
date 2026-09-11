---
layout: post
bigtitle: 'Part 3. 실전 Kubernetes 프로젝트'
subtitle: Ch 2. Social Feed 서버 개발 
date: '2026-09-09 00:00:10 +0900'
categories:
    - for-backend-developers-kubernetes
comments: true
---

# Ch 2. Social Feed 서버 개발

# Ch 2. Social Feed 서버 개발
* toc
{:toc}

---

## 01. 스프링 프로젝트 구성

### 06. Spring Boot 소셜 피드 서버 프로젝트 생성과 데이터베이스 설정

SNS 백엔드의 첫 번째 마이크로서비스로 소셜 피드 서버를 구성한다. 소셜 피드 서버는 사용자가 작성한 게시글을 저장하고 조회하는 역할을 담당한다.

이미지 파일 자체는 이후에 구현할 이미지 서버가 관리한다. 피드 서버는 게시글 작성자 ID, 본문, 이미지 ID와 같은 메타데이터만 저장한다. 서비스의 책임을 이렇게 분리하면 게시글 처리와 이미지 저장 방식을 독립적으로 변경하고 확장할 수 있다.

#### 소셜 피드 서버의 책임

```mermaid
flowchart LR
    CLIENT["SNS Client"] --> FEED["Feed Server"]
    FEED --> DB["Amazon RDS for MySQL"]
    FEED --> IMAGE["Image Server"]
    DB --> META["작성자 ID, 본문, 이미지 ID"]
    IMAGE --> EFS["Amazon EFS 또는 Object Storage"]
```

| 데이터 | 관리 주체 |
|---|---|
| 게시글 본문 | Feed Server |
| 작성자 ID | Feed Server가 참조 |
| 이미지 ID | Feed Server가 참조 |
| 이미지 파일 | Image Server |
| 사용자 상세 정보 | User Server |

MSA에서는 다른 서비스의 데이터를 직접 수정하지 않는 것이 중요하다. 피드 서버가 보관하는 작성자 ID와 이미지 ID는 다른 서비스의 데이터를 가리키는 논리적 참조다. 각 서비스가 데이터베이스를 분리한다면 일반적인 외래 키로 서비스 간 정합성을 강제할 수 없으므로 API 호출이나 이벤트를 이용한 검증과 보상 처리가 필요하다.

#### 전체 구성 흐름

```mermaid
flowchart TD
    A["Spring Initializr에서 프로젝트 생성"] --> B["Gradle과 Java 21 설정"]
    B --> C["Spring Web, Spring Data JPA, MySQL Driver 추가"]
    C --> D["Spring Profile 분리"]
    D --> E["Datasource 환경 변수 설정"]
    E --> F["Kubernetes ConfigMap 생성"]
    E --> G["Kubernetes Secret 생성"]
    F --> H["Feed Server Pod에 환경 변수 주입"]
    G --> H
    H --> I["mysql.infra.svc.cluster.local"]
    I --> J["Amazon RDS for MySQL"]
```

#### Spring Boot 프로젝트 생성

Spring Initializr에서 다음과 같이 프로젝트를 생성한다.

| 항목 | 설정 |
|---|---|
| Project | Gradle - Groovy |
| Language | Java |
| Spring Boot | 유지보수 중인 안정 버전 |
| Group | `com.sns` |
| Artifact | `feed-server` |
| Name | `feed-server` |
| Package name | `com.sns.feed` |
| Packaging | Jar |
| Java | 21 |

새 프로젝트라면 유지보수 중인 Spring Boot 버전을 선택해야 한다. 기존 프로젝트가 Spring Boot 3.2.1처럼 특정 버전에 맞춰 작성되어 있다면 개별 서비스 하나만 임의로 업그레이드하지 말고 Spring Cloud, Gradle, 테스트 환경의 호환성을 함께 확인해야 한다. 현재 안정 버전 목록과 Java 요구사항은 [Spring Boot 공식 문서](https://docs.spring.io/spring-boot/)에서 확인할 수 있다.

다음 의존성을 추가한다.

- Spring Web
- Spring Data JPA
- MySQL Driver
- Validation
- Spring Boot Actuator

#### Gradle 설정

Spring Boot 3.x와 Java 21을 사용하는 예시는 다음과 같다.

```groovy
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.5.16'
    id 'io.spring.dependency-management' version '1.1.7'
}

group = 'com.sns'
version = '0.0.1-SNAPSHOT'

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'

    runtimeOnly 'com.mysql:mysql-connector-j'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
}

tasks.named('test') {
    useJUnitPlatform()
}
```

- `spring-boot-starter-web`은 REST API와 내장 Tomcat을 제공한다.
- `spring-boot-starter-data-jpa`는 JPA와 Hibernate 기반 데이터 접근을 제공한다.
- `mysql-connector-j`는 MySQL JDBC Driver다.
- `spring-boot-starter-validation`은 요청 객체의 입력값을 검증할 때 사용한다.
- `spring-boot-starter-actuator`는 상태 확인과 Kubernetes Probe 구성에 활용할 수 있다.
- Java Toolchain은 빌드 환경이 Java 21을 사용하도록 명시한다.

#### 애플리케이션 진입점

```java
package com.sns.feed;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class FeedServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(FeedServerApplication.class, args);
    }
}
```

`@SpringBootApplication`은 자동 구성, Component Scan, Java Config 기능을 함께 활성화한다. 기본 패키지인 `com.sns.feed` 아래에 Controller, Service, Repository, Entity를 배치하면 별도의 Component Scan 설정 없이 Spring Bean으로 등록된다.

#### Spring Profile 분리

로컬 환경과 EKS 개발 환경은 데이터베이스 주소와 자격 증명이 다르다. 설정값을 소스 코드에 고정하지 않고 Spring Profile과 환경 변수로 분리한다.

`application.yml`에는 공통 설정을 작성한다.

```yaml
spring:
  application:
    name: feed-server
  profiles:
    default: local
  jpa:
    open-in-view: false
    properties:
      hibernate:
        jdbc:
          time_zone: UTC

server:
  port: 8080
  shutdown: graceful

management:
  endpoints:
    web:
      exposure:
        include:
          - health
          - info
  endpoint:
    health:
      probes:
        enabled: true
  health:
    livenessstate:
      enabled: true
    readinessstate:
      enabled: true
```

`open-in-view: false`는 Controller까지 영속성 컨텍스트를 유지하지 않도록 한다. 필요한 연관 데이터는 Service의 트랜잭션 안에서 명확하게 조회해야 한다.

#### 로컬 환경 설정

`application-local.yml`을 작성한다.

```yaml
spring:
  config:
    activate:
      on-profile: local
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://${MYSQL_HOST:localhost}:${MYSQL_PORT:3306}/${MYSQL_DATABASE:sns}?serverTimezone=UTC&characterEncoding=UTF-8&sslMode=DISABLED
    username: ${MYSQL_USER:sns_server}
    password: ${MYSQL_PASSWORD:local-password}
    hikari:
      maximum-pool-size: 5
      minimum-idle: 1
      connection-timeout: 3000
  jpa:
    hibernate:
      ddl-auto: none
    show-sql: true
```

MySQL Connector/J의 올바른 Driver 클래스는 `com.mysql.cj.jdbc.Driver`다. 과거에 사용하던 `com.mysql.jdbc.Driver`는 더 이상 사용하지 않는다. Spring Boot가 JDBC URL을 통해 Driver를 자동으로 판단할 수 있으므로 `driver-class-name`을 생략하는 것도 가능하다.

#### EKS 개발 환경 설정

`application-dev.yml`을 작성한다.

```yaml
spring:
  config:
    activate:
      on-profile: dev
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT:3306}/${MYSQL_DATABASE:sns}?serverTimezone=UTC&characterEncoding=UTF-8&sslMode=REQUIRED
    username: ${MYSQL_USER}
    password: ${MYSQL_PASSWORD}
    hikari:
      maximum-pool-size: 10
      minimum-idle: 2
      connection-timeout: 3000
      validation-timeout: 1000
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
```

- `MYSQL_HOST`와 `MYSQL_PORT`는 ConfigMap에서 주입한다.
- `MYSQL_USER`와 `MYSQL_PASSWORD`는 Secret에서 주입한다.
- `sslMode=REQUIRED`는 RDS와의 통신을 TLS로 암호화한다.
- `ddl-auto: validate`는 애플리케이션 시작 시 Entity와 테이블 구조가 일치하는지 검사한다.
- 운영 환경에서 `ddl-auto: update`를 사용하면 애플리케이션 시작 시 의도하지 않은 스키마 변경이 발생할 수 있으므로 Flyway나 Liquibase로 마이그레이션을 관리하는 것이 좋다.
- HikariCP 크기는 Pod 수와 RDS의 최대 연결 수를 함께 고려해야 한다. Pod가 10개이고 각 Pod의 최대 Pool 크기가 10이면 애플리케이션에서 최대 100개의 연결을 생성할 수 있다.

#### 설정 파일 우선순위

```mermaid
flowchart LR
    COMMON["application.yml"] --> PROFILE["application-dev.yml"]
    PROFILE --> ENV["Kubernetes 환경 변수"]
    ENV --> FINAL["최종 Datasource 설정"]
```

Spring Boot에서는 환경 변수로 전달된 값이 YAML의 기본값보다 높은 우선순위를 가진다. 따라서 동일한 컨테이너 이미지를 사용하더라도 Namespace와 배포 환경에 따라 다른 데이터베이스 설정을 주입할 수 있다.

#### Kubernetes Namespace 생성

애플리케이션 리소스는 `sns` Namespace에 배치한다.

`sns-namespace.yaml`을 작성한다.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: sns
  labels:
    app.kubernetes.io/part-of: sns
    environment: dev
```

```shell
kubectl apply -f sns-namespace.yaml
kubectl get namespace sns
```

Redis, Kafka, MySQL ExternalName Service는 `infra` Namespace에 있고 애플리케이션은 `sns` Namespace에 있다. Namespace가 달라도 Service의 전체 DNS 이름을 사용하면 접근할 수 있다. 네트워크 통신까지 차단하려면 별도의 NetworkPolicy가 필요하다.

#### MySQL ConfigMap 작성

`mysql-configmap.yaml`을 작성한다.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  namespace: sns
  labels:
    app.kubernetes.io/part-of: sns
    app.kubernetes.io/component: database-config
data:
  MYSQL_HOST: mysql.infra.svc.cluster.local
  MYSQL_PORT: "3306"
  MYSQL_DATABASE: sns
```

- `apiVersion: v1`은 ConfigMap이 Kubernetes Core API 객체임을 의미한다.
- `metadata.name`은 Deployment에서 참조할 ConfigMap 이름이다.
- ConfigMap은 자신을 사용하는 Pod와 같은 `sns` Namespace에 있어야 한다.
- `MYSQL_HOST`는 `infra` Namespace의 ExternalName Service를 가리킨다.
- ConfigMap의 `data` 값은 문자열이어야 하므로 포트도 `"3306"`으로 작성한다.

Kubernetes Service의 전체 DNS 형식은 다음과 같다.

```text
<SERVICE_NAME>.<NAMESPACE>.svc.cluster.local
```

따라서 `mysql.infra.svc.cluster.local`은 `infra` Namespace에 있는 `mysql` Service를 의미한다.

#### MySQL Secret 작성

`mysql-secret.yaml`을 작성한다.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: sns
  labels:
    app.kubernetes.io/part-of: sns
    app.kubernetes.io/component: database-credentials
type: Opaque
stringData:
  MYSQL_USER: sns_server
  MYSQL_PASSWORD: CHANGE_ME_STRONG_PASSWORD
```

- `type: Opaque`는 일반적인 Key-Value 형식의 Secret을 의미한다.
- `stringData`는 평문을 입력받아 Kubernetes API Server가 Base64 형식의 `data`로 변환한다.
- `MYSQL_PASSWORD`는 RDS에서 생성한 `sns_server` 계정의 실제 비밀번호로 변경해야 한다.
- 이 파일에 실제 비밀번호를 입력했다면 Git에 Commit해서는 안 된다.

Base64는 암호화가 아니라 인코딩이다. Secret을 Base64로 변환했다고 해서 안전하게 보호되는 것은 아니다. 실무에서는 RBAC으로 Secret 조회 권한을 제한하고 AWS Secrets Manager, External Secrets Operator, Secrets Store CSI Driver 같은 외부 비밀 관리 방식을 고려해야 한다.

명령어로 Secret을 직접 생성하면 평문 비밀번호가 포함된 YAML 파일을 만들지 않을 수 있다.

```shell
kubectl create secret generic mysql-secret \
  --namespace sns \
  --from-literal=MYSQL_USER=sns_server \
  --from-literal=MYSQL_PASSWORD='<MYSQL_PASSWORD>'
```

다만 명령 기록에 비밀번호가 남을 수 있으므로 운영 환경에서는 CI/CD Secret이나 외부 Secret Manager를 통해 생성하는 것이 좋다.

#### ConfigMap과 Secret 적용

```shell
kubectl apply -f mysql-configmap.yaml
kubectl apply -f mysql-secret.yaml
```

생성 결과를 확인한다.

```shell
kubectl get configmap mysql-config -n sns
kubectl describe configmap mysql-config -n sns
kubectl get secret mysql-secret -n sns
kubectl describe secret mysql-secret -n sns
```

`kubectl describe secret`은 일반적으로 실제 값을 출력하지 않고 Key와 바이트 크기만 보여준다. 확인을 위해 Secret 값을 터미널에 출력하는 방식은 로그와 화면 기록에 비밀번호가 남을 수 있으므로 피해야 한다.

#### ConfigMap과 Secret 주입 구조

```mermaid
flowchart TD
    CM["ConfigMap mysql-config"] --> HOST["MYSQL_HOST"]
    CM --> PORT["MYSQL_PORT"]
    CM --> DB["MYSQL_DATABASE"]
    SEC["Secret mysql-secret"] --> USER["MYSQL_USER"]
    SEC --> PASSWORD["MYSQL_PASSWORD"]
    HOST --> POD["Feed Server Pod"]
    PORT --> POD
    DB --> POD
    USER --> POD
    PASSWORD --> POD
    POD --> SPRING["Spring Boot Datasource"]
```

다음 단계에서 Deployment의 `envFrom` 또는 개별 `env.valueFrom` 설정을 이용해 ConfigMap과 Secret을 컨테이너 환경 변수로 주입할 수 있다.

환경 변수로 주입된 ConfigMap과 Secret은 원본 객체를 수정하더라도 실행 중인 컨테이너에서 자동으로 변경되지 않는다. 새로운 값을 적용하려면 Deployment의 Pod를 Rolling Update 방식으로 다시 생성해야 한다.

#### MySQL Service DNS 확인

`sns` Namespace에서 `infra` Namespace의 MySQL Service가 조회되는지 테스트한다.

```shell
kubectl run dns-test \
  --namespace sns \
  --rm \
  --interactive \
  --tty \
  --restart=Never \
  --image=busybox:1.36 \
  -- nslookup mysql.infra.svc.cluster.local
```

정상적인 경우 ExternalName Service가 가리키는 RDS Endpoint가 출력된다.

DNS 조회가 성공했다고 데이터베이스 연결까지 성공한 것은 아니다. MySQL TCP 3306 연결, RDS Security Group, 사용자 인증, TLS 설정은 별도로 검증해야 한다.

#### 로컬 실행

로컬 MySQL 또는 접근 가능한 개발 데이터베이스를 준비한 뒤 환경 변수를 설정한다.

```powershell
$env:MYSQL_HOST = "localhost"
$env:MYSQL_PORT = "3306"
$env:MYSQL_DATABASE = "sns"
$env:MYSQL_USER = "sns_server"
$env:MYSQL_PASSWORD = "local-password"

.\gradlew.bat bootRun --args="--spring.profiles.active=local"
```

애플리케이션이 기동되면 Actuator Health Endpoint를 확인한다.

```shell
curl http://localhost:8080/actuator/health
```

정상적인 경우 다음과 같은 응답을 확인할 수 있다.

```json
{
  "status": "UP"
}
```

`UP`은 애플리케이션과 등록된 HealthIndicator가 정상이라는 의미다. 비즈니스 API 전체가 정상 동작하거나 실제 운영 트래픽을 처리할 수 있다는 의미까지 보장하지는 않는다.

#### 빌드와 테스트

```powershell
.\gradlew.bat clean test
.\gradlew.bat bootJar
```

빌드가 성공하면 다음 위치에 실행 가능한 Jar가 생성된다.

```text
build/libs/feed-server-0.0.1-SNAPSHOT.jar
```

직접 실행할 수도 있다.

```powershell
java -jar build/libs/feed-server-0.0.1-SNAPSHOT.jar --spring.profiles.active=local
```

#### 자주 발생하는 문제

| 현상 | 주요 원인 | 해결 방법 |
|---|---|---|
| `Failed to determine a suitable driver class` | MySQL Driver 누락 | `mysql-connector-j` 의존성 확인 |
| Driver 클래스를 찾지 못함 | 이전 Driver 이름 사용 | `com.mysql.cj.jdbc.Driver` 사용 |
| `Communications link failure` | Host, Port, Security Group 오류 | RDS Endpoint와 TCP 3306 확인 |
| `Access denied for user` | 사용자명, 비밀번호, 권한 오류 | `SHOW GRANTS`와 Secret 값 확인 |
| `UnknownHostException` | Service 이름 또는 Namespace 오타 | `mysql.infra.svc.cluster.local` 확인 |
| 애플리케이션 시작 실패 | 환경 변수 누락 | ConfigMap과 Secret Key 이름 확인 |
| Hibernate 검증 실패 | Entity와 DB Schema 불일치 | 마이그레이션 상태와 `ddl-auto` 확인 |
| Pod가 `CreateContainerConfigError` | ConfigMap 또는 Secret이 같은 Namespace에 없음 | `sns` Namespace의 객체 확인 |

#### 실무적인 구성 기준

ConfigMap과 Secret은 피드 서버만의 리소스처럼 보이지만 실제로는 여러 마이크로서비스가 공유할 수 있는 인프라 설정이다. 초기 실습에서는 피드 서버 프로젝트에 둘 수 있지만, 프로젝트가 커지면 공통 Helm Chart나 별도의 인프라 Repository에서 관리하는 편이 적절하다.

또한 모든 마이크로서비스가 하나의 데이터베이스 계정을 공유하면 특정 서비스의 권한이 전체 테이블로 확장된다. 운영 환경에서는 서비스별 Database 또는 Schema와 전용 계정을 생성하고 필요한 테이블에만 최소 권한을 부여해야 한다.

### 정리

소셜 피드 서버는 게시글 작성자 ID, 본문, 이미지 ID를 관리하며 이미지 파일 자체는 이미지 서버에 위임한다. 이러한 책임 분리는 서비스를 독립적으로 개발하고 확장하기 위한 MSA의 기본 구조다.

Spring Boot 프로젝트는 Java 21, Spring Web, Spring Data JPA, MySQL Driver를 기반으로 생성하고 로컬 환경과 EKS 개발 환경을 Spring Profile로 분리했다. 데이터베이스 주소와 포트는 ConfigMap으로, 사용자명과 비밀번호는 Secret으로 관리하도록 구성했다.

애플리케이션은 `mysql.infra.svc.cluster.local`을 통해 `infra` Namespace의 ExternalName Service를 조회하고 최종적으로 Amazon RDS에 연결한다. ConfigMap과 Secret은 같은 Namespace의 Pod에서만 직접 참조할 수 있지만 Service DNS를 통한 네트워크 호출은 Namespace를 넘어서 수행할 수 있다.

다음 단계에서는 이 설정을 Feed Server Deployment에 주입하고, 컨테이너 이미지와 Resource, Probe, Service를 구성하여 EKS 클러스터에 실제 애플리케이션을 배포할 수 있다.

## 02. Kubernetes를 위한 기본 스프링 설정 및 EKS 배포

### Spring Boot Feed Server를 Kubernetes에 배포하기

이번 단계에서는 Feed Server를 컨테이너 이미지로 빌드해 Amazon ECR에 Push하고, Deployment와 Service를 이용해 EKS 클러스터에 배포한다.

애플리케이션이 정상적으로 시작됐는지 판단할 Health Check Endpoint를 추가하고, Rolling Update 중 처리 중인 요청을 보호하기 위한 Graceful Shutdown도 함께 설정한다.

#### 실습 목표

- Readiness와 Liveness Endpoint 구현
- Spring Boot Graceful Shutdown 설정
- Jib을 이용한 컨테이너 이미지 빌드
- Amazon ECR에 이미지 Push
- Feed Server Deployment와 Service 작성
- ConfigMap과 Secret을 환경 변수로 주입
- CPU와 Memory의 `requests`, `limits` 설정
- Readiness Probe와 Liveness Probe 설정
- EKS 배포 및 Rolling Update 확인

#### 전체 배포 흐름

```mermaid
flowchart TD
    CODE["Spring Boot Feed Server"] --> JIB["Jib Image Build"]
    JIB --> ECR["Amazon ECR feed-server"]
    ECR --> DEPLOY["Kubernetes Deployment"]
    DEPLOY --> POD1["Feed Server Pod 1"]
    DEPLOY --> POD2["Feed Server Pod 2"]
    SERVICE["Feed Service"] --> POD1
    SERVICE --> POD2
    CONFIG["ConfigMap mysql-config"] --> POD1
    CONFIG --> POD2
    SECRET["Secret mysql-secret"] --> POD1
    SECRET --> POD2
    POD1 --> RDS["Amazon RDS for MySQL"]
    POD2 --> RDS
```

#### Health Check Endpoint 구현

Kubernetes의 Probe는 목적에 따라 구분해야 한다.

| Probe | 확인 대상 | 실패 시 동작 |
|---|---|---|
| Startup Probe | 애플리케이션 시작 완료 여부 | Container 재시작 |
| Readiness Probe | 요청 처리 가능 여부 | Service Endpoint에서 제외 |
| Liveness Probe | 애플리케이션이 복구 불가능한 상태인지 | Container 재시작 |

Readiness Probe가 실패해도 Pod나 Container가 재시작되는 것은 아니다. Kubernetes는 해당 Pod를 Service의 요청 대상에서 제외한다.

Liveness Probe가 연속해서 실패하면 kubelet은 해당 Pod 안의 Container를 재시작한다. Deployment가 Pod를 삭제하고 새 Pod를 만드는 동작과는 다르다.

##### 간단한 Health Check Controller

```java
package com.sns.feed.healthcheck;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/health-check")
public class HealthCheckController {

    @GetMapping("/readiness")
    public ResponseEntity<String> readiness() {
        return ResponseEntity.ok("READY");
    }

    @GetMapping("/liveness")
    public ResponseEntity<String> liveness() {
        return ResponseEntity.ok("LIVE");
    }
}
```

두 Endpoint는 정상일 때 HTTP `200 OK`를 반환한다. HTTP 205는 Reset Content를 의미하므로 일반적인 Health Check 성공 응답으로 사용하지 않는다.

현재 코드는 애플리케이션 프로세스가 HTTP 요청에 응답할 수 있는지만 확인한다. Readiness와 Liveness의 동작 차이를 확인하기에는 충분하지만 실제 운영 상태를 자세히 반영하지는 않는다.

Liveness Probe에는 일반적으로 MySQL이나 Kafka 같은 외부 시스템 상태를 포함하지 않는다. 외부 시스템 장애 때문에 모든 애플리케이션 Container가 반복적으로 재시작되면 장애가 더 커질 수 있기 때문이다.

Spring Boot Actuator를 사용하고 있다면 다음 Endpoint를 사용하는 것이 더 적절하다.

```text
/actuator/health/readiness
/actuator/health/liveness
```

#### Graceful Shutdown 설정

Rolling Update나 Pod 종료 과정에서 Spring Boot는 `SIGTERM`을 전달받는다. Graceful Shutdown을 사용하면 진행 중인 요청이 끝날 시간을 확보한 뒤 애플리케이션을 종료할 수 있다.

`application.yml`에 다음 설정을 추가한다.

```yaml
server:
  port: 8080
  shutdown: graceful

spring:
  lifecycle:
    timeout-per-shutdown-phase: 20s
```

- `server.shutdown: graceful`은 즉시 종료하지 않고 처리 중인 요청을 기다린다.
- `timeout-per-shutdown-phase`는 각 종료 단계가 기다릴 수 있는 시간을 제한한다.
- Kubernetes의 `terminationGracePeriodSeconds`는 이 값과 `preStop` 실행 시간을 모두 수용할 수 있어야 한다.

Spring Boot의 Graceful Shutdown은 새 요청 수락을 중단하고 기존 요청을 처리할 시간을 제공한다. [Spring Boot Graceful Shutdown](https://docs.spring.io/spring-boot/reference/web/graceful-shutdown.html)

로컬 개발 환경에서는 즉시 종료하는 편이 편리하다면 `application-local.yml`에서 재정의한다.

```yaml
server:
  shutdown: immediate
```

IDE의 Stop 버튼은 정상적인 `SIGTERM` 종료가 아니라 프로세스를 즉시 중단할 수 있으므로 로컬에서 Graceful Shutdown이 항상 동일하게 동작한다고 가정해서는 안 된다.

#### Jib을 이용한 컨테이너 이미지 빌드

Jib은 Dockerfile 없이 Java 애플리케이션을 OCI 컨테이너 이미지로 빌드할 수 있는 도구다. 애플리케이션 의존성, 리소스, 클래스 파일을 Layer로 분리하므로 변경되지 않은 Layer를 재사용할 수 있다.

`build.gradle`의 `plugins`에 Jib을 추가한다.

```groovy
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.5.16'
    id 'io.spring.dependency-management' version '1.1.7'
    id 'com.google.cloud.tools.jib' version '3.5.4'
}
```

ECR Registry와 이미지 태그를 Gradle Property로 받도록 설정한다.

```groovy
def ecrRegistry = providers.gradleProperty('ecrRegistry')
    .orElse('<ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com')

def imageTag = providers.gradleProperty('imageTag')
    .orElse(project.version.toString())

jib {
    from {
        image = 'eclipse-temurin:21-jre'
    }

    to {
        image = "${ecrRegistry.get()}/feed-server:${imageTag.get()}"
    }

    container {
        mainClass = 'com.sns.feed.FeedServerApplication'
        ports = ['8080']

        jvmFlags = [
            '-XX:InitialRAMPercentage=30.0',
            '-XX:MaxRAMPercentage=70.0',
            '-XX:+ExitOnOutOfMemoryError',
            '-Djava.security.egd=file:/dev/./urandom'
        ]
    }
}
```

- `from.image`는 애플리케이션 실행에 사용할 Java 21 Runtime Image다.
- `to.image`는 ECR Repository와 이미지 태그를 지정한다.
- `mainClass`는 Spring Boot 진입점이다.
- `ports`는 컨테이너가 사용하는 포트를 이미지 Metadata에 기록한다.
- `MaxRAMPercentage`는 Container Memory Limit 전체를 JVM Heap으로 사용하지 않도록 제한한다.

Container Memory에는 Heap뿐 아니라 Metaspace, Thread Stack, Direct Memory와 Native Memory도 포함된다. 따라서 Heap 최대 크기를 Memory Limit과 동일하게 설정하면 `OOMKilled`가 발생할 수 있다.

Jib은 기본적으로 재현 가능한 이미지를 만들기 위해 생성 시간을 고정한다. `creationTime = 'USE_CURRENT_TIMESTAMP'`를 지정할 수도 있지만 빌드마다 이미지 Digest가 달라질 수 있으므로 특별한 이유가 없다면 기본값을 유지하는 것이 좋다. [Jib Gradle Plugin](https://github.com/GoogleContainerTools/jib/blob/master/jib-gradle-plugin/README.md)

#### Amazon ECR 로그인

ECR 인증 토큰은 영구적으로 유지되지 않는다. 인증이 만료되어 Push가 실패하면 다시 로그인해야 한다.

```shell
aws ecr get-login-password \
  --region ap-northeast-2 \
  --profile sns-admin \
  | docker login \
  --username AWS \
  --password-stdin <ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com
```

Docker 설정 파일에서 ECR 인증 정보를 확인할 수 있으면 Jib도 해당 인증 정보를 사용해 이미지를 Push할 수 있다.

#### 이미지 빌드와 Push

Windows PowerShell에서는 다음 명령을 실행한다.

```powershell
.\gradlew.bat clean test

.\gradlew.bat jib `
  -PecrRegistry=<ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com `
  -PimageTag=0.0.1
```

Linux나 macOS에서는 다음과 같이 실행한다.

```shell
./gradlew clean test

./gradlew jib \
  -PecrRegistry=<ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com \
  -PimageTag=0.0.1
```

Push된 이미지를 확인한다.

```shell
aws ecr list-images \
  --repository-name feed-server \
  --region ap-northeast-2 \
  --profile sns-admin
```

#### Feed Server Deployment 작성

`feed-deployment.yaml`을 작성한다.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: feed-server
  namespace: sns
  labels:
    app.kubernetes.io/name: feed-server
    app.kubernetes.io/part-of: sns
spec:
  replicas: 2
  revisionHistoryLimit: 3
  progressDeadlineSeconds: 600
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app.kubernetes.io/name: feed-server
  template:
    metadata:
      labels:
        app.kubernetes.io/name: feed-server
        app.kubernetes.io/part-of: sns
    spec:
      terminationGracePeriodSeconds: 40
      containers:
        - name: feed-server
          image: <ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com/feed-server:0.0.1
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: dev
          envFrom:
            - configMapRef:
                name: mysql-config
            - secretRef:
                name: mysql-secret
          resources:
            requests:
              cpu: 500m
              memory: 512Mi
            limits:
              cpu: "1"
              memory: 1Gi
          lifecycle:
            preStop:
              exec:
                command:
                  - sh
                  - -c
                  - sleep 10
          readinessProbe:
            httpGet:
              path: /health-check/readiness
              port: http
            initialDelaySeconds: 30
            periodSeconds: 5
            timeoutSeconds: 2
            successThreshold: 1
            failureThreshold: 3
          livenessProbe:
            httpGet:
              path: /health-check/liveness
              port: http
            initialDelaySeconds: 30
            periodSeconds: 5
            timeoutSeconds: 2
            failureThreshold: 7
```

##### Deployment 주요 필드

| 필드 | 설명 |
|---|---|
| `replicas` | 유지할 Feed Server Pod 수 |
| `strategy.type` | Rolling Update 방식으로 교체 |
| `maxSurge` | 업데이트 중 추가로 생성할 수 있는 Pod 수 |
| `maxUnavailable` | 업데이트 중 허용할 수 있는 비가용 Pod 수 |
| `selector` | Deployment가 관리할 Pod 선택 |
| `template.metadata.labels` | 새로 생성되는 Pod의 Label |
| `terminationGracePeriodSeconds` | 강제 종료 전까지 기다리는 전체 시간 |
| `image` | ECR에 Push한 컨테이너 이미지 |
| `envFrom` | ConfigMap과 Secret의 모든 Key를 환경 변수로 주입 |
| `resources.requests` | 스케줄링 시 보장받기 위해 요청하는 자원 |
| `resources.limits` | Container가 사용할 수 있는 최대 자원 |
| `preStop` | Container 종료 직전에 실행할 Hook |
| `readinessProbe` | 요청을 받을 준비가 됐는지 확인 |
| `livenessProbe` | Container를 재시작해야 하는지 확인 |

Deployment의 `selector.matchLabels`와 Pod Template의 Label은 일치해야 한다. 일치하지 않으면 API Server가 Deployment 생성을 거부하거나 의도한 Pod를 관리하지 못한다.

#### `requests`와 `limits`

`requests`는 Scheduler가 Pod를 배치할 Node를 결정할 때 사용한다. `limits`는 Container가 사용할 수 있는 최대 자원이다.

- CPU `500m`은 0.5 Core에 해당한다.
- CPU Limit을 넘으면 Container가 종료되는 것이 아니라 CPU 사용이 Throttling된다.
- Memory Limit을 넘으면 Container 프로세스가 `OOMKilled`될 수 있다.
- Memory `requests`가 너무 작으면 Node에 Pod가 과도하게 배치될 수 있다.
- `requests`와 `limits`의 차이가 지나치게 크면 Node 자원 경합 시 성능이 불안정해질 수 있다.

초기 값은 정답이 아니다. 부하 테스트와 Metric을 확인하면서 JVM Heap, CPU Throttling, GC 시간, 응답 시간, OOM 발생 여부를 기준으로 조정해야 한다.

#### Probe 설정 해석

현재 Readiness Probe는 30초 뒤부터 5초마다 실행한다. 3번 연속 실패하면 약 15초 뒤 Pod가 NotReady 상태가 되어 Service 트래픽 대상에서 제외된다.

Liveness Probe는 7번 연속 실패해야 Container를 재시작하므로 일시적인 지연 때문에 재시작되는 가능성을 줄인다. Kubernetes Probe의 구체적인 실패 동작은 [Kubernetes Probe 공식 문서](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)에서 확인할 수 있다.

애플리케이션 시작 시간이 환경에 따라 크게 달라진다면 긴 `initialDelaySeconds`보다 Startup Probe를 추가하는 것이 적합하다. Startup Probe가 성공하기 전에는 Readiness와 Liveness 검사를 시작하지 않으므로 느린 시작과 실제 장애를 명확하게 구분할 수 있다.

#### Graceful Shutdown 동작 과정

```mermaid
sequenceDiagram
    participant D as "Deployment"
    participant S as "Service"
    participant P as "기존 Pod"
    participant N as "새 Pod"

    D->>N: "새 버전 Pod 생성"
    N->>N: "Spring Boot 시작"
    N-->>S: "Readiness 성공"
    D->>P: "기존 Pod 종료 요청"
    S->>P: "Endpoint에서 제외"
    P->>P: "preStop 10초 실행"
    P->>P: "SIGTERM 수신"
    P->>P: "진행 중 요청 처리"
    P-->>D: "정상 종료"
```

`preStop`의 10초 대기는 Service와 외부 Load Balancer가 기존 Endpoint 변경을 반영할 시간을 확보하기 위한 완충 장치다. 무조건 긴 대기 시간을 설정하는 것이 좋은 것은 아니며 실제 Load Balancer와 요청 종료 시간을 확인해 조정해야 한다.

`terminationGracePeriodSeconds: 40`에는 `preStop` 실행 시간과 Spring Boot 종료 시간이 모두 포함된다. 이 시간이 끝나면 kubelet은 Container를 강제로 종료할 수 있다.

#### Feed Server Service 작성

`feed-service.yaml`을 작성한다.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: feed-service
  namespace: sns
  labels:
    app.kubernetes.io/name: feed-server
    app.kubernetes.io/part-of: sns
spec:
  type: ClusterIP
  selector:
    app.kubernetes.io/name: feed-server
  ports:
    - name: http
      protocol: TCP
      port: 8080
      targetPort: http
```

Service의 Selector는 Deployment가 아니라 Pod의 Label을 선택한다. Readiness Probe에 성공한 Pod만 일반적인 Service 트래픽을 받을 수 있다.

- `type: ClusterIP`는 클러스터 내부에서만 접근 가능한 Service를 생성한다.
- `port`는 Service가 제공하는 포트다.
- `targetPort`는 Pod의 이름 있는 Container Port인 `http`를 참조한다.
- 같은 Namespace에서는 `feed-service:8080`으로 접근할 수 있다.
- 다른 Namespace에서는 `feed-service.sns.svc.cluster.local:8080`을 사용한다.

#### Kubernetes 객체 적용

Namespace와 데이터베이스 설정을 먼저 적용한다.

```shell
kubectl apply -f sns-namespace.yaml
kubectl apply -f mysql-configmap.yaml
kubectl apply -f mysql-secret.yaml
```

Deployment와 Service를 적용한다.

```shell
kubectl apply -f feed-deployment.yaml
kubectl apply -f feed-service.yaml
```

적용 상태를 확인한다.

```shell
kubectl rollout status deployment/feed-server -n sns --timeout=5m
kubectl get deployment,pods,service -n sns -o wide
kubectl get endpointslice -n sns \
  -l kubernetes.io/service-name=feed-service
```

정상적인 경우 Deployment는 `2/2` Ready 상태가 되고 두 Pod 모두 `Running`으로 표시된다.

```text
NAME                          READY   UP-TO-DATE   AVAILABLE
deployment.apps/feed-server   2/2     2            2
```

Pod 상태가 `Running`이어도 `READY`가 `0/1`이면 Readiness Probe가 아직 성공하지 않은 상태다. 실제 요청 가능 여부는 `Running`만 보지 말고 Ready 상태와 EndpointSlice를 함께 확인해야 한다.

#### Service 호출 테스트

클러스터 내부에서 Health Check Endpoint를 호출한다.

```shell
kubectl run curl-client \
  --namespace sns \
  --rm \
  --interactive \
  --tty \
  --restart=Never \
  --image=curlimages/curl:8.12.1 \
  -- curl \
  --fail \
  --silent \
  http://feed-service.sns.svc.cluster.local:8080/health-check/readiness
```

정상적인 결과는 다음과 같다.

```text
READY
```

로컬 PC에서 확인하려면 Port Forward를 사용한다.

```shell
kubectl port-forward service/feed-service 8080:8080 -n sns
```

다른 터미널에서 호출한다.

```shell
curl http://localhost:8080/health-check/readiness
curl http://localhost:8080/health-check/liveness
```

#### 로그와 장애 원인 확인

```shell
kubectl logs -n sns deployment/feed-server --all-pods=true --tail=200
kubectl describe pod -n sns <POD_NAME>
kubectl get events -n sns --sort-by=.metadata.creationTimestamp
```

| 현상 | 주요 원인 | 확인 항목 |
|---|---|---|
| `ImagePullBackOff` | ECR 주소, 태그 또는 IAM 권한 오류 | ECR 이미지와 Node IAM Role |
| `CreateContainerConfigError` | ConfigMap 또는 Secret 누락 | 객체 이름과 Namespace |
| `CrashLoopBackOff` | Spring Boot 시작 실패 | Application Log |
| `OOMKilled` | Memory Limit 초과 | JVM Heap과 Native Memory |
| Pod가 `Pending` | Node의 가용 CPU 또는 Memory 부족 | `requests`와 Node Allocatable |
| `Running`이지만 `0/1` | Readiness Probe 실패 | Endpoint 경로와 응답 코드 |
| 반복적인 Container Restart | Liveness Probe가 지나치게 민감 | 초기 지연과 실패 기준 |
| Service 연결 실패 | Selector와 Pod Label 불일치 | Service EndpointSlice |

#### Rolling Update 확인

새 버전 이미지를 Push한다.

```powershell
.\gradlew.bat jib `
  -PecrRegistry=<ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com `
  -PimageTag=0.0.2
```

Deployment의 이미지를 변경한다.

```shell
kubectl set image \
  deployment/feed-server \
  feed-server=<ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com/feed-server:0.0.2 \
  -n sns
```

진행 상황을 확인한다.

```shell
kubectl rollout status deployment/feed-server -n sns
kubectl rollout history deployment/feed-server -n sns
kubectl get pods -n sns --watch
```

새 Pod의 Readiness Probe가 성공해야 기존 Pod가 종료된다. 배포에 문제가 있다면 이전 Revision으로 되돌릴 수 있다.

```shell
kubectl rollout undo deployment/feed-server -n sns
```

Rollback은 컨테이너 이미지와 Pod Template 설정을 이전 Revision으로 되돌리는 기능이다. 데이터베이스 스키마까지 자동으로 되돌리지는 않으므로 애플리케이션과 DB Migration은 하위 호환성을 고려해야 한다.

### 정리

Feed Server에 Readiness와 Liveness Endpoint를 추가하고 Graceful Shutdown을 설정했다. Readiness 실패는 Pod를 Service 트래픽에서 제외하고, Liveness 실패는 해당 Pod 안의 Container를 재시작한다.

Jib을 이용하면 Dockerfile 없이 Spring Boot 애플리케이션을 컨테이너 이미지로 빌드해 ECR에 Push할 수 있다. 이미지 태그는 `latest`보다 버전이나 Git Commit SHA처럼 변경되지 않는 값을 사용하는 것이 배포와 Rollback 추적에 유리하다.

Deployment는 Feed Server Pod 두 개를 유지하며 Rolling Update로 버전을 교체한다. ConfigMap과 Secret은 `envFrom`을 통해 환경 변수로 주입하고, Service는 Label Selector로 Ready 상태의 Pod에 요청을 전달한다.

Resource와 Probe 설정은 고정된 정답이 아니다. 실제 CPU, JVM Memory, 시작 시간, 응답 지연과 장애 상황을 관찰하면서 조정해야 한다. Graceful Shutdown, `preStop`, `terminationGracePeriodSeconds`도 하나의 종료 흐름으로 설계해야 Rolling Update 중 요청 손실을 줄일 수 있다.
