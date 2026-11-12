---
layout: post
bigtitle: '스프링 OAuth2 클라이언트 세션'
subtitle: 스프링 OAuth2 클라이언트 세션 - 5. Security Config 설정
date: '2026-11-11 00:00:04 +0900'
categories:
    - spring-oauth2-client-session
comments: true


---

# 스프링 OAuth2 클라이언트 세션 - 5. Security Config 설정
[https://youtu.be/JxvlYELHNnU?si=71XF1K---6_IYtMJ](https://youtu.be/JxvlYELHNnU?si=71XF1K---6_IYtMJ)

# 스프링 OAuth2 클라이언트 세션 - 5. Security Config 설정
* toc
{:toc}

---

### Spring Security 6 OAuth2 소셜 로그인 SecurityConfig 설정 완벽 이해

Spring Security OAuth2 Client를 이용해 Google이나 Naver와 같은 외부 인증 제공자로 로그인하려면, Spring Security가 OAuth2 인증 요청을 처리하도록 설정해야 한다.

앞서 OAuth2 Client에 필요한 의존성을 추가하고, 외부 인증 제공자와 통신하기 위한 설정 변수의 역할을 살펴보았다.

하지만 의존성과 환경설정을 준비했다고 해서 모든 소셜 로그인 기능이 원하는 방식으로 동작하는 것은 아니다.

애플리케이션에서 OAuth2 로그인을 사용하도록 Spring Security를 구성하고, 인증되지 않은 사용자가 접근할 수 있는 경로와 인증된 사용자만 접근할 수 있는 경로를 구분해야 한다.

이러한 설정을 담당하는 것이 `SecurityConfig`다.

이번 프로젝트에서는 다음 환경을 사용한다.

| 항목 | 기술 |
|---|---|
| Java | 17 |
| Spring Boot | 3.2.1 |
| Spring Security | 6.2.1 |
| OAuth2 | Spring Security OAuth2 Client |
| 인증 방식 | OAuth2 Authorization Code |
| 로그인 상태 유지 | HttpSession |
| 화면 처리 | Mustache |
| 데이터베이스 | MySQL |
| ORM | Spring Data JPA |

이번에 구성할 인증 시스템의 전체적인 흐름은 다음과 같다.

```mermaid
flowchart TD
    A["사용자"] --> B["Spring Boot"]

    B --> C["SecurityFilterChain"]

    C --> D{"요청 경로 확인"}

    D -->|"공개 경로"| E["접근 허용"]

    D -->|"보호된 경로"| F{"인증 여부 확인"}

    F -->|"인증되지 않음"| G["OAuth2 로그인 시작"]

    G --> H["Google / Naver"]

    H --> I["Authorization Code 발급"]

    I --> J["OAuth2LoginAuthenticationFilter"]

    J --> K["Access Token 교환"]

    K --> L["외부 사용자 정보 조회"]

    L --> M["Authentication 생성"]

    M --> N["SecurityContext 저장"]

    N --> O["HttpSession"]

    F -->|"인증됨"| P["Controller 실행"]

    O --> P
```

이번에 작성하는 SecurityConfig는 이 구조에서 다음과 같은 역할을 담당한다.

| 설정 | 역할 |
|---|---|
| `csrf()` | CSRF 공격 방어 정책 |
| `formLogin()` | 아이디·비밀번호 기반 Form Login 설정 |
| `httpBasic()` | HTTP Basic 인증 설정 |
| `oauth2Login()` | OAuth2 소셜 로그인 활성화 |
| `authorizeHttpRequests()` | 경로별 접근 권한 설정 |
| `sessionManagement()` | 세션 생성 및 인증 상태 관리 정책 |

각 설정이 어떤 역할을 하는지 이해하면 OAuth2 로그인뿐 아니라 이후 인증 시스템을 확장할 때도 SecurityFilterChain을 정확하게 구성할 수 있다.

---

### 개념

#### SecurityConfig란?

`SecurityConfig`는 Spring Security의 인증 및 인가 정책을 정의하기 위해 작성하는 설정 클래스다.

예를 들어 다음과 같은 요구사항이 있다고 생각해보자.

```text
메인 화면
    ↓
누구나 접근 가능
```

```text
마이 화면
    ↓
로그인한 사용자만 접근 가능
```

```text
Google / Naver 로그인
    ↓
외부 인증 제공자를 이용한 인증
```

```text
아이디 / 비밀번호 로그인
    ↓
사용하지 않음
```

이러한 요구사항을 Spring Security에 전달하기 위해 SecurityConfig를 작성한다.

Spring Security 6에서는 일반적으로 `SecurityFilterChain` Bean을 등록하는 방식으로 HTTP 보안 정책을 구성한다.

예를 들어 다음과 같다.

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(
            HttpSecurity http
    ) throws Exception {

        // HTTP 보안 정책 설정

        return http.build();
    }
}
```

여기서 `HttpSecurity`는 Servlet 기반 웹 애플리케이션의 HTTP 보안 설정을 구성하는 빌더다.

개발자는 `HttpSecurity`를 이용해 인증 방식과 인가 정책을 정의한다.

이후 `build()`를 호출하면 설정에 따라 SecurityFilterChain이 구성된다.

#### SecurityFilterChain이란?

Spring Security는 Servlet Filter 기반으로 HTTP 요청을 처리한다.

브라우저가 Spring Boot 서버로 요청을 보내면 일반적으로 Controller가 실행되기 전에 Spring Security의 필터 체인을 거친다.

```text
HTTP Request
    ↓
Servlet Filter Chain
    ↓
DelegatingFilterProxy
    ↓
FilterChainProxy
    ↓
SecurityFilterChain
    ↓
Spring MVC
    ↓
DispatcherServlet
    ↓
Controller
```

여기서 `SecurityFilterChain`에는 다양한 보안 필터가 포함될 수 있다.

대표적으로 다음과 같다.

| 필터 | 역할 |
|---|---|
| `CsrfFilter` | CSRF 보호 |
| `LogoutFilter` | 로그아웃 처리 |
| `OAuth2AuthorizationRequestRedirectFilter` | 외부 인증 서버로 이동 |
| `OAuth2LoginAuthenticationFilter` | OAuth2 Callback 인증 처리 |
| `SecurityContextHolderFilter` | SecurityContext 조회 및 관리 |
| `AnonymousAuthenticationFilter` | 익명 사용자 인증 객체 구성 |
| `ExceptionTranslationFilter` | 인증 및 인가 예외 처리 |
| `AuthorizationFilter` | 요청에 대한 접근 권한 확인 |

실제로 어떤 필터가 등록되는지는 SecurityFilterChain 설정에 따라 달라진다.

따라서 OAuth2 소셜 로그인을 구현하려면 관련 인증 기능을 활성화해야 한다.

그 핵심이 다음 설정이다.

```java
.oauth2Login(Customizer.withDefaults())
```

---

### 왜 사용하는가?

#### 기본 Spring Security 설정을 원하는 인증 방식으로 변경하기 위해서

Spring Boot 프로젝트에 다음 의존성을 추가했다고 생각해보자.

```gradle
implementation 'org.springframework.boot:spring-boot-starter-security'
```

별도의 보안 설정이 없다면 Spring Boot의 기본 보안 자동 설정이 적용될 수 있다.

이때 일반적인 웹 요청은 인증을 요구하며, 개발용 기본 사용자와 로그인 기능이 구성될 수 있다.

하지만 이번 프로젝트에서 구현하려는 인증 방식은 다르다.

사용자가 직접 아이디와 비밀번호를 우리 서버에 입력하는 Form Login이 아니라, Google이나 Naver와 같은 외부 인증 제공자를 이용하는 소셜 로그인이다.

따라서 기존 인증 방식을 비활성화하고 OAuth2 로그인을 사용하도록 구성한다.

```text
Spring Security 기본 인증
    ↓
Form Login / HTTP Basic
```

```text
이번 프로젝트의 인증
    ↓
OAuth2 Login
    ↓
Google / Naver
    ↓
