---
layout: post
bigtitle: '스프링 클라우드 MSA'
subtitle: JetBrains Space 리포지토리 Config 서버 저장소 사용법
date: '2026-08-13 00:00:02 +0900'
categories:
    - developer-yumi
comments: true

---

# JetBrains Space 리포지토리 Config 서버 저장소 사용법
[https://youtu.be/ujgz094STCc?si=Cr895ohDpVWXy-rq](https://youtu.be/ujgz094STCc?si=Cr895ohDpVWXy-rq)

# JetBrains Space 리포지토리 Config 서버 저장소 사용법
* toc
{:toc}

---

## JetBrains Space를 Spring Cloud Config Repository로 활용하는 방법

Spring Cloud Config Server는 Git Repository를 외부 설정 저장소로 사용할 수 있다. 일반적으로 GitHub나 GitLab을 많이 사용하지만, Git 프로토콜을 제공하는 다른 저장소 역시 Config Repository로 활용할 수 있다.

JetBrains Space 역시 Git Repository를 제공했기 때문에 Spring Cloud Config Server의 설정 저장소로 사용할 수 있었다. GitHub에서 SSH Key를 활용했던 방식과 달리, HTTPS 기반 Repository 주소와 사용자 인증 정보를 이용하여 연결하는 구성이 가능했다.

다만 현재 시점에서 반드시 알아야 할 사항이 있다.

> **JetBrains Space Cloud는 2025년 6월 1일부터 서비스가 종료되었으며 신규 구축 대상으로 사용할 수 없다.** JetBrains는 기존 Space 및 SpaceCode Cloud 조직의 접근이 2025년 6월 1일부터 비활성화된다고 안내했다. 다만 일정 조건을 충족한 Space On-Premises 사용자는 기존 인스턴스를 계속 사용할 수 있다.

따라서 이번 내용은 **기존 JetBrains Space 또는 유지 중인 On-Premises 환경에서 Config Repository를 연결했던 구조를 이해하는 목적**으로 보는 것이 적절하다.

핵심 구조 자체는 GitHub, GitLab, 사내 Git Server 등 다른 Git Repository에도 그대로 적용할 수 있다.

---

## Spring Cloud Config Repository의 역할

MSA 환경에서는 여러 개의 Spring Boot 애플리케이션이 독립적으로 실행된다.

예를 들어 다음과 같은 서비스가 존재할 수 있다.

```text
user-service
order-service
payment-service
delivery-service
notification-service
```

각 서비스는 다양한 설정 정보를 필요로 한다.

```text
Database URL
Database Username
Redis 주소
Kafka Broker 주소
외부 API 주소
Timeout
Retry 횟수
서버 Port
Feature Flag
```

각 프로젝트 내부에서 모든 설정을 관리하면 서비스 수가 증가할수록 관리가 어려워진다.

이를 해결하기 위해 Spring Cloud Config에서는 설정을 외부 Repository에 저장하고 Config Server가 해당 설정을 읽어 각 서비스에 전달하는 구조를 사용할 수 있다.

```mermaid
flowchart LR
    A[Git Config Repository] --> B[Spring Cloud Config Server]
    B --> C[User Service]
    B --> D[Order Service]
    B --> E[Payment Service]
```

Config Repository는 실제 설정값을 저장하는 역할을 한다.

Config Server는 해당 Repository에서 데이터를 읽어 Config Client에게 전달한다.

```text
Config Repository
→ 설정 저장

Config Server
→ 설정 조회 및 제공

Config Client
→ 설정 사용
```

---

## GitHub를 Config Repository로 사용하는 기본 구조

GitHub Private Repository를 Spring Cloud Config Server와 연결할 때 SSH 방식을 사용할 수 있다.

전체 구조는 다음과 같다.

```mermaid
flowchart LR
    A[Config Server] --> B[SSH Private Key]
    B --> C[GitHub]
    D[Deploy Key Public Key] --> C
    C --> E[Config Repository]
```

Config Server가 Private Key를 가지고 있고 GitHub Repository에는 대응하는 Public Key를 Deploy Key로 등록한다.

Config Server가 Repository에 접근하면 GitHub는 두 키가 올바른 쌍인지 확인하여 접근을 허용한다.

이 구조에서 필요한 정보는 다음과 같다.

```text
Git Repository SSH 주소
Private Key
Public Key 등록
```

예를 들어 Repository 주소가 다음과 같다고 가정한다.

```text
git@github.com:example/config-repository.git
```

Config Server는 Private Key를 사용해 해당 Repository를 Clone하거나 Fetch한다.

---

## JetBrains Space에서는 무엇이 달랐을까?

JetBrains Space를 사용할 당시에는 GitHub의 Deploy Key 기반 구성 대신 HTTP 또는 HTTPS Repository 주소와 사용자 인증 정보를 이용하는 방식으로 구성할 수 있었다.

구조를 비교하면 다음과 같다.

| 구분               | GitHub SSH 방식      | Space HTTP 인증 방식  |
| ---------------- | ------------------ | ----------------- |
| Repository 주소    | SSH                | HTTP/HTTPS        |
| 인증               | Public/Private Key | Username/Password |
| Config Server 설정 | Private Key        | Username/Password |
| Repository 측 설정  | Public Key 등록      | 접근 가능한 사용자 필요     |

Spring Cloud Config 자체도 HTTP Basic 인증을 사용하는 Git Repository에 대해 `username`과 `password` 속성을 별도로 설정하는 방식을 공식적으로 지원한다.

따라서 이 방식은 JetBrains Space에만 한정된 개념이라기보다 **HTTP 인증을 지원하는 Private Git Repository를 Spring Cloud Config와 연결하는 일반적인 패턴**으로 이해할 수 있다.

---

## JetBrains Space란 무엇이었나?

JetBrains Space는 Git Repository만 제공하는 단순한 코드 저장소가 아니라 여러 개발 협업 기능을 통합해 제공했던 플랫폼이다.

대표적으로 다음과 같은 기능을 제공했다.

```text
Git Repository
Code Review
CI/CD
Issue 관리
문서 관리
팀 협업
개발 환경 관리
```

하나의 플랫폼에서 코드 저장부터 리뷰와 자동화까지 관리할 수 있다는 특징이 있었다.

다만 JetBrains는 2024년 Space의 종료 계획을 발표했고, Space와 SpaceCode Cloud 서비스는 2025년 6월 1일 종료되었다.

따라서 신규 프로젝트에서는 GitHub, GitLab, Bitbucket, 사내 Git Server 등 현재 유지되고 있는 Git 저장소를 사용하는 것이 현실적이다.

---

## Space Repository를 Config Repository로 사용하는 전체 구조

기존 Space 환경에서는 다음과 같은 구조로 Config Repository를 사용할 수 있었다.

```mermaid
flowchart LR
    A[JetBrains Space Git Repository] --> B[HTTPS Authentication]
    B --> C[Spring Cloud Config Server]
    C --> D[Config Client 1]
    C --> E[Config Client 2]
    C --> F[Config Client 3]
```

Config Server는 다음 정보를 사용하여 Repository에 접근한다.

```text
Repository HTTPS 주소
Username
Password 또는 인증 Credential
```

Repository에 저장된 설정 파일을 읽어 Config Client에게 제공한다.

---

## Config Repository 파일 구성

Config Repository에는 서비스와 실행 환경에 맞는 설정 파일을 저장한다.

예를 들어 다음과 같이 구성할 수 있다.

```text
config-repository
├── application.yml
├── application-dev.yml
├── application-prod.yml
├── user-service-dev.yml
├── order-service-dev.yml
├── order-service-prod.yml
└── payment-service-prod.yml
```

Spring Cloud Config에서는 일반적으로 다음 규칙을 사용한다.

```text
application.yml
application-{profile}.yml

{application}.yml
{application}-{profile}.yml
```

예를 들어 다음 파일이 존재한다고 가정한다.

```text
order-service-dev.yml
```

Config Client가 다음과 같이 설정되어 있다면:

```yaml
spring:
  application:
    name: order-service

  profiles:
    active: dev
```

Config Server는 `order-service`와 `dev`를 기준으로 해당 설정을 제공한다.

---

## Config Server에서 HTTPS Repository 연결하기

HTTP Basic 인증이 가능한 Git Repository를 Config Server와 연결하는 기본 구조는 다음과 같다.

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
          uri: https://git.example.com/config/config-repository.git
          username: ${CONFIG_GIT_USERNAME}
          password: ${CONFIG_GIT_PASSWORD}
          default-label: main
          clone-on-start: true
```

Spring Cloud Config 공식 문서에서도 HTTP Basic 인증 Repository를 사용할 때 `username`과 `password`를 URL에 포함하기보다 별도 속성으로 설정하는 방식을 제공한다.

각 설정의 의미는 다음과 같다.

| 설정               | 역할                                  |
| ---------------- | ----------------------------------- |
| `uri`            | Config Repository 주소                |
| `username`       | Repository 인증 사용자                   |
| `password`       | Repository 인증 정보                    |
| `default-label`  | 기본 Git Branch                       |
| `clone-on-start` | Config Server 시작 시 Repository Clone |

---

## 인증 정보를 URL에 직접 넣지 않는 이유

다음과 같이 사용자 이름과 비밀번호를 URL에 직접 작성할 수도 있는 환경이 있다.

```text
https://user:password@git.example.com/config-repository.git
```

하지만 이런 방식은 피하는 것이 좋다.

URL은 다음 위치에 노출될 가능성이 있기 때문이다.

```text
애플리케이션 로그
예외 메시지
모니터링 시스템
설정 파일
프로세스 정보
Git Repository
```

따라서 인증 정보는 다음과 같이 분리한다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: ${CONFIG_GIT_URI}
          username: ${CONFIG_GIT_USERNAME}
          password: ${CONFIG_GIT_PASSWORD}
```

실제 값은 환경 변수에서 주입한다.

```text
CONFIG_GIT_URI=https://git.example.com/config/config-repository.git
CONFIG_GIT_USERNAME=config-server-user
CONFIG_GIT_PASSWORD=strong-secret-value
```

---

## 운영 환경에서는 개인 사용자 계정을 사용하지 않는 것이 좋다

기존 예제에서는 Space에 가입된 특정 사용자 계정의 ID와 비밀번호를 이용해 Repository에 접근하는 형태를 사용할 수 있었다.

하지만 운영 시스템의 Config Server가 개발자 개인 계정을 사용하는 구조는 피하는 것이 좋다.

예를 들어 다음 계정을 Config Server에서 사용한다고 가정한다.

```text
개발자 개인 계정
→ config repository 접근
```

해당 개발자가 퇴사하거나 비밀번호를 변경하면 Config Server의 Repository 접근도 실패할 수 있다.

권장되는 형태는 다음과 같다.

```text
개발자 계정
≠
애플리케이션 서비스 계정
```

Config Server만을 위한 별도의 Machine User 또는 Service Account를 사용하는 것이 좋다.

```text
config-server-service-account
```

권한도 최소화한다.

```text
Config Repository
→ Read Only
```

Config Server는 일반적으로 설정을 읽기만 하기 때문에 Write 권한이 필요하지 않다.

---

## Config Server의 Git 접근 흐름

Config Server가 시작되면 Git Repository를 읽는다.

```mermaid
sequenceDiagram
    participant C as Config Server
    participant G as Git Repository

    C->>G: HTTPS 연결
    G->>C: 인증 요청
    C->>G: Username + Credential
    G-->>C: 인증 성공
    C->>G: Repository Clone 또는 Fetch
    G-->>C: 설정 파일 반환
```

Config Client가 설정을 요청하면 다음 흐름으로 이어진다.

```mermaid
sequenceDiagram
    participant A as Config Client
    participant C as Config Server
    participant G as Git Repository

    A->>C: order-service/dev 요청
    C->>G: 최신 Repository 상태 확인
    G-->>C: 설정 파일 반환
    C-->>A: 병합된 설정 반환
```

Spring Cloud Config의 Git Backend는 원격 Repository를 Clone하여 설정을 읽는 방식으로 동작한다.

---

## Config Server 연결 확인하기

Config Server가 정상적으로 Repository에 접근하는지 테스트한다.

Config Server가 다음 Port에서 실행된다고 가정한다.

```text
9000
```

Repository에는 다음 파일이 존재한다.

```text
ms1-dev.properties
```

내용은 다음과 같다.

```properties
server.port=8081
custom.message=hello
```

Config Server에 다음 요청을 보낸다.

```bash
curl http://localhost:9000/ms1/dev
```

Config Server 자체에 HTTP Basic 인증이 적용되어 있다면 다음과 같이 요청한다.

```bash
curl \
  -u config-client:config-password \
  http://localhost:9000/ms1/dev
```

Config Repository 접근이 정상적이라면 다음과 같은 형태의 응답을 확인할 수 있다.

```json
{
  "name": "ms1",
  "profiles": [
    "dev"
  ],
  "propertySources": [
    {
      "source": {
        "server.port": "8081",
        "custom.message": "hello"
      }
    }
  ]
}
```

---

## Git 인증 오류가 발생하는 경우

HTTPS Repository 연결에서는 다음 오류가 발생할 수 있다.

```text
Authentication failed
Repository not found
401 Unauthorized
403 Forbidden
```

다음 항목을 확인한다.

```text
Repository URL
Username
Password 또는 Token
Repository 접근 권한
Branch 이름
Private Repository 여부
```

개인 사용자 비밀번호 인증을 더 이상 허용하지 않는 Git 서비스라면 Password 자리에 Personal Access Token 또는 서비스 전용 Credential을 사용해야 할 수 있다.

따라서 사용하는 Git 서비스의 인증 방식을 먼저 확인해야 한다.

---

## Repository 주소 오류

SSH 주소와 HTTPS 주소를 혼동할 수 있다.

SSH 형식은 다음과 같다.

```text
git@git.example.com:team/config-repository.git
```

HTTPS 형식은 다음과 같다.

```text
https://git.example.com/team/config-repository.git
```

Username과 Password 기반으로 인증하려면 Repository 서버에서 HTTPS Git 인증을 지원해야 한다.

Config Server 설정도 HTTPS 주소에 맞게 작성한다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://git.example.com/team/config-repository.git
```

---

## Branch 설정 확인

Repository 기본 Branch가 `main`이라고 가정한다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          default-label: main
```

Repository가 `master`를 사용한다면 다음처럼 변경한다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          default-label: master
```

잘못된 Branch를 지정하면 Config Server는 설정 파일을 찾지 못할 수 있다.

---

## Repository의 하위 디렉터리를 사용하는 경우

설정 파일을 Repository 루트가 아닌 별도 디렉터리에 저장할 수도 있다.

```text
config-repository
├── README.md
└── config
    ├── application.yml
    ├── order-service-dev.yml
    └── payment-service-dev.yml
```

이 경우 `search-paths`를 지정한다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: ${CONFIG_GIT_URI}
          username: ${CONFIG_GIT_USERNAME}
          password: ${CONFIG_GIT_PASSWORD}
          search-paths:
            - config
```

Config Server는 지정된 디렉터리에서 설정 파일을 찾는다.

---

## GitHub 방식과 HTTPS 방식 비교

두 방식을 정리하면 다음과 같다.

| 항목     | SSH 방식          | HTTPS 인증 방식           |
| ------ | --------------- | --------------------- |
| 주소     | `git@...`       | `https://...`         |
| 인증 정보  | Private Key     | Username + Credential |
| 서버 등록  | Public Key      | 사용자 또는 Token 권한       |
| Secret | SSH Private Key | Password/Token        |
| 자동화    | 적합              | 적합                    |
| 인증 관리  | Key 관리 필요       | Credential 관리 필요      |

어떤 방식이 무조건 더 좋은 것은 아니다.

사용 중인 Git 플랫폼과 조직의 인증 정책에 따라 결정하면 된다.

---

## Spring Cloud Config의 관점에서는 Git Provider가 중요하지 않다

Spring Cloud Config Server가 중요하게 보는 것은 Repository가 Git Backend로 접근 가능한지 여부다.

즉 다음과 같은 서비스가 Config Repository 후보가 될 수 있다.

```text
GitHub
GitLab
Bitbucket
사내 Git Server
Self-hosted Git
```

중요한 것은 Config Server가 해당 Repository에 대해 다음 작업을 수행할 수 있어야 한다는 것이다.

```text
Clone
Fetch
Branch 조회
파일 읽기
```

Spring Cloud Config는 Git Repository를 Environment Repository Backend로 사용할 수 있도록 공식적으로 지원한다.

따라서 JetBrains Space에서 사용했던 HTTP 인증 구조도 다른 Git Repository로 충분히 전환할 수 있다.

---

## Config Repository를 Private으로 운영하는 이유

Config Repository에는 서비스 운영에 필요한 여러 정보가 포함될 수 있다.

```text
내부 서버 주소
Database Host
Redis Host
Kafka Broker 주소
외부 API Endpoint
기능 활성 여부
운영 환경 구조
```

따라서 Config Repository를 Public으로 노출하는 것은 피해야 한다.

다만 Private Repository라고 해서 비밀번호를 평문으로 저장해도 된다는 의미는 아니다.

다음 정보는 별도의 Secret Store에서 관리하는 것이 좋다.

```text
Database Password
JWT Secret
OAuth Secret
API Key
Cloud Access Key
SSH Private Key
```

Spring Cloud Config는 설정값 암호화 기능도 제공하며, 공식 문서에서는 `{cipher}` 형태의 암호화된 설정값을 사용할 수 있다고 설명한다.

더 높은 수준의 Secret 관리가 필요하다면 Vault와 같은 Secret Backend도 사용할 수 있다. Spring Cloud Config는 Vault Backend를 공식적으로 지원한다.

---

## Repository 인증 정보 역시 Secret이다

다음 값도 중요한 Secret이다.

```text
CONFIG_GIT_USERNAME
CONFIG_GIT_PASSWORD
CONFIG_GIT_TOKEN
SSH_PRIVATE_KEY
```

따라서 다음 위치에 직접 작성하지 않는 것이 좋다.

```text
소스 코드
application.yml
Git Repository
Dockerfile
공개 CI 로그
```

대신 다음과 같은 방식으로 관리한다.

```text
환경 변수
Docker Secret
Kubernetes Secret
AWS Secrets Manager
AWS Parameter Store
Vault
CI/CD Secret
```

---

## Kubernetes 환경 예시

Config Server를 Kubernetes에서 운영한다면 Repository Credential을 Secret으로 관리할 수 있다.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: config-git-credential
type: Opaque
stringData:
  username: config-server-user
  password: strong-secret-value
```

Deployment에서 환경 변수로 주입한다.

```yaml
env:
  - name: CONFIG_GIT_USERNAME
    valueFrom:
      secretKeyRef:
        name: config-git-credential
        key: username

  - name: CONFIG_GIT_PASSWORD
    valueFrom:
      secretKeyRef:
        name: config-git-credential
        key: password
```

Config Server에서는 환경 변수를 참조한다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: ${CONFIG_GIT_URI}
          username: ${CONFIG_GIT_USERNAME}
          password: ${CONFIG_GIT_PASSWORD}
```

이렇게 하면 Repository Credential이 애플리케이션 코드와 분리된다.

---

## Config Server 자체의 보안도 필요하다

Repository가 Private이어도 Config Server API가 외부에 그대로 공개되어 있다면 설정이 노출될 수 있다.

전체 구조는 다음과 같이 보호하는 것이 좋다.

```mermaid
flowchart LR
    A[Config Client] --> B[Private Network]
    B --> C[Config Server]
    C --> D[Private Git Repository]
```

Config Server에는 다음 보안을 고려한다.

```text
Spring Security
HTTP Basic 또는 서비스 인증
HTTPS
Private Network
Firewall
Security Group
NetworkPolicy
mTLS
```

Spring Cloud Config 공식 문서도 Config Server에 Spring Security를 적용할 수 있도록 별도의 보안 구성을 안내한다.

---

## JetBrains Space를 신규 도입하면 안 되는 이유

이전 환경에서는 다음 구조를 사용할 수 있었다.

```text
JetBrains Space Repository
→ Config Server
→ Config Client
```

하지만 현재 JetBrains Space Cloud는 종료되었다.

JetBrains는 Space와 SpaceCode를 2025년 6월 1일부로 중단했으며, 기존 Cloud Organization도 비활성화되었다.

따라서 신규 환경에서는 다음과 같은 대체 저장소를 사용하는 것이 적절하다.

```text
GitHub
GitLab
Bitbucket
사내 Git Server
```

기존 Space On-Premises 환경은 JetBrains가 안내한 조건을 충족한 경우 계속 사용할 수 있지만 공식적인 신규 제품 개발 방향과는 분리해서 판단해야 한다.

---

## 기존 Space Config Repository를 다른 Git 서비스로 이전한다면

구조 자체는 크게 변경되지 않는다.

기존 구조:

```text
Space Git Repository
→ Config Server
→ Config Client
```

변경 후:

```text
GitHub/GitLab
→ Config Server
→ Config Client
```

변경해야 하는 핵심 설정은 Config Server의 Repository 연결 정보다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: ${NEW_CONFIG_GIT_URI}
          username: ${NEW_CONFIG_GIT_USERNAME}
          password: ${NEW_CONFIG_GIT_PASSWORD}
```

SSH 인증을 사용한다면 해당 Git Provider에 맞는 SSH 설정으로 변경한다.

설정 파일 이름과 Config Client의 다음 값은 그대로 유지할 수 있다.

```text
spring.application.name
spring.profiles.active
```

따라서 Git 저장소 변경은 Config Client보다는 Config Server의 Environment Repository 연결 부분에 집중된다.

---

## 실무에서의 권장 구조

운영 환경에서는 다음 구조가 안정적이다.

```mermaid
flowchart TD
    A[Private Git Repository] --> B[Config Server 1]
    A --> C[Config Server 2]

    D[Secret Manager] --> B
    D --> C

    B --> E[Load Balancer]
    C --> E

    F[Config Clients] --> E
```

각 구성 요소의 책임을 나누면 다음과 같다.

```text
Private Git Repository
→ 일반 설정과 변경 이력 관리

Secret Manager
→ 비밀번호와 인증 정보 관리

Config Server
→ 설정 제공

Load Balancer
→ Config Server 고가용성

Config Client
→ 실제 설정 사용
```

이 구조는 특정 Git Provider에 의존하지 않기 때문에 Repository를 GitHub에서 GitLab으로 변경하더라도 전체 애플리케이션 구조에 미치는 영향을 줄일 수 있다.

---

## 정리

Spring Cloud Config Repository는 반드시 GitHub를 사용해야 하는 것은 아니다.

Spring Cloud Config Server가 Git Repository에 접근할 수 있다면 다양한 Git 서비스를 설정 저장소로 활용할 수 있다.

기존 JetBrains Space 환경에서는 GitHub SSH 방식 대신 HTTPS Repository와 사용자 인증 정보를 이용해 다음과 같이 연결할 수 있었다.

```text
GitHub SSH 방식

Repository SSH 주소
+
Private Key
+
GitHub Deploy Key
```

```text
HTTPS Repository 방식

Repository HTTPS 주소
+
Username
+
Password 또는 Token
```

Spring Cloud Config에서는 이를 다음과 같이 설정한다.

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: ${CONFIG_GIT_URI}
          username: ${CONFIG_GIT_USERNAME}
          password: ${CONFIG_GIT_PASSWORD}
```

운영 환경에서는 개발자 개인 계정 대신 서비스 전용 계정을 사용하고, Repository 권한을 Read Only로 제한하는 것이 좋다.

또한 Repository 인증 정보와 DB Password 같은 Secret은 소스 코드나 Config Repository에 직접 기록하지 않고 Secret Manager나 환경 변수로 분리해야 한다.

마지막으로 현재 JetBrains Space Cloud는 2025년 6월 1일 서비스가 종료되었으므로 신규 환경에서는 GitHub, GitLab, Bitbucket 또는 사내 Git Server와 같은 다른 Git Repository를 사용하는 것이 적절하다.

### 한 줄 요약

Spring Cloud Config Server는 특정 Git Provider에 종속되지 않으며, 기존 JetBrains Space처럼 HTTPS 인증을 지원하는 Git Repository도 `uri`, `username`, `password`를 통해 Config Repository로 연결할 수 있지만 현재 Space Cloud는 종료되었으므로 신규 구축에서는 다른 Git 서비스를 사용해야 한다.


