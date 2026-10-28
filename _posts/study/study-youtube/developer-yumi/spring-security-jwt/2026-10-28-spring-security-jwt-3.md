---
layout: post
bigtitle: '스프링 시큐리티 JWT'
subtitle: 스프링 시큐리티 JWT - 3. Security Config 클래스 (STATELESS)
date: '2026-10-27 00:00:02 +0900'
categories:
    - spring-security-jwt
comments: true


---

# 스프링 시큐리티 JWT - 3. Security Config 클래스 (STATELESS)
[https://youtu.be/A3YsWHGbeZQ?si=4ay4bd3Y6fvygmHQ](https://youtu.be/A3YsWHGbeZQ?si=4ay4bd3Y6fvygmHQ)

# 스프링 시큐리티 JWT - 3. Security Config 클래스 (STATELESS)
* toc
{:toc}

---

### Spring Security 6 JWT SecurityConfig 완벽 정리: SecurityFilterChain, Stateless, CSRF, 인증·인가 설정

Spring Security는 Spring Boot 애플리케이션에서 인증(Authentication)과 인가(Authorization)를 처리하기 위한 보안 프레임워크다.

사용자의 로그인 요청을 검증하고, 인증된 사용자가 접근할 수 있는 API를 구분하며, 애플리케이션의 보안 정책을 일관되게 적용하는 역할을 담당한다.

Spring Boot 프로젝트에 Spring Security 의존성을 추가하면 기본적으로 대부분의 요청에 인증이 요구된다.

하지만 JWT 기반 REST API 서버를 구현하려면 이러한 기본 동작을 서비스의 요구사항에 맞게 변경해야 한다.

예를 들어 다음과 같은 API가 있다고 생각해보자.

| API      | 접근 조건                 |
| -------- | --------------------- |
| `/login` | 누구나 접근 가능             |
| `/join`  | 누구나 접근 가능             |
| `/`      | 인증된 사용자만 접근 가능        |
| `/admin` | 관리자 권한이 있는 사용자만 접근 가능 |

로그인과 회원가입은 아직 인증되지 않은 사용자도 이용할 수 있어야 한다.

반면 일반 API는 인증이 필요하고, 관리자 API는 추가적인 권한이 필요하다.

또한 JWT 인증은 일반적으로 매 요청마다 토큰을 검증하는 Stateless 방식으로 구성하므로 서버에 로그인 세션을 유지할 필요가 없다.

이러한 요구사항을 Spring Security에 전달하는 설정 클래스가 **SecurityConfig**다.

```mermaid
flowchart TD
    A["Client"] --> B["Spring Security"]

    B --> C["SecurityFilterChain"]

    C --> D["CSRF 정책"]
    C --> E["로그인 방식"]
    C --> F["세션 관리"]
    C --> G["URL별 접근 권한"]

    D --> H["Controller"]
    E --> H
    F --> H
    G --> H
```

이번에는 Spring Security 6.2.1을 기준으로 `SecurityConfig` 클래스를 구현하고, 각 설정이 실제 HTTP 요청에 어떤 영향을 미치는지 자세히 살펴본다.

---

### 개념

#### SecurityConfig란?

`SecurityConfig`는 Spring Security의 보안 정책을 설정하기 위해 작성하는 클래스다.

일반적으로 다음과 같은 설정을 담당한다.

* HTTP 요청에 적용할 보안 필터 구성
* CSRF 보호 정책
* Form Login 및 HTTP Basic 인증 활성화 여부
* URL별 접근 권한 설정
* 세션 생성 및 인증 상태 관리 정책
* 비밀번호 해시 처리를 위한 PasswordEncoder 등록
* JWT 인증 필터 등 사용자 정의 보안 구성요소 연결

예를 들어 일반 사용자가 관리자 API에 접근하는 상황을 생각해보자.

```http
GET /admin HTTP/1.1
Host: localhost:8080
Authorization: Bearer <ACCESS_TOKEN>
```

Spring Security는 해당 요청을 처리할 때 보안 정책을 확인한다.

```text
GET /admin
    ↓
Spring Security Filter Chain
    ↓
인증 정보 확인
    ↓
사용자 권한 확인
    ↓
ROLE_ADMIN 존재 여부 판단
    ↓
접근 허용 또는 거부
```

이때 `/admin` 경로에 관리자 권한을 요구하도록 설정하는 곳이 `SecurityConfig`다.

즉 `SecurityConfig`는 사용자 정보를 직접 저장하거나 JWT를 직접 생성하는 클래스가 아니다.

**HTTP 요청에 어떤 인증 방식과 인가 규칙을 적용할 것인지 정의하는 클래스**라고 이해하면 된다.

#### Spring Security 6에서 달라진 설정 방식

Spring Security는 버전에 따라 설정 방식이 변화해 왔다.

과거에는 `WebSecurityConfigurerAdapter`를 상속하여 보안 설정을 구현하는 방식이 널리 사용되었다.

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig
        extends WebSecurityConfigurerAdapter {

    // 이전 버전에서 사용하던 방식
}
```

하지만 `WebSecurityConfigurerAdapter`는 Spring Security 5.7에서 Deprecated 처리되었고, Spring Security 6에서는 제거되었다.

따라서 Spring Security 6에서는 해당 클래스를 상속할 수 없다.

대신 `SecurityFilterChain`을 Bean으로 등록하는 방식을 사용한다.

```java
@Bean
public SecurityFilterChain filterChain(
        HttpSecurity http
) throws Exception {

    return http.build();
}
```

두 방식의 차이를 정리하면 다음과 같다.

| 구분       | 이전 방식                        | Spring Security 6        |
| -------- | ---------------------------- | ------------------------ |
| 주요 구성 방식 | 클래스 상속                       | Bean 등록                  |
| 핵심 클래스   | WebSecurityConfigurerAdapter | SecurityFilterChain      |
| 설정 메서드   | configure(HttpSecurity)      | SecurityFilterChain Bean |
| 의존성 주입   | 상속 기반 설정                     | 필요한 객체를 직접 주입            |
| 권장 방식    | 사용하지 않음                      | 컴포넌트 기반 설정               |

Spring Security 공식 문서에서도 `SecurityFilterChain` Bean을 이용해 HTTP 보안 정책을 구성하는 방식을 제공한다.

---

### 왜 SecurityConfig가 필요한가?

Spring Security 의존성만 추가한 애플리케이션에서는 기본 보안 설정이 적용된다.

예를 들어 다음 의존성이 존재한다고 생각해보자.

```gradle
implementation 'org.springframework.boot:spring-boot-starter-security'
```

별도의 보안 설정이 없다면 Spring Boot는 Spring Security의 기본 인증 구성을 활성화할 수 있다.

일반적으로 다음 기능이 적용된다.

| 기능         | 기본 동작             |
| ---------- | ----------------- |
| 인증         | 대부분의 요청에 인증 요구    |
| 로그인        | 기본 Form Login 제공  |
| HTTP Basic | 기본 인증 방식 제공       |
| CSRF       | 보호 활성화            |
| 사용자 계정     | 개발용 기본 사용자 생성 가능  |
| 인증 상태      | 세션 기반 인증 구조 사용 가능 |

그런데 JWT 기반 REST API 서버에서는 요구사항이 다르다.

HTML 로그인 페이지를 제공하지 않고, JSON 요청을 받아 로그인하도록 구성할 수 있다.

로그인에 성공하면 JWT를 발급하고, 이후 요청에서는 해당 토큰을 HTTP 헤더로 전달받는다.

```text
Client
    ↓
POST /login
    ↓
아이디·비밀번호 검증
    ↓
JWT 발급
    ↓
Client에 JWT 반환
```

이후 요청에서는 JWT를 검증한다.

```text
Client
    ↓
Authorization: Bearer JWT
    ↓
JWT 검증
    ↓
Authentication 생성
    ↓
인가 처리
    ↓
Controller 실행
```

따라서 다음과 같은 설정이 필요하다.

**첫째, 기본 Form Login을 비활성화한다.**

**둘째, HTTP Basic 인증을 비활성화한다.**

**셋째, 로그인과 회원가입 경로를 공개한다.**

**넷째, 관리자 API에 별도의 권한을 요구한다.**

**다섯째, 인증 상태를 서버 세션에 유지하지 않도록 설정한다.**

이를 한곳에서 구성할 수 있도록 `SecurityConfig`를 작성한다.

---

### SecurityConfig 클래스 생성

#### 프로젝트 구조

기존 Spring Boot 프로젝트에 `config` 패키지를 추가한다.

```text
src
└── main
    └── java
        └── com
            └── example
                └── jwt
                    ├── JwtApplication.java
                    │
                    ├── config
                    │   └── SecurityConfig.java
                    │
                    └── controller
                        ├── MainController.java
                        └── AdminController.java
```

`SecurityConfig`는 메인 애플리케이션 클래스의 하위 패키지에 배치한다.

이렇게 하면 Spring Boot의 기본 컴포넌트 스캔 범위에 포함된다.

#### @Configuration

먼저 클래스를 작성한다.

```java
package com.example.jwt.config;

import org.springframework.context.annotation.Configuration;

@Configuration
public class SecurityConfig {

}
```

`@Configuration`은 해당 클래스가 Spring의 설정 정보를 제공한다는 의미다.

Spring은 이 클래스 안에 선언된 `@Bean` 메서드를 처리하여 객체를 Spring 컨테이너에 등록할 수 있다.

예를 들어 다음과 같다.

```java
@Configuration
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

이렇게 등록한 `PasswordEncoder`는 다른 Spring Bean에서 의존성 주입을 통해 사용할 수 있다.

#### @EnableWebSecurity

다음으로 `@EnableWebSecurity`를 추가한다.

```java
package com.example.jwt.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

}
```

`@EnableWebSecurity`는 Spring Security의 Servlet 기반 웹 보안 구성을 활성화하는 Annotation이다.

Spring Security의 Java 설정을 명시적으로 구성할 때 사용할 수 있다.

Spring Boot에서는 Security 자동 구성에 의해 웹 보안 기능이 이미 활성화될 수 있으므로, 모든 프로젝트에서 `@EnableWebSecurity`를 반드시 직접 작성해야 하는 것은 아니다.

다만 보안 설정을 명시적으로 표현하기 위해 함께 선언할 수 있다.

```text
@Configuration
    ↓
Spring 설정 클래스 등록

@EnableWebSecurity
    ↓
Spring Security 웹 보안 구성 활성화
```

이제 `SecurityFilterChain`을 등록할 준비가 되었다.

---

### SecurityFilterChain이란?

`SecurityFilterChain`은 HTTP 요청에 적용할 Spring Security 필터들의 구성을 나타낸다.

Spring Security는 Controller가 요청을 처리하기 전에 Servlet Filter 기반 보안 처리를 수행한다.

예를 들어 클라이언트가 다음 요청을 보낸다고 생각해보자.

```http
GET /admin HTTP/1.1
Host: localhost:8080
```

이 요청은 곧바로 `AdminController`에 전달되는 것이 아니다.

먼저 Spring Security의 필터 체인을 통과한다.

```mermaid
flowchart TD
    A["Client"] --> B["Servlet Filter Chain"]

    B --> C["Spring Security Filter Chain"]

    C --> D["인증 처리"]
    D --> E["인가 처리"]

    E --> F{"접근 허용?"}

    F -->|Yes| G["DispatcherServlet"]
    G --> H["AdminController"]

    F -->|No| I["접근 거부 응답"]
```

실제로는 여러 보안 필터가 정해진 순서에 따라 실행된다.

대표적으로 다음과 같은 구성요소들이 관여할 수 있다.

| 구성요소                          | 역할                |
| ----------------------------- | ----------------- |
| SecurityContext 관련 필터         | 현재 요청의 보안 컨텍스트 관리 |
| LogoutFilter                  | 로그아웃 처리           |
| 인증 필터                         | 사용자 인증 수행         |
| AnonymousAuthenticationFilter | 익명 사용자 인증 표현      |
| ExceptionTranslationFilter    | 인증·인가 예외 처리 연결    |
| AuthorizationFilter           | 접근 권한 판단          |

실제 필터의 종류와 순서는 활성화한 인증 방식 및 Spring Security 설정에 따라 달라진다.

여기서 중요한 점은 `SecurityFilterChain`이 직접 사용자의 비밀번호를 검증하는 클래스는 아니라는 것이다.

**HTTP 요청에 적용할 보안 필터와 정책을 구성하는 역할**을 담당한다.

---

### SecurityFilterChain Bean 등록하기

다음과 같이 `SecurityFilterChain`을 Bean으로 등록한다.

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(
            HttpSecurity http
    ) throws Exception {

        return http.build();
    }
}
```

코드를 자세히 살펴보자.

#### @Bean

```java
@Bean
```

해당 메서드의 반환 객체를 Spring 컨테이너에 등록한다.

Spring Security는 등록된 `SecurityFilterChain`을 이용해 애플리케이션의 HTTP 보안 정책을 적용한다.

#### HttpSecurity

```java
HttpSecurity http
```

`HttpSecurity`는 HTTP 보안 설정을 구성하는 Builder다.

대표적으로 다음 설정을 제공한다.

```java
http.csrf(...)
```

```java
http.formLogin(...)
```

```java
http.httpBasic(...)
```

```java
http.authorizeHttpRequests(...)
```

```java
http.sessionManagement(...)
```

이러한 메서드를 이용해 인증, 인가, 세션, 보안 정책을 설정한다.

#### http.build()

```java
return http.build();
```

`HttpSecurity`에 정의한 설정을 바탕으로 `SecurityFilterChain`을 생성한다.

즉 다음과 같은 관계다.

```text
HttpSecurity
    ↓