Spring Security Session
```

또한 모든 요청에 로그인을 요구하는 것이 아니라 일부 경로는 공개해야 한다.

예를 들어 다음과 같다.

| 요청 경로 | 접근 정책 |
|---|---|
| `/` | 누구나 접근 가능 |
| `/oauth2/authorization/google` | 로그인하지 않아도 접근 가능 |
| `/oauth2/authorization/naver` | 로그인하지 않아도 접근 가능 |
| `/login/oauth2/code/google` | OAuth2 인증 응답 처리 경로 |
| `/login/oauth2/code/naver` | OAuth2 인증 응답 처리 경로 |
| `/my` | 인증된 사용자만 접근 가능 |
| `/admin` | 별도 관리자 권한 필요 |

이러한 정책을 명시하기 위해 SecurityFilterChain을 직접 구성한다.

Spring Security는 `oauth2Login()`을 이용한 OAuth2 로그인 설정을 공식적으로 지원한다.

---

### 주요 특징

#### SecurityConfig 클래스 생성

먼저 기존 프로젝트에 `config` 패키지를 생성한다.

프로젝트 구조는 다음과 같다.

```text
src
└── main
    ├── java
    │   └── com
    │       └── example
    │           └── oauth2session
    │               │
    │               ├── Oauth2SessionApplication.java
    │               │
    │               ├── controller
    │               │   ├── MainController.java
    │               │   └── MyController.java
    │               │
    │               └── config
    │                   └── SecurityConfig.java
    │
    └── resources
        ├── application.properties
        │
        └── templates
            ├── main.mustache
            └── my.mustache
```

`config` 패키지 아래에 `SecurityConfig.java`를 생성한다.

가장 기본적인 구조는 다음과 같다.

```java
package com.example.oauth2session.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

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

이제 각각의 구성요소를 살펴보자.

---

### @Configuration

`@Configuration`은 해당 클래스가 Spring의 설정 클래스임을 나타낸다.

```java
@Configuration
public class SecurityConfig {

}
```

Spring은 이 클래스를 설정 클래스로 인식하고 내부에서 정의한 Bean을 관리한다.

예를 들어 다음과 같다.

```java
@Bean
public SecurityFilterChain filterChain(
        HttpSecurity http
) throws Exception {

    return http.build();
}
```

`@Bean`을 선언하면 반환된 객체가 Spring Container에 Bean으로 등록된다.

따라서 `SecurityFilterChain`이 Spring Security의 보안 설정에 사용될 수 있다.

#### @Configuration과 @Bean의 관계

두 Annotation은 서로 다른 역할을 담당한다.

| Annotation | 역할 |
|---|---|
| `@Configuration` | Spring 설정 클래스 선언 |
| `@Bean` | 메서드가 반환한 객체를 Bean으로 등록 |

이 관계를 구조로 표현하면 다음과 같다.

```text
@Configuration
    ↓
SecurityConfig
    ↓
@Bean
    ↓
SecurityFilterChain
    ↓
Spring Container
```

---

### @EnableWebSecurity

`@EnableWebSecurity`는 Spring Security의 웹 보안 구성을 활성화하기 위한 Annotation이다.

```java
@EnableWebSecurity
```

Spring Security 공식 설정에서도 다음과 같은 형태를 확인할 수 있다.

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

}
```

하지만 Spring Boot에서 다음 의존성을 사용하고 있다면 상황이 조금 다르다.

```gradle
implementation 'org.springframework.boot:spring-boot-starter-security'
```

Spring Boot는 Spring Security와 관련된 자동 설정을 제공한다.

따라서 **Spring Boot 기반 애플리케이션에서는 `@EnableWebSecurity`를 반드시 직접 선언해야 하는 것은 아니다.**

이번에는 보안 설정 클래스의 역할을 명확하게 표현하기 위해 명시적으로 사용한다.

---

### SecurityFilterChain Bean

다음으로 SecurityFilterChain Bean을 등록한다.

```java
@Bean
public SecurityFilterChain filterChain(
        HttpSecurity http
) throws Exception {

    return http.build();
}
```

이 코드는 Spring Security 6에서 HTTP 보안 정책을 설정하는 핵심 구조다.

#### HttpSecurity

`HttpSecurity`는 HTTP 요청에 적용할 보안 설정을 구성하기 위한 객체다.

예를 들어 다음과 같은 기능을 제공한다.

```java
http
        .csrf(...)
        .formLogin(...)
        .httpBasic(...)
        .oauth2Login(...)
        .authorizeHttpRequests(...);
```

각 메서드를 통해 서로 다른 보안 기능을 구성할 수 있다.

#### throws Exception

`HttpSecurity`를 이용해 필터 체인을 구성하는 과정에서는 설정 오류 등이 발생할 수 있다.

따라서 메서드 선언부에 다음과 같이 예외를 명시할 수 있다.

```java
throws Exception
```

Spring Security의 SecurityFilterChain 설정 예제에서도 일반적으로 사용되는 형태다.

#### http.build()

설정이 완료되면 다음 메서드를 호출한다.

```java
return http.build();
```

이 메서드는 `HttpSecurity`에 정의한 정책을 바탕으로 SecurityFilterChain을 구성한다.

이렇게 반환한 SecurityFilterChain Bean이 Spring Security에서 요청을 처리하는 데 사용된다.

---

### CSRF 설정

이제 실제 보안 설정을 시작한다.

가장 먼저 살펴볼 것은 CSRF다.

#### CSRF란?

CSRF(Cross-Site Request Forgery)는 사용자가 이미 인증된 웹사이트에 대해 공격자가 원하지 않는 요청을 유도하는 공격이다.

예를 들어 사용자가 특정 서비스에 로그인한 상태라고 생각해보자.

```text
사용자
    ↓
서비스 로그인
    ↓
세션 쿠키 보유
```

이후 사용자가 악성 웹사이트에 접근한다.

공격자는 브라우저가 기존 인증 쿠키를 포함하여 다른 서비스로 요청을 보내도록 유도할 수 있다.

```mermaid
sequenceDiagram
    participant User as 사용자
    participant Browser as 브라우저
    participant Attacker as 공격자 웹사이트
    participant Server as 서비스 서버

    User->>Server: 정상 로그인

    Server-->>Browser: 세션 쿠키 발급

    User->>Attacker: 공격자 웹사이트 접근

    Attacker-->>Browser: 비정상 요청 유도

    Browser->>Server: 인증 쿠키가 포함될 수 있는 요청

    Server->>Server: CSRF 검증

    alt CSRF 검증 실패
        Server-->>Browser: 요청 거부
    else 정상 요청
        Server-->>Browser: 요청 처리
    end
```

CSRF 방어를 위해 Spring Security는 CSRF Token 검증 기능을 제공한다.

#### CSRF 비활성화

초기 개발 단계에서 다음과 같이 CSRF를 비활성화하는 설정을 사용할 수 있다.

```java
.csrf(AbstractHttpConfigurer::disable)
```

해당 코드를 사용하려면 다음 클래스를 import해야 한다.

```java
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
```

하지만 이번 프로젝트에서는 중요한 주의사항이 있다.

**OAuth2 로그인 이후 HttpSession으로 로그인 상태를 유지하는 브라우저 애플리케이션이라면 CSRF 보호를 유지하는 것이 일반적으로 적절하다.**

JWT를 Authorization 헤더로 직접 전달하는 Stateless API와 달리, 세션 인증에서는 브라우저가 세션 쿠키를 자동으로 전송할 수 있기 때문이다.

따라서 CSRF 비활성화는 초기 동작 확인을 위한 설정으로만 이해하고, 실제 서비스에서는 기본 CSRF 보호를 유지하도록 구성하는 것이 좋다.

Spring Security는 로그인과 로그아웃 요청에도 CSRF 보호가 중요하다고 설명한다.

이번에는 먼저 CSRF를 비활성화한 기본 설정을 살펴본 뒤, 실제 서비스에서 사용할 수 있는 구성을 별도로 정리한다.

---

### Form Login 비활성화

다음은 Form Login 설정이다.

```java
.formLogin(AbstractHttpConfigurer::disable)
```

#### Form Login이란?

Form Login은 사용자가 HTML Form에 아이디와 비밀번호를 입력하는 방식이다.

일반적인 처리 흐름은 다음과 같다.

```text
사용자
    ↓
아이디 / 비밀번호 입력
    ↓
POST /login
    ↓
UsernamePasswordAuthenticationFilter
    ↓
AuthenticationManager
    ↓
UserDetailsService
    ↓
비밀번호 검증
    ↓
로그인 성공
```

이 방식은 Spring Security에서 제공하는 대표적인 인증 방식이다.

하지만 이번 프로젝트에서는 사용자가 우리 서버에 아이디와 비밀번호를 직접 제출하지 않는다.

대신 외부 인증 제공자가 사용자 인증을 수행한다.

```text
사용자
    ↓
Google / Naver 선택
    ↓
외부 인증 서버
    ↓
사용자 인증
    ↓
