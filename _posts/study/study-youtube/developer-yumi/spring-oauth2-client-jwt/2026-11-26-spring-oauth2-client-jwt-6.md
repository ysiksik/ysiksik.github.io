---
layout: post
bigtitle: '스프링 OAuth2 클라이언트 JWT'
subtitle: 스프링 OAuth2 클라이언트 JWT - 6. SecurityConfig 등록
date: '2026-11-26 00:00:03 +0900'
categories:
    - spring-oauth2-client-jwt
comments: true


---

# 스프링 OAuth2 클라이언트 JWT - 6. SecurityConfig 등록
[https://youtu.be/NuOLlxPet3w?si=s6RNQHrcTBEiM9I_](https://youtu.be/NuOLlxPet3w?si=s6RNQHrcTBEiM9I_)

# 스프링 OAuth2 클라이언트 JWT - 6. SecurityConfig 등록
{:toc}

---

## Spring Security OAuth2 Client - SecurityConfig 등록

### 개념

Spring Security에서 OAuth2 Client를 사용하려면 OAuth2 인증을 처리할 수 있도록 보안 설정을 구성해야 한다.

`application.properties` 또는 `application.yml`에 OAuth2 클라이언트 정보를 등록하는 과정이 외부 인증 서버와 통신하기 위한 정보를 정의하는 과정이라면, `SecurityConfig`를 작성하는 과정은 해당 정보를 활용하여 실제 인증 및 인가 처리가 이루어지도록 보안 정책을 구성하는 과정이다.

Spring Security에서는 `SecurityFilterChain`을 통해 다음과 같은 보안 정책을 설정할 수 있다.

- CSRF 공격 방어 설정
- Form Login 활성화 및 비활성화
- HTTP Basic 인증 활성화 및 비활성화
- OAuth2 소셜 로그인 활성화
- 요청 경로별 접근 권한 설정
- 세션 관리 정책 설정
- JWT 인증 필터 등록
- 인증 성공 및 실패 처리

OAuth2 Client와 JWT를 함께 사용하는 환경에서는 외부 인증 서버를 통한 사용자 인증과 자체 JWT를 통한 서비스 인증을 분리하여 구성해야 한다.

### 왜 사용하는가?

Spring Boot에 Spring Security 의존성을 추가하면 기본적인 보안 설정이 자동으로 적용된다.

하지만 모든 서비스가 동일한 인증 방식을 사용하는 것은 아니다.

서버 사이드 렌더링 기반의 웹 애플리케이션에서는 세션과 Form Login을 사용할 수 있지만, 프론트엔드와 백엔드가 분리된 REST API 기반의 애플리케이션에서는 OAuth2 및 JWT 기반 인증을 사용할 수 있다.

| 구분 | 일반적인 세션 기반 인증 | OAuth2 + JWT 기반 인증 |
|---|---|---|
| 최초 인증 | 아이디 및 비밀번호 | 외부 인증 서버 |
| 인증 정보 유지 | HTTP Session | JWT |
| 인증 정보 저장 | 서버 세션 저장소 | 클라이언트 측 토큰 저장소 |
| 요청별 인증 | Session ID 확인 | JWT 검증 |
| 서버 확장 | 세션 공유 방식 고려 | JWT 검증 키 및 토큰 정책 공유 |
| 로그인 처리 | Form Login 등 | OAuth2 Login |
| 주요 사용 환경 | SSR 기반 웹 서비스 | SPA, REST API, 모바일 애플리케이션 |

따라서 기본 보안 설정을 서비스의 인증 구조에 맞게 변경할 필요가 있다.

```mermaid
flowchart LR
    A["클라이언트 요청"] --> B["Spring Security Filter Chain"]

    B --> C{"인증 방식"}

    C --> D["Form Login"]
    C --> E["HTTP Basic"]
    C --> F["OAuth2 Login"]
    C --> G["JWT 인증"]

    F --> H["외부 인증 서버"]
    G --> I["JWT 검증"]

    H --> J["인증 정보 생성"]
    I --> J

    J --> K["접근 권한 확인"]
    K --> L["Controller"]
```

OAuth2와 JWT만 사용하는 서비스라면 불필요한 인증 방식을 비활성화하고, 필요한 인증 방식과 접근 정책을 명시적으로 구성하는 것이 좋다.

### SecurityConfig 작성

#### 프로젝트 구조

```text
src/main/java/com/example/oauth2jwt
├── config
│   └── SecurityConfig.java
├── controller
├── service
├── dto
├── entity
├── repository
└── jwt
```

`config` 패키지 내부에 Spring Security 설정을 담당하는 `SecurityConfig` 클래스를 생성한다.

#### SecurityConfig.java

다음은 Spring Security 6.x에서 OAuth2 로그인과 JWT 인증을 결합하기 위한 초기 설정 예제이다.

아직 JWT 발급 및 검증 로직은 구현하지 않은 상태이며, CSRF 비활성화는 기본적인 동작을 설명하기 위한 설정이다.

```java
package com.example.oauth2jwt.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

        // CSRF 설정
        http
                .csrf(csrf -> csrf.disable());

        // Form Login 비활성화
        http
                .formLogin(form -> form.disable());

        // HTTP Basic 인증 비활성화
        http
                .httpBasic(basic -> basic.disable());

        // OAuth2 Login 활성화
        http
                .oauth2Login(Customizer.withDefaults());

        // 요청 경로별 접근 권한 설정
        http
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/").permitAll()
                        .anyRequest().authenticated());

        // 세션 관리 정책 설정
        http
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS));

        return http.build();
    }
}
```

위 설정은 OAuth2 로그인 기능을 활성화하고, 이후 JWT 기반 인증을 구현하기 위한 기본적인 보안 구조를 구성한다.

**다만 `oauth2Login()`과 `STATELESS`를 설정하는 것만으로 JWT 인증이 완성되는 것은 아니다.** 자체 JWT 발급, 전달, 검증 및 인증 정보 복원 로직은 별도로 구현해야 한다.

### 주요 설정 항목

| 설정 | 역할 |
|---|---|
| `@Configuration` | Spring 설정 클래스 등록 |
| `@EnableWebSecurity` | Spring Security 웹 보안 설정 활성화 |
| `@Bean` | SecurityFilterChain을 Spring Bean으로 등록 |
| `HttpSecurity` | HTTP 요청에 대한 보안 정책 구성 |
| `csrf()` | CSRF 방어 정책 설정 |
| `formLogin()` | HTML Form 기반 로그인 설정 |
| `httpBasic()` | HTTP Basic 인증 설정 |
| `oauth2Login()` | OAuth2 및 OpenID Connect 로그인 설정 |
| `authorizeHttpRequests()` | HTTP 요청별 접근 권한 설정 |
| `sessionManagement()` | 인증 정보의 세션 관리 정책 설정 |
| `build()` | 설정을 기반으로 SecurityFilterChain 생성 |

### @Configuration

`@Configuration`은 해당 클래스를 Spring의 설정 클래스로 등록하기 위한 어노테이션이다.

```java
@Configuration
public class SecurityConfig {
}
```

Spring은 설정 클래스 내부에 선언된 `@Bean` 메서드를 통해 객체를 생성하고 Spring Container에서 관리한다.

따라서 `SecurityConfig` 내부에서 생성한 `SecurityFilterChain`도 Spring Bean으로 관리된다.

### @EnableWebSecurity

`@EnableWebSecurity`는 Spring Security의 웹 보안 관련 설정을 활성화하기 위한 어노테이션이다.

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
}
```

Spring Security는 Servlet Filter 기반의 보안 구조를 사용한다.

클라이언트의 요청이 Controller에 도달하기 전에 Spring Security의 필터를 거치도록 구성하고, 인증 및 인가 정책을 적용한다.

Spring Boot 환경에서는 자동 설정에 의해 웹 보안 기능이 활성화될 수 있으므로 `@EnableWebSecurity`가 항상 필수인 것은 아니다. 다만 직접 보안 설정을 구성한다는 의도를 명확하게 표현하기 위해 사용할 수 있다.

### SecurityFilterChain

`SecurityFilterChain`은 특정 HTTP 요청에 적용할 Spring Security 필터들을 관리하는 인터페이스이다.

```java
@Bean
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

    return http.build();
}
```

`HttpSecurity` 객체를 통해 보안 정책을 설정한 뒤 `build()`를 호출하면 해당 정책이 적용된 `SecurityFilterChain`이 생성된다.

#### SecurityFilterChain 인터페이스

```java
public interface SecurityFilterChain {