보안 정책 설정
    ↓
http.build()
    ↓
SecurityFilterChain
    ↓
Spring Security에 등록
```

이제 실제 JWT 기반 REST API 서버에 필요한 설정을 추가해보자.

---

### CSRF 비활성화 설정

가장 먼저 CSRF 보호 정책을 설정한다.

```java
http.csrf(
        AbstractHttpConfigurer::disable
);
```

일반적으로 메서드 체이닝을 사용하면 다음과 같이 작성한다.

```java
http
        .csrf(AbstractHttpConfigurer::disable);
```

#### CSRF란?

CSRF(Cross-Site Request Forgery)는 사용자가 의도하지 않은 요청을 다른 웹사이트가 발생시키도록 유도하는 공격이다.

예를 들어 사용자가 은행 서비스에 로그인한 상태라고 생각해보자.

브라우저는 은행 서비스의 세션 쿠키를 가지고 있다.

```http
Cookie: JSESSIONID=...
```

사용자가 공격자가 만든 사이트에 접속한다.

이 사이트에서 은행 서비스로 송금 요청을 발생시키면 브라우저의 쿠키 자동 전송 기능이 악용될 수 있다.

```mermaid
sequenceDiagram
    participant U as 사용자
    participant B as Browser
    participant A as 공격자 사이트
    participant S as 은행 서버

    U->>B: 은행 로그인
    B->>S: 로그인 요청
    S-->>B: 세션 쿠키 발급

    U->>A: 공격자 사이트 접속
    A-->>B: 송금 요청 유도

    B->>S: 송금 요청 + 자동 전송된 쿠키

    Note over S: 요청이 사용자의 의도와 일치하는지 검증 필요