Spring Security OAuth2 Login
```

따라서 일반적인 Form Login을 사용하지 않도록 설정한다.

```java
.formLogin(AbstractHttpConfigurer::disable)
```

#### Form Login을 비활성화하면 로그인 화면도 사라질까?

여기서 구분해야 할 부분이 있다.

Form Login을 비활성화하면 일반적인 아이디·비밀번호 기반 로그인 처리를 사용하지 않도록 구성할 수 있다.

하지만 `oauth2Login()`을 활성화했다면 OAuth2 로그인을 위한 기본 로그인 화면이 제공될 수 있다.

Spring Security는 등록된 OAuth2 Client 정보를 이용해 Google, Naver 등의 로그인 링크를 표시하는 기본 화면을 생성할 수 있다.

따라서 다음 두 설정은 서로 다른 인증 방식을 제어한다.

```java
.formLogin(AbstractHttpConfigurer::disable)
```

```java
.oauth2Login(Customizer.withDefaults())
```

첫 번째는 Form Login을 비활성화한다.

두 번째는 OAuth2 로그인을 활성화한다.

Spring Security는 OAuth2 Client 등록 정보를 기반으로 기본 OAuth2 로그인 화면을 생성하는 기능을 제공한다.

---

### HTTP Basic 인증 비활성화

다음은 HTTP Basic 인증이다.

```java
.httpBasic(AbstractHttpConfigurer::disable)
```

#### HTTP Basic이란?

HTTP Basic 인증은 HTTP Authorization 헤더에 사용자 이름과 비밀번호를 포함하여 전달하는 인증 방식이다.

예를 들어 다음과 같다.

```http
GET /my HTTP/1.1
Host: localhost:8080
Authorization: Basic dXNlcjpwYXNzd29yZA==
```

여기서 `dXNlcjpwYXNzd29yZA==`는 다음 문자열을 Base64 인코딩한 예시다.

```text
user:password
```

중요한 것은 Base64 인코딩 자체가 암호화를 의미하지 않는다는 사실이다.

Base64는 데이터를 문자열 형태로 표현하는 인코딩 방식이므로 쉽게 디코딩할 수 있다.

따라서 HTTP Basic 인증은 HTTPS와 같은 전송 구간 보호가 중요하다.

이번 프로젝트에서는 HTTP Basic 인증을 사용하지 않는다.

외부 인증 제공자를 이용한 OAuth2 로그인이 목적이기 때문이다.

따라서 다음과 같이 비활성화한다.

```java
.httpBasic(AbstractHttpConfigurer::disable)
```

이렇게 하면 HTTP Basic 인증 처리에 의존하지 않는 구조를 구성할 수 있다.

---

### OAuth2 Login 활성화

이번 SecurityConfig에서 가장 중요한 설정이다.

```java
.oauth2Login(Customizer.withDefaults())
```

이 설정은 Spring Security의 OAuth2 로그인 기능을 활성화한다.

#### oauth2Login()이란?

`oauth2Login()`은 OAuth2 Authorization Code Grant를 이용한 사용자 로그인 기능을 구성하는 메서드다.

대표적으로 다음과 같은 인증 흐름을 지원한다.

```text
OAuth2 로그인 요청
    ↓
OAuth2AuthorizationRequestRedirectFilter
    ↓
외부 인증 서버
    ↓
사용자 인증
    ↓
Authorization Code 반환
    ↓
OAuth2LoginAuthenticationFilter
    ↓
AuthenticationManager
    ↓
AuthenticationProvider
    ↓
Access Token 교환
    ↓
OAuth2UserService
    ↓
Authentication 생성
```

이러한 과정에 필요한 주요 인증 필터와 설정은 Spring Security가 제공한다.

따라서 개발자가 모든 OAuth2 인증 흐름을 처음부터 구현할 필요는 없다.

#### Customizer.withDefaults()

다음 코드를 살펴보자.

```java
.oauth2Login(Customizer.withDefaults())
```

`Customizer.withDefaults()`는 별도의 세부 설정을 지정하지 않고 기본 구성을 사용하도록 하는 방식이다.

즉 기본 OAuth2 로그인 기능을 활성화한다.

이후 사용자 정보 처리를 커스터마이징하거나 로그인 성공 및 실패 동작을 변경해야 한다면 다음과 같이 확장할 수 있다.

```java
.oauth2Login(oauth2 -> oauth2

        .userInfoEndpoint(userInfo -> userInfo
                .userService(customOAuth2UserService)
        )

        .successHandler(customSuccessHandler)

        .failureHandler(customFailureHandler)
)
```

위 코드는 확장 구조를 설명하기 위한 예시다.

`customOAuth2UserService`, `customSuccessHandler`, `customFailureHandler`는 실제로 구현하고 주입받아야 하는 객체다.

또한 Google OIDC 로그인에서는 `oidcUserService()`를 별도로 설정해야 할 수 있다.

현재 단계에서는 아직 사용자 정보 처리 로직을 구현하지 않았으므로 기본 설정을 사용한다.

```java
.oauth2Login(Customizer.withDefaults())
```

---

### oauth2Login()과 oauth2Client()의 차이

Spring Security에서는 다음 두 가지 설정을 사용할 수 있다.

```java
.oauth2Login(Customizer.withDefaults())
```

```java
.oauth2Client(Customizer.withDefaults())
```

이름이 비슷하지만 목적이 다르다.

#### oauth2Login()

`oauth2Login()`은 사용자를 OAuth2 또는 OIDC 기반으로 로그인시키는 기능에 초점을 맞춘다.

예를 들어 다음과 같다.

```text
사용자
    ↓
Google 로그인
    ↓
Google 사용자 인증
    ↓
우리 서버 로그인 완료
    ↓
HttpSession에 인증 상태 유지
```

이번 프로젝트에서는 이 기능이 필요하다.

#### oauth2Client()

`oauth2Client()`는 애플리케이션이 OAuth2 Client로서 외부 보호 리소스에 접근하는 기능을 구성할 때 사용한다.

예를 들어 우리 서비스가 인증된 사용자의 동의를 바탕으로 외부 API를 호출해야 하는 상황이다.

```text
Spring Boot
    ↓
OAuth2 Access Token 사용
    ↓
외부 Resource Server
    ↓