    boolean matches(HttpServletRequest request);

    List<Filter> getFilters();
}
```

| 메서드 | 설명 |
|---|---|
| `matches()` | 해당 요청에 필터 체인을 적용할 것인지 판단 |
| `getFilters()` | 요청에 적용할 보안 필터 목록 반환 |

Spring Security에서는 여러 개의 `SecurityFilterChain`을 구성할 수도 있다.

예를 들어 관리자 API와 일반 사용자 API에 서로 다른 보안 정책을 적용하는 것이 가능하다.

```mermaid
flowchart TD
    A["HTTP Request"] --> B["DelegatingFilterProxy"]
    B --> C["FilterChainProxy"]

    C --> D{"SecurityFilterChain 선택"}

    D -->|"/admin/**"| E["관리자 보안 필터 체인"]
    D -->|"/api/**"| F["일반 API 보안 필터 체인"]
    D -->|"기타 요청"| G["기본 보안 필터 체인"]

    E --> H["DispatcherServlet"]
    F --> H
    G --> H

    H --> I["Controller"]
```

여러 필터 체인 중 요청에 처음으로 일치하는 필터 체인이 선택된다. [Home](https://docs.spring.io/spring-security/reference/6.5/servlet/architecture.html)

### HttpSecurity

`HttpSecurity`는 HTTP 요청에 적용할 보안 정책을 구성하기 위한 객체이다.

```java
http
        .csrf(csrf -> csrf.disable())
        .formLogin(form -> form.disable())
        .httpBasic(basic -> basic.disable())
        .oauth2Login(Customizer.withDefaults());
```

내부적으로 각각의 설정은 관련 보안 필터 및 구성 요소를 등록하거나 제거한다.

| 설정 | 주요 관련 구성 요소 |
|---|---|
| `csrf()` | CsrfFilter |
| `formLogin()` | UsernamePasswordAuthenticationFilter |
| `httpBasic()` | BasicAuthenticationFilter |
| `oauth2Login()` | OAuth2AuthorizationRequestRedirectFilter |
| `oauth2Login()` | OAuth2LoginAuthenticationFilter |
| `authorizeHttpRequests()` | AuthorizationFilter |
| `securityContext()` | SecurityContextRepository |

즉, `HttpSecurity`는 단순히 설정값을 저장하는 객체가 아니라 Spring Security의 필터 체인을 구성하기 위한 빌더 역할을 수행한다.

### CSRF 설정

#### CSRF란?

CSRF(Cross-Site Request Forgery)는 인증된 사용자의 브라우저를 이용하여 사용자가 의도하지 않은 요청을 서버에 전송하도록 유도하는 공격 방식이다.

예를 들어 사용자가 특정 서비스에 로그인하여 인증 쿠키를 발급받은 상태라고 가정한다.

```mermaid
sequenceDiagram
    participant U as 사용자
    participant B as 브라우저
    participant S as 정상 서비스
    participant A as 악성 사이트

    U->>B: 정상 서비스 로그인
    B->>S: 로그인 요청
    S-->>B: 인증 쿠키 발급

    U->>B: 악성 사이트 접속
    B->>A: 페이지 요청
    A-->>B: 위조된 요청을 발생시키는 페이지

    B->>S: 인증 쿠키가 포함된 위조 요청
    S->>S: 인증 쿠키 확인
    S-->>B: 요청 처리
```

브라우저는 쿠키의 전송 조건을 만족하면 요청에 쿠키를 자동으로 포함한다.

서버가 쿠키만 확인하고 요청의 정당성을 별도로 검증하지 않는다면 사용자가 의도하지 않은 요청이 처리될 수 있다.

#### CSRF 비활성화

```java
http
        .csrf(csrf -> csrf.disable());
```

Spring Security는 기본적으로 POST, PUT, PATCH, DELETE 등 상태를 변경할 수 있는 HTTP 요청에 대한 CSRF 방어 기능을 제공한다.

`disable()`을 호출하면 Spring Security의 CSRF 보호 기능이 비활성화된다. [Home](https://docs.spring.io/spring-security/reference/6.5/servlet/exploits/csrf.html)

#### JWT 환경에서 CSRF를 비활성화하는 이유

JWT를 다음과 같이 Authorization 헤더에 포함하여 전달하는 구조를 고려해 보자.

```http
GET /api/members/me HTTP/1.1
Host: api.example.com
Authorization: Bearer ACCESS_TOKEN
```

일반적으로 브라우저는 애플리케이션이 직접 관리하는 Bearer Token을 임의의 요청에 자동으로 추가하지 않는다.

클라이언트가 명시적으로 Authorization 헤더에 JWT를 포함해야 하므로 쿠키 기반 인증과는 CSRF 공격 조건이 달라진다.

하지만 JWT를 사용한다고 해서 항상 CSRF 방어가 필요 없는 것은 아니다.

#### JWT 저장 방식에 따른 CSRF 위험

| 인증 방식 | 브라우저 자동 전송 | CSRF 위험 |
|---|---|---|
| Session ID 쿠키 | 전송 조건 충족 시 자동 전송 | 존재 |
| Authorization 헤더 JWT | 애플리케이션이 직접 추가 | 일반적인 CSRF 위험 낮음 |
| HttpOnly Cookie JWT | 전송 조건 충족 시 자동 전송 | 존재 |
| LocalStorage JWT + Authorization 헤더 | 애플리케이션이 직접 추가 | 일반적인 CSRF 위험 낮음 |
| HTTP Basic | 브라우저가 인증 정보를 재사용할 수 있음 | 존재 |

**CSRF 공격 가능성을 결정하는 핵심은 토큰의 형식이 아니라 브라우저가 인증 정보를 자동으로 전송하는지 여부이다.**

OAuth2 로그인 성공 후 자체 JWT를 쿠키에 저장하는 구조라면 CSRF 방어 정책을 별도로 고려해야 한다.

### Form Login 비활성화

Spring Security는 HTML Form 기반의 로그인 기능을 제공한다.

일반적으로 사용자는 아이디와 비밀번호를 입력하여 로그인 요청을 전송한다.

```http
POST /login HTTP/1.1
Content-Type: application/x-www-form-urlencoded