```

서버가 세션 쿠키의 존재만으로 요청을 신뢰한다면 문제가 발생할 수 있다.

이러한 공격에 대응하기 위해 CSRF Token을 이용한 요청 검증 등의 보호 장치를 사용할 수 있다.

#### JWT 인증에서는 왜 CSRF를 비활성화할까?

이번에 구현하는 REST API는 다음 구조를 전제로 한다.

```http
Authorization: Bearer <ACCESS_TOKEN>
```

클라이언트가 JWT를 Authorization 헤더에 명시적으로 추가한다.

그리고 서버는 인증 상태를 HttpSession에 저장하지 않는다.

이처럼 브라우저가 자동으로 전송하는 인증 쿠키에 의존하지 않는 API에서는 CSRF 보호를 비활성화하는 구성이 사용될 수 있다.

```java
.csrf(AbstractHttpConfigurer::disable)
```

다만 주의해야 할 점이 있다.

**JWT를 사용하거나 Stateless로 구성했다는 이유만으로 CSRF 공격이 무조건 불가능해지는 것은 아니다.**

예를 들어 JWT를 쿠키에 저장하고 브라우저가 해당 쿠키를 자동으로 전송한다면 CSRF 위협을 다시 고려해야 한다.

Spring Security 공식 문서에서도 Stateless 애플리케이션이라고 해서 자동으로 CSRF 공격에 안전한 것은 아니라고 설명한다.

따라서 다음과 같이 구분해야 한다.

| 인증 구조                  | CSRF 검토                     |
| ---------------------- | --------------------------- |
| 서버 세션 + 인증 쿠키          | CSRF 보호 필요                  |
| JWT + Authorization 헤더 | 인증 쿠키에 의존하지 않는다면 비활성화 검토 가능 |
| JWT + 자동 전송 쿠키         | CSRF 보호 필요성 검토              |
| HTTP Basic + 브라우저      | CSRF 위험 검토 필요               |

결국 중요한 것은 JWT 사용 여부 자체가 아니라 **브라우저가 인증 정보를 자동으로 전송하는 구조인지**다.

---

### Form Login 비활성화

다음으로 Spring Security가 제공하는 기본 Form Login을 비활성화한다.

```java
.formLogin(AbstractHttpConfigurer::disable)
```

#### Form Login이란?

Form Login은 사용자가 HTML 로그인 페이지에서 아이디와 비밀번호를 입력하는 인증 방식이다.

일반적인 동작은 다음과 같다.

```text
사용자
    ↓
로그인 페이지 접근
    ↓
아이디·비밀번호 입력
    ↓
POST /login
    ↓
Spring Security 인증
    ↓
로그인 성공
```

Spring Security는 기본적인 로그인 화면과 인증 처리 기능을 제공할 수 있다.

하지만 JWT 기반 REST API에서는 HTML 로그인 페이지를 제공하지 않고 JSON 요청으로 로그인할 수 있도록 구성하려고 한다.

예를 들어 다음과 같다.

```http
POST /login HTTP/1.1
Content-Type: application/json
```

```json
{
  "username": "user01",
  "password": "password123!"
}
```

이 요청은 별도로 구현할 로그인 Controller 또는 로그인 인증 필터에서 처리할 수 있다.

따라서 기본 Form Login 기능을 비활성화한다.

```java
.formLogin(AbstractHttpConfigurer::disable)
```

이 설정을 적용하면 기본 Form Login의 로그인 페이지와 인증 처리 기능을 사용하지 않도록 구성할 수 있다.

여기서 중요한 점은 **Form Login을 비활성화했다고 해서 사용자 로그인 기능 자체가 사라져야 한다는 의미는 아니라는 것**이다.

기본 제공 인증 방식을 사용하지 않고 JWT 발급을 위한 로그인 기능을 별도로 구현한다는 의미다.

---

### HTTP Basic 비활성화

다음으로 HTTP Basic 인증을 비활성화한다.

```java
.httpBasic(AbstractHttpConfigurer::disable)
```

#### HTTP Basic 인증이란?

HTTP Basic은 HTTP Authorization 헤더에 사용자 이름과 비밀번호를 인코딩하여 전달하는 인증 방식이다.

예를 들어 다음과 같은 형태다.

```http
Authorization: Basic dXNlcjpwYXNzd29yZA==
```

여기서 Base64로 인코딩된 데이터는 일반적으로 다음과 같은 형식이다.

```text
username:password
```

중요한 점은 Base64가 암호화가 아니라는 것이다.

따라서 HTTP Basic 인증을 사용하는 경우에도 HTTPS가 필요하다.

#### JWT Bearer 인증과의 차이

HTTP Basic과 JWT Bearer는 모두 Authorization 헤더를 사용할 수 있다.

하지만 전달하는 정보가 다르다.

**HTTP Basic**

```http
Authorization: Basic <BASE64_USERNAME_PASSWORD>
```

**JWT Bearer**

```http
Authorization: Bearer <JWT>
```

HTTP Basic은 사용자 이름과 비밀번호를 기반으로 인증한다.

JWT Bearer는 발급받은 토큰을 이용해 인증한다.

이번 프로젝트는 JWT를 사용하므로 HTTP Basic을 비활성화한다.

```java
.httpBasic(AbstractHttpConfigurer::disable)
```

두 가지 인증 방식의 차이를 정리하면 다음과 같다.

| 구분         | HTTP Basic   | JWT Bearer |
| ---------- | ------------ | ---------- |
| 전달 정보      | 사용자 이름과 비밀번호 | 발급받은 토큰    |
| Header     | Basic        | Bearer     |
| 인증 상태 복원   | 자격 증명 검증     | 토큰 검증      |
| 비밀번호 반복 전송 | 일반적으로 발생     | 필요 없음      |
| HTTPS 필요   | 필요           | 필요         |

JWT 역시 탈취되면 악용될 수 있으므로 HTTPS와 안전한 토큰 관리가 필요하다.

---

### authorizeHttpRequests로 URL별 접근 권한 설정하기

이번에는 Spring Security의 인가 정책을 설정한다.

인가(Authorization)는 사용자가 특정 API에 접근할 수 있는지 판단하는 과정이다.

Spring Security 6에서는 `authorizeHttpRequests()`를 이용해 URL별 접근 권한을 설정할 수 있다.

```java
.authorizeHttpRequests(auth -> auth
        .requestMatchers("/login", "/join").permitAll()
        .requestMatchers("/admin", "/admin/**").hasRole("ADMIN")
        .anyRequest().authenticated()
)
```

이 설정을 순서대로 살펴보자.

#### 1. 로그인 및 회원가입 경로 허용

```java
.requestMatchers("/login", "/join").permitAll()
```

`requestMatchers()`는 요청 경로를 지정한다.

`permitAll()`은 해당 경로의 접근을 인증 없이 허용한다.

따라서 다음 경로는 로그인하지 않은 사용자도 접근할 수 있다.

```http
POST /login
```

```http
POST /join
```

이 설정이 필요한 이유는 로그인하지 않은 사용자가 로그인 기능을 이용해야 하기 때문이다.

만약 `/login`에도 인증을 요구한다면 아직 인증되지 않은 사용자는 로그인 API에 접근할 수 없게 된다.

```text
사용자
    ↓
로그인 요청
    ↓
로그인 API도 인증 필요
    ↓
인증되지 않아 접근 불가
```

따라서 인증을 시작하는 API는 별도의 공개 정책이 필요하다.

다만 다음 설정은:

```java
.requestMatchers("/login", "/join").permitAll()
```

**해당 URL을 자동으로 생성하는 기능이 아니다.**

로그인과 회원가입 Controller 또는 인증 필터는 별도로 구현해야 한다.

즉 URL에 대한 접근을 허용하더라도 해당 경로를 처리하는 코드가 없다면 정상적인 로그인이나 회원가입이 수행되지 않는다.

또한 `permitAll()`은 인증 요구를 생략한다는 의미이지, 입력값 검증이나 비즈니스 보안 검사를 생략한다는 의미는 아니다.

#### 2. 관리자 API 접근 제한

다음 설정을 살펴보자.

```java
.requestMatchers("/admin", "/admin/**").hasRole("ADMIN")
```

`hasRole("ADMIN")`은 사용자가 관리자 역할을 가지고 있는지 확인한다.

예를 들어 일반 사용자에게는 다음 권한이 있다고 생각해보자.

```text
ROLE_USER
```

관리자에게는 다음 권한이 있다.

```text
ROLE_ADMIN
```

일반 사용자가 `/admin`에 접근하면 권한이 부족하므로 요청이 거부된다.

반면 `ROLE_ADMIN` 권한이 있는 사용자는 해당 URL에 접근할 수 있다.

```mermaid
flowchart TD
    A["GET /admin"] --> B["Spring Security"]

    B --> C["Authentication 확인"]

    C --> D{"ROLE_ADMIN 보유?"}

    D -->|Yes| E["AdminController 실행"]
    D -->|No| F["접근 거부"]