보호된 API 호출
```

두 설정의 차이를 정리하면 다음과 같다.

| 구분 | oauth2Login() | oauth2Client() |
|---|---|---|
| 주요 목적 | OAuth2 사용자 로그인 | OAuth2 기반 외부 API 접근 |
| 핵심 기능 | 사용자 인증 | Authorized Client 및 토큰 사용 |
| Authentication 구성 | 로그인 기능 지원 | 별도 로그인 기능을 자동으로 제공하지 않음 |
| 대표 활용 | Google, Naver 소셜 로그인 | 외부 서비스 API 호출 |
| 함께 사용 | 가능 | 가능 |

여기서 주의해야 할 점이 있다.

`oauth2Client()`를 사용한다고 해서 모든 인증 필터와 OAuth2 프로토콜을 직접 구현해야 한다는 의미는 아니다.

Spring Security는 OAuth2 Client를 위한 여러 구성요소와 토큰 관리 기능을 제공한다.

다만 `oauth2Client()`만으로 일반적인 사용자 로그인 기능이 완성되는 것은 아니다.

이번 목적은 **Google과 Naver로 사용자를 로그인시키는 것**이므로 `oauth2Login()`을 사용한다.

두 기능이 모두 필요한 서비스라면 함께 사용할 수 있다.

```java
.oauth2Login(Customizer.withDefaults())
.oauth2Client(Customizer.withDefaults())
```

Spring Security는 OAuth2 로그인과 OAuth2 Client 기능을 구분하며, 두 기능을 함께 구성하는 방식도 지원한다.

---

### 경로별 인가 설정

OAuth2 로그인 기능을 활성화한 뒤에는 요청 경로별 접근 권한을 설정해야 한다.

Spring Security에서는 다음 메서드를 사용한다.

```java
.authorizeHttpRequests(auth -> auth

)
```

이 설정은 HTTP 요청에 대한 인가 정책을 정의한다.

이번 프로젝트에서는 메인 화면과 OAuth2 인증 관련 경로를 공개하고 나머지 경로는 인증된 사용자만 접근하도록 구성한다.

```java
.authorizeHttpRequests(auth -> auth

        .requestMatchers(
                "/",
                "/oauth2/**",
                "/login/**"
        ).permitAll()

        .anyRequest().authenticated()
)
```

각 설정을 살펴보자.

---

### requestMatchers()

`requestMatchers()`는 특정 HTTP 요청에 적용할 인가 정책을 지정하는 데 사용한다.

예를 들어 다음과 같다.

```java
.requestMatchers("/").permitAll()
```

이 설정은 `/` 경로에 대한 접근을 허용한다.

반면 다음과 같이 작성할 수도 있다.

```java
.requestMatchers("/my").authenticated()
```

이 설정은 `/my` 경로에 인증된 사용자만 접근할 수 있도록 한다.

#### permitAll()

`permitAll()`은 해당 요청에 접근하기 위해 사용자 인증이 필요하지 않도록 허용하는 설정이다.

```java
.requestMatchers("/").permitAll()
```

따라서 인증되지 않은 사용자도 메인 화면에 접근할 수 있다.

현재 프로젝트에서는 다음 경로를 공개한다.

```text
/
```

```text
/oauth2/**
```

```text
/login/**
```

다만 실제 운영 환경에서는 공개할 경로를 필요한 범위로 제한하는 것이 좋다.

---

### OAuth2 인증 시작 경로 허용

다음 설정을 살펴보자.

```java
.requestMatchers("/oauth2/**").permitAll()
```

Spring Security의 기본 OAuth2 로그인 시작 경로는 다음과 같다.

```text
/oauth2/authorization/{registrationId}
```

예를 들어 Google 로그인은 다음과 같다.

```text
/oauth2/authorization/google
```

Naver 로그인은 다음과 같다.

```text
/oauth2/authorization/naver
```

이 요청은 일반적으로 인증되지 않은 사용자가 실행한다.

소셜 로그인은 아직 로그인하지 않은 사용자가 인증을 시작하기 위한 기능이기 때문이다.

따라서 공개 경로로 설정할 수 있다.

```java
.requestMatchers("/oauth2/**").permitAll()
```

다만 더 명확한 경로 제한을 원한다면 다음과 같이 설정할 수 있다.

```java
.requestMatchers(
        "/oauth2/authorization/**"
).permitAll()
```

이 방식은 OAuth2 인증 시작 경로를 보다 구체적으로 지정한다.

---

### OAuth2 Callback 경로 허용

다음 설정을 살펴보자.

```java
.requestMatchers("/login/**").permitAll()
```

Spring Security의 기본 OAuth2 Callback 경로는 다음과 같다.

```text
/login/oauth2/code/{registrationId}
```

Google은 다음과 같다.

```text
/login/oauth2/code/google
```

Naver는 다음과 같다.

```text
/login/oauth2/code/naver
```

이 경로는 외부 인증 서버에서 사용자 인증을 완료한 뒤 브라우저가 돌아오는 주소다.

Callback 요청에는 일반적으로 Authorization Code와 State가 포함된다.

```http
GET /login/oauth2/code/naver?code=AUTHORIZATION_CODE&state=STATE_VALUE
```

Spring Security의 `OAuth2LoginAuthenticationFilter`가 해당 요청을 처리한다.

이때 한 가지를 구분해야 한다.

**Callback 경로가 공개되어 있다는 것은 누구나 인증에 성공한다는 의미가 아니다.**

OAuth2LoginAuthenticationFilter는 Authorization Code와 State, 기존 인증 요청 정보 등을 이용해 OAuth2 인증 절차를 수행한다.

따라서 해당 경로에 접근할 수 있다고 해서 로그인 인증이 생략되는 것은 아니다.

또한 실제 OAuth2 Callback 요청은 필터가 처리하므로, 모든 환경에서 명시적인 `permitAll()` 설정이 반드시 필요한 것은 아니다.

이번에는 인증 관련 경로의 접근 정책을 명확하게 표현하기 위해 설정한다.

---

### anyRequest().authenticated()

다음 설정은 앞에서 지정하지 않은 나머지 요청에 적용된다.

```java
.anyRequest().authenticated()
```

이는 다른 모든 요청에 대해 인증된 사용자만 접근하도록 요구한다.

예를 들어 다음과 같다.

```text
GET /my
    ↓
인증 필요
```

```text
GET /orders
    ↓
인증 필요
```

```text
GET /profile
    ↓
인증 필요
```

이러한 정책을 사용하면 공개 경로를 제외한 나머지 경로를 기본적으로 보호할 수 있다.

#### permitAll과 authenticated 비교

| 설정 | 의미 |
|---|---|
| `permitAll()` | 인증 여부와 관계없이 접근 허용 |
| `authenticated()` | 인증된 사용자만 접근 허용 |
| `hasRole("ADMIN")` | 관리자 역할을 가진 사용자만 접근 허용 |
| `hasAuthority("ROLE_USER")` | 지정한 Authority를 가진 사용자만 접근 허용 |
| `denyAll()` | 접근 거부 |

이번에는 사용자 역할별 권한을 아직 구현하지 않는다.

따라서 `authenticated()`를 이용해 로그인 여부만 확인한다.

---

### 예제

#### 초기 SecurityConfig 전체 코드

지금까지 살펴본 설정을 하나의 클래스로 작성해보자.

먼저 CSRF 보호를 비활성화한 초기 개발용 구성을 살펴본다.

```java
package com.example.oauth2session.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;

import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(
            HttpSecurity http
    ) throws Exception {

        http
                // CSRF 보호 비활성화: 초기 개발용
                .csrf(AbstractHttpConfigurer::disable)

                // Form Login 비활성화
                .formLogin(AbstractHttpConfigurer::disable)

                // HTTP Basic 비활성화
                .httpBasic(AbstractHttpConfigurer::disable)

                // OAuth2 로그인 활성화
                .oauth2Login(Customizer.withDefaults())

                // 경로별 접근 권한 설정
                .authorizeHttpRequests(auth -> auth

                        .requestMatchers(
                                "/",
                                "/oauth2/**",
                                "/login/**"
                        ).permitAll()

                        .anyRequest().authenticated()
                );

        return http.build();
    }
}
```

이 설정의 목적은 간단하다.

일반적인 아이디·비밀번호 로그인과 HTTP Basic 인증을 사용하지 않고, OAuth2 로그인 기능을 활성화한다.

그리고 메인 화면과 OAuth2 인증 관련 경로를 공개한다.

그 외의 요청에는 인증된 사용자만 접근할 수 있도록 설정한다.

설정 구조를 표현하면 다음과 같다.

```mermaid
flowchart TD
    A["SecurityConfig"] --> B["SecurityFilterChain"]

    B --> C["CSRF 비활성화"]
    B --> D["Form Login 비활성화"]
    B --> E["HTTP Basic 비활성화"]
    B --> F["OAuth2 Login 활성화"]
    B --> G["HTTP 요청 인가 설정"]

    G --> H["공개 경로"]
    G --> I["인증 필요 경로"]

    H --> J["/"]
    H --> K["/oauth2/**"]
    H --> L["/login/**"]

    I --> M["/my"]
    I --> N["기타 경로"]
```

이렇게 하면 기본적인 OAuth2 로그인 보안 설정이 준비된다.

다만 현재 프로젝트는 세션 기반 인증을 사용하므로 CSRF 보호를 비활성화한 설정을 그대로 운영 환경에 적용하는 것은 권장하지 않는다.

---

### 실제 서비스에 적합한 SecurityConfig

세션 기반 인증의 특성을 고려하면 CSRF 보호를 유지하는 것이 좋다.

또한 공개 경로를 더욱 구체적으로 제한할 수 있다.

다음은 이러한 사항을 반영한 구성이다.

```java
package com.example.oauth2session.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;

import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(
            HttpSecurity http
    ) throws Exception {

        http
                // CSRF 보호는 기본값 유지

                // 일반 아이디 / 비밀번호 로그인 비활성화
                .formLogin(AbstractHttpConfigurer::disable)

                // HTTP Basic 인증 비활성화
                .httpBasic(AbstractHttpConfigurer::disable)

                // OAuth2 로그인 활성화
                .oauth2Login(Customizer.withDefaults())

                // 세션 기반 인증
                .sessionManagement(session -> session
                        .sessionCreationPolicy(
                                SessionCreationPolicy.IF_REQUIRED
                        )
                )

                // 경로별 접근 권한
                .authorizeHttpRequests(auth -> auth

                        // 공개 화면 및 정적 리소스
                        .requestMatchers(
                                "/",
                                "/error",
                                "/css/**",
                                "/js/**",
                                "/images/**"
                        ).permitAll()

                        // OAuth2 로그인 시작 및 인증 응답
                        .requestMatchers(
                                "/login",
                                "/oauth2/authorization/**",
                                "/login/oauth2/code/**"
                        ).permitAll()

                        // 나머지 요청은 인증 필요
                        .anyRequest().authenticated()
                );

        return http.build();
    }
}
```

이 구성에서는 다음 설정을 사용하지 않는다.

```java
.csrf(AbstractHttpConfigurer::disable)
```

따라서 Spring Security의 기본 CSRF 보호가 유지된다.

또한 다음 세션 정책을 명시했다.

```java
.sessionManagement(session -> session
        .sessionCreationPolicy(
                SessionCreationPolicy.IF_REQUIRED
        )
)
```

이는 필요한 경우 세션을 생성하여 사용할 수 있도록 한다.

`IF_REQUIRED`는 기본적인 세션 생성 정책이므로 반드시 명시할 필요는 없지만, JWT Stateless 인증과 구분하기 위해 작성했다.

#### 왜 세션 인증에서는 CSRF를 유지해야 할까?

이번 구조에서는 OAuth2 로그인이 완료된 후 서버 세션으로 로그인 상태를 유지한다.

일반적인 흐름은 다음과 같다.

```text
OAuth2 로그인 성공
    ↓
Authentication 생성
    ↓
SecurityContext
    ↓
HttpSession
    ↓
세션 쿠키
    ↓
브라우저가 이후 요청에 쿠키 전달
```

브라우저는 쿠키 정책에 따라 인증 쿠키를 자동으로 전송할 수 있다.

따라서 사용자의 의도와 관계없는 상태 변경 요청이 발생하지 않도록 CSRF 보호가 중요하다.

특히 회원 정보 변경, 주문 생성, 로그아웃 등과 같은 요청을 보호해야 한다.

---

### SecurityConfig만 작성하면 바로 실행될까?

여기서 중요한 문제가 하나 있다.

현재까지 작성한 SecurityConfig에는 다음 설정이 포함되어 있다.

```java
.oauth2Login(Customizer.withDefaults())
```

이 설정은 OAuth2 로그인 기능을 활성화한다.

하지만 Spring Security가 외부 인증 서버와 통신하려면 OAuth2 Client 등록 정보가 필요하다.

대표적으로 다음 정보다.

```text
Client ID

Client Secret

Authorization URI

Token URI

Redirect URI

UserInfo URI
```

이러한 정보를 관리하는 객체가 `ClientRegistrationRepository`다.

Spring Security의 OAuth2 로그인 기능에는 최소 하나 이상의 ClientRegistration이 필요하다.

따라서 등록 정보가 전혀 없는 상태에서 OAuth2 로그인을 활성화하면 애플리케이션 시작 과정에서 필요한 ClientRegistrationRepository를 찾지 못해 실패할 수 있다.

이를 구조로 표현하면 다음과 같다.

```text
SecurityConfig
    ↓
oauth2Login() 활성화
    ↓
OAuth2 Login 구성
    ↓
ClientRegistrationRepository 필요
    ↓
등록된 OAuth2 Client 없음
    ↓
애플리케이션 시작 실패 가능
```

이것은 OAuth2 Login 설정이 잘못되었다는 의미가 아니다.

외부 인증 제공자에 대한 등록 정보가 아직 준비되지 않았기 때문이다.

---

### ClientRegistrationRepository가 필요한 이유

Spring Security는 OAuth2 로그인을 시작할 때 등록된 Client 정보를 조회한다.

예를 들어 사용자가 다음 경로에 접근한다고 생각해보자.

```text
/oauth2/authorization/google
```

Spring Security는 `google`이라는 registrationId를 이용해 ClientRegistration을 조회한다.

```text
registrationId = google
    ↓
ClientRegistrationRepository
    ↓
Google ClientRegistration
    ↓
Authorization Request 생성
```

이때 Google ClientRegistration에는 다음과 같은 정보가 포함된다.

```text
clientId

clientSecret

authorizationGrantType

redirectUri

authorizationUri

tokenUri

scopes
```

이 정보가 있어야 Google 인증 서버로 보낼 Authorization Request를 생성할 수 있다.

따라서 OAuth2 로그인 기능과 ClientRegistration은 밀접한 관계를 가진다.

---

### OAuth2 Client 설정 추가

Google 로그인을 기준으로 최소한의 설정을 작성해보자.

`application.yml`에 다음과 같이 등록한다.

```yaml
server:
  port: 8080

spring:
  application:
    name: oauth2-session

  security:
    oauth2:
      client:
        registration:
          google:
            client-id: ${GOOGLE_CLIENT_ID}
            client-secret: ${GOOGLE_CLIENT_SECRET}

            authorization-grant-type: authorization_code

            redirect-uri: "{baseUrl}/login/oauth2/code/{registrationId}"

            scope:
              - openid
              - profile
              - email
```

Google은 Spring Security가 기본 Provider 설정을 제공하는 인증 제공자 중 하나다.

따라서 기본적인 Google OAuth2 Client 설정에서는 Client ID와 Client Secret을 중심으로 등록할 수 있다.

반면 Naver는 별도의 Provider Endpoint 설정이 필요하다.

이번에는 SecurityConfig 구성이 주제이므로 Google 설정을 이용해 기본 동작을 확인한다.

#### 환경변수 설정

다음과 같이 환경변수를 설정한다.

```bash
export GOOGLE_CLIENT_ID="your-google-client-id"
export GOOGLE_CLIENT_SECRET="your-google-client-secret"
```

각 명령은 현재 셸 환경에 환경변수를 등록한다.

설정한 값은 Spring Boot의 다음 속성에서 참조된다.

```yaml
client-id: ${GOOGLE_CLIENT_ID}
```

```yaml
client-secret: ${GOOGLE_CLIENT_SECRET}
```

실제로 Google 로그인까지 완료하려면 Google에 애플리케이션을 등록하고 Redirect URI도 일치시켜야 한다.

---

### OAuth2 로그인 시작 경로 확인

OAuth2 Client 설정이 준비되었다면 다음 경로로 로그인 요청을 시작할 수 있다.

```text
http://localhost:8080/oauth2/authorization/google
```

이 경로는 Spring Security의 다음 필터가 처리한다.

```text
OAuth2AuthorizationRequestRedirectFilter
```

처리 흐름은 다음과 같다.

```mermaid
sequenceDiagram
    participant Browser
    participant Security as Spring Security
    participant Repository as ClientRegistrationRepository
    participant Google as Google Authorization Server

    Browser->>Security: GET /oauth2/authorization/google

    Security->>Repository: google 등록 정보 조회

    Repository-->>Security: ClientRegistration 반환

    Security->>Security: Authorization Request 생성

    Security-->>Browser: HTTP 302 Redirect

    Browser->>Google: Authorization Endpoint 접근

    Google-->>Browser: 로그인 화면 응답
```

여기서 중요한 점은 Spring Security가 Google 로그인 화면을 직접 제공하는 것이 아니라는 사실이다.

Spring Security는 브라우저가 Google 인증 서버로 이동하도록 HTTP Redirect 응답을 생성한다.

실제 사용자 인증은 Google에서 수행된다.

---

### 실행 및 확인

#### Spring Boot 실행

다음 명령을 사용한다.

```bash
./gradlew bootRun
```

`bootRun`은 Spring Boot 애플리케이션을 실행하는 Gradle 작업이다.

정상적으로 실행되면 다음과 유사한 로그를 확인할 수 있다.

```text
Tomcat started on port 8080 (http)

Started Oauth2SessionApplication
```

이제 메인 화면에 접근한다.

```text
http://localhost:8080/
```

현재 SecurityConfig에서는 다음 경로를 허용하고 있다.

```java
.requestMatchers("/").permitAll()
```

따라서 로그인하지 않은 사용자도 접근할 수 있다.

---

### 마이 화면 접근 확인

이번에는 다음 주소로 요청한다.

```text
http://localhost:8080/my
```

현재 보안 정책은 다음과 같다.

```java
.anyRequest().authenticated()
```

따라서 `/my`에 접근하려면 인증이 필요하다.

요청 흐름은 다음과 같다.

```text
GET /my
    ↓
SecurityFilterChain
    ↓
AuthorizationFilter
    ↓
인증 여부 확인
    ↓
인증되지 않은 사용자
    ↓
OAuth2 로그인 유도
```

구체적인 로그인 화면 또는 리다이렉트 동작은 등록된 OAuth2 Client 수와 로그인 설정에 따라 달라질 수 있다.

예를 들어 여러 OAuth2 Client가 등록된 경우 기본 OAuth2 로그인 화면에서 제공자를 선택하도록 구성할 수 있다.

반면 하나의 제공자만 등록된 구성에서는 해당 제공자의 인증 경로로 직접 이동하는 동작이 적용될 수 있다.

중요한 것은 **인증되지 않은 사용자가 보호된 Controller를 바로 실행하지 못한다는 사실**이다.

---

### curl로 리다이렉트 확인하기

브라우저를 실행하지 않고 HTTP 응답을 확인할 수도 있다.

다음 명령을 실행한다.

```bash
curl -i \
  http://localhost:8080/oauth2/authorization/google
```

각 옵션의 의미는 다음과 같다.

| 옵션 | 역할 |
|---|---|
| `curl` | HTTP 요청 실행 |
| `-i` | 응답 상태와 헤더 출력 |
| URL | OAuth2 로그인 시작 경로 |

Google ClientRegistration이 정상적으로 구성되어 있다면 다음과 유사한 응답을 받을 수 있다.

```http
HTTP/1.1 302 Found
Location: https://accounts.google.com/o/oauth2/v2/auth?...
```

여기서 중요한 부분은 `Location` 헤더다.

이 헤더에는 브라우저가 이동할 Google Authorization Endpoint 주소가 포함된다.

OAuth2 로그인에서는 Authorization Request를 생성할 때 `state`와 같은 인증 관련 정보도 함께 관리한다.

기본 세션 기반 구성에서는 인증 요청 상태를 HttpSession에 저장할 수 있다.

따라서 실제 로그인 흐름에서는 최초 요청에 사용된 세션 쿠키가 Callback 요청까지 유지되는 것이 중요하다.

---

### 구조

#### OAuth2 Login과 SecurityFilterChain의 관계

이번 설정에서 가장 중요한 흐름을 다시 정리해보자.

```mermaid
flowchart TD
    A["HTTP 요청"] --> B["SecurityFilterChain"]

    B --> C{"요청 종류"}

    C -->|"메인 화면"| D["공개 경로"]
    C -->|"OAuth2 로그인 시작"| E["OAuth2AuthorizationRequestRedirectFilter"]
    C -->|"OAuth2 Callback"| F["OAuth2LoginAuthenticationFilter"]
    C -->|"보호된 경로"| G["AuthorizationFilter"]

    D --> H["MainController"]

    E --> I["외부 인증 서버로 Redirect"]

    I --> J["Google / Naver"]

    J --> K["Authorization Code"]

    K --> F

    F --> L["AuthenticationManager"]

    L --> M["OAuth2 AuthenticationProvider"]

    M --> N["OAuth2User / OidcUser"]

    N --> O["Authentication 생성"]

    O --> P["SecurityContext"]

    P --> Q["HttpSession"]

    G --> R{"인증 여부"}

    R -->|"인증됨"| S["MyController"]

    R -->|"인증되지 않음"| T["로그인 필요"]
```

여기서 중요한 부분은 경로별 인가 설정과 OAuth2 인증 필터가 서로 다른 역할을 담당한다는 점이다.

#### 경로별 인가 설정

```java
.authorizeHttpRequests(auth -> auth

        .requestMatchers(
                "/",
                "/oauth2/**",
                "/login/**"
        ).permitAll()

        .anyRequest().authenticated()
)
```

이 설정은 사용자가 특정 경로에 접근할 권한이 있는지 판단하는 정책이다.

#### OAuth2 로그인 설정

```java
.oauth2Login(Customizer.withDefaults())
```

이 설정은 OAuth2 로그인 인증 흐름을 처리하는 기능을 활성화한다.

따라서 `permitAll()`을 설정했다고 해서 OAuth2 인증이 이루어지는 것이 아니다.

반대로 `oauth2Login()`을 활성화했다고 해서 모든 애플리케이션 경로가 자동으로 공개되는 것도 아니다.

두 설정은 서로 다른 책임을 가진다.

---

### OAuth2 인증 성공 이후의 처리

OAuth2 로그인에 성공하면 Spring Security는 인증된 사용자 정보를 구성한다.

일반적인 OAuth2 로그인에서는 다음과 같은 Authentication 객체를 사용할 수 있다.

```text
OAuth2AuthenticationToken
    │
    ├── Principal
    │     └── OAuth2User
    │
    ├── Authorities
    │     └── 사용자 권한
    │
    └── Authenticated
          └── true
```

Google OIDC 로그인에서는 Principal로 OidcUser가 사용될 수 있다.

이후 Spring Security는 SecurityContext에 인증 정보를 등록하고 세션 기반 구성에서 인증 상태를 저장할 수 있다.

```text
OAuth2 인증 성공
    ↓
Authentication 생성
    ↓
SecurityContext 구성
    ↓
SecurityContextRepository
    ↓
HttpSession
```

이때 다음 요청부터는 저장된 인증 정보를 이용할 수 있다.

```http
GET /my HTTP/1.1
Host: localhost:8080
Cookie: JSESSIONID=SESSION_ID
```

Spring Security는 해당 세션에 저장된 Authentication을 복원하여 인가 정책을 평가한다.

따라서 매번 Google이나 Naver에 다시 로그인할 필요는 없다.

다만 사용자 세션이 만료되거나 무효화되면 다시 인증을 진행해야 할 수 있다.

---

### 실무에서의 활용

#### 1. OAuth2 로그인과 일반 Form Login을 명확하게 분리한다

Spring Security에서는 다양한 인증 방식을 동시에 구성할 수 있다.

예를 들어 다음과 같은 조합이 가능하다.

```text
아이디 / 비밀번호 로그인
    ↓
Form Login
```

```text
Google / Naver 로그인
    ↓
OAuth2 Login
```

하지만 이번 프로젝트에서는 OAuth2 로그인만 사용한다.

따라서 불필요한 Form Login을 비활성화하여 인증 흐름을 단순하게 유지한다.

```java
.formLogin(AbstractHttpConfigurer::disable)
```

향후 일반 회원 로그인까지 지원해야 한다면 해당 기능을 다시 활성화할 수 있다.

다만 두 로그인 방식을 함께 사용할 경우 내부 사용자 계정 연결과 Authentication Principal의 구조를 일관되게 설계해야 한다.

---

#### 2. HTTP Basic 인증을 불필요하게 활성화하지 않는다

HTTP Basic 인증은 특정 API나 내부 시스템에서 활용할 수 있다.

하지만 모든 웹 애플리케이션에서 반드시 필요한 인증 방식은 아니다.

현재와 같이 OAuth2 로그인으로 인증을 통일하려는 경우에는 비활성화할 수 있다.

```java
.httpBasic(AbstractHttpConfigurer::disable)
```

이렇게 하면 의도하지 않은 인증 방식이 활성화되는 것을 줄일 수 있다.

특히 애플리케이션이 제공해야 하는 인증 방식이 명확하다면 필요하지 않은 인증 수단은 제외하는 것이 설정 관리에 도움이 된다.

---

#### 3. 세션 기반 인증에서는 CSRF 보호를 유지한다

OAuth2 로그인을 사용한다고 해서 CSRF를 반드시 비활성화해야 하는 것은 아니다.

현재 프로젝트는 브라우저의 세션 쿠키를 이용한다.

따라서 CSRF 공격에 대한 방어가 필요하다.

개발 편의를 위해 다음과 같이 비활성화할 수는 있다.

```java
.csrf(AbstractHttpConfigurer::disable)
```

하지만 실제 서비스에서는 기본 CSRF 보호를 유지하는 것이 적절하다.

특히 사용자의 상태를 변경하는 POST, PUT, PATCH, DELETE 요청에 대해 CSRF Token 검증을 적용해야 한다.

---

#### 4. 공개 경로를 너무 넓게 설정하지 않는다

다음과 같은 설정은 넓은 범위를 허용한다.

```java
.requestMatchers("/login/**").permitAll()
```

하지만 실제 서비스에 `/login/history`와 같은 별도 비즈니스 API가 존재한다면 의도하지 않게 공개될 수 있다.

따라서 운영 환경에서는 필요한 OAuth2 경로를 구체적으로 지정하는 것이 좋다.

```java
.requestMatchers(
        "/oauth2/authorization/**",
        "/login/oauth2/code/**"
).permitAll()
```

이렇게 하면 OAuth2 인증과 관련된 경로만 명확하게 허용할 수 있다.

---

#### 5. permitAll과 인증 생략을 혼동하지 않는다

OAuth2 Callback 경로에 `permitAll()`을 설정했다고 해서 Authorization Code 검증이 생략되는 것은 아니다.

Spring Security의 OAuth2LoginAuthenticationFilter는 Callback 요청에 포함된 인증 정보를 처리한다.

따라서 해당 경로가 공개되어 있더라도 올바른 Authorization Code와 State 등의 검증을 통과해야 로그인에 성공할 수 있다.

즉 `permitAll()`은 경로 접근 정책이고, OAuth2 인증 성공 여부는 별도의 인증 처리 과정에서 결정된다.

---

#### 6. OAuth2 Client 등록 정보를 먼저 준비한다

OAuth2 Login을 활성화하려면 ClientRegistrationRepository가 필요하다.

따라서 Google이나 Naver 등의 등록 정보가 전혀 없는 상태에서는 애플리케이션 시작에 실패할 수 있다.

이 문제를 해결하려면 필요한 Client 정보를 등록해야 한다.

예를 들어 Google은 다음과 같다.

```yaml
spring:
  security:
    oauth2:
      client:
        registration:
          google:
            client-id: ${GOOGLE_CLIENT_ID}
            client-secret: ${GOOGLE_CLIENT_SECRET}
```

다만 위 설정은 주요 필드를 보여주는 예시이며, 실제 인증을 완료하려면 외부 제공자 등록 및 Redirect URI 구성 등이 필요하다.

---

#### 7. OAuth2 로그인 화면과 애플리케이션 메인 화면을 구분한다

현재 프로젝트에는 Mustache를 이용한 메인 화면이 있다.

```text
/
```

하지만 OAuth2 로그인 화면은 Spring Security의 기본 기능으로 생성할 수도 있다.

```text
/login
```

따라서 두 화면은 서로 다른 역할을 담당한다.

메인 화면에서는 Google이나 Naver 로그인 버튼을 제공할 수 있다.

OAuth2 로그인 화면에서는 등록된 Client 목록을 보여줄 수 있다.

필요하다면 기본 로그인 화면 대신 Mustache를 이용한 사용자 정의 로그인 화면을 구현할 수도 있다.

---

#### 8. OAuth2 로그인 성공 후 이동할 경로를 설계한다

OAuth2 인증에 성공했다고 해서 반드시 `/` 경로로 이동해야 하는 것은 아니다.

사용자가 원래 접근하려던 경로로 이동하도록 설정할 수도 있다.

예를 들어 다음과 같은 흐름이다.

```text
GET /my
    ↓
인증되지 않음
    ↓
Google 로그인
    ↓
OAuth2 인증 성공
    ↓
GET /my
```

Spring Security는 SavedRequest와 AuthenticationSuccessHandler 등을 이용해 로그인 성공 이후의 이동을 처리할 수 있다.

다만 사용자 입력으로 전달된 임의의 URL로 무조건 이동시키면 Open Redirect 문제가 발생할 수 있으므로 이동할 경로를 검증해야 한다.

---

#### 9. OAuth2UserService는 별도로 확장한다

현재 설정에서는 다음과 같이 기본 OAuth2 로그인 기능을 사용한다.

```java
.oauth2Login(Customizer.withDefaults())
```

하지만 실제 서비스에서는 외부 사용자 정보를 내부 회원과 연결해야 한다.

예를 들어 다음과 같다.

```text
Google 사용자 정보
    ↓
CustomOAuth2UserService
    ↓
우리 서비스 회원 조회
    ↓
회원가입 또는 로그인
    ↓
OAuth2User 반환
```

이러한 기능은 OAuth2UserService를 구현한 뒤 `oauth2Login()`의 `userInfoEndpoint()`를 통해 연결할 수 있다.

다만 Google OIDC 로그인과 Naver 일반 OAuth2 로그인은 사용자 정보 처리 경로가 다를 수 있으므로 구분해야 한다.

---

#### 10. Authentication과 세션 저장을 직접 구현할 필요는 없다

OAuth2 로그인에서 외부 인증이 완료되면 Spring Security가 Authentication을 구성한다.

세션 기반 구성에서는 SecurityContextRepository를 통해 인증 상태를 저장할 수 있다.

따라서 일반적인 OAuth2 로그인에서는 개발자가 매번 다음과 같은 코드를 직접 구현할 필요가 없다.

```java
SecurityContextHolder.getContext()
        .setAuthentication(authentication);
```

Spring Security의 기본 인증 성공 처리를 활용할 수 있기 때문이다.

다만 인증 성공 처리를 직접 커스터마이징한다면 SecurityContext 저장 책임과 세션 정책을 정확하게 이해해야 한다.

---

#### 11. 기본 세션 정책을 이해한다

이번 프로젝트에서는 JWT Stateless 인증과 달리 서버 세션을 사용한다.

따라서 다음 정책을 사용할 수 있다.

```java
.sessionManagement(session -> session
        .sessionCreationPolicy(
                SessionCreationPolicy.IF_REQUIRED
        )
)
```

이는 필요한 경우 세션을 생성할 수 있도록 허용한다.

OAuth2 Authorization Code 방식에서는 인증 요청과 Callback을 연결하기 위한 상태 관리도 필요하다.

따라서 기본적인 세션 기반 OAuth2 로그인에서는 HttpSession이 자연스럽게 사용될 수 있다.

---

#### 12. 인증 관련 경로와 서비스 경로를 분리한다

실무에서는 다음과 같이 경로의 역할을 구분하는 것이 좋다.

```text
/oauth2/**
    ↓
OAuth2 인증 시작
```

```text
/login/oauth2/**
    ↓
OAuth2 인증 응답
```

```text
/my/**
    ↓
사용자 서비스
```

```text
/admin/**
    ↓
관리자 서비스
```

이처럼 인증 관련 경로와 실제 비즈니스 경로를 구분하면 SecurityFilterChain의 접근 정책도 명확하게 작성할 수 있다.

---

#### 13. 권한 검증은 로그인 성공 이후에도 필요하다

OAuth2 로그인에 성공했다고 해서 사용자가 모든 기능에 접근할 수 있는 것은 아니다.

예를 들어 다음과 같은 정책을 적용할 수 있다.

```java
.requestMatchers("/admin/**")
.hasRole("ADMIN")
```

이 설정은 관리자 권한을 가진 사용자에게만 해당 경로의 접근을 허용한다.

외부 제공자가 인증에 성공한 사용자에게 우리 서비스의 관리자 권한까지 자동으로 부여해서는 안 된다.

따라서 사용자 권한은 내부 회원 데이터와 서비스 정책에 따라 결정해야 한다.

---

#### 14. 여러 SecurityFilterChain을 사용하는 환경을 고려한다

서비스 규모가 커지면 보안 정책이 서로 다른 여러 영역이 존재할 수 있다.

예를 들어 다음과 같다.

```text
/api/**
    ↓
JWT 기반 인증
```

```text
/web/**
    ↓
OAuth2 세션 기반 인증
```

이 경우 SecurityFilterChain을 분리하여 구성할 수 있다.

다만 여러 체인을 사용할 때는 `securityMatcher()`와 `@Order` 등을 이용해 각 요청에 어떤 체인이 적용되는지 명확하게 설정해야 한다.

그렇지 않으면 특정 OAuth2 인증 요청이 의도하지 않은 SecurityFilterChain에서 처리될 수 있다.

---

#### 15. 애플리케이션 실행 실패와 인증 실패를 구분한다

OAuth2 Login 설정 과정에서는 크게 두 가지 종류의 문제가 발생할 수 있다.

첫 번째는 애플리케이션 자체가 시작되지 않는 경우다.

```text
OAuth2 Login 활성화
    ↓
ClientRegistrationRepository 없음
    ↓
애플리케이션 시작 실패
```

두 번째는 애플리케이션은 정상 실행되지만 OAuth2 로그인에 실패하는 경우다.

```text
OAuth2 로그인 요청
    ↓
외부 인증 서버
    ↓
Client ID 또는 Redirect URI 오류
    ↓
OAuth2 인증 실패
```

두 문제는 원인이 다르다.

따라서 먼저 애플리케이션이 정상적으로 실행되는지 확인하고, 그다음 OAuth2 리다이렉트와 인증 응답을 확인하는 것이 좋다.

---

### 테스트 코드로 경로별 인가 검증하기

SecurityConfig를 작성했다면 실제 경로별 접근 정책이 의도대로 적용되는지 확인하는 것이 좋다.

Spring Boot에서는 MockMvc를 이용해 HTTP 요청에 대한 보안 동작을 검증할 수 있다.

#### 테스트 환경 구성

먼저 다음 의존성이 필요하다.

```gradle
testImplementation 'org.springframework.boot:spring-boot-starter-test'
testImplementation 'org.springframework.security:spring-security-test'
```

그리고 테스트 전용 OAuth2 Client 등록 정보를 설정한다.

파일 경로는 다음과 같다.

```text
src/test/resources/application-test.yml
```

설정은 다음과 같다.

```yaml
spring:
  security:
    oauth2:
      client:
        registration:
          google:
            client-id: test-client-id
            client-secret: test-client-secret
```

이 설정은 테스트에서 ClientRegistrationRepository를 구성하기 위한 값이다.

실제 Google 인증 서버에 로그인하거나 유효한 Access Token을 발급받기 위한 설정은 아니다.

---

### SecurityConfig 통합 테스트

다음 테스트 클래스를 작성한다.

```java
package com.example.oauth2session.config;

import org.junit.jupiter.api.Test;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.view;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SecurityConfigTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void 메인_화면은_인증_없이_접근할_수_있다()
            throws Exception {

        mockMvc.perform(
                    get("/")
                )

                .andExpect(status().isOk())

                .andExpect(view().name("main"));
    }

    @Test
    void 마이_화면은_인증되지_않으면_리다이렉트된다()
            throws Exception {

        mockMvc.perform(
                    get("/my")
                )

                .andExpect(status().is3xxRedirection());
    }

    @Test
    void OAuth2_로그인_요청은_외부_인증_서버로_리다이렉트된다()
            throws Exception {

        mockMvc.perform(
                    get("/oauth2/authorization/google")
                )

                .andExpect(status().is3xxRedirection());
    }
}
```

이 테스트는 다음 내용을 검증한다.

| 테스트 | 검증 내용 |
|---|---|
| 메인 화면 접근 | 공개 경로 접근 허용 |
| 마이 화면 접근 | 인증되지 않은 사용자 접근 제한 |
| OAuth2 로그인 시작 | 외부 인증 서버로 리다이렉트 |

단, `@SpringBootTest`는 전체 Spring Boot 애플리케이션 컨텍스트를 실행한다.

따라서 프로젝트에 MySQL 연결이나 추가 환경변수 설정이 포함되어 있다면 해당 테스트 환경도 정상적으로 구성해야 한다.

현재 단계에서는 JPA와 MySQL 연결을 아직 활성화하지 않은 구성을 전제로 한다.

#### 테스트 실행

다음 명령을 실행한다.

```bash
./gradlew test --tests "com.example.oauth2session.config.SecurityConfigTest"
```

명령어의 의미는 다음과 같다.

| 명령 | 의미 |
|---|---|
| `./gradlew` | Gradle Wrapper 실행 |
| `test` | 테스트 작업 실행 |
| `--tests` | 지정한 테스트 클래스만 실행 |

모든 테스트가 성공하면 다음과 유사한 결과를 확인할 수 있다.

```text
BUILD SUCCESSFUL
```

이렇게 하면 SecurityConfig에서 설정한 공개 경로, 보호된 경로, OAuth2 로그인 시작 기능이 의도대로 동작하는지 확인할 수 있다.

---

### 정리

Spring Security에서 OAuth2 소셜 로그인을 구현하려면 SecurityFilterChain을 통해 인증 및 인가 정책을 구성할 수 있다.

이번 프로젝트에서는 SecurityConfig를 생성하고 다음 기능을 설정했다.

| 설정 | 역할 |
|---|---|
| `@Configuration` | Spring 설정 클래스 선언 |
| `@EnableWebSecurity` | 웹 보안 설정 활성화 |
| `@Bean SecurityFilterChain` | HTTP 보안 필터 체인 구성 |
| `csrf()` | CSRF 보호 정책 |
| `formLogin()` | 일반 Form Login 설정 |
| `httpBasic()` | HTTP Basic 인증 설정 |
| `oauth2Login()` | OAuth2 소셜 로그인 활성화 |
| `authorizeHttpRequests()` | 요청 경로별 접근 권한 설정 |
| `sessionManagement()` | 세션 정책 설정 |

가장 중요한 설정은 다음과 같다.

```java
.oauth2Login(Customizer.withDefaults())
```

이 설정을 사용하면 Spring Security의 OAuth2 로그인 기능을 활성화할 수 있다.

또한 일반적인 아이디·비밀번호 로그인을 사용하지 않으려면 다음과 같이 설정한다.

```java
.formLogin(AbstractHttpConfigurer::disable)
```

HTTP Basic 인증도 사용하지 않는다면 비활성화할 수 있다.

```java
.httpBasic(AbstractHttpConfigurer::disable)
```

경로별 접근 권한은 다음과 같이 설정할 수 있다.

```java
.authorizeHttpRequests(auth -> auth

        .requestMatchers(
                "/",
                "/oauth2/authorization/**",
                "/login/oauth2/code/**",
                "/login"
        ).permitAll()

        .anyRequest().authenticated()
)
```

이렇게 하면 메인 화면과 OAuth2 인증 관련 경로는 공개하고 나머지 요청은 인증된 사용자만 접근하도록 구성할 수 있다.

다만 세션 기반 인증에서는 CSRF 보호를 유지하는 것이 중요하다.

따라서 CSRF를 비활성화하는 설정은 초기 개발용 구성으로만 이해하고, 실제 서비스에서는 기본 CSRF 보호를 유지하도록 설계하는 것이 적절하다.

또한 OAuth2 로그인 기능을 활성화하려면 최소 하나 이상의 ClientRegistration이 필요하다.

현재 외부 인증 제공자의 등록 정보가 없다면 ClientRegistrationRepository를 구성하지 못해 애플리케이션 시작에 실패할 수 있다.

전체 인증 흐름은 다음과 같다.

```mermaid
flowchart TD
    A["사용자 요청"] --> B["SecurityFilterChain"]

    B --> C{"요청 경로 확인"}

    C -->|"공개 경로"| D["Controller 실행"]

    C -->|"인증 필요 경로"| E{"인증 여부"}

    E -->|"인증됨"| F["Controller 실행"]

    E -->|"인증되지 않음"| G["OAuth2 로그인 시작"]

    G --> H["OAuth2AuthorizationRequestRedirectFilter"]

    H --> I["Google / Naver"]

    I --> J["Authorization Code"]

    J --> K["OAuth2LoginAuthenticationFilter"]

    K --> L["AuthenticationManager"]

    L --> M["AuthenticationProvider"]

    M --> N["Access Token 교환"]

    N --> O["OAuth2User / OidcUser"]

    O --> P["Authentication"]

    P --> Q["SecurityContext"]

    Q --> R["HttpSession"]

    R --> F
```

이번 내용에서 기억해야 할 핵심은 다음과 같다.

**첫째, SecurityConfig는 인증 방식과 경로별 인가 정책을 정의하는 역할을 담당한다.**

**둘째, OAuth2 소셜 로그인은 `oauth2Login()`으로 활성화하며, 일반적인 Form Login과 HTTP Basic 인증과는 별개의 기능이다.**

**셋째, `oauth2Login()`과 `oauth2Client()`는 서로 다른 기능을 제공한다.**

**넷째, `permitAll()`은 특정 경로의 접근을 허용하는 설정이며 OAuth2 인증 자체를 생략하는 기능이 아니다.**

**다섯째, 세션 기반 인증에서는 CSRF 보호를 유지하는 것이 중요하다.**

**여섯째, OAuth2 Login을 활성화하려면 외부 인증 제공자에 대한 ClientRegistration이 필요하다.**

**일곱째, OAuth2 인증에 성공하면 Spring Security는 Authentication을 구성하고 세션 기반 로그인 상태를 유지할 수 있다.**

이러한 구조를 이해하면 Spring Security OAuth2 Client를 이용한 소셜 로그인 시스템에서 인증 요청이 어떤 필터를 통해 처리되고, 실제 서비스의 접근 권한은 어디에서 결정되는지 명확하게 파악할 수 있다.

#### 한 줄 요약

Spring Security 6에서 OAuth2 소셜 로그인을 구현하려면 `@Bean SecurityFilterChain`을 등록하고 `oauth2Login(Customizer.withDefaults())`을 통해 OAuth2 로그인 기능을 활성화한다. `formLogin()`과 `httpBasic()`은 사용하지 않는 경우 비활성화할 수 있으며, `authorizeHttpRequests()`를 이용해 공개 경로와 인증이 필요한 경로를 구분한다. 세션 기반 인증에서는 CSRF 보호를 유지하는 것이 적절하고, 실제 OAuth2 로그인 기능을 실행하려면 Google이나 Naver 등의 ClientRegistration 설정이 필요하다.