username=user&password=password
```

Spring Security의 `UsernamePasswordAuthenticationFilter`가 해당 요청을 처리한다.

```mermaid
flowchart TD
    A["POST /login"] --> B["UsernamePasswordAuthenticationFilter"]
    B --> C["AuthenticationManager"]
    C --> D["AuthenticationProvider"]
    D --> E["UserDetailsService"]
    E --> F["사용자 조회"]
    F --> G["비밀번호 검증"]
    G --> H{"인증 성공 여부"}

    H -->|성공| I["Authentication 생성"]
    H -->|실패| J["AuthenticationFailureHandler"]
```

OAuth2 로그인만 사용하는 서비스에서는 자체 아이디 및 비밀번호를 통한 Form Login 기능이 필요하지 않을 수 있다.

```java
http
        .formLogin(form -> form.disable());
```

이를 통해 Spring Security가 제공하는 일반적인 Form Login 인증 기능을 비활성화한다.

다만 Form Login을 비활성화하더라도 OAuth2 Login이 활성화되어 있다면 Spring Security가 OAuth2 로그인 링크를 포함한 기본 로그인 페이지를 제공할 수 있다.

즉, Form Login 비활성화와 로그인 페이지 자체의 비활성화는 서로 다른 개념이다.

### HTTP Basic 인증 비활성화

HTTP Basic 인증은 HTTP Authorization 헤더에 사용자 아이디와 비밀번호를 Base64로 인코딩하여 전달하는 인증 방식이다.

```http
GET /api/members HTTP/1.1
Host: api.example.com
Authorization: Basic dXNlcjpwYXNzd29yZA==
```

원본 인증 정보는 다음과 같다.

```text
user:password
```

Base64 인코딩 결과는 다음과 같다.

```text
dXNlcjpwYXNzd29yZA==
```

Base64는 암호화가 아니므로 원본 데이터를 복원할 수 있다.

따라서 HTTP Basic 인증을 사용할 때는 전송 구간 보호를 위해 HTTPS가 필요하다.

OAuth2와 JWT 기반의 인증만 사용하는 환경에서는 HTTP Basic 인증을 비활성화할 수 있다.

```java
http
        .httpBasic(basic -> basic.disable());
```

#### 인증 방식 비교

| 구분 | Form Login | HTTP Basic | OAuth2 Login | JWT 인증 |
|---|---|---|---|---|
| 주요 인증 정보 | ID/PW | ID/PW | Authorization Code 등 | JWT |
| 인증 정보 전달 | Form Body | Authorization 헤더 | Redirect 및 서버 간 통신 | 헤더 또는 쿠키 |
| 주요 처리 필터 | UsernamePasswordAuthenticationFilter | BasicAuthenticationFilter | OAuth2LoginAuthenticationFilter | BearerTokenAuthenticationFilter 또는 커스텀 필터 |
| 외부 인증 서버 | 불필요 | 불필요 | 필요 | 필수 아님 |
| 주요 목적 | 사용자 로그인 | HTTP 요청 인증 | 외부 계정을 통한 로그인 | 요청별 토큰 인증 |

### OAuth2 Login 활성화

OAuth2 Client 기능을 사용하기 위해 다음과 같이 설정한다.

```java
http
        .oauth2Login(Customizer.withDefaults());
```

`Customizer.withDefaults()`는 별도의 커스텀 설정 없이 Spring Security가 제공하는 기본 설정을 사용한다는 의미이다.

이 설정을 통해 OAuth2 및 OpenID Connect 로그인 흐름을 처리하는 구성 요소들이 등록된다.

#### 주요 필터

| 필터 | 역할 | 기본 요청 경로 |
|---|---|---|
| OAuth2AuthorizationRequestRedirectFilter | 외부 인증 서버로 인증 요청 전달 | `/oauth2/authorization/{registrationId}` |
| OAuth2LoginAuthenticationFilter | 인증 서버로부터 전달받은 인증 결과 처리 | `/login/oauth2/code/{registrationId}` |
| DefaultLoginPageGeneratingFilter | 필요한 경우 기본 로그인 페이지 생성 | `/login` |

OAuth2 인증 요청과 콜백 요청은 일반적인 Controller가 아니라 Spring Security의 필터에서 처리할 수 있다.

따라서 기본 OAuth2 로그인 기능을 사용한다면 해당 경로에 대한 Controller를 직접 구현할 필요가 없다. [Home](https://docs.spring.io/spring-security/reference/6.5/servlet/oauth2/login/core.html)

### OAuth2 Login 동작 구조

#### 최초 로그인 요청

사용자가 네이버 로그인을 요청한다고 가정한다.

```http
GET /oauth2/authorization/naver
```

Spring Security의 `OAuth2AuthorizationRequestRedirectFilter`가 해당 요청을 처리한다.

```mermaid
sequenceDiagram
    participant U as 사용자 브라우저
    participant F as OAuth2AuthorizationRequestRedirectFilter
    participant R as ClientRegistrationRepository
    participant N as Naver 인증 서버

    U->>F: GET /oauth2/authorization/naver
    F->>R: findByRegistrationId("naver")
    R-->>F: ClientRegistration

    F->>F: OAuth2AuthorizationRequest 생성
    F->>F: State 생성 및 인증 요청 저장
    F-->>U: 302 Redirect
    U->>N: OAuth2 인증 요청
    N-->>U: 로그인 화면
```

이때 앞서 설정한 `application.yml` 또는 `application.properties`의 OAuth2 클라이언트 정보가 사용된다.

| 설정값 | 사용 목적 |
|---|---|
| `client-id` | 클라이언트 애플리케이션 식별 |
| `redirect-uri` | 인증 결과를 전달받을 주소 |
| `scope` | 사용자에게 요청할 접근 권한 |
| `authorization-uri` | 인증 요청을 전달할 주소 |
| `authorization-grant-type` | 사용할 권한 부여 방식 |

#### 로그인 성공 후 콜백 요청

사용자가 외부 인증 서버에서 로그인에 성공하면 브라우저가 다음 주소로 이동한다.

```http
GET /login/oauth2/code/naver?code=AUTHORIZATION_CODE&state=STATE
```

해당 요청은 `OAuth2LoginAuthenticationFilter`가 처리한다.

```mermaid
sequenceDiagram
    participant U as 사용자 브라우저
    participant F as OAuth2LoginAuthenticationFilter
    participant M as AuthenticationManager
    participant P as OAuth2LoginAuthenticationProvider
    participant N as Naver 인증 서버
    participant R as Naver 리소스 서버

    U->>F: Authorization Code + State
    F->>F: 기존 인증 요청 조회 및 복원

    F->>M: 인증 요청
    M->>P: 인증 처리 위임

    P->>P: State 및 인증 응답 검증
    P->>N: Authorization Code로 토큰 요청
    N-->>P: Access Token

    P->>R: Access Token으로 사용자 정보 요청
    R-->>P: 사용자 정보

    P-->>M: 인증 결과
    M-->>F: Authentication
    F->>F: 인증 성공 처리
