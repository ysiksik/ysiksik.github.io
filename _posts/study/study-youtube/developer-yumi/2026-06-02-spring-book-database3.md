---
layout: post
bigtitle: '스프링 부트 데이터베이스'
subtitle: 스프링 부트 데이터베이스 3 - 오라클 ATP 단일 연결 (전자지갑)
date: '2026-06-02 00:00:11 +0900'
categories:
    - developer-yumi
comments: true

---

# 스프링 부트 데이터베이스 3 - 오라클 ATP 단일 연결 (전자지갑)
[https://youtu.be/mDBl7yIcgzM?si=Dg6t40XbbXXzdf_c](https://youtu.be/mDBl7yIcgzM?si=Dg6t40XbbXXzdf_c)

# 스프링 부트 데이터베이스 3 - 오라클 ATP 단일 연결 (전자지갑)
* toc
{:toc}

---

## Spring Boot + Oracle ATP : 전자지갑 방식으로 단일 DB 연결하기

이번 글에서는
Spring Boot 프로젝트에서 **Oracle Cloud ATP 데이터베이스**를
전자지갑 방식으로 연결하는 방법을 정리한다.

핵심은 다음이다.

> **Oracle Cloud ATP는 일반적인 IP/Port 연결이 아니라 전자지갑 Wallet 기반 연결을 사용한다**

즉, MySQL처럼 단순히 URL, ID, 비밀번호만 넣는 방식이 아니라
Oracle Cloud에서 발급받은 **전자지갑 파일 경로**까지 함께 설정해야 한다.

---

## 1. Oracle ATP 전자지갑 방식이란?

Oracle ATP는 Autonomous Transaction Processing의 약자로,
Oracle Cloud에서 제공하는 관리형 데이터베이스 서비스다.

일반적인 RDB 연결은 다음 정보만 있으면 된다.

```text
DB IP
Port
Database Name
Username
Password
```

하지만 Oracle Cloud ATP는 보안 강화를 위해 추가로:

```text
전자지갑 Wallet
```

을 사용한다.

전자지갑에는 DB 접속에 필요한 인증서와 보안 설정 정보가 포함되어 있다.

---

## 2. 전체 연결 순서

이번 실습 흐름은 다음과 같다.

```text
Oracle Cloud ATP 생성
   ↓
전자지갑 다운로드
   ↓
Spring Boot 프로젝트 생성
   ↓
Oracle Driver + JPA 의존성 추가
   ↓
전자지갑 관련 의존성 추가
   ↓
application.yml 설정
   ↓
애플리케이션 실행
   ↓
DB 연결 확인
```

---

## 3. 전자지갑 다운로드

Oracle Cloud 콘솔에서 ATP 데이터베이스에 접근한 뒤
**Database Connection** 또는 **데이터베이스 접속** 메뉴로 이동한다.

이후 다음 순서로 진행한다.

```text
데이터베이스 접속
→ 전자지갑 다운로드
→ 인스턴스 전자지갑 선택
→ 비밀번호 설정
→ 다운로드
```

다운로드한 파일은 압축 파일 형태다.

압축을 해제한 뒤, 작업하기 편한 위치로 이동시킨다.

예시:

```text
C:/Users/사용자명/oracle_wallet/Wallet_DBName
```

Mac 또는 Linux 예시:

```text
/Users/사용자명/oracle_wallet/Wallet_DBName
```

중요한 점은 이 경로를 이후 `application.yml`에 입력해야 한다는 것이다.

---

## 4. Spring Boot 프로젝트 생성

Spring Initializr 또는 IntelliJ Ultimate의 Spring Initializr 기능을 사용해 프로젝트를 생성한다.

기본 설정은 다음과 같이 잡을 수 있다.

```text
Language: Java
Build Tool: Gradle
Packaging: Jar
Java: 17 이상
Spring Boot: 3.x
```

Spring Boot 3 이상은 Java 17 이상이 필요하므로
JDK는 17 이상을 사용하면 된다.

---

## 5. 필수 의존성 추가

Oracle DB 연결을 위해 필요한 핵심 의존성은 다음이다.

```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    runtimeOnly 'com.oracle.database.jdbc:ojdbc11'
}
```

역할은 다음과 같다.

| 의존성             | 역할                  |
| --------------- | ------------------- |
| Spring Data JPA | ORM 기반 DB 접근        |
| Oracle Driver   | Oracle DB 연결 Driver |

JDBC 방식으로 직접 쿼리를 사용할 경우 JDBC 의존성을 추가할 수도 있다.

---

## 6. 전자지갑 연결용 추가 의존성

Oracle ATP 전자지갑 방식은 일반 Oracle JDBC 연결보다 추가 의존성이 필요하다.

예시는 다음과 같다.

```gradle
dependencies {
    implementation 'com.oracle.database.security:oraclepki'
    implementation 'com.oracle.database.security:osdt_core'
    implementation 'com.oracle.database.security:osdt_cert'
}
```

이 의존성들은 전자지갑 기반 보안 연결을 처리하는 데 필요하다.

추가 후에는 반드시 Gradle Reload를 실행한다.

---

## 7. application.yml 설정

단일 DB 연결은 별도의 `Configuration` 클래스를 만들지 않고
`application.yml` 또는 `application.properties` 설정만으로 연결할 수 있다.

예시는 다음과 같다.

```yaml
spring:
  datasource:
    driver-class-name: oracle.jdbc.OracleDriver
    url: jdbc:oracle:thin:@DB이름_high?TNS_ADMIN=C:/Users/사용자명/oracle_wallet/Wallet_DBName
    username: ADMIN
    password: 비밀번호

  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
```

여기서 가장 중요한 부분은 `TNS_ADMIN`이다.

```yaml
TNS_ADMIN=C:/Users/사용자명/oracle_wallet/Wallet_DBName
```

이 값에는 전자지갑 압축을 해제한 폴더 경로를 입력한다.

Windows 환경에서는 `\` 대신 `/`를 사용하는 것이 좋다.

```text
잘못된 예:
C:\Users\user\wallet

권장 예:
C:/Users/user/wallet
```

---

## 8. DB 이름 뒤의 high, medium, low 의미

Oracle ATP 연결 문자열에는 보통 다음과 같은 값이 붙는다.

```text
DB이름_high
DB이름_medium
DB이름_low
```

각 의미는 다음과 같다.

| 값      | 특징                         |
| ------ | -------------------------- |
| high   | 쿼리 성능 우선, 동시 접속 수 상대적으로 적음 |
| medium | 성능과 동시성 균형                 |
| low    | 동시 접속 수 우선                 |

실습이나 단순 연결 확인 목적이라면 `high`를 사용해도 된다.

---

## 9. DDL 설정

Entity 기반으로 테이블을 자동 생성하거나 수정하려면 다음 옵션을 사용한다.

```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: update
```

주요 옵션은 다음과 같다.

| 옵션       | 설명                     |
| -------- | ---------------------- |
| create   | 실행 시 기존 테이블 삭제 후 새로 생성 |
| update   | 변경 사항만 반영              |
| none     | 아무 작업도 하지 않음           |
| validate | Entity와 Table 구조 검증    |

개발 환경에서는 `update`를 사용할 수 있지만,
운영 환경에서는 `none` 또는 `validate`가 안전하다.

---

## 10. 네이밍 전략 설정

Entity 필드명을 DB 컬럼명에 그대로 반영하고 싶다면 네이밍 전략을 설정할 수 있다.

```yaml
spring:
  jpa:
    hibernate:
      naming:
        physical-strategy: org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
```

기본 설정에서는 `userName`이 `user_name`처럼 변환될 수 있다.

위 설정을 추가하면 Entity 변수명을 최대한 그대로 사용할 수 있다.

---

## 11. 연결 확인 방법

설정이 끝난 뒤 애플리케이션을 실행한다.

정상 연결되면 다음과 같이 애플리케이션이 종료되지 않고 실행된다.

```text
Started Application
```

반대로 설정이 잘못되면 실행 중 DB 연결 오류가 발생하며 애플리케이션이 종료된다.

---

## 12. 연결 실패 시 확인할 것

Oracle ATP 연결이 실패한다면 다음을 확인한다.

---

### 1) 전자지갑 경로 오류

가장 흔한 문제다.

```text
TNS_ADMIN 경로가 실제 전자지갑 폴더를 가리키는지 확인
```

---

### 2) 전자지갑 의존성 누락

다음 의존성이 누락되면 전자지갑 방식 연결에서 오류가 발생할 수 있다.

```gradle
implementation 'com.oracle.database.security:oraclepki'
implementation 'com.oracle.database.security:osdt_core'
implementation 'com.oracle.database.security:osdt_cert'
```

---

### 3) Oracle Cloud ACL 설정

Oracle Cloud ATP는 접근 가능한 IP 대역을 제한할 수 있다.

따라서 로컬 PC 또는 서버 IP가 허용되어 있는지 확인해야 한다.

```text
Oracle Cloud Console
→ Database
→ Network
→ Access Control List
→ 현재 IP 허용
```

---

### 4) ID / 비밀번호 오류

기본적으로 ATP는 `ADMIN` 계정을 많이 사용한다.

```yaml
username: ADMIN
password: 설정한 비밀번호
```

비밀번호가 틀리면 인증 오류가 발생한다.

---

## 13. MySQL 연결과 Oracle ATP 연결 차이

| 구분       | MySQL       | Oracle ATP         |
| -------- | ----------- | ------------------ |
| 연결 방식    | URL + 계정 정보 | URL + 계정 정보 + 전자지갑 |
| 보안       | 일반 TCP 연결   | Wallet 기반 보안 연결    |
| 설정 난이도   | 쉬움          | 상대적으로 복잡           |
| 추가 파일    | 없음          | Wallet 필요          |
| 클라우드 최적화 | 직접 구성       | Oracle Cloud 최적화   |

---

## 14. 실무 관점에서 중요한 포인트

Oracle ATP 전자지갑 방식은 보안성이 높지만, 설정 경로와 의존성에 민감하다.

특히 다음 사항은 실무에서 반드시 분리 관리하는 것이 좋다.

```text
DB URL
DB Username
DB Password
Wallet 경로
```

운영 환경에서는 `application.yml`에 직접 넣기보다:

```text
환경 변수
Secret Manager
CI/CD 변수
서버 외부 설정 파일
```

등으로 분리하는 것이 안전하다.

---

## 정리

이번 글에서는 Spring Boot에서 Oracle ATP 데이터베이스를
전자지갑 방식으로 단일 연결하는 방법을 정리했다.

핵심은 다음이다.

```text
전자지갑 다운로드
Oracle Driver 추가
전자지갑 의존성 추가
application.yml에 TNS_ADMIN 경로 설정
DB 접속 정보 입력
ACL 접근 허용 확인
```

Oracle ATP는 일반적인 DB 연결보다 설정이 복잡하지만,
전자지갑 기반 연결을 통해 더 안전한 클라우드 DB 연결 구조를 만들 수 있다.

제공된 정리 자료에서도 Oracle ATP 연결은 전자지갑 다운로드, 의존성 추가, application 설정, ACL 확인 순서로 진행된다고 설명하고 있다. 