```

여기서는 다음 두 경로를 함께 지정했다.

```java
"/admin", "/admin/**"
```

기존 Controller의 경로가 `/admin`이기 때문에 해당 URL을 명시적으로 포함한 것이다.

`/admin/**`는 `/admin/users`, `/admin/settings` 등 하위 경로를 보호하기 위한 패턴으로 사용할 수 있다.

#### 3. 나머지 API는 인증 요구

```java
.anyRequest().authenticated()
```

`anyRequest()`는 앞에서 정의한 규칙에 해당하지 않는 나머지 요청을 의미한다.

`authenticated()`는 해당 요청에 인증된 사용자가 필요하다는 의미다.

예를 들어 다음과 같다.

```http
GET /
```

```http
GET /products
```

```http
GET /orders
```

별도로 공개하지 않았다면 인증된 사용자만 접근할 수 있다.

이러한 정책을 적용하면 개발자가 특정 API의 권한 설정을 누락했을 때도 기본적으로 인증을 요구하도록 구성할 수 있다.

Spring Security는 인가 규칙을 선언된 순서대로 평가하며, 처음 일치하는 규칙을 적용한다.

---

### hasRole과 hasAuthority의 차이

인가 정책을 구현할 때 자주 혼동하는 부분이다.

Spring Security에서는 역할과 권한을 다음과 같은 메서드로 검사할 수 있다.

```java
hasRole("ADMIN")
```

```java
hasAuthority("ROLE_ADMIN")
```

기본적인 역할 접두사 설정에서는 두 표현이 같은 권한을 검사한다.

#### hasRole

```java
.hasRole("ADMIN")
```

일반적으로 내부적으로 `ROLE_` 접두사가 적용된다.

따라서 실제 Authentication에 다음 권한이 존재해야 한다.

```text
ROLE_ADMIN
```

#### hasAuthority

```java
.hasAuthority("ROLE_ADMIN")
```

`hasAuthority()`는 지정한 권한 문자열을 직접 비교한다.

따라서 `ROLE_ADMIN`이라는 값을 그대로 지정한다.

차이를 정리하면 다음과 같다.

| 설정                           | 실제 확인할 권한    |
| ---------------------------- | ------------ |
| `hasRole("ADMIN")`           | `ROLE_ADMIN` |
| `hasAuthority("ROLE_ADMIN")` | `ROLE_ADMIN` |
| `hasAuthority("ADMIN")`      | `ADMIN`      |

따라서 다음과 같이 작성하면 문제가 발생할 수 있다.

```java
.hasRole("ROLE_ADMIN")
```

`hasRole()`은 기본적으로 `ROLE_` 접두사를 추가하는 방식이므로 일반적인 설정에서는 접두사를 직접 포함하지 않아야 한다.

Spring Security 공식 문서에서도 `hasRole()`과 `hasAuthority()`의 차이를 명확하게 구분하고 있다.

#### JWT와 권한 정보의 관계

향후 JWT에 사용자 권한을 포함한다면 다음과 같은 Claim을 사용할 수 있다.

```json
{
  "sub": "user01",
  "role": "ROLE_ADMIN"
}
```

다만 JWT에 `ROLE_ADMIN`이라는 문자열이 존재한다고 Spring Security가 자동으로 관리자 권한을 부여하는 것은 아니다.

토큰 검증 후 해당 값을 `GrantedAuthority`로 변환하고, `Authentication`에 설정하는 과정이 필요하다.

```text
JWT 검증
    ↓
role Claim 추출
    ↓
GrantedAuthority 생성
    ↓
Authentication 구성
    ↓
hasRole("ADMIN") 검사
```

따라서 URL별 인가 정책과 JWT 인증 정보 구성을 함께 고려해야 한다.

---

### SessionCreationPolicy.STATELESS 설정

JWT 기반 REST API에서 가장 중요한 설정 중 하나다.

```java
.sessionManagement(session -> session
        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
)
```

이 설정을 이해하려면 먼저 세션 기반 인증과 JWT 인증의 차이를 살펴볼 필요가 있다.

#### 세션 기반 인증

일반적인 세션 기반 로그인에서는 인증 성공 후 서버에 인증 상태를 저장하도록 구성할 수 있다.

```text
로그인 요청
    ↓
사용자 인증 성공
    ↓
HttpSession에 인증 상태 저장
    ↓
세션 식별자 발급
```

이후 클라이언트는 세션 식별자를 전달한다.

```http
Cookie: JSESSIONID=...
```

서버는 해당 세션을 조회하여 인증 정보를 복원할 수 있다.

```mermaid
sequenceDiagram
    participant C as Client
    participant S as Server
    participant H as HttpSession

    C->>S: 로그인 요청
    S->>H: 인증 정보 저장
    S-->>C: JSESSIONID 전달

    C->>S: 보호된 API 요청 + JSESSIONID
    S->>H: 세션 조회
    H-->>S: Authentication 정보
    S-->>C: API 응답
```

#### JWT 기반 Stateless 인증

JWT 인증에서는 일반적으로 로그인 성공 시 토큰을 발급한다.

```text
로그인 요청
    ↓
사용자 인증 성공
    ↓
JWT 생성
    ↓
JWT 반환
```

이후 클라이언트는 각 요청마다 JWT를 전달한다.

```http
Authorization: Bearer <ACCESS_TOKEN>
```

서버는 토큰을 검증하여 현재 요청에 필요한 인증 정보를 구성한다.

```mermaid
sequenceDiagram
    participant C as Client
    participant F as JWT 인증 처리
    participant S as SecurityContext
    participant API as Controller

    C->>F: API 요청 + JWT
    F->>F: JWT 서명 및 유효기간 검증
    F->>S: Authentication 구성
    F->>API: 요청 전달
    API-->>C: 응답

    Note over S: 요청 처리 종료 후 컨텍스트 정리

    C->>F: 다음 API 요청 + JWT
    F->>F: JWT 다시 검증
    F->>S: 새 요청의 Authentication 구성
    F->>API: 요청 전달
```

이 방식에서는 이전 요청의 인증 정보를 HttpSession에서 조회할 필요가 없다.

매 요청마다 JWT를 이용해 인증 상태를 복원할 수 있기 때문이다.

이 구조를 설정하는 것이 다음 코드다.

```java
.sessionManagement(session -> session
        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
)
```

#### SessionCreationPolicy의 종류

Spring Security는 여러 세션 생성 정책을 제공한다.

| 설정            | 의미                                            |
| ------------- | --------------------------------------------- |
| `ALWAYS`      | Spring Security가 세션을 생성                       |
| `IF_REQUIRED` | 필요한 경우 세션 생성                                  |
| `NEVER`       | Spring Security가 세션을 직접 생성하지 않지만 기존 세션은 사용 가능 |
| `STATELESS`   | Spring Security가 인증 상태를 위해 세션을 생성하거나 사용하지 않음  |

JWT 기반 인증에서는 일반적으로 `STATELESS`를 사용한다.

```java
SessionCreationPolicy.STATELESS
```

Spring Security 공식 문서에서도 Stateless 인증을 위한 설정으로 이 방식을 제공한다.

---

### Stateless에서는 SecurityContextHolder를 사용하지 않을까?

JWT를 처음 구현할 때 가장 헷갈리기 쉬운 부분이다.

Stateless는 서버 세션에 인증 상태를 유지하지 않는다는 의미다.

그렇다고 Spring Security의 `SecurityContextHolder`를 사용하지 않는 것은 아니다.

#### SecurityContextHolder란?

Spring Security는 현재 인증된 사용자 정보를 `SecurityContext`에 저장한다.

그리고 `SecurityContextHolder`를 통해 현재 컨텍스트에 접근할 수 있도록 제공한다.

```java
Authentication authentication =
        SecurityContextHolder
                .getContext()
                .getAuthentication();
```

이렇게 가져온 `Authentication`에는 사용자 정보와 권한 등이 포함될 수 있다.

그런데 중요한 점은 다음과 같다.

**SecurityContextHolder와 HttpSession은 서로 다른 개념이다.**

| 구분          | SecurityContextHolder           | HttpSession        |
| ----------- | ------------------------------- | ------------------ |
| 목적          | 현재 실행 흐름의 인증 정보 관리              | 여러 HTTP 요청 간 상태 유지 |
| 주요 데이터      | SecurityContext, Authentication | Session Attribute  |
| JWT 인증에서 사용 | 사용 가능                           | 인증 상태 저장에 필수 아님    |
| 요청 종료 후     | 일반적으로 컨텍스트 정리                   | 세션 정책에 따라 유지 가능    |

JWT 인증에서는 매 요청마다 토큰을 검증하고 `SecurityContextHolder`에 현재 요청의 인증 정보를 설정할 수 있다.

```text
Request A
    ↓
JWT 검증
    ↓
SecurityContextHolder에 Authentication 설정
    ↓
Controller 실행
    ↓
컨텍스트 정리
```

다음 요청에서도 동일한 과정이 반복된다.

```text
Request B
    ↓
JWT 검증
    ↓
SecurityContextHolder에 Authentication 설정
    ↓
Controller 실행
    ↓
컨텍스트 정리
```

따라서 Stateless라고 해서 인증 정보가 메모리에 전혀 존재하지 않는다는 의미는 아니다.

**요청 간 인증 상태를 서버 세션에 지속적으로 저장하지 않는다는 의미**다.

또한 `STATELESS` 설정은 Spring Security의 세션 사용 정책을 구성하는 것이며, 애플리케이션의 다른 코드가 모든 상황에서 HttpSession을 생성하지 못하도록 강제하는 것은 아니다.

---

### BCryptPasswordEncoder Bean 등록하기

JWT 인증 시스템에서는 로그인할 때 사용자 이름과 비밀번호를 검증해야 한다.

이를 위해 사용자 비밀번호를 안전하게 저장하는 방식이 필요하다.

일반적으로 비밀번호 원문을 데이터베이스에 저장해서는 안 된다.

예를 들어 다음과 같은 방식은 위험하다.

```text
username = user01

password = password123!
```

데이터베이스가 노출되면 비밀번호도 함께 노출되기 때문이다.

따라서 비밀번호는 안전한 비밀번호 해시 알고리즘을 이용해 저장해야 한다.

Spring Security는 이를 위해 `PasswordEncoder` 인터페이스를 제공한다.

대표적인 구현체가 `BCryptPasswordEncoder`다.

#### BCryptPasswordEncoder란?

BCrypt는 비밀번호를 안전하게 저장하기 위한 적응형 단방향 해시 알고리즘이다.

BCrypt는 내부적으로 Salt를 사용하고 연산 비용을 조절할 수 있다.

이러한 특성은 공격자가 대량의 비밀번호 후보를 빠르게 대입하기 어렵도록 만드는 데 도움이 된다.

중요한 점은 BCrypt를 사용해 생성한 비밀번호 해시를 복호화하여 원문 비밀번호를 얻는 방식이 아니라는 것이다.

로그인 시 입력한 비밀번호와 저장된 해시가 일치하는지 검증한다.

#### Bean 등록

`SecurityConfig`에 다음 메서드를 추가한다.

```java
@Bean
public PasswordEncoder passwordEncoder() {

    return new BCryptPasswordEncoder();
}
```

또는 반환 타입을 구현체로 지정할 수도 있다.

```java
@Bean
public BCryptPasswordEncoder bCryptPasswordEncoder() {

    return new BCryptPasswordEncoder();
}
```

두 방식 모두 Bean으로 등록할 수 있다.

다만 애플리케이션 코드에서는 구현체보다 `PasswordEncoder` 인터페이스에 의존하는 편이 변경에 유리하다.

```java
private final PasswordEncoder passwordEncoder;
```

이렇게 하면 향후 비밀번호 해시 정책을 변경할 때 영향을 줄일 수 있다.

---

### BCrypt 비밀번호 저장 과정

회원가입에서 비밀번호를 저장한다고 가정하자.

클라이언트가 다음 정보를 전달한다.

```json
{
  "username": "user01",
  "password": "password123!"
}
```

서버는 비밀번호를 해시한다.

```java
String encodedPassword =
        passwordEncoder.encode("password123!");
```

이후 데이터베이스에는 원문 대신 해시를 저장한다.

```text
username = user01

password = $2a$10$...
```

실제 BCrypt 결과는 Salt를 포함하므로 같은 비밀번호를 여러 번 해시하더라도 결과가 달라질 수 있다.

```java
String first = passwordEncoder.encode("password123!");

String second = passwordEncoder.encode("password123!");
```

일반적으로 두 값은 다르다.

```java
first.equals(second); // 일반적으로 false
```

이 결과는 정상적인 동작이다.

BCrypt는 해시마다 Salt를 사용하므로 같은 비밀번호라도 동일한 문자열이 생성된다고 가정하면 안 된다.

---

### BCrypt 비밀번호 검증 과정

로그인할 때는 사용자가 입력한 비밀번호와 데이터베이스에 저장된 해시를 비교한다.

이때 `matches()`를 사용한다.

```java
boolean matched = passwordEncoder.matches(
        "password123!",
        encodedPassword
);
```

첫 번째 인자는 사용자가 입력한 원문 비밀번호다.

두 번째 인자는 저장된 비밀번호 해시다.

```text
사용자 입력 비밀번호
    ↓
PasswordEncoder.matches()
    ↓
저장된 해시와 비교
    ↓
true 또는 false
```

여기서 주의해야 할 점이 있다.

다음처럼 새롭게 해시를 생성한 뒤 문자열을 비교하면 안 된다.

```java
String inputHash =
        passwordEncoder.encode(inputPassword);

boolean matched =
        inputHash.equals(savedPasswordHash);
```

BCrypt는 Salt를 사용하기 때문에 동일한 원문 비밀번호라도 매번 다른 해시가 생성될 수 있다.

따라서 `matches()`를 이용해 검증해야 한다.

Spring Security 6.2.1의 `BCryptPasswordEncoder` 역시 `encode()`와 `matches()`를 통해 이러한 기능을 제공한다.

---

### SecurityConfig 전체 코드

지금까지 살펴본 설정을 하나의 클래스로 구성해보자.

이번 프로젝트의 요구사항은 다음과 같다.

| 요구사항          | 설정        |
| ------------- | --------- |
| CSRF          | 비활성화      |
| 기본 Form Login | 비활성화      |
| HTTP Basic    | 비활성화      |
| `/login`      | 인증 없이 접근  |
| `/join`       | 인증 없이 접근  |
| `/admin`      | 관리자 권한 필요 |
| 나머지 API       | 인증 필요     |
| 세션            | Stateless |
| 비밀번호          | BCrypt    |

다음은 Spring Security 6.2.1에서 사용할 수 있는 `SecurityConfig` 전체 코드다.

```java
package com.example.jwt.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;

import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(
            HttpSecurity http
    ) throws Exception {

        http
                // CSRF 비활성화
                .csrf(AbstractHttpConfigurer::disable)

                // 기본 Form Login 비활성화
                .formLogin(AbstractHttpConfigurer::disable)

                // HTTP Basic 인증 비활성화
                .httpBasic(AbstractHttpConfigurer::disable)

                // URL별 접근 권한 설정
                .authorizeHttpRequests(auth -> auth

                        // 로그인 및 회원가입 허용
                        .requestMatchers(
                                "/login",
                                "/join"
                        ).permitAll()

                        // 관리자 권한 필요
                        .requestMatchers(
                                "/admin",
                                "/admin/**"
                        ).hasRole("ADMIN")

                        // 나머지 요청은 인증 필요
                        .anyRequest().authenticated()
                )

                // Stateless 세션 정책
                .sessionManagement(session -> session
                        .sessionCreationPolicy(
                                SessionCreationPolicy.STATELESS
                        )
                );

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {

        return new BCryptPasswordEncoder();
    }
}
```

이 코드는 JWT 기반 REST API 서버의 기본적인 보안 정책을 정의한다.

각 설정이 담당하는 역할을 정리하면 다음과 같다.

```text
SecurityConfig
│
├── @Configuration
│   └── Spring 설정 클래스
│
├── @EnableWebSecurity
│   └── 웹 보안 구성
│
├── SecurityFilterChain
│   │
│   ├── csrf
│   │   └── 비활성화
│   │
│   ├── formLogin
│   │   └── 비활성화
│   │
│   ├── httpBasic
│   │   └── 비활성화
│   │
│   ├── authorizeHttpRequests
│   │   ├── /login → permitAll
│   │   ├── /join → permitAll
│   │   ├── /admin → ROLE_ADMIN
│   │   └── 그 외 → authenticated
│   │
│   └── sessionManagement
│       └── STATELESS
│
└── PasswordEncoder
    └── BCryptPasswordEncoder
```

여기서 주목해야 할 부분은 **아직 JWT 인증 필터를 등록하지 않았다는 점**이다.

현재 설정은 JWT 인증을 위한 보안 정책만 구성한 상태다.

JWT 발급 및 검증 기능은 별도로 구현해야 한다.

---

### 현재 SecurityConfig에서 실제로 동작하는 것

앞에서 `SecurityConfig`를 작성했지만 JWT 인증이 완성된 것은 아니다.

이 차이를 정확하게 이해해야 한다.

현재 구현된 기능은 다음과 같다.

| 기능                         | 현재 상태 |
| -------------------------- | ----- |
| 기본 로그인 화면 비활성화             | 완료    |
| HTTP Basic 비활성화            | 완료    |
| 로그인 경로 공개                  | 완료    |
| 회원가입 경로 공개                 | 완료    |
| 관리자 API 접근 권한 정책           | 완료    |
| Stateless 정책               | 완료    |
| BCryptPasswordEncoder Bean | 완료    |
| 사용자 DB 조회                  | 미구현   |
| 아이디·비밀번호 인증                | 미구현   |
| JWT 발급                     | 미구현   |
| JWT 검증                     | 미구현   |
| JWT 기반 Authentication 구성   | 미구현   |

예를 들어 다음 요청을 보낸다고 생각해보자.

```http
GET /admin HTTP/1.1
Authorization: Bearer <JWT>
```

Authorization 헤더에 JWT를 넣었다고 하더라도 현재 설정만으로는 Spring Security가 토큰을 검증하지 않는다.

JWT를 읽고 검증하는 필터 또는 Resource Server 구성이 없기 때문이다.

따라서 인증 정보가 생성되지 않았고 접근 권한을 충족하지 못한다면 요청이 거부된다.

즉 다음 두 작업은 별개다.

**인가 규칙 정의**

```java
.requestMatchers("/admin").hasRole("ADMIN")
```

**JWT를 이용한 Authentication 구성**

```text
JWT 검증
    ↓
ROLE_ADMIN 추출
    ↓
Authentication 생성
    ↓
SecurityContext 설정
```

두 작업이 연결되어야 실제 JWT 기반 인가가 동작한다.

---

### JWT 인증 필터는 어디에 추가할까?

현재는 다음과 같은 구조다.

```mermaid
flowchart TD
    A["Client"] --> B["SecurityFilterChain"]

    B --> C["인증 정보 확인"]
    C --> D["인가 정책"]

    D --> E{"접근 허용?"}

    E -->|Yes| F["Controller"]
    E -->|No| G["접근 거부"]
```

향후 JWT 인증 기능이 추가되면 요청에서 전달된 토큰을 검증하는 단계가 필요하다.

```mermaid
flowchart TD
    A["Client"] --> B["SecurityFilterChain"]

    B --> C["JWT 인증 필터"]

    C --> D{"JWT 유효?"}

    D -->|Yes| E["Authentication 생성"]
    E --> F["SecurityContext 설정"]

    D -->|No| G["인증 실패 처리"]

    F --> H["인가 정책 확인"]

    H --> I{"권한 충분?"}

    I -->|Yes| J["Controller"]
    I -->|No| K["접근 거부"]
```

Spring Security에서 커스텀 JWT 필터를 사용하는 경우에는 `SecurityFilterChain`에 해당 필터를 추가할 수 있다.

대표적으로 다음 메서드를 사용할 수 있다.

```java
http.addFilterBefore(
        jwtFilter,
        UsernamePasswordAuthenticationFilter.class
);
```

이 코드는 특정 필터보다 앞에 JWT 필터를 배치하는 방법을 보여주는 예시다.

실제 구현에서는 JWT 필터의 책임, 필터 체인 내 위치, 인증 예외 처리 방식을 함께 결정해야 한다.

또한 Spring Security는 OAuth2 Resource Server를 통해 JWT Bearer 인증을 처리하는 기능도 제공하므로 모든 프로젝트에서 JWT 필터를 직접 작성해야 하는 것은 아니다.

현재 단계에서는 **SecurityConfig가 JWT 인증 필터를 연결할 수 있는 확장 지점이라는 사실**을 이해하면 된다.

---

### 구조

#### HTTP 요청이 처리되는 전체 흐름

현재 작성한 `SecurityConfig`에서 요청을 처리하는 과정을 살펴보자.

```mermaid
flowchart TD
    A["HTTP 요청"] --> B["Spring Security Filter Chain"]

    B --> C["CSRF 정책"]
    C --> D["인증 관련 필터"]

    D --> E["AuthorizationFilter"]

    E --> F{"요청 경로"}

    F -->|/login 또는 /join| G["permitAll"]

    F -->|/admin| H{"ROLE_ADMIN 확인"}

    F -->|그 외| I{"인증 여부 확인"}

    H -->|허용| J["Controller 실행"]
    H -->|거부| K["접근 거부"]

    I -->|인증됨| J
    I -->|미인증| K

    G --> J
```

이 구조에서 중요한 점은 URL별 인가 규칙이 단순히 문자열 비교만 수행하는 것은 아니라는 사실이다.

Spring Security는 현재 요청의 경로와 `Authentication`을 기반으로 정책을 평가한다.

특히 다음과 같은 규칙은:

```java
.requestMatchers("/admin").hasRole("ADMIN")
```

현재 요청의 사용자에게 `ROLE_ADMIN`이 있는지 확인할 수 있어야 한다.

따라서 인증 기능과 인가 기능은 밀접하게 연결된다.

하지만 인증과 인가의 역할은 구분되어야 한다.

```text
Authentication
    ↓
사용자가 누구인지 확인
```

```text
Authorization
    ↓
해당 사용자가 무엇에 접근할 수 있는지 확인
```

JWT는 인증 정보를 전달하는 수단으로 사용할 수 있고, Spring Security는 검증된 인증 정보를 이용해 인가를 수행한다.

---

### 예제: URL별 접근 정책 확인하기

기존 프로젝트에는 두 개의 Controller가 있다고 가정하자.

#### MainController

```java
package com.example.jwt.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MainController {

    @GetMapping("/")
    public String main() {

        return "Main Controller";
    }
}
```

#### AdminController

```java
package com.example.jwt.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AdminController {

    @GetMapping("/admin")
    public String admin() {

        return "Admin Controller";
    }
}
```

여기서 인가 규칙은 다음과 같다.

```java
.authorizeHttpRequests(auth -> auth
        .requestMatchers("/login", "/join").permitAll()
        .requestMatchers("/admin", "/admin/**").hasRole("ADMIN")
        .anyRequest().authenticated()
)
```

따라서 다음과 같은 접근 정책이 적용된다.

| 요청            | 필요한 조건        |
| ------------- | ------------- |
| GET `/`       | 인증 필요         |
| GET `/admin`  | ROLE_ADMIN 필요 |
| POST `/login` | 공개            |
| POST `/join`  | 공개            |

단, 현재는 `/login`과 `/join`을 처리하는 기능을 작성하지 않았다고 가정한다.

따라서 `permitAll()`이 설정되어 있어도 해당 API가 자동으로 동작하지는 않는다.

#### 애플리케이션 실행

다음 명령으로 Spring Boot를 실행한다.

```bash
./gradlew bootRun
```

정상적으로 실행되었다면 내장 웹 서버가 시작된다.

이제 다음 요청을 보내보자.

```bash
curl -i http://localhost:8080/
```

현재는 JWT 인증 필터가 없고 Form Login과 HTTP Basic 인증도 비활성화되어 있다.

따라서 인증 정보를 구성할 수 없다면 요청은 거부된다.

여기서 주의해야 할 점은 **현재 설정만으로 미인증 요청이 반드시 HTTP 401을 반환한다고 단정할 수 없다는 것**이다.

활성화된 `AuthenticationEntryPoint`와 예외 처리 구성에 따라 결과가 달라질 수 있다.

REST API에서는 일반적으로 미인증 요청에 401, 인증된 사용자의 권한 부족에 403을 반환하도록 명시적인 예외 처리를 구성한다.

이 부분은 실제 인증 기능과 함께 설정하는 것이 좋다.

---

### 실무 보완: 401과 403을 명확하게 구분하기

REST API를 운영할 때는 인증 실패와 권한 부족을 구분해야 한다.

| 상황                     | 의미           | 일반적인 응답 |
| ---------------------- | ------------ | ------- |
| 토큰 없음                  | 인증 정보 부재     | 401     |
| 토큰 만료                  | 유효한 인증 정보 없음 | 401     |
| 서명 검증 실패               | 토큰 신뢰 불가     | 401     |
| 인증된 일반 사용자가 관리자 API 접근 | 권한 부족        | 403     |

Spring Security에서는 이러한 처리를 위해 `AuthenticationEntryPoint`와 `AccessDeniedHandler`를 사용할 수 있다.

다음은 단순한 상태 코드 응답을 구성하는 예시다.

```java
.exceptionHandling(exceptions -> exceptions

        .authenticationEntryPoint(
                (request, response, exception) -> {

                    response.sendError(
                            HttpServletResponse.SC_UNAUTHORIZED
                    );
                }
        )

        .accessDeniedHandler(
                (request, response, exception) -> {

                    response.sendError(
                            HttpServletResponse.SC_FORBIDDEN
                    );
                }
        )
)
```

위 코드에는 다음 import가 필요하다.

```java
import jakarta.servlet.http.HttpServletResponse;
```

여기서 중요한 것은 두 Handler의 역할이 다르다는 점이다.

`AuthenticationEntryPoint`는 인증이 필요한 요청에서 인증을 시작하거나 인증 실패를 응답하는 역할을 한다.

`AccessDeniedHandler`는 인증된 사용자가 필요한 권한을 가지고 있지 않을 때 접근 거부를 처리하는 역할을 한다.

다만 커스텀 JWT 필터 내부에서 예외를 직접 처리하거나 별도로 던지는 경우에는 필터 위치와 예외 전달 경로에 따라 추가 구성이 필요할 수 있다.

따라서 401과 403 응답 정책을 정의하는 것과 JWT 검증 예외를 실제로 해당 처리 과정에 연결하는 것은 구분해야 한다.

---

### 실무에서의 활용

#### 1. URL 접근 정책은 구체적인 규칙부터 작성한다

Spring Security는 인가 규칙을 선언된 순서대로 검사한다.

예를 들어 다음과 같이 구성하면 문제가 발생할 수 있다.

```java
.authorizeHttpRequests(auth -> auth

        .anyRequest().authenticated()

        .requestMatchers("/admin").hasRole("ADMIN")
)
```

`anyRequest()`는 나머지 모든 요청을 처리하는 규칙이므로 보통 마지막에 배치해야 한다.

적절한 구성은 다음과 같다.

```java
.authorizeHttpRequests(auth -> auth

        .requestMatchers("/login", "/join").permitAll()

        .requestMatchers("/admin", "/admin/**").hasRole("ADMIN")

        .anyRequest().authenticated()
)
```

이렇게 구성해야 관리자 경로의 권한 정책이 먼저 적용된다.

#### 2. 인증을 생략할 API를 최소화한다

`permitAll()`은 누구나 해당 경로에 접근할 수 있도록 허용한다.

따라서 공개할 필요가 없는 API에 무분별하게 적용하면 보안 문제가 발생할 수 있다.

특히 관리자 API나 내부 운영 API가 실수로 공개되지 않도록 주의해야 한다.

#### 3. JWT 인증 구현 전에는 보호된 API가 정상적으로 차단될 수 있다

현재 `SecurityConfig`는 JWT 인증 필터를 추가하기 전 단계다.

따라서 일반 API에 접근했을 때 요청이 차단되는 것은 반드시 잘못된 설정이라는 의미가 아니다.

인가 정책은 존재하지만 인증 정보를 구성하는 기능이 아직 구현되지 않았기 때문이다.

#### 4. Stateless와 SecurityContextHolder를 혼동하지 않는다

`SessionCreationPolicy.STATELESS`는 세션을 이용해 인증 상태를 유지하지 않도록 구성한다.

하지만 요청 처리 중에는 `SecurityContextHolder`를 통해 인증 정보를 사용할 수 있다.

따라서 JWT 기반 Stateless 인증에서도 `Authentication`과 `SecurityContext`는 여전히 중요한 구성요소다.

#### 5. JWT라고 무조건 CSRF를 비활성화하지 않는다

JWT를 Authorization 헤더로 전달하는 구조와 쿠키로 전달하는 구조는 보안 특성이 다르다.

브라우저가 인증 쿠키를 자동으로 전송한다면 Stateless 구조에서도 CSRF 공격 가능성을 고려해야 한다.

따라서 인증 정보의 저장 위치와 전송 방식을 먼저 확인해야 한다.

#### 6. PasswordEncoder를 반드시 사용한다

회원가입에서 비밀번호를 원문으로 저장하지 않아야 한다.

```java
passwordEncoder.encode(rawPassword);
```

로그인에서는 다음 메서드로 검증한다.

```java
passwordEncoder.matches(
        rawPassword,
        encodedPassword
);
```

특히 BCrypt는 Salt를 사용하므로 입력한 비밀번호를 다시 `encode()`한 뒤 문자열을 직접 비교하는 방식은 적절하지 않다.

#### 7. BCrypt 강도는 시스템 환경에 맞게 결정한다

`BCryptPasswordEncoder`는 연산 비용을 조절할 수 있다.

예를 들어 다음과 같이 설정할 수 있다.

```java
@Bean
public PasswordEncoder passwordEncoder() {

    return new BCryptPasswordEncoder(12);
}
```

여기서 `12`는 BCrypt의 Strength다.

값이 증가하면 비밀번호 해시 계산 비용도 증가한다.

하지만 Strength가 높을수록 무조건 좋은 것은 아니다.

로그인 요청 처리량과 서버 성능을 고려해야 하며, 지나치게 높은 값은 인증 시스템의 처리량을 감소시킬 수 있다.

#### 8. hasRole과 hasAuthority를 혼동하지 않는다

`hasRole("ADMIN")`은 일반적으로 `ROLE_ADMIN` 권한을 요구한다.

반면 `hasAuthority("ADMIN")`은 `ADMIN`이라는 문자열을 직접 검사한다.

따라서 JWT에서 추출한 권한 문자열과 SecurityConfig의 인가 규칙이 일치해야 한다.

#### 9. API 경로가 추가되면 인가 정책도 함께 검토한다

서비스 기능이 증가하면 새로운 API가 계속 추가된다.

예를 들어 다음과 같은 API가 추가되었다고 생각해보자.

```text
/admin/users
/admin/settings
/admin/statistics
```

이러한 경로에 관리자 권한을 요구한다면 다음 설정을 사용할 수 있다.

```java
.requestMatchers(
        "/admin",
        "/admin/**"
).hasRole("ADMIN")
```

이때 사용자에게 공개해야 할 경로와 관리자 전용 경로가 혼합되지 않도록 패키지와 URL 구조를 명확하게 설계하는 것이 좋다.

#### 10. SecurityConfig에 모든 인증 로직을 작성하지 않는다

`SecurityConfig`는 HTTP 보안 정책과 필요한 Bean을 구성하는 역할을 담당한다.

회원가입, 사용자 조회, JWT 생성 및 검증 등의 비즈니스 로직까지 모두 작성하는 것은 적절하지 않다.

예를 들어 다음처럼 책임을 분리할 수 있다.

```text
SecurityConfig
    ↓
보안 정책 및 필터 구성

JwtAuthenticationFilter
    ↓
JWT 인증 처리

JwtTokenService
    ↓
JWT 생성 및 검증

UserDetailsService
    ↓
사용자 정보 조회

JoinService
    ↓
회원가입 처리
```

이렇게 분리하면 각 구성요소의 역할을 명확하게 유지할 수 있다.

#### 11. JWT 인증 필터의 위치를 신중하게 결정한다

Spring Security는 여러 필터를 정해진 순서에 따라 실행한다.

JWT 인증 필터는 인가 판단이 이루어지기 전에 현재 요청의 인증 정보를 구성할 수 있어야 한다.

따라서 필터를 아무 위치에 추가하는 것이 아니라 기존 Spring Security 필터와의 관계를 고려해야 한다.

#### 12. 인증이 없는 요청과 권한이 부족한 요청을 구분한다

JWT가 없는 요청과 JWT는 유효하지만 권한이 부족한 요청은 다르다.

```text
JWT 없음
    ↓
인증 실패
```

```text
JWT 유효
    ↓
ROLE_USER 보유
    ↓
ROLE_ADMIN 필요
    ↓
인가 실패
```

이러한 차이를 HTTP 상태 코드와 오류 응답에서도 일관되게 표현하는 것이 좋다.

#### 13. URL 인가만으로 모든 보안 문제가 해결되지는 않는다

예를 들어 다음 API가 있다고 생각해보자.

```http
GET /users/100
```

사용자 A가 사용자 B의 정보를 조회할 수 있는지는 단순히 로그인 여부만으로 판단할 수 없다.

```java
.anyRequest().authenticated()
```

이 설정은 인증된 사용자임을 확인하지만, 요청한 리소스가 해당 사용자의 소유인지까지 판단하지는 않는다.

따라서 사용자별 데이터 접근 권한은 Service 계층 또는 메서드 보안 등을 통해 추가 검증할 필요가 있다.

#### 14. JWT 토큰의 권한 정보가 최신 상태인지 고려한다

JWT에 `ROLE_ADMIN`을 포함해 발급했다고 생각해보자.

이후 데이터베이스에서 관리자 권한을 회수하더라도 기존 JWT에는 해당 권한이 남아 있을 수 있다.

따라서 권한 변경을 즉시 반영해야 하는 서비스에서는 토큰 만료 정책이나 최신 권한 조회 전략을 함께 고려해야 한다.

#### 15. Spring Security 버전에 맞는 API를 사용한다

Spring Security 6에서는 `WebSecurityConfigurerAdapter`를 사용할 수 없다.

따라서 `SecurityFilterChain` 기반으로 설정해야 한다.

또한 오래된 예제에 등장하는 다음 API는 현재 버전에서 사용 여부를 확인해야 한다.

```java
authorizeRequests()
```

```java
antMatchers()
```

Spring Security 6에서는 일반적으로 다음과 같은 구성을 사용한다.

```java
.authorizeHttpRequests(auth -> auth
        .requestMatchers("/admin").hasRole("ADMIN")
        .anyRequest().authenticated()
)
```

이처럼 설정 방식은 버전 변화에 따라 달라질 수 있으므로 프로젝트에서 사용 중인 Spring Security 버전을 확인하는 것이 중요하다.

---

### 정리

Spring Security 6에서 JWT 기반 REST API를 구현하려면 기본적인 HTTP 보안 정책을 구성하는 `SecurityConfig` 클래스가 필요하다.

먼저 다음 Annotation을 이용해 설정 클래스를 정의한다.

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

}
```

이후 `SecurityFilterChain`을 Bean으로 등록한다.

```java
@Bean
public SecurityFilterChain filterChain(
        HttpSecurity http
) throws Exception {

    return http.build();
}
```

`HttpSecurity`를 이용하면 다음과 같은 설정을 적용할 수 있다.

| 설정                        | 역할                     |
| ------------------------- | ---------------------- |
| `csrf()`                  | CSRF 보호 정책             |
| `formLogin()`             | 기본 Form Login 설정       |
| `httpBasic()`             | HTTP Basic 인증 설정       |
| `authorizeHttpRequests()` | URL별 접근 권한             |
| `sessionManagement()`     | 세션 생성 및 인증 상태 관리       |
| `http.build()`            | SecurityFilterChain 생성 |

JWT 기반 REST API에서는 다음과 같은 설정을 사용할 수 있다.

```java
http
        .csrf(AbstractHttpConfigurer::disable)

        .formLogin(AbstractHttpConfigurer::disable)

        .httpBasic(AbstractHttpConfigurer::disable)

        .authorizeHttpRequests(auth -> auth

                .requestMatchers(
                        "/login",
                        "/join"
                ).permitAll()

                .requestMatchers(
                        "/admin",
                        "/admin/**"
                ).hasRole("ADMIN")

                .anyRequest().authenticated()
        )

        .sessionManagement(session -> session
                .sessionCreationPolicy(
                        SessionCreationPolicy.STATELESS
                )
        );
```

그리고 비밀번호 해시를 위해 `PasswordEncoder`를 Bean으로 등록한다.

```java
@Bean
public PasswordEncoder passwordEncoder() {

    return new BCryptPasswordEncoder();
}
```

이렇게 하면 JWT 인증 시스템을 위한 기본적인 보안 설정이 완료된다.

전체 구성을 정리하면 다음과 같다.

```text
SecurityConfig
    ↓
SecurityFilterChain 등록
    ↓
CSRF 정책 설정
    ↓
Form Login 비활성화
    ↓
HTTP Basic 비활성화
    ↓
URL별 인가 정책 적용
    ↓
SessionCreationPolicy.STATELESS
    ↓
PasswordEncoder Bean 등록
```

여기서 가장 중요하게 기억해야 할 점은 **Stateless는 SecurityContextHolder를 사용하지 않는다는 의미가 아니라, 여러 요청에 걸쳐 HttpSession에 인증 상태를 유지하지 않는다는 의미**라는 것이다.

또한 JWT를 사용한다는 이유만으로 CSRF 보호가 불필요한 것은 아니다. 토큰을 Authorization 헤더로 전달하는지, 브라우저가 자동으로 전송하는 쿠키를 사용하는지에 따라 CSRF 위험을 판단해야 한다.

마지막으로 현재 `SecurityConfig`는 인증·인가 정책을 정의한 상태이지 JWT 인증이 완성된 상태는 아니다.

실제 JWT 인증 시스템을 완성하려면 로그인 인증, JWT 생성 및 검증, 요청별 Authentication 구성, JWT 인증 필터 연결 등이 추가로 필요하다.

결국 `SecurityConfig`의 핵심 역할은 **Spring Security가 HTTP 요청을 어떤 방식으로 인증하고, 어떤 권한을 가진 사용자에게 접근을 허용하며, 인증 상태를 어떻게 관리할 것인지 정의하는 것**이다.

#### 한 줄 요약

Spring Security 6에서는 `SecurityFilterChain` Bean을 통해 JWT 기반 REST API의 보안 정책을 설정한다. `csrf`, `formLogin`, `httpBasic`, `authorizeHttpRequests`, `SessionCreationPolicy.STATELESS`를 이용해 인증·인가와 세션 정책을 구성하고, `BCryptPasswordEncoder`를 Bean으로 등록하여 안전한 비밀번호 해시 및 검증 기능을 제공할 수 있다.