```

위 구조는 일반적인 OAuth2 로그인 기준이다.

Google과 같이 OpenID Connect를 사용하는 경우에는 `OidcAuthorizationCodeAuthenticationProvider` 및 `OidcUserService` 등 OIDC 전용 구성 요소가 사용될 수 있다.

### 요청 경로별 접근 권한 설정

Spring Security에서는 `authorizeHttpRequests()`를 통해 요청 경로별 접근 권한을 설정한다.

```java
http
        .authorizeHttpRequests(auth -> auth
                .requestMatchers("/").permitAll()
                .anyRequest().authenticated());
```

#### 주요 메서드

| 메서드 | 설명 |
|---|---|
| `permitAll()` | 인증 여부와 관계없이 접근 허용 |
| `authenticated()` | 인증된 사용자만 접근 허용 |
| `hasRole()` | 특정 역할을 가진 사용자만 접근 허용 |
| `hasAnyRole()` | 지정된 역할 중 하나 이상 보유한 사용자 접근 허용 |
| `hasAuthority()` | 특정 권한을 보유한 사용자만 접근 허용 |
| `denyAll()` | 모든 사용자 접근 차단 |
| `anonymous()` | 익명 사용자만 접근 허용 |

#### 경로별 접근 제어 예제

```java
http
        .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                        "/",
                        "/login",
                        "/oauth2/**",
                        "/login/oauth2/code/**",
                        "/public/**"
                ).permitAll()
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .requestMatchers("/member/**").hasAnyRole("USER", "ADMIN")
                .anyRequest().authenticated());
```

| 요청 경로 | 접근 조건 |
|---|---|
| `/` | 모든 사용자 |
| `/login` | 모든 사용자 |
| `/oauth2/**` | 모든 사용자 |
| `/login/oauth2/code/**` | 모든 사용자 |
| `/public/**` | 모든 사용자 |
| `/admin/**` | ADMIN 역할 |
| `/member/**` | USER 또는 ADMIN 역할 |
| 기타 경로 | 인증된 사용자 |

#### 요청 경로 설정 순서

Spring Security는 요청 경로와 일치하는 인가 규칙을 선언 순서대로 확인한다.

따라서 구체적인 경로를 먼저 선언하고, 포괄적인 경로를 이후에 선언해야 한다.

잘못된 설정은 다음과 같다.

```java
http
        .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated());
```

`/api/admin/users` 요청은 앞서 선언한 `/api/**` 패턴에 먼저 일치하기 때문에 관리자 권한 검증이 적용되지 않는다.

올바른 설정은 다음과 같다.

```java
http
        .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/**").authenticated()
                .anyRequest().denyAll());
```

또한 `permitAll()`은 Spring Security 필터 자체를 건너뛰도록 하는 설정이 아니다.

해당 요청은 보안 필터 체인을 거치며, 인가 단계에서 인증 여부와 관계없이 접근이 허용된다. [Home](https://docs.spring.io/spring-security/reference/6.5/servlet/authorization/authorize-http-requests.html)

### 세션 관리 정책 설정

OAuth2와 JWT를 함께 사용하는 환경에서 중요한 설정 중 하나는 세션 관리 정책이다.

```java
http
        .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS));
```

Spring Security에서는 `SessionCreationPolicy`를 통해 세션 관리 정책을 지정할 수 있다.

#### SessionCreationPolicy

| 정책 | 설명 |
|---|---|
| `ALWAYS` | 항상 HTTP Session 생성 |
| `IF_REQUIRED` | 필요한 경우에만 HTTP Session 생성 |
| `NEVER` | 세션을 생성하지 않지만 기존 세션은 사용 가능 |
| `STATELESS` | 인증 정보를 얻기 위해 HTTP Session을 생성하거나 사용하지 않음 |

#### ALWAYS

```java
.sessionCreationPolicy(SessionCreationPolicy.ALWAYS)
```

Spring Security가 항상 HTTP Session을 생성하도록 설정한다.

#### IF_REQUIRED

```java
.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
```

인증 처리 등 세션이 필요한 상황에서만 세션을 생성한다.

일반적인 세션 기반 웹 애플리케이션에서 사용하는 기본적인 정책이다.

#### NEVER

```java
.sessionCreationPolicy(SessionCreationPolicy.NEVER)
```

Spring Security가 세션을 직접 생성하지 않지만, 이미 생성된 세션이 존재한다면 사용할 수 있다.

#### STATELESS

```java
.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
```

Spring Security가 사용자 인증 정보를 유지하거나 복원하기 위해 HTTP Session을 사용하지 않도록 설정한다.

JWT 기반 인증에서는 일반적으로 해당 정책을 사용한다. [Home](https://docs.spring.io/spring-security/reference/6.5/servlet/authentication/session-management.html?utm_source=chatgpt.com)

### 세션 기반 인증과 Stateless 인증의 차이

#### 세션 기반 인증

```mermaid
sequenceDiagram
    participant C as 클라이언트
    participant S as Spring Security
    participant R as Session Store

    C->>S: 로그인 요청
    S->>S: 사용자 인증
    S->>R: 인증 정보 저장
    R-->>S: Session ID
    S-->>C: Session Cookie 발급

    C->>S: API 요청 + Session Cookie
    S->>R: Session ID로 인증 정보 조회
    R-->>S: 인증 정보
    S-->>C: API 응답
```

서버는 사용자의 인증 상태를 세션 저장소에 유지한다.

이후 요청에서는 Session ID를 이용하여 저장된 인증 정보를 조회한다.

#### JWT 기반 Stateless 인증

```mermaid
sequenceDiagram
    participant C as 클라이언트
    participant S as Spring Security
    participant J as JWT Provider

    C->>S: 로그인 요청
    S->>S: 사용자 인증
    S->>J: JWT 생성 요청
    J-->>S: JWT
    S-->>C: JWT 발급

    C->>S: API 요청 + JWT
    S->>J: JWT 서명 및 만료 검증
    J-->>S: 사용자 인증 정보
    S->>S: SecurityContext에 인증 정보 등록
    S-->>C: API 응답

    S->>S: 요청 종료 후 SecurityContext 정리
```

JWT 기반 인증에서는 매 요청마다 JWT를 검증하고, 해당 요청을 처리하는 동안 사용할 인증 정보를 생성한다.

사용자 인증 정보를 HTTP Session에 지속적으로 저장할 필요가 없다.

### OAuth2 Login에서 STATELESS 설정 시 주의사항

OAuth2와 JWT를 함께 사용할 때 가장 혼동하기 쉬운 부분이다.

```java
.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
```

위 설정을 적용한다고 해서 애플리케이션 전체에서 HTTP Session이 절대 생성되지 않는 것은 아니다.

OAuth2 Authorization Code 방식은 여러 HTTP 요청과 리다이렉트에 걸쳐 진행되기 때문에 최초 인증 요청에 대한 정보를 일시적으로 저장해야 한다.

대표적으로 다음 정보가 필요하다.

| 정보 | 저장 목적 |
|---|---|
| State | 최초 인증 요청과 콜백 요청의 연관성 확인 |
| Registration ID | 인증 제공자 식별 |
| Redirect URI | 인증 코드 교환 시 사용 |
| Authorization Request | 최초 인증 요청 정보 복원 |
| Code Verifier | PKCE 적용 시 인증 코드 교환에 사용 |
| Nonce 관련 정보 | OIDC 인증 응답 검증에 사용 |

Spring Security에서는 기본적으로 `HttpSessionOAuth2AuthorizationRequestRepository`를 사용하여 OAuth2 인증 요청 정보를 HTTP Session에 저장한다.

```mermaid
sequenceDiagram
    participant C as 클라이언트
    participant S as Spring Security
    participant H as HTTP Session
    participant O as OAuth2 Provider

    C->>S: OAuth2 로그인 요청
    S->>S: Authorization Request 생성
    S->>H: 인증 요청 및 State 저장
    S-->>C: 외부 인증 서버 Redirect

    C->>O: 로그인 요청
    O-->>C: Authorization Code + State

    C->>S: Callback 요청
    S->>H: 기존 Authorization Request 조회
    H-->>S: 인증 요청 정보
    S->>S: State 검증 및 토큰 교환
    S->>H: 사용한 인증 요청 정보 제거

    S-->>C: 자체 JWT 발급

    C->>S: 이후 API 요청 + JWT
    S->>S: JWT 기반 인증
```

여기서 중요한 점은 OAuth2 인증 과정에서 사용하는 일시적인 상태와 로그인 이후 유지하는 사용자 인증 상태가 서로 다르다는 것이다.

| 구분 | OAuth2 인증 요청 상태 | 사용자 인증 상태 |
|---|---|---|
| 목적 | OAuth2 인증 흐름 검증 | 로그인 상태 유지 |
| 유지 기간 | 로그인 요청부터 콜백 처리까지 | 로그인 이후 |
| 주요 정보 | State, Authorization Request | Authentication, 사용자 권한 |
| 기본 저장 방식 | HTTP Session | HTTP Session 또는 JWT 기반 재구성 |
| Stateless 환경 | 별도의 저장 방식 또는 임시 세션 필요 | JWT로 대체 가능 |

따라서 `STATELESS`를 사용하더라도 OAuth2 인증 요청 저장소에 의해 임시 HTTP Session이 생성될 수 있다.

이를 완전히 제거하려면 `AuthorizationRequestRepository`의 구현 방식도 변경해야 한다.

### AuthorizationRequestRepository

`AuthorizationRequestRepository`는 OAuth2 인증 요청 정보를 저장하고 조회하기 위한 인터페이스이다.

```java
public interface AuthorizationRequestRepository
        <T extends OAuth2AuthorizationRequest> {

    T loadAuthorizationRequest(HttpServletRequest request);

    void saveAuthorizationRequest(
            T authorizationRequest,
            HttpServletRequest request,
            HttpServletResponse response
    );

    T removeAuthorizationRequest(
            HttpServletRequest request,
            HttpServletResponse response
    );
}
```

#### 주요 메서드

| 메서드 | 역할 |
|---|---|
| `loadAuthorizationRequest()` | 저장된 OAuth2 인증 요청 정보 조회 |
| `saveAuthorizationRequest()` | 최초 OAuth2 인증 요청 정보 저장 |
| `removeAuthorizationRequest()` | 인증 결과 처리 시 저장된 정보 조회 및 제거 |

Spring Security의 기본 세션 기반 저장 방식 외에도 서비스 요구사항에 따라 다른 저장 구조를 설계할 수 있다.

```mermaid
flowchart TD
    A["AuthorizationRequestRepository"]

    A --> B["HttpSession 기반"]
    A --> C["Redis 기반 커스텀 구현"]
    A --> D["Cookie 기반 커스텀 구현"]

    B --> E["서버 HTTP Session"]
    C --> F["분산 저장소"]
    D --> G["클라이언트 Cookie"]
```

| 저장 방식 | 장점 | 단점 |
|---|---|---|
| HTTP Session | 기본 제공, 구현 간단 | 다중 서버 환경에서 세션 공유 고려 |
| Spring Session + Redis | 기존 세션 구조 유지, 서버 간 공유 | Redis 의존성 |
| Redis 직접 구현 | TTL, 일회성 사용 등 세부 제어 가능 | 별도 구현 및 브라우저 연관성 검증 필요 |
| Cookie | 별도의 서버 저장소 없이 구성 가능 | 크기 제한, 위변조 방지, 재사용 방어 필요 |

커스텀 저장소는 다음과 같이 등록할 수 있다.

```java
http
        .oauth2Login(oauth2 -> oauth2
                .authorizationEndpoint(authorization -> authorization
                        .authorizationRequestRepository(
                                customAuthorizationRequestRepository
                        )
                )
        );
```

위 코드는 별도로 구현한 `AuthorizationRequestRepository` 객체를 사용하도록 설정하는 예제이다.

쿠키 기반 저장소를 구현할 때는 인증 요청 정보의 무결성, 기밀성, 만료 시간, 브라우저와의 연관성 및 재사용 방지 정책을 함께 설계해야 한다.

### Spring Security 내부 구조

SecurityConfig에서 OAuth2 Login을 활성화하면 Spring Security는 OAuth2 인증에 필요한 필터 및 인증 처리 객체를 구성한다.

#### 주요 구성 요소

| 구성 요소 | 역할 |
|---|---|
| DelegatingFilterProxy | Servlet Container와 Spring Bean 기반 필터 연결 |
| FilterChainProxy | 요청에 적합한 SecurityFilterChain 선택 |
| SecurityFilterChain | 요청에 적용할 보안 필터 관리 |
| SecurityContextHolderFilter | 현재 요청의 SecurityContext 로딩 및 정리 |
| OAuth2AuthorizationRequestRedirectFilter | 외부 인증 서버로 인증 요청 |
| OAuth2LoginAuthenticationFilter | OAuth2 콜백 요청 처리 |
| AuthenticationManager | 인증 처리 위임 |
| OAuth2LoginAuthenticationProvider | OAuth2 인증 수행 |
| OAuth2UserService | 외부 사용자 정보 조회 |
| AuthenticationSuccessHandler | 인증 성공 후 처리 |
| AuthenticationFailureHandler | 인증 실패 후 처리 |
| AuthorizationFilter | 요청에 대한 접근 권한 검증 |

#### 전체 필터 구조

```mermaid
flowchart TD
    A["HTTP Request"] --> B["DelegatingFilterProxy"]
    B --> C["FilterChainProxy"]
    C --> D["SecurityFilterChain"]

    D --> E["SecurityContextHolderFilter"]
    E --> F["HeaderWriterFilter"]
    F --> G["OAuth2AuthorizationRequestRedirectFilter"]
    G --> H["OAuth2LoginAuthenticationFilter"]
    H --> I["기타 보안 필터"]
    I --> J["AnonymousAuthenticationFilter"]
    J --> K["ExceptionTranslationFilter"]
    K --> L["AuthorizationFilter"]

    L --> M{"접근 가능 여부"}
    M -->|허용| N["DispatcherServlet"]
    M -->|거부| O["인증 또는 인가 실패 응답"]

    N --> P["Controller"]
```

위 구조는 이해를 돕기 위해 주요 필터만 표현한 것이다.

실제 등록되는 필터의 종류와 구성은 Spring Security 버전 및 보안 설정에 따라 달라질 수 있다.

또한 OAuth2 로그인 요청처럼 특정 필터에서 리다이렉트 응답을 반환하는 경우 이후 필터나 Controller까지 요청이 전달되지 않을 수 있다.

### OAuth2 Login 커스터마이징

`Customizer.withDefaults()`를 사용하면 Spring Security가 제공하는 기본 OAuth2 로그인 동작을 사용할 수 있다.

하지만 실제 서비스에서는 사용자 정보 처리, 회원 가입, JWT 발급 등 추가적인 비즈니스 로직이 필요하다.

이를 위해 OAuth2 Login 설정을 확장할 수 있다.

```java
http
        .oauth2Login(oauth2 -> oauth2
                .authorizationEndpoint(authorization -> {
                    // 인증 요청 관련 설정
                })
                .redirectionEndpoint(redirection -> {
                    // 인증 결과 Callback 관련 설정
                })
                .tokenEndpoint(token -> {
                    // Access Token 발급 관련 설정
                })
                .userInfoEndpoint(userInfo -> {
                    // 사용자 정보 조회 관련 설정
                })
        );
```

#### 주요 커스터마이징 항목

| 설정 | 역할 |
|---|---|
| `authorizationEndpoint()` | 인증 요청 생성 및 저장 방식 변경 |
| `redirectionEndpoint()` | 인증 결과를 전달받을 콜백 경로 변경 |
| `tokenEndpoint()` | 인증 코드와 Access Token 교환 방식 변경 |
| `userInfoEndpoint()` | 외부 사용자 정보 처리 방식 변경 |
| `loginPage()` | 사용자 정의 로그인 페이지 설정 |
| `successHandler()` | OAuth2 인증 성공 후 처리 |
| `failureHandler()` | OAuth2 인증 실패 후 처리 |
| `authorizedClientService()` | 외부 인증 서버의 토큰 관리 방식 설정 |
| `clientRegistrationRepository()` | OAuth2 클라이언트 등록 정보 관리 방식 설정 |

이러한 확장 지점을 통해 서비스 요구사항에 맞는 인증 구조를 구현할 수 있다. [Home](https://docs.spring.io/spring-security/reference/6.5/servlet/oauth2/login/advanced.html)

### OAuth2와 JWT를 결합한 최종 구조

OAuth2 Login과 자체 JWT 인증을 함께 사용하려면 추가적으로 다음과 같은 구성 요소가 필요하다.

```text
src/main/java/com/example/oauth2jwt
├── config
│   └── SecurityConfig.java
├── service
│   └── CustomOAuth2UserService.java
├── handler
│   ├── CustomSuccessHandler.java
│   └── CustomFailureHandler.java
├── jwt
│   ├── JWTUtil.java
│   └── JWTFilter.java
├── dto
│   ├── OAuth2Response.java
│   ├── GoogleResponse.java
│   ├── NaverResponse.java
│   └── CustomOAuth2User.java
├── entity
│   └── UserEntity.java
└── repository
    └── UserRepository.java
```

| 클래스 | 역할 |
|---|---|
| SecurityConfig | 인증 및 인가 정책 구성 |
| CustomOAuth2UserService | 외부 사용자 정보 조회 및 내부 회원 처리 |
| OAuth2Response | 서비스별 사용자 정보 추상화 |
| GoogleResponse | Google 사용자 응답 처리 |
| NaverResponse | Naver 사용자 응답 처리 |
| CustomOAuth2User | 자체 서비스 사용자 인증 정보 관리 |
| CustomSuccessHandler | OAuth2 로그인 성공 후 JWT 발급 및 전달 |
| CustomFailureHandler | OAuth2 로그인 실패 처리 |
| JWTUtil | JWT 생성 및 검증 |
| JWTFilter | 요청별 JWT 검증 및 Authentication 생성 |
| UserRepository | 내부 회원 정보 조회 및 저장 |

#### OAuth2 Login과 JWT 인증의 책임 분리

```mermaid
flowchart TD
    A["클라이언트"]

    A --> B["OAuth2 로그인 요청"]

    subgraph OAuth2["최초 사용자 인증"]
        B --> C["OAuth2AuthorizationRequestRedirectFilter"]
        C --> D["외부 OAuth2 인증 서버"]
        D --> E["OAuth2LoginAuthenticationFilter"]
        E --> F["CustomOAuth2UserService"]
        F --> G["회원 조회 및 가입"]
        G --> H["CustomSuccessHandler"]
        H --> I["JWTUtil"]
    end

    I --> J["자체 JWT 발급"]
    J --> A

    A --> K["API 요청 + JWT"]

    subgraph JWT["요청별 사용자 인증"]
        K --> L["JWTFilter"]
        L --> M["JWTUtil 검증"]
        M --> N["Authentication 생성"]
        N --> O["SecurityContextHolder"]
        O --> P["AuthorizationFilter"]
    end

    P --> Q["Controller"]
```

OAuth2 Client는 최초 사용자를 인증하고 사용자 정보를 획득하는 역할을 수행한다.

JWT 인증은 이후 발생하는 API 요청에서 사용자의 인증 정보를 검증하고 복원하는 역할을 수행한다.

외부 서비스의 Access Token과 자체 서비스에서 발급한 JWT를 구분하여 관리하는 것이 중요하다.

### 실무에서의 활용

#### 1. JWT 인증 필터 등록

자체 JWT를 검증하는 필터를 구현하였다면 SecurityFilterChain에 등록해야 한다.

```java
http
        .addFilterBefore(
                jwtFilter,
                UsernamePasswordAuthenticationFilter.class
        );
```

JWT 필터에서는 다음과 같은 작업을 수행한다.

```mermaid
flowchart TD
    A["HTTP Request"] --> B["JWT 추출"]
    B --> C{"JWT 존재 여부"}

    C -->|없음| D["다음 필터 진행"]
    C -->|있음| E["JWT 서명 검증"]

    E --> F{"유효한 토큰인가?"}
    F -->|아니오| G["인증 실패 처리"]
    F -->|예| H["사용자 정보 추출"]

    H --> I["Authentication 생성"]
    I --> J["SecurityContextHolder 등록"]
    J --> D
```

주의할 점은 JWT 필터에서 JWT가 없거나 만료되었다는 이유만으로 모든 요청을 차단해서는 안 된다는 것이다.

OAuth2 최초 로그인 요청이나 콜백 요청에는 자체 서비스 JWT가 존재하지 않을 수 있기 때문이다.

필요하다면 `OncePerRequestFilter`의 `shouldNotFilter()`를 재정의하여 JWT 검증 대상에서 OAuth2 인증 관련 경로를 제외할 수 있다.

```java
@Override
protected boolean shouldNotFilter(HttpServletRequest request) {

    String path = request.getServletPath();

    return path.startsWith("/oauth2/authorization/")
            || path.startsWith("/login/oauth2/code/");
}
```

#### 2. OAuth2 로그인과 API 보안 정책 분리

실무에서는 OAuth2 로그인 요청과 일반 API 요청의 특성이 다르다는 점을 활용하여 SecurityFilterChain 자체를 분리할 수 있다.

OAuth2 로그인에는 리다이렉트 및 임시 인증 상태 관리가 필요하지만, 일반 API에서는 JWT 검증과 접근 권한 확인이 필요하다.

```mermaid
flowchart TD
    A["클라이언트 요청"] --> B["FilterChainProxy"]

    B --> C{"요청 경로"}

    C -->|"/oauth2/**, /login/**"| D["OAuth2 SecurityFilterChain"]
    C -->|"/api/**"| E["API SecurityFilterChain"]

    D --> F["OAuth2 Login"]
    F --> G["임시 인증 요청 상태 관리"]
    G --> H["JWT 발급"]

    E --> I["Stateless"]
    I --> J["JWT 검증"]
    J --> K["401 또는 403 응답"]
    J --> L["API Controller"]
```

다음은 Authorization 헤더에 Bearer Token을 전달하는 API를 가정한 구성 예제이다.

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    @Order(1)
    public SecurityFilterChain oauth2FilterChain(
            HttpSecurity http
    ) throws Exception {

        http
                .securityMatcher(
                        "/oauth2/**",
                        "/login",
                        "/login/oauth2/**"
                )
                .authorizeHttpRequests(auth -> auth
                        .anyRequest().permitAll()
                )
                .oauth2Login(Customizer.withDefaults())
                .sessionManagement(session -> session
                        .sessionCreationPolicy(
                                SessionCreationPolicy.IF_REQUIRED
                        )
                );

        return http.build();
    }

    @Bean
    @Order(2)
    public SecurityFilterChain apiFilterChain(
            HttpSecurity http
    ) throws Exception {

        http
                .securityMatcher("/api/**")
                .csrf(csrf -> csrf.disable())
                .formLogin(form -> form.disable())
                .httpBasic(basic -> basic.disable())
                .sessionManagement(session -> session
                        .sessionCreationPolicy(
                                SessionCreationPolicy.STATELESS
                        )
                )
                .oauth2ResourceServer(oauth2 -> oauth2
                        .jwt(Customizer.withDefaults())
                )
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/public/**").permitAll()
                        .anyRequest().authenticated()
                );

        return http.build();
    }

    @Bean
    @Order(3)
    public SecurityFilterChain defaultFilterChain(
            HttpSecurity http
    ) throws Exception {

        http
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/", "/error").permitAll()
                        .anyRequest().denyAll()
                );

        return http.build();
    }
}
```

위 예제에서는 다음 import가 추가로 필요하다.

```java
import org.springframework.core.annotation.Order;
```

또한 Resource Server 기반 JWT 검증을 사용하기 위해 관련 의존성이 필요하다.

```groovy
implementation 'org.springframework.boot:spring-boot-starter-oauth2-resource-server'
```

자체 발급 JWT를 검증할 수 있는 `JwtDecoder`와 검증 키 설정도 별도로 구성해야 한다. OAuth2 로그인 성공 후 JWT를 발급하는 SuccessHandler 역시 생략된 상태이다.

직접 구현한 JWTFilter를 사용하는 경우에는 `oauth2ResourceServer()` 대신 해당 필터를 등록하는 방식으로 구성할 수 있다.

#### 3. REST API의 인증 실패 응답 처리

OAuth2 로그인 기능을 활성화하면 인증되지 않은 요청에 대해 로그인 페이지로 리다이렉트하는 동작이 발생할 수 있다.

하지만 REST API에서는 일반적으로 HTTP 상태 코드를 통해 인증 및 인가 실패를 처리하는 것이 적합하다.

| HTTP 상태 코드 | 의미 |
|---|---|
| 302 Found | 로그인 페이지 또는 외부 인증 서버로 이동 |
| 401 Unauthorized | 인증 정보가 없거나 유효하지 않음 |
| 403 Forbidden | 접근 권한이 부족하거나 보안 정책에 의해 거부됨 |

API 전용 필터 체인에서는 다음과 같은 설정을 적용할 수 있다.

```java
http
        .exceptionHandling(exception -> exception
                .authenticationEntryPoint(
                        (request, response, authException) -> {

                            response.setStatus(
                                    HttpServletResponse.SC_UNAUTHORIZED
                            );
                        }
                )
                .accessDeniedHandler(
                        (request, response, accessDeniedException) -> {

                            response.setStatus(
                                    HttpServletResponse.SC_FORBIDDEN
                            );
                        }
                )
        );
```

이를 통해 프론트엔드에서는 응답 상태 코드에 따라 로그인 화면 이동, 토큰 재발급, 접근 권한 안내 등의 처리를 수행할 수 있다.

#### 4. 다중 서버 환경의 OAuth2 인증 상태 관리

서버가 여러 대 운영되는 환경에서는 OAuth2 최초 로그인 요청과 콜백 요청이 서로 다른 서버에 전달될 수 있다.

```mermaid
sequenceDiagram
    participant C as 클라이언트
    participant L as Load Balancer
    participant A as Server A
    participant B as Server B
    participant O as OAuth2 Provider

    C->>L: OAuth2 로그인 요청
    L->>A: 요청 전달
    A->>A: 인증 요청 정보 저장
    A-->>C: Redirect

    C->>O: 사용자 인증
    O-->>C: Authorization Code + State

    C->>L: Callback 요청
    L->>B: 요청 전달
    B->>B: 인증 요청 정보 조회 실패
    B-->>C: authorization_request_not_found
```

Server A의 로컬 세션에 인증 요청 정보가 저장되어 있다면 Server B에서는 이를 조회할 수 없다.

이러한 문제는 Spring Session과 Redis를 이용한 분산 세션 저장소로 해결할 수 있다.

```mermaid
flowchart TD
    A["클라이언트"] --> B["Load Balancer"]

    B --> C["Server A"]
    B --> D["Server B"]
    B --> E["Server C"]

    C <--> F["Redis Session Store"]
    D <--> F
    E <--> F
```

최초 OAuth2 인증 요청 정보가 Redis에 저장되면 다른 서버에서 콜백 요청을 처리하더라도 동일한 정보를 조회할 수 있다.

OAuth2 로그인 과정에서만 분산 세션을 사용하고, 이후 일반 API 인증은 Stateless JWT 기반으로 운영하는 구조도 가능하다.

#### 5. SecurityFilterChain 디버깅

Spring Security의 실제 필터 동작을 확인하려면 로그 레벨을 설정할 수 있다.

```yaml
logging:
  level:
    org.springframework.security: DEBUG
```

더 상세한 필터 실행 과정을 확인해야 한다면 `TRACE`를 사용할 수 있다.

```yaml
logging:
  level:
    org.springframework.security: TRACE
```

다음과 같은 정보를 확인할 수 있다.

| 확인 항목 | 활용 목적 |
|---|---|
| SecurityFilterChain 구성 | 실제 등록된 보안 필터 확인 |
| 요청별 필터 실행 | 특정 요청의 처리 흐름 분석 |
| OAuth2 인증 요청 | 로그인 리다이렉트 문제 분석 |
| 인증 객체 생성 | Authentication 생성 여부 확인 |
| Anonymous 인증 처리 | 인증 정보 누락 확인 |
| 인가 실패 | 요청 경로 및 권한 설정 검증 |
| 인증 실패 | OAuth2 콜백 및 JWT 오류 분석 |

운영 환경에서는 민감한 인증 정보 노출과 로그 증가를 방지하기 위해 상세 로그를 상시 활성화하지 않는 것이 좋다.

#### 6. Spring Security 설정 관련 주요 오류

| 오류 및 증상 | 주요 원인 |
|---|---|
| 기본 로그인 화면이 나타남 | OAuth2 기본 로그인 페이지 또는 인증 진입점 설정 |
| OAuth2 로그인 요청 실패 | ClientRegistration 설정 또는 OAuth2 Login 등록 누락 |
| `redirect_uri_mismatch` | 등록된 콜백 주소와 실제 요청 주소 불일치 |
| `authorization_request_not_found` | 기존 OAuth2 인증 요청 정보 유실 |
| `invalid_state_parameter` | State 검증 실패 |
| 로그인 성공 후 다시 로그인 화면으로 이동 | JWT 미발급 또는 인증 정보 복원 실패 |
| API 요청 시 302 응답 | 로그인 페이지 리다이렉트 기반 인증 진입점 사용 |
| API 요청 시 401 응답 | JWT 누락, 만료 또는 검증 실패 |
| API 요청 시 403 응답 | 권한 부족 또는 CSRF 검증 실패 |
| STATELESS 설정 후 JSESSIONID 생성 | OAuth2 인증 요청 저장소 등에서 세션 생성 |
| 다중 서버에서 간헐적 로그인 실패 | 서버 간 OAuth2 인증 요청 상태 공유 문제 |
| JWT 필터에서 OAuth2 로그인 차단 | 필터 적용 경로 및 예외 처리 문제 |

### Spring Security 버전에 따른 설정 방식

Spring Security의 버전이 변경되면서 보안 설정 방식도 변경되었다.

#### 기존 설정 방식

Spring Security의 이전 버전에서는 `WebSecurityConfigurerAdapter`를 상속하여 보안 정책을 구성하는 방식을 사용하였다.

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig
        extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {

        http
                .csrf().disable()
                .formLogin().disable()
                .httpBasic().disable()
                .oauth2Login()
                .and()
                .authorizeRequests()
                .antMatchers("/").permitAll()
                .anyRequest().authenticated();
    }
}
```

#### Spring Security 6.x 설정 방식

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(
            HttpSecurity http
    ) throws Exception {

        http
                .csrf(csrf -> csrf.disable())
                .formLogin(form -> form.disable())
                .httpBasic(basic -> basic.disable())
                .oauth2Login(Customizer.withDefaults())
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/").permitAll()
                        .anyRequest().authenticated()
                );

        return http.build();
    }
}
```

#### 버전별 주요 변경 사항

| 구분 | 기존 방식 | 현재 권장 방식 |
|---|---|---|
| 보안 설정 | WebSecurityConfigurerAdapter 상속 | SecurityFilterChain Bean 등록 |
| 설정 구성 | 메서드 체이닝 | Lambda DSL |
| 요청 경로 매칭 | antMatchers() | requestMatchers() |
| 인가 설정 | authorizeRequests() | authorizeHttpRequests() |
| 설정 연결 | `.and()` | Lambda 기반 설정 |
| 설정 확장 | 상속 중심 | Bean 및 구성 중심 |

`WebSecurityConfigurerAdapter`는 Spring Security 5.7에서 deprecated 되었으며 Spring Security 6에서 제거되었다.

또한 Spring Security 7에서는 기존의 인자 없는 설정 메서드와 `.and()` 중심의 구성 방식 대신 Lambda DSL을 사용해야 한다.

따라서 신규 프로젝트에서는 `SecurityFilterChain`과 Lambda DSL을 기반으로 보안 정책을 구성하는 것이 적합하다.

### 정리

Spring Security에서 `SecurityConfig`는 애플리케이션의 인증 방식, 접근 권한, 세션 관리 및 보안 필터를 구성하기 위한 핵심 설정 클래스이다.

OAuth2 Client와 JWT를 함께 사용하는 환경에서는 불필요한 Form Login과 HTTP Basic 인증을 비활성화하고 OAuth2 Login을 활성화하여 외부 인증 서버를 통한 사용자 인증을 구성할 수 있다.

| 설정 | 핵심 역할 |
|---|---|
| `csrf()` | 인증 정보 전달 방식에 따른 CSRF 정책 구성 |
| `formLogin().disable()` | 일반 Form Login 비활성화 |
| `httpBasic().disable()` | HTTP Basic 인증 비활성화 |
| `oauth2Login()` | OAuth2 및 OIDC 로그인 활성화 |
| `authorizeHttpRequests()` | 요청 경로별 접근 권한 관리 |
| `sessionCreationPolicy(STATELESS)` | 세션에 의존하지 않는 요청별 인증 구성 |
| `AuthorizationRequestRepository` | OAuth2 인증 요청의 일시적인 상태 관리 |
| `AuthenticationSuccessHandler` | OAuth2 로그인 성공 후 자체 JWT 발급 |
| `JWTFilter` | 요청별 JWT 검증 및 인증 정보 생성 |

특히 OAuth2 인증 과정에서 필요한 일시적인 상태 관리와 로그인 이후 사용자 인증 상태 관리를 분리하여 이해해야 한다.

JWT를 사용한다고 해서 모든 서버 상태가 사라지는 것은 아니며, `STATELESS`를 설정한다고 해서 애플리케이션의 모든 HTTP Session 생성이 금지되는 것도 아니다.

OAuth2는 최초 사용자의 인증을 담당하고, 자체 JWT는 이후 서비스 요청에 대한 인증을 담당하도록 책임을 분리하는 것이 핵심이다.

#### 참고 문서

- [Spring Security - OAuth2 Login Core Configuration](https://docs.spring.io/spring-security/reference/6.5/servlet/oauth2/login/core.html?utm_source=chatgpt.com)
- [Spring Security - OAuth2 Login Advanced Configuration](https://docs.spring.io/spring-security/reference/6.5/servlet/oauth2/login/advanced.html?utm_source=chatgpt.com)
- [Spring Security - Servlet Architecture](https://docs.spring.io/spring-security/reference/6.5/servlet/architecture.html?utm_source=chatgpt.com)
- [Spring Security - Authentication Persistence and Session Management](https://docs.spring.io/spring-security/reference/6.5/servlet/authentication/session-management.html?utm_source=chatgpt.com)
- [Spring Security - Authorize HTTP Requests](https://docs.spring.io/spring-security/reference/6.5/servlet/authorization/authorize-http-requests.html?utm_source=chatgpt.com)
- [Spring Security - CSRF Protection](https://docs.spring.io/spring-security/reference/6.5/servlet/exploits/csrf.html?utm_source=chatgpt.com)

#### 한 줄 요약

Spring Security의 SecurityConfig는 OAuth2 로그인, JWT 인증, 접근 권한 및 세션 관리 정책을 하나의 보안 구조로 구성하며, 외부 인증 서버를 통한 최초 사용자 인증과 자체 JWT를 통한 요청별 인증을 연결하는 역할을 수행한다.
