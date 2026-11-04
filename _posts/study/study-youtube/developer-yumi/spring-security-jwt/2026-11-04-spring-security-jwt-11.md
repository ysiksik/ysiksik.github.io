---
layout: post
bigtitle: '스프링 시큐리티 JWT'
subtitle: 스프링 시큐리티 JWT - 11. JWT 검증 필터
date: '2026-11-04 00:00:02 +0900'
categories:
    - spring-security-jwt
comments: true


---

# 스프링 시큐리티 JWT - 11. JWT 검증 필터
[https://youtu.be/7B6KHSZN3jY?si=dXJb3JoT86BmciDz](https://youtu.be/7B6KHSZN3jY?si=dXJb3JoT86BmciDz)

# 스프링 시큐리티 JWT - 11. JWT 검증 필터
* toc
{:toc}

---

### Spring Security 6 JWT 검증 필터 구현: OncePerRequestFilter, SecurityContextHolder와 Stateless 인증 완벽 정리

Spring Security에서 JWT 기반 인증 시스템을 구현하려면 로그인 성공 시 JWT를 발급하는 기능뿐만 아니라, 이후 HTTP 요청에서 전달받은 JWT를 검증하는 기능도 필요하다.

기존에 구현한 로그인 시스템에서는 다음과 같은 과정으로 JWT를 발급했다.

```text
POST /login
    ↓
LoginFilter
    ↓
AuthenticationManager
    ↓
DaoAuthenticationProvider
    ↓
CustomUserDetailsService
    ↓
MySQL 사용자 조회
    ↓
비밀번호 검증
    ↓
successfulAuthentication()
    ↓
JWTUtil.createJwt()
    ↓
JWT 발급
```

로그인에 성공한 클라이언트는 HTTP 응답의 Authorization 헤더에서 JWT를 전달받는다.

```http
HTTP/1.1 200 OK
Authorization: Bearer <ACCESS_TOKEN>
```

그런데 JWT를 발급했다고 해서 모든 인증 기능이 완성되는 것은 아니다.

클라이언트가 발급받은 JWT를 이용해 다른 API를 호출할 때, 서버는 해당 JWT가 정상적으로 발급된 토큰인지 확인해야 한다.

예를 들어 다음과 같은 요청을 생각해보자.

```http
GET /admin HTTP/1.1
Host: localhost:8080
Authorization: Bearer <ACCESS_TOKEN>
```

서버는 다음 사항을 확인해야 한다.

1. Authorization 헤더에 JWT가 존재하는가?
2. Bearer 인증 형식으로 전달되었는가?
3. JWT의 서명이 유효한가?
4. JWT의 만료 시간이 지나지 않았는가?
5. JWT에 필요한 사용자 정보가 존재하는가?
6. 해당 사용자에게 요청한 API에 접근할 권한이 있는가?

이 과정을 수행하는 구성요소가 **JWT 인증 필터(JWT Authentication Filter)**다.

JWT 인증 필터는 HTTP 요청에서 JWT를 추출하고 검증한 뒤, 검증된 사용자 정보를 Spring Security의 인증 객체로 변환한다.

이후 `SecurityContextHolder`에 인증 정보를 등록하면 Spring Security는 해당 요청을 인증된 사용자의 요청으로 처리할 수 있다.

전체적인 구조는 다음과 같다.

```mermaid
flowchart TD
    A["Client"] -->|"Authorization: Bearer JWT"| B["JWTFilter"]

    B --> C["JWT 추출"]

    C --> D["JWTUtil"]

    D --> E{"JWT 검증 성공?"}

    E -->|"No"| F["HTTP 401"]

    E -->|"Yes"| G["username / role 추출"]

    G --> H["UsernamePasswordAuthenticationToken 생성"]

    H --> I["SecurityContextHolder 등록"]

    I --> J["AuthorizationFilter"]

    J --> K{"접근 권한 확인"}

    K -->|"허용"| L["Controller"]

    K -->|"거부"| M["HTTP 403"]
```

여기서 가장 중요한 점은 **JWT 검증과 Spring Security 인증 객체 생성이 서로 다른 작업이라는 사실**이다.

JWTUtil이 정상적인 JWT라고 판단하더라도 Spring Security가 해당 요청을 자동으로 인증된 요청으로 처리하는 것은 아니다.

JWT에서 추출한 사용자 정보를 이용해 `Authentication` 객체를 만들고, 이를 `SecurityContextHolder`에 등록해야 한다.

이번에는 Spring Boot 3.2.1, Spring Security 6.2.1, JJWT 0.12.3을 기준으로 전체 과정을 구현한다.

---

### 개념

#### JWT를 발급했는데도 보호된 API에 접근할 수 없는 이유

앞서 구현한 프로젝트의 SecurityConfig에는 다음과 같은 설정이 존재한다.

```java
.authorizeHttpRequests(auth -> auth

        .requestMatchers("/", "/login", "/join")
        .permitAll()

        .requestMatchers("/admin", "/admin/**")
        .hasRole("ADMIN")

        .anyRequest()
        .authenticated()
)
```

각 설정의 의미는 다음과 같다.

| 설정 | 의미 |
|---|---|
| `permitAll()` | 인증 없이 접근 가능 |
| `hasRole("ADMIN")` | ADMIN 역할을 가진 사용자만 접근 가능 |
| `authenticated()` | 인증된 사용자만 접근 가능 |

예를 들어 다음 요청은 인증 없이도 접근할 수 있다.

```http
GET /
```

반면 관리자 API는 별도의 권한이 필요하다.

```http
GET /admin
```

그런데 LoginFilter에서 JWT를 발급하는 기능만 구현한 상태라면, 다음과 같이 Authorization 헤더를 전달해도 정상적으로 인증되지 않을 수 있다.

```http
GET /admin
Authorization: Bearer <ACCESS_TOKEN>
```

이유는 간단하다.

**Spring Security에 JWT를 검증하고 인증 정보를 구성하는 과정이 아직 존재하지 않기 때문이다.**

JWT 문자열이 전달되었다는 사실과 사용자가 인증되었다는 사실은 다르다.

```text
JWT 전달
    ↓
서버가 JWT를 전달받음
    ↓
하지만 JWT 검증 로직이 없음
    ↓
SecurityContext에 인증 정보 없음
    ↓
관리자 API 접근 거부
```

따라서 JWT 인증 필터를 추가해야 한다.

---

### JWT 인증 필터는 어떤 역할을 할까?

JWTFilter는 클라이언트가 전달한 JWT를 검증하고 현재 요청의 인증 정보를 구성하는 역할을 담당한다.

주요 작업은 다음과 같다.

| 순서 | 작업 | 역할 |
|---|---|---|
| 1 | Authorization 헤더 추출 | JWT 전달 여부 확인 |
| 2 | Bearer 접두사 검사 | 인증 형식 확인 |
| 3 | JWT 문자열 추출 | 실제 토큰 분리 |
| 4 | JWT 서명 검증 | 토큰 위변조 여부 확인 |
| 5 | JWT 만료 검증 | 유효기간 확인 |
| 6 | Claims 추출 | 사용자 이름과 권한 확인 |
| 7 | Authentication 생성 | Spring Security 인증 객체 구성 |
| 8 | SecurityContext 등록 | 현재 요청의 인증 상태 설정 |
| 9 | FilterChain 진행 | 이후 인가 및 Controller 처리 |

이를 요청 처리 흐름으로 표현하면 다음과 같다.

```mermaid
sequenceDiagram
    participant Client
    participant Filter as JWTFilter
    participant Util as JWTUtil
    participant Context as SecurityContextHolder
    participant Auth as AuthorizationFilter
    participant Controller

    Client->>Filter: GET /admin + Bearer JWT

    Filter->>Filter: Authorization 헤더 확인

    Filter->>Util: JWT 검증 요청

    Util->>Util: 서명 및 만료 시간 검증

    Util-->>Filter: 검증된 username, role

    Filter->>Filter: Authentication 생성

    Filter->>Context: Authentication 등록

    Filter->>Auth: filterChain.doFilter()

    Auth->>Context: Authentication 확인

    alt ROLE_ADMIN 보유
        Auth->>Controller: 요청 전달
        Controller-->>Client: HTTP 200
    else ROLE_ADMIN 없음
        Auth-->>Client: HTTP 403
    end
```

로그인 필터와 JWT 인증 필터는 모두 인증과 관련되어 있지만 서로 다른 역할을 수행한다.

#### LoginFilter

아이디와 비밀번호를 이용해 사용자를 인증한다.

```text
POST /login
    ↓
username / password
    ↓
AuthenticationManager
    ↓
사용자 검증
    ↓
JWT 발급
```

#### JWTFilter

이미 발급된 JWT를 이용해 현재 요청을 인증한다.

```text
GET /admin
    ↓
Authorization 헤더
    ↓
JWT 검증
    ↓
Authentication 생성
    ↓
SecurityContextHolder 등록
```

따라서 두 필터는 서로 대체 관계가 아니다.

각각 다른 인증 단계에서 사용된다.

---

### Stateless 인증과 SecurityContext의 관계

JWT 인증을 구현할 때 가장 많이 혼동하는 부분이다.

현재 프로젝트에는 다음 설정이 존재한다.

```java
.sessionManagement(session -> session
        .sessionCreationPolicy(
                SessionCreationPolicy.STATELESS
        )
)
```

이 설정은 Spring Security가 인증 상태를 유지하기 위해 HttpSession을 생성하거나 사용하지 않도록 구성한다.

그런데 JWT 인증 필터에서는 `SecurityContextHolder`에 사용자 인증 정보를 저장한다.

그렇다면 서버에 인증 상태가 저장되므로 Stateful 인증이라고 생각할 수도 있다.

하지만 그렇지 않다.

**SecurityContext와 HttpSession은 서로 다른 개념이다.**

#### HttpSession이란?

HttpSession은 서버에서 여러 HTTP 요청에 걸쳐 상태를 유지하기 위해 사용할 수 있는 객체다.

일반적인 세션 인증에서는 다음과 같은 구조를 사용할 수 있다.

```text
로그인 성공
    ↓
서버 HttpSession 생성
    ↓
세션에 인증 상태 저장
    ↓
클라이언트에 세션 ID 전달
    ↓
다음 요청
    ↓
세션 ID로 인증 상태 복원
```

서버가 여러 요청에 걸쳐 로그인 상태를 관리한다.

#### SecurityContext란?

SecurityContext는 Spring Security에서 현재 사용자의 인증 정보를 담는 객체다.

대표적으로 다음 정보를 포함한다.

```text
SecurityContext
    ↓
Authentication
    ├── Principal
    ├── Credentials
    ├── Authorities
    └── Authenticated
```

SecurityContext는 현재 요청을 처리할 때도 사용할 수 있다.

반드시 HttpSession에 저장해야 하는 것은 아니다.

JWT 기반 Stateless 인증에서는 다음과 같이 동작한다.

```text
HTTP 요청 A
    ↓
JWT 검증
    ↓
Authentication 생성
    ↓
SecurityContext 설정
    ↓
인가 및 Controller 실행
    ↓
요청 처리 종료
```

다음 요청이 도착하면 JWT를 다시 검증한다.

```text
HTTP 요청 B
    ↓
JWT 검증
    ↓
Authentication 생성
    ↓
SecurityContext 설정
    ↓
인가 및 Controller 실행
    ↓
요청 처리 종료
```

즉 JWT 인증 필터가 구성하는 것은 **현재 요청에서 사용할 인증 컨텍스트**다.

임시 HttpSession을 생성하는 것이 아니다.

Spring Security는 기본적으로 `SecurityContextHolder`에서 `ThreadLocal`을 이용해 현재 실행 흐름의 인증 정보를 관리하며, 보안 필터 체인에서 요청 처리 이후 컨텍스트가 정리되도록 구성한다.

따라서 Stateless 환경에서도 요청을 처리하는 동안 `SecurityContextHolder`를 사용하는 것은 자연스러운 동작이다.

#### 두 방식 비교

| 구분 | 세션 기반 인증 | JWT 기반 Stateless 인증 |
|---|---|---|
| 로그인 상태 관리 | 서버 세션에 저장 가능 | 서버 세션에 로그인 상태를 저장하지 않음 |
| 클라이언트 전달 정보 | 세션 ID | JWT |
| 요청 인증 | 세션 정보 조회 | JWT 검증 |
| SecurityContext 사용 | 사용 | 사용 |
| 요청 간 인증 상태 유지 | 세션을 통해 가능 | JWT를 다시 전달해 인증 |
| 서버 재시작 영향 | 세션 저장 방식에 따라 다름 | JWT 서명 키가 유지되면 검증 가능 |
| 권한 변경 반영 | 세션 갱신 정책 필요 | 토큰 만료 또는 추가 검증 정책 필요 |

중요한 것은 **Stateless라는 용어가 SecurityContext를 사용하지 않는다는 의미는 아니라는 점**이다.

---

### OncePerRequestFilter란?

이번 JWTFilter는 Spring Framework에서 제공하는 `OncePerRequestFilter`를 상속하여 구현한다.

```java
public class JWTFilter extends OncePerRequestFilter {

}
```

`OncePerRequestFilter`는 Servlet Filter를 구현할 때 사용할 수 있는 추상 클래스다.

이 클래스의 핵심 목적은 요청 처리 과정에서 필터가 중복 실행되는 상황을 제어하는 것이다.

일반적인 Servlet Filter에서는 다음 메서드를 구현한다.

```java
@Override
public void doFilter(
        ServletRequest request,
        ServletResponse response,
        FilterChain chain
) throws IOException, ServletException {

}
```

반면 `OncePerRequestFilter`를 상속하면 다음 메서드를 구현한다.

```java
@Override
protected void doFilterInternal(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain filterChain
) throws ServletException, IOException {

}
```

두 방식의 차이는 다음과 같다.

| 구분 | Filter | OncePerRequestFilter |
|---|---|---|
| 구현 방식 | `Filter` 인터페이스 구현 | 추상 클래스 상속 |
| 주요 메서드 | `doFilter()` | `doFilterInternal()` |
| 요청 객체 | ServletRequest | HttpServletRequest |
| 응답 객체 | ServletResponse | HttpServletResponse |
| 중복 실행 제어 | 직접 관리 가능 | 기본적인 제어 기능 제공 |
| 주요 사용 예시 | 일반 Servlet Filter | JWT 인증, 공통 요청 처리 |

`OncePerRequestFilter`는 일반적인 REQUEST 디스패치에서 중복 실행을 제어한다.

다만 비동기 처리나 ERROR 디스패치에서는 별도 실행 흐름이 존재할 수 있다.

따라서 **모든 상황에서 HTTP 요청 전체 생명주기 동안 무조건 한 번만 실행된다고 이해해서는 안 된다.**

비동기 및 오류 디스패치에 대한 실행 여부는 관련 메서드로 조정할 수 있다.

#### doFilterInternal()

실제 JWT 검증 로직은 이 메서드에 구현한다.

```java
@Override
protected void doFilterInternal(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain filterChain
) throws ServletException, IOException {

    // JWT 검증 처리
}
```

각 매개변수의 역할은 다음과 같다.

| 매개변수 | 역할 |
|---|---|
| request | 클라이언트의 HTTP 요청 |
| response | 클라이언트에 반환할 HTTP 응답 |
| filterChain | 다음 Filter로 요청을 전달하는 객체 |

이제 실제 JWT 검증 필터를 구현해보자.

---

### 예제

#### 프로젝트 환경

이번 구현에서는 다음 환경을 사용한다.

| 항목 | 기술 |
|---|---|
| Java | 17 |
| Spring Boot | 3.2.1 |
| Spring Security | 6.2.1 |
| JWT | JJWT 0.12.3 |
| Database | MySQL |
| ORM | Spring Data JPA |
| Build Tool | Gradle |

현재 프로젝트에는 다음 구성요소가 존재한다.

```text
src/main/java/com/example/jwt
│
├── JwtApplication.java
│
├── config
│   └── SecurityConfig.java
│
├── controller
│   ├── MainController.java
│   ├── AdminController.java
│   └── JoinController.java
│
├── dto
│   ├── JoinDTO.java
│   └── CustomUserDetails.java
│
├── entity
│   └── UserEntity.java
│
├── repository
│   └── UserRepository.java
│
├── service
│   ├── JoinService.java
│   └── CustomUserDetailsService.java
│
└── jwt
    ├── LoginFilter.java
    └── JWTUtil.java
```

이번에는 `jwt` 패키지에 `JWTFilter`를 추가한다.

```text
src/main/java/com/example/jwt/jwt/JWTFilter.java
```

변경된 구조는 다음과 같다.

```text
src/main/java/com/example/jwt
│
├── config
│   └── SecurityConfig.java
│
├── controller
│   ├── MainController.java
│   ├── AdminController.java
│   └── JoinController.java
│
├── dto
│   ├── JoinDTO.java
│   └── CustomUserDetails.java
│
├── entity
│   └── UserEntity.java
│
├── repository
│   └── UserRepository.java
│
├── service
│   ├── JoinService.java
│   └── CustomUserDetailsService.java
│
└── jwt
    ├── LoginFilter.java
    ├── JWTUtil.java
    └── JWTFilter.java
```

JWTFilter의 구현은 크게 네 단계로 나눌 수 있다.

```mermaid
flowchart TD
    A["JWTFilter"] --> B["1. Authorization 헤더 확인"]

    B --> C["2. JWT 추출 및 검증"]

    C --> D["3. Authentication 생성"]

    D --> E["4. SecurityContextHolder 등록"]

    E --> F["다음 Filter 실행"]
```

각 단계를 순서대로 구현한다.

---

### JWTFilter 생성

먼저 `JWTFilter.java`를 생성한다.

기본 구조는 다음과 같다.

```java
package com.example.jwt.jwt;

import org.springframework.web.filter.OncePerRequestFilter;

public class JWTFilter extends OncePerRequestFilter {

}
```

`OncePerRequestFilter`를 상속하면 `doFilterInternal()`을 구현해야 한다.

```java
@Override
protected void doFilterInternal(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain filterChain
) throws ServletException, IOException {

}
```

필요한 import는 다음과 같다.

```java
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
```

이제 JWTUtil을 주입받는다.

---

### JWTFilter에 JWTUtil 주입하기

JWT 검증은 앞서 구현한 JWTUtil에서 담당한다.

JWTUtil에는 다음과 같은 기능이 존재한다.

```java
getUsername(token);
```

```java
getRole(token);
```

```java
isExpired(token);
```

```java
isValid(token);
```

따라서 JWTFilter에서 JWTUtil을 사용할 수 있어야 한다.

다음과 같이 필드를 선언한다.

```java
private final JWTUtil jwtUtil;
```

그리고 생성자를 구현한다.

```java
public JWTFilter(JWTUtil jwtUtil) {

    this.jwtUtil = jwtUtil;
}
```

전체 구조는 다음과 같다.

```java
public class JWTFilter extends OncePerRequestFilter {

    private final JWTUtil jwtUtil;

    public JWTFilter(JWTUtil jwtUtil) {

        this.jwtUtil = jwtUtil;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        // JWT 검증
    }
}
```

JWTFilter는 JWTUtil을 직접 생성하지 않는다.

외부에서 생성된 JWTUtil을 전달받는다.

```text
SecurityConfig
    ↓
JWTUtil
    ↓
new JWTFilter(jwtUtil)
    ↓
JWTFilter
```

이렇게 하면 JWT 생성과 검증에 사용하는 SecretKey를 한곳에서 관리할 수 있다.

---

### Authorization 헤더 추출하기

이제 HTTP 요청에서 JWT를 추출해야 한다.

일반적인 JWT 인증 요청은 다음과 같다.

```http
GET /admin HTTP/1.1
Host: localhost:8080
Authorization: Bearer <ACCESS_TOKEN>
```

여기서 필요한 것은 Authorization 헤더다.

Servlet API에서는 다음 메서드를 이용해 특정 헤더를 조회할 수 있다.

```java
request.getHeader("Authorization");
```

Spring에서 제공하는 상수를 이용하면 다음과 같이 작성할 수도 있다.

```java
String authorization =
        request.getHeader(HttpHeaders.AUTHORIZATION);
```

필요한 import는 다음과 같다.

```java
import org.springframework.http.HttpHeaders;
```

이 코드는 다음 헤더의 값을 가져온다.

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

결과는 다음과 같은 문자열이다.

```text
Bearer eyJhbGciOiJIUzI1NiJ9...
```

여기서 주의할 점이 있다.

`getHeader()`는 해당 헤더가 없으면 `null`을 반환할 수 있다.

따라서 헤더가 존재하는지 확인해야 한다.

---

### Authorization 헤더 존재 여부 확인

다음과 같은 조건문을 작성할 수 있다.

```java
if (authorization == null) {

    filterChain.doFilter(request, response);

    return;
}
```

Authorization 헤더가 없다면 현재 JWTFilter에서 인증을 수행할 수 없다.

하지만 헤더가 없다고 해서 모든 요청을 즉시 거부해야 하는 것은 아니다.

예를 들어 다음 경로는 인증 없이 접근할 수 있도록 설정했다.

```http
GET /
```

이 요청에는 JWT가 없어도 된다.

따라서 헤더가 없는 요청은 다음 필터로 전달한다.

```java
filterChain.doFilter(request, response);
```

그리고 JWTFilter의 실행을 종료한다.

```java
return;
```

이렇게 하면 다음과 같은 흐름이 만들어진다.

```text
HTTP 요청
    ↓
JWTFilter
    ↓
Authorization 헤더 없음
    ↓
다음 Filter
    ↓
AuthorizationFilter
    ↓
permitAll() 또는 authenticated() 판단
```

여기서 중요한 것은 **JWTFilter가 요청을 다음 단계로 전달한다고 해서 접근이 허용되는 것은 아니라는 점**이다.

최종적인 접근 권한은 Spring Security의 인가 설정에 따라 판단된다.

예를 들어 다음 경로는 인증이 없어도 접근할 수 있다.

```java
.requestMatchers("/").permitAll()
```

반면 다음 경로는 인증된 사용자만 접근할 수 있다.

```java
.anyRequest().authenticated()
```

따라서 JWT가 없는 요청은 다음과 같이 처리될 수 있다.

| 요청 | JWT | 결과 |
|---|---|---|
| GET `/` | 없음 | 200 |
| GET `/api/me` | 없음 | 401 |
| GET `/admin` | 없음 | 401 |

위 결과는 뒤에서 구성할 SecurityConfig와 예시 Controller를 기준으로 한다.

---

### Bearer 접두사 확인하기

Authorization 헤더에는 여러 인증 방식이 존재할 수 있다.

예를 들어 다음과 같다.

```http
Authorization: Basic <CREDENTIALS>
```

```http
Authorization: Bearer <ACCESS_TOKEN>
```

이번 프로젝트에서는 Bearer 방식만 처리한다.

따라서 다음 조건을 확인한다.

```java
if (!authorization.startsWith("Bearer ")) {

    filterChain.doFilter(request, response);

    return;
}
```

`startsWith()`는 문자열이 특정 접두사로 시작하는지 확인한다.

예를 들어 다음 문자열은 정상적인 Bearer 형식이다.

```text
Bearer eyJhbGciOiJIUzI1NiJ9...
```

반면 다음 문자열은 Bearer 형식이 아니다.

```text
Basic dXNlcjpwYXNzd29yZA==
```

현재는 Bearer 형식이 아니면 JWT 인증을 수행하지 않고 다음 필터로 전달한다.

단, 실제 운영 환경에서는 허용되지 않은 인증 형식이 전달된 경우 명시적으로 401을 반환하는 정책도 선택할 수 있다.

이 선택은 다른 인증 방식과의 공존 여부에 따라 달라진다.

---

### JWT 문자열 추출하기

Authorization 헤더는 다음과 같이 구성된다.

```text
Bearer <JWT>
```

JWTUtil에는 Bearer 접두사를 제외한 실제 JWT 문자열을 전달해야 한다.

예를 들어 다음 값이 있다고 생각해보자.

```text
Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6InVzZXIwMSJ9...
```

이 문자열에서 앞부분을 제거해야 한다.

#### split()을 사용하는 방법

공백을 기준으로 문자열을 나눌 수 있다.

```java
String token =
        authorization.split(" ")[1];
```

이 방식은 이해하기 쉽지만 문제가 있다.

예를 들어 다음과 같은 요청이 들어올 수 있다.

```text
Bearer
```

또는 다음과 같다.

```text
Bearer 
```

이때 배열의 두 번째 요소가 존재하지 않을 수 있다.

따라서 단순히 `split(" ")[1]`을 사용하는 방식은 예외 처리에 주의해야 한다.

#### substring()을 사용하는 방법

이번에는 다음 방식을 사용한다.

```java
String token =
        authorization.substring(7);
```

`Bearer `는 총 7개의 문자로 구성된다.

```text
B e a r e r 공백
1 2 3 4 5 6  7
```

따라서 7번째 인덱스부터 문자열을 추출하면 실제 JWT를 얻을 수 있다.

다만 앞에서 반드시 Bearer 접두사를 확인해야 한다.

그리고 토큰이 비어 있는지도 검사해야 한다.

```java
String token =
        authorization.substring(7).trim();

if (token.isEmpty()) {

    // 잘못된 인증 요청
}
```

실제 JWT 문자열에는 공백이 포함되지 않아야 한다.

따라서 앞뒤 공백을 제거한 뒤에도 값이 없다면 유효한 JWT가 전달되지 않은 것이다.

---

### JWT 만료 시간 검증하기

JWT를 추출했다면 유효한 토큰인지 확인해야 한다.

앞서 구현한 JWTUtil에는 다음 메서드가 있다.

```java
public boolean isExpired(String token)
```

일반적으로 다음과 같이 사용할 수 있다.

```java
if (jwtUtil.isExpired(token)) {

    filterChain.doFilter(request, response);

    return;
}
```

이 코드는 토큰이 만료되었다면 인증 정보를 구성하지 않고 다음 필터로 전달하는 방식이다.

하지만 실제 서비스에서는 중요한 보완이 필요하다.

**만료 여부만 확인해서는 JWT의 전체 유효성을 보장할 수 없다.**

JWT는 다음과 같은 이유로도 검증에 실패할 수 있다.

- 서명이 올바르지 않음
- JWT 형식이 잘못됨
- 지원하지 않는 JWT 형식
- 필수 Claim 누락
- 만료 시간 경과
- 잘못된 SecretKey 사용

따라서 실제 인증에서는 서명과 만료 시간을 포함한 전체 검증을 수행해야 한다.

또한 JJWT 0.12.3에서는 다음 메서드를 호출할 때 만료 여부도 검증한다.

```java
Jwts.parser()
        .verifyWith(secretKey)
        .build()
        .parseSignedClaims(token);
```

토큰이 만료되었다면 `ExpiredJwtException`이 발생할 수 있다.

따라서 `isExpired()`의 반환값만 확인하는 것이 아니라, 파싱 과정에서 발생하는 예외도 처리해야 한다.

---

### JWT 검증은 한 번만 수행하는 것이 좋다

앞서 구현한 JWTUtil의 메서드는 다음과 같다.

```java
jwtUtil.isValid(token);
```

```java
jwtUtil.getUsername(token);
```

```java
jwtUtil.getRole(token);
```

이 메서드를 각각 호출하면 내부적으로 JWT 파싱이 반복될 수 있다.

예를 들어 다음과 같은 코드다.

```java
if (!jwtUtil.isValid(token)) {
    // 검증 실패
}

String username =
        jwtUtil.getUsername(token);

String role =
        jwtUtil.getRole(token);
```

이 경우 JWT를 여러 번 검증하고 파싱한다.

기능상으로는 사용할 수 있지만 한 요청에서 불필요한 중복 작업이 발생할 수 있다.

따라서 실제 인증 필터에서는 **JWT를 한 번 검증하고, 검증된 Claims에서 필요한 사용자 정보를 함께 추출하는 방식**이 더 효율적이다.

이를 위해 JWTUtil에 메서드를 하나 추가해보자.

---

### JWTUtil에 검증 및 사용자 정보 추출 메서드 추가

현재 JWTUtil에는 JWT 생성과 검증에 필요한 기능이 구현되어 있다.

여기에 `verifyAndExtract()` 메서드를 추가한다.

이 메서드는 다음 작업을 수행한다.

```text
JWT 입력
    ↓
서명 검증
    ↓
만료 시간 검증
    ↓
Claims 확인
    ↓
username 추출
    ↓
role 추출
    ↓
검증된 사용자 정보 반환
```

먼저 반환할 사용자 정보 타입을 정의한다.

Java 17에서는 Record를 사용할 수 있다.

```java
public record JwtUserInfo(
        String username,
        String role
) {
}
```

Record는 데이터를 전달하기 위한 불변 객체를 간단하게 정의할 수 있는 Java 기능이다.

이번에는 JWTUtil 내부에 중첩 Record로 정의한다.

이후 다음 메서드를 추가한다.

```java
public JwtUserInfo verifyAndExtract(String token) {

    Claims claims = parseVerifiedClaims(token);

    String username =
            claims.get("username", String.class);

    String role =
            claims.get("role", String.class);

    return new JwtUserInfo(
            username,
            role
    );
}
```

여기서 `parseVerifiedClaims()`는 앞서 구현한 JWT 검증 메서드다.

서명과 만료 시간을 검증하고, 필수 Claim을 확인한 뒤 Claims를 반환한다.

이렇게 하면 JWTFilter에서 다음과 같이 사용할 수 있다.

```java
JWTUtil.JwtUserInfo jwtUserInfo =
        jwtUtil.verifyAndExtract(token);
```

사용자 이름은 다음과 같이 가져온다.

```java
String username =
        jwtUserInfo.username();
```

권한은 다음과 같이 가져온다.

```java
String role =
        jwtUserInfo.role();
```

이 구조는 JWT 검증과 사용자 정보 추출을 하나의 작업으로 묶는다는 장점이 있다.

---

### JWTUtil 전체 코드

기존 JWTUtil에 `verifyAndExtract()`를 추가한 전체 코드는 다음과 같다.

JJWT 0.12.3을 기준으로 작성했다.

```java
package com.example.jwt.jwt;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.JwtParser;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;

import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;

import java.time.Instant;
import java.util.Date;

@Component
public class JWTUtil {

    private final SecretKey secretKey;

    private final JwtParser jwtParser;

    public JWTUtil(
            @Value("${jwt.secret}") String secret
    ) {

        // Base64 문자열을 키 바이트로 변환
        byte[] keyBytes =
                Decoders.BASE64.decode(secret);

        // HMAC SecretKey 생성
        this.secretKey =
                Keys.hmacShaKeyFor(keyBytes);

        // JWT Parser 생성
        this.jwtParser = Jwts.parser()
                .verifyWith(secretKey)
                .build();
    }

    /**
     * JWT 생성
     */
    public String createJwt(
            String username,
            String role,
            long expiredMs
    ) {

        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException(
                    "username은 필수입니다."
            );
        }

        if (role == null || role.isBlank()) {
            throw new IllegalArgumentException(
                    "role은 필수입니다."
            );
        }

        if (expiredMs <= 0) {
            throw new IllegalArgumentException(
                    "JWT 유효기간은 0보다 커야 합니다."
            );
        }

        Instant now = Instant.now();

        Instant expiration =
                now.plusMillis(expiredMs);

        return Jwts.builder()
                .claim("username", username)
                .claim("role", role)
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiration))
                .signWith(secretKey, Jwts.SIG.HS256)
                .compact();
    }

    /**
     * JWT 검증 및 사용자 정보 추출
     */
    public JwtUserInfo verifyAndExtract(String token) {

        Claims claims = parseVerifiedClaims(token);

        String username =
                claims.get("username", String.class);

        String role =
                claims.get("role", String.class);

        return new JwtUserInfo(
                username,
                role
        );
    }

    /**
     * JWT 사용자 이름 추출
     */
    public String getUsername(String token) {

        return verifyAndExtract(token).username();
    }

    /**
     * JWT 사용자 권한 추출
     */
    public String getRole(String token) {

        return verifyAndExtract(token).role();
    }

    /**
     * JWT 만료 여부 확인
     */
    public boolean isExpired(String token) {

        try {

            parseVerifiedClaims(token);

            return false;

        } catch (ExpiredJwtException exception) {

            return true;
        }
    }

    /**
     * JWT 전체 유효성 확인
     */
    public boolean isValid(String token) {

        try {

            verifyAndExtract(token);

            return true;

        } catch (JwtException | IllegalArgumentException exception) {

            return false;
        }
    }

    /**
     * JWT 파싱 및 검증
     */
    private Claims parseVerifiedClaims(String token) {

        // 서명 및 만료 시간 검증
        Jws<Claims> parsedJwt =
                jwtParser.parseSignedClaims(token);

        // HS256만 허용
        String algorithm =
                parsedJwt.getHeader().getAlgorithm();

        if (!"HS256".equals(algorithm)) {

            throw new JwtException(
                    "지원하지 않는 서명 알고리즘입니다."
            );
        }

        Claims claims = parsedJwt.getPayload();

        String username =
                claims.get("username", String.class);

        String role =
                claims.get("role", String.class);

        // 사용자 이름 확인
        if (username == null || username.isBlank()) {

            throw new JwtException(
                    "username Claim이 없습니다."
            );
        }

        // 권한 확인
        if (role == null || role.isBlank()) {

            throw new JwtException(
                    "role Claim이 없습니다."
            );
        }

        // 발급 시간 확인
        if (claims.getIssuedAt() == null) {

            throw new JwtException(
                    "발급 시간이 없습니다."
            );
        }

        // 만료 시간 확인
        if (claims.getExpiration() == null) {

            throw new JwtException(
                    "만료 시간이 없습니다."
            );
        }

        return claims;
    }

    /**
     * 검증된 JWT 사용자 정보
     */
    public record JwtUserInfo(
            String username,
            String role
    ) {
    }
}
```

이제 JWTFilter에서는 `verifyAndExtract()`만 호출하면 된다.

```java
JWTUtil.JwtUserInfo userInfo =
        jwtUtil.verifyAndExtract(token);
```

이 메서드 호출이 정상적으로 완료되었다면 필요한 검증을 통과한 JWT에서 사용자 정보를 추출할 수 있다.

반대로 검증에 실패하면 예외가 발생한다.

이후 필터에서는 해당 예외를 처리하여 인증 실패 응답을 반환한다.

---

### JWT 검증 이후 Authentication 생성하기

JWT 검증에 성공했다면 다음 두 가지 정보가 준비된다.

```text
username = admin01

role = ROLE_ADMIN
```

이제 Spring Security가 이해할 수 있는 인증 객체를 생성해야 한다.

이때 사용할 수 있는 클래스가 다음과 같다.

```java
UsernamePasswordAuthenticationToken
```

이 클래스는 이름에 UsernamePassword가 포함되어 있지만, 인증이 완료된 사용자 정보를 표현할 때도 사용할 수 있다.

#### 로그인 인증 요청과 JWT 인증 결과의 차이

로그인 요청에서는 다음과 같이 인증되지 않은 객체를 생성했다.

```java
UsernamePasswordAuthenticationToken authenticationToken =
        UsernamePasswordAuthenticationToken.unauthenticated(
                username,
                password
        );
```

이때는 사용자가 직접 입력한 username과 password만 존재한다.

아직 인증되지 않은 상태다.

반면 JWT 검증에 성공한 이후에는 이미 검증된 사용자 정보를 이용해 인증 객체를 만들 수 있다.

```java
UsernamePasswordAuthenticationToken authentication =
        UsernamePasswordAuthenticationToken.authenticated(
                username,
                null,
                authorities
        );
```

여기서 세 가지 인자의 의미는 다음과 같다.

| 인자 | 값 | 역할 |
|---|---|---|
| principal | username | 인증된 사용자 식별자 |
| credentials | null | 비밀번호 등 자격 증명 |
| authorities | 권한 목록 | 사용자에게 부여된 권한 |

현재 JWT 검증 단계에서는 비밀번호를 다시 검증하지 않는다.

따라서 credentials에 비밀번호를 넣을 필요가 없다.

---

### JWT 인증에서 비밀번호가 필요 없는 이유

로그인에서는 다음 정보가 필요하다.

```text
username
password
```

서버는 이 값을 이용해 사용자를 검증한다.

하지만 JWT 인증은 다른 방식으로 동작한다.

```text
JWT
    ↓
HS256 서명 검증
    ↓
만료 시간 검증
    ↓
Claims 추출
    ↓
사용자 인증 정보 생성
```

JWT 자체가 서버의 비밀키를 이용해 서명되어 있으므로, JWT 검증에서는 사용자의 원문 비밀번호를 다시 확인할 필요가 없다.

따라서 다음과 같은 작업을 수행할 필요도 없다.

```java
userRepository.findByUsername(username);
```

물론 서비스 정책에 따라 계정 상태나 최신 권한 정보를 조회하는 경우는 존재한다.

하지만 **JWT의 서명과 만료 시간을 검증하는 기본적인 인증 과정 자체에 사용자 비밀번호 조회가 필수적인 것은 아니다.**

#### 비밀번호를 임의의 문자열로 채울 필요가 있을까?

JWT에서 추출한 사용자 이름과 권한을 이용해 UserEntity를 생성하고, 비밀번호에 임의의 값을 넣는 구현도 가능하다.

예를 들어 다음과 같다.

```java
UserEntity userEntity = new UserEntity();

userEntity.setUsername(username);
userEntity.setRole(role);
userEntity.setPassword("temporary");
```

이후 해당 Entity로 `CustomUserDetails`를 생성할 수도 있다.

하지만 이번 구현에서는 더 단순한 방법을 사용한다.

**Principal에 username을 직접 전달하고 credentials에는 null을 사용한다.**

```java
UsernamePasswordAuthenticationToken.authenticated(
        username,
        null,
        authorities
);
```

이렇게 하면 불필요한 UserEntity나 가짜 비밀번호를 생성하지 않아도 된다.

또한 데이터베이스 영속성 객체와 인증 객체를 분리할 수 있다.

---

### GrantedAuthority 생성하기

Spring Security는 사용자의 권한을 `GrantedAuthority` 인터페이스로 표현한다.

JWT에서 추출한 role은 문자열이다.

```text
ROLE_ADMIN
```

따라서 Spring Security의 권한 객체로 변환해야 한다.

이를 위해 `SimpleGrantedAuthority`를 사용할 수 있다.

```java
SimpleGrantedAuthority authority =
        new SimpleGrantedAuthority(role);
```

여러 권한을 전달할 수 있도록 Collection에 담는다.

```java
List<SimpleGrantedAuthority> authorities =
        List.of(
                new SimpleGrantedAuthority(role)
        );
```

현재 프로젝트는 하나의 사용자에게 하나의 역할을 부여하는 구조다.

따라서 하나의 권한 객체만 생성한다.

이후 Authentication 생성 시 전달한다.

```java
UsernamePasswordAuthenticationToken authentication =
        UsernamePasswordAuthenticationToken.authenticated(
                username,
                null,
                authorities
        );
```

이제 Spring Security가 사용할 수 있는 인증 객체가 만들어졌다.

#### hasRole과 ROLE_ 접두사

SecurityConfig에는 다음 설정이 존재한다.

```java
.requestMatchers("/admin", "/admin/**")
.hasRole("ADMIN")
```

일반적인 Spring Security 설정에서 `hasRole("ADMIN")`은 `ROLE_ADMIN` 권한을 확인한다.

따라서 JWT에 다음 값이 포함되어 있다면:

```text
ROLE_ADMIN
```

다음과 같이 권한 객체를 생성할 수 있다.

```java
new SimpleGrantedAuthority("ROLE_ADMIN");
```

반대로 JWT에 다음 값이 들어 있다면:

```text
ADMIN
```

현재 권한 설정과 일치하지 않을 수 있다.

따라서 JWT 발급과 검증 과정에서 권한 문자열의 규칙을 일관되게 관리해야 한다.

---

### SecurityContextHolder에 Authentication 등록하기

이제 Authentication 객체가 준비되었다.

다음으로 Spring Security의 SecurityContextHolder에 등록해야 한다.

가장 간단한 형태는 다음과 같다.

```java
SecurityContextHolder.getContext()
        .setAuthentication(authentication);
```

하지만 새로운 SecurityContext를 생성하여 등록하는 방법을 사용하는 것이 좋다.

```java
SecurityContext context =
        SecurityContextHolder.createEmptyContext();

context.setAuthentication(authentication);

SecurityContextHolder.setContext(context);
```

필요한 import는 다음과 같다.

```java
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
```

이 코드가 하는 작업을 자세히 살펴보자.

#### createEmptyContext()

```java
SecurityContextHolder.createEmptyContext();
```

새로운 SecurityContext를 생성한다.

기존 컨텍스트에 직접 인증 정보를 변경하는 대신 새로운 객체를 만든다.

#### setAuthentication()

```java
context.setAuthentication(authentication);
```

생성한 SecurityContext에 인증 정보를 등록한다.

이제 해당 컨텍스트는 다음 정보를 가진다.

```text
SecurityContext
    ↓
Authentication
    ├── Principal: admin01
    ├── Credentials: null
    ├── Authorities: ROLE_ADMIN
    └── Authenticated: true
```

#### setContext()

```java
SecurityContextHolder.setContext(context);
```

생성한 SecurityContext를 현재 실행 흐름에서 사용할 수 있도록 등록한다.

이후 Spring Security의 인가 처리에서는 등록된 Authentication을 확인할 수 있다.

전체 과정은 다음과 같다.

```mermaid
flowchart TD
    A["JWT 검증 성공"] --> B["username 추출"]

    B --> C["role 추출"]

    C --> D["SimpleGrantedAuthority 생성"]

    D --> E["UsernamePasswordAuthenticationToken 생성"]

    E --> F["SecurityContext 생성"]

    F --> G["Authentication 등록"]

    G --> H["SecurityContextHolder.setContext"]

    H --> I["AuthorizationFilter"]

    I --> J["권한 확인"]
```

여기서 중요한 것은 **SecurityContextHolder에 Authentication을 등록하는 순간, 이후 Spring Security의 인가 처리에서 해당 인증 정보를 사용할 수 있다는 사실**이다.

---

### filterChain.doFilter()의 역할

JWT 검증과 SecurityContext 등록이 완료되었다면 다음 필터로 요청을 전달해야 한다.

```java
filterChain.doFilter(request, response);
```

이 메서드는 다음 단계의 Filter 또는 Servlet으로 요청 처리를 진행한다.

예를 들어 다음과 같은 흐름이다.

```text
JWTFilter
    ↓
filterChain.doFilter()
    ↓
이후 Security Filter
    ↓
AuthorizationFilter
    ↓
DispatcherServlet
    ↓
Controller
```

JWTFilter에서 인증이 완료되었다고 해서 Controller가 자동으로 실행되는 것은 아니다.

다음 필터로 요청을 전달해야 한다.

반대로 JWT가 유효하지 않아 요청을 종료해야 한다면, 오류 응답을 작성하고 `filterChain.doFilter()`를 호출하지 않을 수 있다.

#### JWT가 없는 요청

```java
filterChain.doFilter(request, response);

return;
```

다음 단계로 전달한다.

#### JWT가 유효한 요청

```java
SecurityContextHolder.setContext(context);

filterChain.doFilter(request, response);
```

인증 정보를 등록한 후 다음 단계로 전달한다.

#### JWT가 유효하지 않은 요청

```java
response.setStatus(
        HttpServletResponse.SC_UNAUTHORIZED
);

return;
```

인증 실패 응답을 반환하고 현재 필터에서 요청 처리를 종료한다.

이처럼 `filterChain.doFilter()`를 호출하는지에 따라 이후 요청 처리 흐름이 달라진다.

---

### JWTFilter에서 유효하지 않은 토큰 처리하기

JWT를 검증하는 과정에서는 여러 예외가 발생할 수 있다.

대표적으로 다음과 같다.

| 상황 | 설명 |
|---|---|
| 토큰 만료 | ExpiredJwtException |
| 서명 불일치 | SignatureException |
| 형식 오류 | MalformedJwtException |
| 지원하지 않는 JWT | UnsupportedJwtException |
| 필수 Claim 누락 | JwtException |
| 잘못된 토큰 값 | IllegalArgumentException |

이러한 토큰을 사용해 Authentication을 구성해서는 안 된다.

따라서 JWT 검증에 실패하면 현재 요청의 인증 정보를 설정하지 않고 오류 응답을 반환해야 한다.

이번에는 유효하지 않은 JWT에 대해 다음 응답을 반환한다.

```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer error="invalid_token"
Content-Type: application/json;charset=UTF-8

{
  "error": "invalid_token"
}
```

이때 401은 인증에 실패했음을 의미한다.

JWT가 만료되었거나 서명이 올바르지 않은 경우에 사용할 수 있다.

---

### JWTFilter 전체 코드

지금까지 구현한 내용을 하나의 클래스로 정리해보자.

다음 코드는 다음 기능을 포함한다.

1. Authorization 헤더 확인
2. Bearer 인증 방식 검사
3. JWT 문자열 추출
4. JWT 서명 및 만료 검증
5. 사용자 이름과 권한 추출
6. Authentication 생성
7. SecurityContextHolder 등록
8. 유효하지 않은 JWT에 대한 401 응답
9. 다음 Filter로 요청 전달

```java
package com.example.jwt.jwt;

import io.jsonwebtoken.JwtException;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.http.HttpHeaders;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;

import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

public class JWTFilter extends OncePerRequestFilter {

    private static final String BEARER_PREFIX = "Bearer ";

    private final JWTUtil jwtUtil;

    public JWTFilter(JWTUtil jwtUtil) {

        this.jwtUtil = jwtUtil;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        // 1. Authorization 헤더 추출
        String authorization =
                request.getHeader(HttpHeaders.AUTHORIZATION);

        // 2. Authorization 헤더가 없으면 다음 필터 진행
        if (authorization == null || authorization.isBlank()) {

            filterChain.doFilter(request, response);

            return;
        }

        // 3. Bearer 인증 방식이 아니면 다음 필터 진행
        if (!authorization.startsWith(BEARER_PREFIX)) {

            filterChain.doFilter(request, response);

            return;
        }

        // 4. Bearer 접두사 제거
        String token =
                authorization.substring(BEARER_PREFIX.length())
                        .trim();

        // 5. 토큰이 비어 있으면 인증 실패
        if (token.isEmpty()) {

            sendUnauthorized(response);

            return;
        }

        // 6. JWT 검증 및 사용자 정보 추출
        JWTUtil.JwtUserInfo userInfo;

        try {

            userInfo = jwtUtil.verifyAndExtract(token);

        } catch (JwtException | IllegalArgumentException exception) {

            // 유효하지 않은 JWT
            SecurityContextHolder.clearContext();

            sendUnauthorized(response);

            return;
        }

        // 7. JWT에서 검증된 사용자 정보 추출
        String username =
                userInfo.username();

        String role =
                userInfo.role();

        // 8. 사용자 권한 생성
        List<SimpleGrantedAuthority> authorities =
                List.of(
                        new SimpleGrantedAuthority(role)
                );

        // 9. 인증된 Authentication 생성
        UsernamePasswordAuthenticationToken authentication =
                UsernamePasswordAuthenticationToken.authenticated(
                        username,
                        null,
                        authorities
                );

        // 10. HTTP 요청 부가 정보 설정
        authentication.setDetails(
                new WebAuthenticationDetailsSource()
                        .buildDetails(request)
        );

        // 11. 새로운 SecurityContext 생성
        SecurityContext context =
                SecurityContextHolder.createEmptyContext();

        // 12. Authentication 등록
        context.setAuthentication(authentication);

        // 13. SecurityContextHolder에 등록
        SecurityContextHolder.setContext(context);

        // 14. 다음 필터 실행
        filterChain.doFilter(request, response);
    }

    /**
     * JWT 인증 실패 응답
     */
    private void sendUnauthorized(
            HttpServletResponse response
    ) throws IOException {

        response.setStatus(
                HttpServletResponse.SC_UNAUTHORIZED
        );

        response.setContentType(
                "application/json;charset=UTF-8"
        );

        response.setHeader(
                HttpHeaders.WWW_AUTHENTICATE,
                "Bearer error=\"invalid_token\""
        );

        response.setHeader(
                HttpHeaders.CACHE_CONTROL,
                "no-store"
        );

        response.getWriter().write(
                "{\"error\":\"invalid_token\"}"
        );
    }
}
```

이 코드에서 핵심 부분은 다음과 같다.

```java
userInfo = jwtUtil.verifyAndExtract(token);
```

JWT의 서명과 만료 시간 등을 검증하고 사용자 정보를 가져온다.

이후 다음 코드로 Authentication 객체를 생성한다.

```java
UsernamePasswordAuthenticationToken authentication =
        UsernamePasswordAuthenticationToken.authenticated(
                username,
                null,
                authorities
        );
```

마지막으로 SecurityContextHolder에 등록한다.

```java
SecurityContext context =
        SecurityContextHolder.createEmptyContext();

context.setAuthentication(authentication);

SecurityContextHolder.setContext(context);
```

이렇게 하면 현재 요청을 처리하는 Spring Security의 인가 단계에서 인증된 사용자 정보를 사용할 수 있다.

---

### 왜 JWTFilter에 @Component를 선언하지 않을까?

이번 JWTFilter에는 다음 Annotation을 선언하지 않았다.

```java
@Component
```

이유는 JWTFilter를 SecurityFilterChain에 직접 등록하기 때문이다.

다음과 같은 방식으로 사용한다.

```java
.addFilterBefore(
        new JWTFilter(jwtUtil),
        UsernamePasswordAuthenticationFilter.class
)
```

Spring Boot에서는 Filter를 Spring Bean으로 등록했을 때 Servlet Container에 자동 등록되는 경우가 있다.

그런데 동일한 Filter를 SecurityFilterChain에도 등록하면 의도하지 않은 중복 실행 문제가 발생할 수 있다.

따라서 이번에는 JWTFilter를 별도의 Servlet Filter Bean으로 등록하지 않고 SecurityFilterChain 내부에서 생성한다.

```text
SecurityConfig
    ↓
new JWTFilter(jwtUtil)
    ↓
SecurityFilterChain 등록
```

이렇게 하면 Spring Security의 보안 필터 체인에서 해당 필터를 관리할 수 있다.

---

### SecurityConfig에 JWTFilter 등록하기

JWTFilter 클래스를 작성했다고 자동으로 모든 요청에 적용되는 것은 아니다.

Spring Security의 SecurityFilterChain에 등록해야 한다.

이번에는 기존 LoginFilter보다 앞에서 JWTFilter가 실행되도록 구성한다.

#### addFilterBefore()

Spring Security에서는 다음 메서드를 제공한다.

```java
addFilterBefore()
```

이 메서드는 특정 필터의 순서보다 앞에 새로운 필터를 등록한다.

예를 들어 다음과 같다.

```java
.addFilterBefore(
        new JWTFilter(jwtUtil),
        UsernamePasswordAuthenticationFilter.class
)
```

이 코드는 JWTFilter를 UsernamePasswordAuthenticationFilter에 해당하는 순서보다 앞에 배치한다.

현재 프로젝트에서는 커스텀 LoginFilter를 다음과 같이 등록했다.

```java
.addFilterAt(
        loginFilter,
        UsernamePasswordAuthenticationFilter.class
)
```

즉 LoginFilter는 UsernamePasswordAuthenticationFilter의 순서 위치에 등록된다.

따라서 JWTFilter를 해당 위치보다 앞에 등록하면 LoginFilter보다 먼저 실행되는 구조를 만들 수 있다.

```text
SecurityFilterChain
    ↓
JWTFilter
    ↓
LoginFilter
    ↓
이후 Security Filter
    ↓
AuthorizationFilter
```

여기서 주의할 점은 JWTFilter의 역할이 로그인 필터보다 먼저 실행된다는 사실 자체에 있는 것은 아니다.

**가장 중요한 것은 JWTFilter가 인가를 수행하는 AuthorizationFilter보다 먼저 인증 정보를 구성해야 한다는 점**이다.

또한 필터 등록 순서는 보안 설정에 따라 달라질 수 있으므로 실제 등록된 순서를 확인하는 것이 좋다.

---

### SecurityConfig 전체 코드

이제 기존 SecurityConfig에 JWTFilter를 추가해보자.

다음 코드는 기존 LoginFilter와 JWTUtil을 유지하면서 JWTFilter를 추가한 전체 설정이다.

```java
package com.example.jwt.config;

import com.example.jwt.jwt.JWTFilter;
import com.example.jwt.jwt.JWTUtil;
import com.example.jwt.jwt.LoginFilter;

import jakarta.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Value;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;

import org.springframework.security.authentication.AuthenticationManager;

import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;

import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;

import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;

import org.springframework.security.config.http.SessionCreationPolicy;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import org.springframework.security.web.SecurityFilterChain;

import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    /**
     * AuthenticationManager Bean
     */
    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration authenticationConfiguration
    ) throws Exception {

        return authenticationConfiguration.getAuthenticationManager();
    }

    /**
     * SecurityFilterChain
     */
    @Bean
    public SecurityFilterChain filterChain(
            HttpSecurity http,
            AuthenticationManager authenticationManager,
            JWTUtil jwtUtil,
            @Value("${jwt.access-token-expiration-ms}")
            long accessTokenExpirationMs
    ) throws Exception {

        // 1. LoginFilter 생성
        LoginFilter loginFilter =
                new LoginFilter(
                        authenticationManager,
                        jwtUtil,
                        accessTokenExpirationMs
                );

        // 2. JWTFilter 생성
        JWTFilter jwtFilter =
                new JWTFilter(jwtUtil);

        http
                // CSRF 비활성화
                .csrf(AbstractHttpConfigurer::disable)

                // Form Login 비활성화
                .formLogin(AbstractHttpConfigurer::disable)

                // HTTP Basic 비활성화
                .httpBasic(AbstractHttpConfigurer::disable)

                // Stateless 인증
                .sessionManagement(session -> session
                        .sessionCreationPolicy(
                                SessionCreationPolicy.STATELESS
                        )
                )

                // URL별 인가 설정
                .authorizeHttpRequests(auth -> auth

                        // 메인 API 공개
                        .requestMatchers(
                                HttpMethod.GET,
                                "/"
                        ).permitAll()

                        // 로그인 및 회원가입 공개
                        .requestMatchers(
                                HttpMethod.POST,
                                "/login",
                                "/join"
                        ).permitAll()

                        // 관리자 권한 필요
                        .requestMatchers(
                                "/admin",
                                "/admin/**"
                        ).hasRole("ADMIN")

                        // 그 외 API는 인증 필요
                        .anyRequest().authenticated()
                )

                // 인증 및 인가 실패 처리
                .exceptionHandling(exception -> exception

                        // 인증되지 않은 사용자
                        .authenticationEntryPoint(
                                (request, response, authException) -> {

                                    response.setStatus(
                                            HttpServletResponse.SC_UNAUTHORIZED
                                    );

                                    response.setHeader(
                                            HttpHeaders.WWW_AUTHENTICATE,
                                            "Bearer"
                                    );
                                }
                        )

                        // 인증됐지만 권한이 없는 사용자
                        .accessDeniedHandler(
                                (request, response, accessDeniedException) -> {

                                    response.setStatus(
                                            HttpServletResponse.SC_FORBIDDEN
                                    );
                                }
                        )
                )

                // 커스텀 로그인 필터
                .addFilterAt(
                        loginFilter,
                        UsernamePasswordAuthenticationFilter.class
                )

                // JWT 인증 필터
                .addFilterBefore(
                        jwtFilter,
                        UsernamePasswordAuthenticationFilter.class
                );

        return http.build();
    }

    /**
     * PasswordEncoder Bean
     */
    @Bean
    public PasswordEncoder passwordEncoder() {

        return new BCryptPasswordEncoder();
    }
}
```

이번에 추가한 핵심 설정은 다음과 같다.

```java
.addFilterBefore(
        jwtFilter,
        UsernamePasswordAuthenticationFilter.class
)
```

이렇게 하면 JWTFilter가 기존 LoginFilter보다 앞에서 요청을 검사하도록 구성된다.

#### 메인 경로를 공개한 이유

현재 설정에서는 다음 경로를 공개했다.

```java
.requestMatchers(
        HttpMethod.GET,
        "/"
).permitAll()
```

따라서 JWT가 없어도 메인 Controller에 접근할 수 있다.

반면 관리자 API는 다음 설정을 적용한다.

```java
.requestMatchers(
        "/admin",
        "/admin/**"
).hasRole("ADMIN")
```

JWT가 없거나 관리자 권한이 없다면 접근이 제한된다.

---

### AuthorizationFilter는 어떤 역할을 할까?

JWTFilter가 인증 정보를 구성했다면, 실제 접근 권한은 AuthorizationFilter가 판단한다.

예를 들어 JWTFilter에서 다음 인증 객체를 생성했다고 생각해보자.

```text
Principal = user01

Authorities = ROLE_USER

Authenticated = true
```

이 상태에서 `/admin`에 접근한다.

SecurityConfig에는 다음 조건이 존재한다.

```java
.hasRole("ADMIN")
```

Spring Security는 현재 Authentication에 `ROLE_ADMIN`이 있는지 확인한다.

하지만 사용자의 권한은 `ROLE_USER`다.

따라서 접근이 거부된다.

```text
JWT 검증 성공
    ↓
Authentication 생성
    ↓
ROLE_USER
    ↓
GET /admin
    ↓
hasRole("ADMIN")
    ↓
권한 부족
    ↓
HTTP 403
```

반대로 다음 권한을 가진 사용자라면 접근할 수 있다.

```text
ROLE_ADMIN
```

```text
JWT 검증 성공
    ↓
Authentication 생성
    ↓
ROLE_ADMIN
    ↓
GET /admin
    ↓
hasRole("ADMIN")
    ↓
접근 허용
    ↓
HTTP 200
```

여기서 중요한 점은 **JWTFilter가 관리자 권한을 직접 판단할 필요가 없다는 사실**이다.

JWTFilter는 인증 정보를 구성한다.

AuthorizationFilter는 접근 권한을 판단한다.

이러한 책임 분리가 Spring Security를 사용하는 중요한 이유 중 하나다.

---

### 401 Unauthorized와 403 Forbidden의 차이

JWT 인증 시스템에서는 401과 403을 구분하는 것이 중요하다.

#### 401 Unauthorized

인증되지 않은 요청을 의미한다.

예를 들어 다음과 같은 상황이다.

- JWT가 없음
- JWT가 만료됨
- JWT 서명 검증 실패
- JWT 형식이 잘못됨
- 정상적인 인증 정보를 구성하지 못함

예를 들어 JWT 없이 관리자 API에 접근한다.

```http
GET /admin
```

현재 설정에서는 다음 응답이 반환된다.

```http
HTTP/1.1 401 Unauthorized
```

#### 403 Forbidden

사용자가 인증되었지만 해당 리소스에 접근할 권한이 없는 상황이다.

예를 들어 다음과 같다.

```text
JWT 검증 성공
    ↓
ROLE_USER
    ↓
GET /admin
    ↓
관리자 권한 없음
    ↓
HTTP 403
```

응답은 다음과 같다.

```http
HTTP/1.1 403 Forbidden
```

두 상태 코드를 비교하면 다음과 같다.

| 구분 | 401 Unauthorized | 403 Forbidden |
|---|---|---|
| 인증 상태 | 인증되지 않음 | 일반적으로 인증됨 |
| 대표적인 원인 | 토큰 누락·만료·변조 | 접근 권한 부족 |
| JWT 검증 | 실패하거나 미수행 | 성공 |
| 해결 방향 | 유효한 인증 정보 필요 | 필요한 권한 필요 |

이 차이를 이해해야 인증 오류와 인가 오류를 정확하게 처리할 수 있다.

---

### 테스트를 위한 Controller 작성

이제 JWT 인증이 정상적으로 동작하는지 확인해보자.

기존 프로젝트에는 다음 두 Controller가 존재한다.

```text
MainController
AdminController
```

메인 경로는 공개한다.

관리자 경로는 `ROLE_ADMIN` 권한을 요구한다.

추가로 인증된 사용자 정보를 확인하기 위한 API도 작성해보자.

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

이 경로는 인증 없이 접근할 수 있다.

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

이 경로는 `ROLE_ADMIN` 권한이 있어야 접근할 수 있다.

#### AuthController

현재 인증된 사용자 정보를 확인하기 위한 API를 작성한다.

```java
package com.example.jwt.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
public class AuthController {

    @GetMapping("/api/me")
    public Map<String, Object> me(
            Authentication authentication
    ) {

        List<String> authorities = authentication
                .getAuthorities()
                .stream()
                .map(GrantedAuthority::getAuthority)
                .toList();

        return Map.of(
                "username",
                authentication.getName(),
                "authorities",
                authorities
        );
    }
}
```

이 Controller에서는 다음 값을 확인할 수 있다.

```java
authentication.getName();
```

현재 인증된 사용자 이름을 반환한다.

다음 코드로 사용자 권한을 가져올 수 있다.

```java
authentication.getAuthorities();
```

JWTFilter가 정상적으로 SecurityContext를 구성했다면 해당 정보가 Controller까지 전달된다.

---

### 실행 및 확인

#### 1. Spring Boot 실행

다음 명령으로 프로젝트를 실행한다.

```bash
./gradlew bootRun
```

이 명령은 Gradle Wrapper를 통해 Spring Boot 애플리케이션을 실행한다.

정상적으로 실행되면 다음과 유사한 로그가 출력된다.

```text
Tomcat started on port 8080 (http)

Started JwtApplication
```

이제 로그인 요청을 보내 JWT를 발급받을 수 있다.

---

### 로그인 후 JWT 발급 확인

먼저 로그인 API를 호출한다.

```http
POST http://localhost:8080/login
```

요청 본문은 `x-www-form-urlencoded` 형식으로 전달한다.

| Key | Value |
|---|---|
| username | admin01 |
| password | password123! |

여기서 `admin01`은 실제 MySQL에 존재하고 `ROLE_ADMIN` 권한을 가진 사용자라고 가정한다.

로그인에 성공하면 다음과 같은 응답을 받을 수 있다.

```http
HTTP/1.1 200 OK
Authorization: Bearer <ACCESS_TOKEN>
```

이때 JWT를 복사한다.

다음 요청에서 사용한다.

---

### curl로 JWT 발급 확인하기

Postman 대신 curl을 사용할 수도 있다.

```bash
curl -i -X POST \
  http://localhost:8080/login \
  --data-urlencode "username=admin01" \
  --data-urlencode "password=password123!"
```

각 옵션의 의미는 다음과 같다.

| 옵션 | 의미 |
|---|---|
| `-i` | HTTP 응답 헤더 출력 |
| `-X POST` | POST 요청 |
| `--data-urlencode` | 요청 데이터를 URL 인코딩하여 전송 |

응답 헤더에서 다음 값을 확인한다.

```http
Authorization: Bearer <ACCESS_TOKEN>
```

이 값을 다음 API 호출에 사용한다.

---

### JWT 없이 메인 API 접근하기

먼저 공개된 API를 호출한다.

```bash
curl -i http://localhost:8080/
```

현재 SecurityConfig에는 다음 설정이 존재한다.

```java
.requestMatchers(
        HttpMethod.GET,
        "/"
).permitAll()
```

따라서 JWT가 없어도 접근할 수 있다.

정상적인 경우 다음과 같은 응답을 확인할 수 있다.

```http
HTTP/1.1 200 OK

Main Controller
```

이 요청에서는 JWTFilter가 Authorization 헤더를 확인한다.

하지만 JWT가 없으므로 인증 정보를 구성하지 않는다.

이후 요청을 다음 필터로 전달한다.

```java
filterChain.doFilter(request, response);
```

AuthorizationFilter는 해당 경로가 `permitAll()`로 설정되어 있으므로 요청을 허용한다.

---

### JWT 없이 관리자 API 접근하기

이번에는 관리자 API를 호출한다.

```bash
curl -i http://localhost:8080/admin
```

현재 SecurityConfig는 관리자 API에 다음 권한을 요구한다.

```java
.hasRole("ADMIN")
```

JWT가 없으므로 인증된 사용자 정보를 구성하지 못한다.

따라서 현재 설정에서는 다음 응답이 반환된다.

```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer
```

여기서 중요한 점은 JWTFilter가 직접 401을 반환한 것이 아니라는 사실이다.

JWTFilter는 토큰이 없는 요청을 다음 필터로 전달했다.

이후 Spring Security의 인가 과정에서 인증이 필요하다고 판단하여 401을 반환한다.

---

### JWT로 관리자 API 접근하기

이제 관리자 권한이 포함된 JWT를 전달해보자.

```bash
curl -i \
  http://localhost:8080/admin \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

여기서 `<ACCESS_TOKEN>`은 실제 로그인 응답에서 발급받은 JWT로 변경해야 한다.

정상적인 토큰이라면 다음 과정이 실행된다.

```text
GET /admin
    ↓
JWTFilter
    ↓
Authorization 헤더 추출
    ↓
JWT 서명 검증
    ↓
JWT 만료 시간 검증
    ↓
username = admin01
    ↓
role = ROLE_ADMIN
    ↓
Authentication 생성
    ↓
SecurityContextHolder 등록
    ↓
AuthorizationFilter
    ↓
hasRole("ADMIN")
    ↓
접근 허용
```

정상적으로 인증과 인가가 완료되었다면 다음 응답을 확인할 수 있다.

```http
HTTP/1.1 200 OK

Admin Controller
```

이렇게 하면 JWT를 이용한 인증과 관리자 권한 검증이 정상적으로 동작한다.

---

### 일반 사용자 JWT로 관리자 API 접근하기

이번에는 `ROLE_USER` 권한만 가진 사용자로 로그인한다고 생각해보자.

예를 들어 다음과 같은 사용자다.

```text
username = user01

role = ROLE_USER
```

이 사용자에게도 정상적인 JWT를 발급할 수 있다.

하지만 관리자 API에 접근할 권한은 없다.

따라서 다음 요청을 보내면:

```http
GET /admin
Authorization: Bearer <USER_ACCESS_TOKEN>
```

JWT 검증 자체는 성공할 수 있다.

```text
JWT 서명 정상

JWT 만료되지 않음

username = user01

role = ROLE_USER
```

하지만 이후 인가 과정에서 다음 조건을 통과하지 못한다.

```java
.hasRole("ADMIN")
```

따라서 다음 응답이 반환된다.

```http
HTTP/1.1 403 Forbidden
```

즉 **JWT가 정상적으로 검증되었다는 사실과 해당 API에 접근할 권한이 있다는 사실은 다르다.**

---

### JWT에서 인증된 사용자 정보 확인하기

이번에는 `/api/me` 경로를 호출해보자.

```bash
curl -i \
  http://localhost:8080/api/me \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

해당 요청은 다음 Controller로 전달된다.

```java
@GetMapping("/api/me")
public Map<String, Object> me(
        Authentication authentication
) {

    List<String> authorities = authentication
            .getAuthorities()
            .stream()
            .map(GrantedAuthority::getAuthority)
            .toList();

    return Map.of(
            "username",
            authentication.getName(),
            "authorities",
            authorities
    );
}
```

JWT가 정상적으로 검증되었다면 다음과 같은 응답을 확인할 수 있다.

```json
{
  "username": "admin01",
  "authorities": [
    "ROLE_ADMIN"
  ]
}
```

이 결과는 JWTFilter가 생성한 Authentication이 현재 요청의 SecurityContext에 등록되었음을 확인하는 데 도움이 된다.

---

### 만료된 JWT로 접근하기

JWT에는 만료 시간이 존재한다.

예를 들어 JWT의 유효기간이 1시간이라면 발급 후 1시간이 지나면 더 이상 인증에 사용할 수 없다.

만료된 JWT를 전달하면 다음과 같은 흐름이 발생한다.

```text
JWTFilter
    ↓
JWTUtil.verifyAndExtract()
    ↓
parseSignedClaims()
    ↓
ExpiredJwtException
    ↓
JWTFilter 예외 처리
    ↓
HTTP 401
```

응답은 다음과 같다.

```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer error="invalid_token"

{
  "error": "invalid_token"
}
```

만료된 JWT로 Authentication을 구성하지 않기 때문에 보호된 API에 접근할 수 없다.

---

### JWT를 변조하면 어떻게 될까?

JWT는 일반적으로 다음과 같은 구조를 가진다.

```text
Header.Payload.Signature
```

Payload는 Base64URL로 인코딩되어 있으므로 외부에서 디코딩할 수 있다.

하지만 JWT에 서명이 존재하기 때문에 Payload를 임의로 변경하면 서명 검증에 실패해야 한다.

예를 들어 기존 JWT가 다음 권한을 가진 사용자에게 발급되었다고 생각해보자.

```json
{
  "username": "user01",
  "role": "ROLE_USER"
}
```

공격자가 권한을 다음과 같이 변경하려고 한다.

```json
{
  "username": "user01",
  "role": "ROLE_ADMIN"
}
```

하지만 올바른 SecretKey를 이용해 다시 서명하지 않으면 JWT의 Signature가 일치하지 않는다.

따라서 다음 과정에서 검증에 실패한다.

```java
jwtParser.parseSignedClaims(token);
```

JWTUtil은 예외를 발생시킨다.

JWTFilter는 해당 예외를 처리하고 401을 반환한다.

```text
변조된 JWT
    ↓
JWTFilter
    ↓
JWTUtil
    ↓
서명 검증 실패
    ↓
HTTP 401
```

이것이 서명 기반 JWT가 무결성을 검증하는 기본적인 원리다.

---

### JWTFilter 단위 테스트 작성하기

JWT 인증 필터는 인증 시스템의 핵심이므로 자동화 테스트를 작성하는 것이 좋다.

이번에는 다음 상황을 검증한다.

| 테스트 | 기대 결과 |
|---|---|
| 정상 JWT | Authentication 생성 |
| 정상 JWT | username 확인 |
| 정상 JWT | ROLE_ADMIN 확인 |
| JWT 없음 | 인증 정보 생성하지 않음 |
| 만료된 JWT | 401 |
| 서명이 잘못된 JWT | 401 |
| Bearer 접두사만 존재 | 401 |

단위 테스트에서는 실제 MySQL을 사용하지 않는다.

JWTUtil에 테스트용 SecretKey를 전달하고, MockHttpServletRequest와 MockHttpServletResponse를 이용해 검증한다.

#### JWTFilterTest 전체 코드

```java
package com.example.jwt.jwt;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Encoders;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import org.springframework.http.HttpHeaders;

import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import javax.crypto.SecretKey;

import java.time.Instant;
import java.util.Date;
import java.util.concurrent.atomic.AtomicReference;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class JWTFilterTest {

    private SecretKey secretKey;

    private JWTUtil jwtUtil;

    private JWTFilter jwtFilter;

    @BeforeEach
    void setUp() {

        secretKey = Jwts.SIG.HS256
                .key()
                .build();

        String encodedSecret =
                Encoders.BASE64.encode(
                        secretKey.getEncoded()
                );

        jwtUtil = new JWTUtil(encodedSecret);

        jwtFilter = new JWTFilter(jwtUtil);
    }

    @AfterEach
    void tearDown() {

        SecurityContextHolder.clearContext();
    }

    @Test
    void 정상_JWT는_인증정보를_생성한다()
            throws Exception {

        // given
        String token = jwtUtil.createJwt(
                "admin01",
                "ROLE_ADMIN",
                3600000L
        );

        MockHttpServletRequest request =
                new MockHttpServletRequest(
                        "GET",
                        "/admin"
                );

        request.addHeader(
                HttpHeaders.AUTHORIZATION,
                "Bearer " + token
        );

        MockHttpServletResponse response =
                new MockHttpServletResponse();

        AtomicReference<Authentication> captured =
                new AtomicReference<>();

        // when
        jwtFilter.doFilter(
                request,
                response,
                (req, res) -> {

                    captured.set(
                            SecurityContextHolder
                                    .getContext()
                                    .getAuthentication()
                    );
                }
        );

        // then
        assertEquals(
                200,
                response.getStatus()
        );

        Authentication authentication =
                captured.get();

        assertNotNull(authentication);

        assertTrue(
                authentication.isAuthenticated()
        );

        assertEquals(
                "admin01",
                authentication.getName()
        );

        assertTrue(
                authentication.getAuthorities()
                        .stream()
                        .anyMatch(authority ->
                                authority.getAuthority()
                                        .equals("ROLE_ADMIN")
                        )
        );
    }

    @Test
    void JWT가_없으면_인증정보를_생성하지_않는다()
            throws Exception {

        // given
        MockHttpServletRequest request =
                new MockHttpServletRequest(
                        "GET",
                        "/admin"
                );

        MockHttpServletResponse response =
                new MockHttpServletResponse();

        AtomicReference<Authentication> captured =
                new AtomicReference<>();

        // when
        jwtFilter.doFilter(
                request,
                response,
                (req, res) -> {

                    captured.set(
                            SecurityContextHolder
                                    .getContext()
                                    .getAuthentication()
                    );
                }
        );

        // then
        assertNull(captured.get());
    }

    @Test
    void 만료된_JWT는_인증에_실패한다()
            throws Exception {

        // given
        Instant now = Instant.now();

        String expiredToken = Jwts.builder()
                .claim("username", "admin01")
                .claim("role", "ROLE_ADMIN")
                .issuedAt(
                        Date.from(now.minusSeconds(3600))
                )
                .expiration(
                        Date.from(now.minusSeconds(60))
                )
                .signWith(secretKey, Jwts.SIG.HS256)
                .compact();

        MockHttpServletRequest request =
                new MockHttpServletRequest(
                        "GET",
                        "/admin"
                );

        request.addHeader(
                HttpHeaders.AUTHORIZATION,
                "Bearer " + expiredToken
        );

        MockHttpServletResponse response =
                new MockHttpServletResponse();

        // when
        jwtFilter.doFilter(
                request,
                response,
                (req, res) -> {
                }
        );

        // then
        assertEquals(
                401,
                response.getStatus()
        );

        assertNull(
                SecurityContextHolder
                        .getContext()
                        .getAuthentication()
        );
    }

    @Test
    void 다른_키로_서명된_JWT는_인증에_실패한다()
            throws Exception {

        // given
        SecretKey otherKey = Jwts.SIG.HS256
                .key()
                .build();

        String token = Jwts.builder()
                .claim("username", "admin01")
                .claim("role", "ROLE_ADMIN")
                .issuedAt(new Date())
                .expiration(
                        Date.from(
                                Instant.now().plusSeconds(3600)
                        )
                )
                .signWith(otherKey, Jwts.SIG.HS256)
                .compact();

        MockHttpServletRequest request =
                new MockHttpServletRequest(
                        "GET",
                        "/admin"
                );

        request.addHeader(
                HttpHeaders.AUTHORIZATION,
                "Bearer " + token
        );

        MockHttpServletResponse response =
                new MockHttpServletResponse();

        // when
        jwtFilter.doFilter(
                request,
                response,
                (req, res) -> {
                }
        );

        // then
        assertEquals(
                401,
                response.getStatus()
        );
    }

    @Test
    void Bearer_뒤에_토큰이_없으면_401을_반환한다()
            throws Exception {

        // given
        MockHttpServletRequest request =
                new MockHttpServletRequest(
                        "GET",
                        "/admin"
                );

        request.addHeader(
                HttpHeaders.AUTHORIZATION,
                "Bearer "
        );

        MockHttpServletResponse response =
                new MockHttpServletResponse();

        // when
        jwtFilter.doFilter(
                request,
                response,
                (req, res) -> {
                }
        );

        // then
        assertEquals(
                401,
                response.getStatus()
        );
    }
}
```

이 테스트는 JWTFilter 자체의 동작을 검증한다.

다만 단위 테스트의 Mock FilterChain에는 실제 AuthorizationFilter가 포함되지 않는다.

따라서 다음 테스트들은 JWTFilter만을 대상으로 한다.

```text
JWT 없음
    ↓
JWTFilter
    ↓
다음 필터로 전달
```

실제 애플리케이션에서는 이후 AuthorizationFilter가 해당 API의 접근 권한을 판단한다.

즉 **JWTFilter 단위 테스트와 Spring Security 전체 인가 테스트는 구분해야 한다.**

#### 테스트 실행

다음 명령을 실행한다.

```bash
./gradlew test --tests "com.example.jwt.jwt.JWTFilterTest"
```

정상적으로 완료되면 다음과 유사한 결과를 확인할 수 있다.

```text
BUILD SUCCESSFUL
```

---

### 구조

#### JWT 인증 필터의 전체 처리 과정

지금까지 구현한 내용을 하나의 구조로 정리해보자.

```mermaid
flowchart TD
    A["HTTP 요청"] --> B["JWTFilter"]

    B --> C["Authorization 헤더 추출"]

    C --> D{"Authorization 존재?"}

    D -->|"No"| E["다음 Filter"]

    D -->|"Yes"| F{"Bearer 형식?"}

    F -->|"No"| E

    F -->|"Yes"| G["JWT 문자열 추출"]

    G --> H{"JWT 비어 있음?"}

    H -->|"Yes"| I["HTTP 401"]

    H -->|"No"| J["JWTUtil.verifyAndExtract"]

    J --> K{"서명 및 만료 검증 성공?"}

    K -->|"No"| I

    K -->|"Yes"| L["username / role 추출"]

    L --> M["GrantedAuthority 생성"]

    M --> N["UsernamePasswordAuthenticationToken 생성"]

    N --> O["SecurityContext 생성"]

    O --> P["SecurityContextHolder 등록"]

    P --> E

    E --> Q["AuthorizationFilter"]

    Q --> R{"접근 권한 충족?"}

    R -->|"Yes"| S["Controller"]

    R -->|"No - 미인증"| T["HTTP 401"]

    R -->|"No - 권한 부족"| U["HTTP 403"]
```

이 과정의 핵심은 JWTFilter와 AuthorizationFilter의 역할 분리다.

JWTFilter는 다음을 수행한다.

```text
JWT 검증
    ↓
Authentication 생성
    ↓
SecurityContext 등록
```

AuthorizationFilter는 다음을 수행한다.

```text
Authentication 조회
    ↓
요청 경로의 접근 조건 확인
    ↓
허용 또는 거부
```

이렇게 분리하면 JWTFilter에서 모든 API의 권한 정책을 직접 작성하지 않아도 된다.

---

### 실무에서의 활용

#### 1. SecurityContext와 HttpSession을 혼동하지 않는다

JWTFilter는 SecurityContext에 인증 정보를 설정한다.

하지만 Stateless 설정에서는 이 인증 정보를 서버 HttpSession에 저장하여 다음 요청에서 재사용하는 구조를 사용하지 않는다.

따라서 요청마다 JWT를 다시 검증해야 한다.

#### 2. JWT가 없다고 모든 요청을 즉시 거부하지 않는다

공개 API에서는 JWT 없이도 접근할 수 있어야 한다.

따라서 JWTFilter는 JWT가 없는 요청을 다음 필터로 전달하고, 실제 접근 여부는 AuthorizationFilter가 판단하도록 구성할 수 있다.

#### 3. 유효하지 않은 JWT는 인증 정보로 사용하지 않는다

만료되었거나 서명이 올바르지 않은 JWT에서 사용자 정보를 가져와 Authentication을 구성해서는 안 된다.

JWT 검증에 실패하면 인증을 거부해야 한다.

#### 4. JWT Payload를 디코딩하는 것만으로 인증하지 않는다

JWT Payload는 Base64URL 디코딩만으로 읽을 수 있다.

하지만 디코딩된 사용자 정보가 신뢰할 수 있다는 의미는 아니다.

반드시 서명과 만료 시간 등을 검증한 뒤 인증 정보를 구성해야 한다.

#### 5. UserDetails를 만들기 위해 가짜 비밀번호를 사용할 필요는 없다

현재 프로젝트에서는 다음 방식으로 인증 객체를 생성했다.

```java
UsernamePasswordAuthenticationToken.authenticated(
        username,
        null,
        authorities
);
```

따라서 임시 UserEntity나 가짜 비밀번호를 생성하지 않아도 된다.

#### 6. JWT 검증에서 불필요한 DB 조회를 피한다

JWT는 서버가 서명한 Claim을 이용해 사용자를 인증할 수 있다.

따라서 매 요청마다 반드시 MySQL에서 사용자 비밀번호를 조회할 필요는 없다.

이는 데이터베이스 부하를 줄이는 데 도움이 될 수 있다.

다만 최신 계정 상태나 권한 확인이 필요한 API에서는 추가 조회 정책을 적용할 수 있다.

#### 7. JWT 인증 객체와 로그인 인증 요청 객체를 구분한다

로그인에서는 다음 객체를 생성한다.

```java
UsernamePasswordAuthenticationToken.unauthenticated(
        username,
        password
);
```

반면 JWT 검증 후에는 다음 객체를 사용할 수 있다.

```java
UsernamePasswordAuthenticationToken.authenticated(
        username,
        null,
        authorities
);
```

두 객체는 같은 클래스지만 생성 시점과 목적이 다르다.

첫 번째는 인증을 요청하는 객체다.

두 번째는 검증된 사용자 정보를 표현하는 객체다.

#### 8. 필터 순서를 확인한다

JWTFilter는 AuthorizationFilter가 인가를 판단하기 전에 Authentication을 설정해야 한다.

따라서 SecurityFilterChain의 필터 순서를 확인해야 한다.

현재 프로젝트에서는 다음과 같이 등록했다.

```java
.addFilterBefore(
        jwtFilter,
        UsernamePasswordAuthenticationFilter.class
)
```

#### 9. JWT 검증 필터를 중복 등록하지 않는다

JWTFilter를 Servlet Filter와 SecurityFilterChain 양쪽에 등록하면 예상하지 못한 중복 실행이 발생할 수 있다.

따라서 필터 등록 위치와 등록 방식을 명확하게 관리해야 한다.

#### 10. JWT 검증 예외를 직접 처리하는 위치를 고려한다

이번 JWTFilter는 잘못된 JWT를 발견하면 직접 401을 반환한다.

이는 필터 내부에서 인증 실패를 명확하게 처리하는 방법이다.

다만 실제 시스템에서는 인증 실패 응답의 형식을 통일하기 위해 AuthenticationEntryPoint와 연결하는 구조를 사용할 수도 있다.

주의할 점은 JWTFilter가 ExceptionTranslationFilter보다 앞에서 실행되면 해당 필터에서 발생한 예외를 ExceptionTranslationFilter가 자동으로 처리하지 못할 수 있다는 사실이다.

따라서 인증 실패 예외를 어느 계층에서 처리할지 명확하게 설계해야 한다.

#### 11. 401과 403을 구분한다

JWT가 없거나 유효하지 않다면 일반적으로 401을 사용한다.

JWT는 유효하지만 해당 API에 접근할 권한이 없다면 403을 사용할 수 있다.

이 차이를 정확하게 구분해야 클라이언트에서도 인증 실패와 권한 부족 상황을 올바르게 처리할 수 있다.

#### 12. JWT 검증을 한 번만 수행하도록 최적화한다

다음처럼 JWTUtil을 여러 번 호출하면 파싱이 반복될 수 있다.

```java
jwtUtil.isValid(token);

jwtUtil.getUsername(token);

jwtUtil.getRole(token);
```

따라서 한 번의 검증으로 Claims를 추출하고 필요한 정보를 함께 가져오는 방식이 효율적이다.

#### 13. 토큰에 포함된 권한이 최신 정보인지 고려한다

JWT 발급 당시 사용자가 관리자였더라도 이후 권한이 변경될 수 있다.

하지만 이미 발급된 JWT에는 기존 권한이 남아 있을 수 있다.

따라서 권한 변경을 즉시 반영해야 하는 서비스에서는 별도의 권한 확인이나 토큰 무효화 정책이 필요할 수 있다.

#### 14. 계정 탈퇴 및 정지 상태를 고려한다

JWT의 서명과 만료 시간이 정상적이라고 해서 사용자의 계정 상태가 항상 유효한 것은 아니다.

사용자가 탈퇴하거나 관리자가 계정을 정지했을 수도 있다.

따라서 보안 요구사항에 따라 사용자 상태를 추가로 검증하는 구조를 고려해야 한다.

#### 15. JWT 원문을 로그에 기록하지 않는다

JWT는 Bearer Token으로 사용할 수 있다.

따라서 JWT 원문이 로그에 남으면 해당 토큰이 유출될 위험이 있다.

다음과 같은 코드는 피해야 한다.

```java
log.info("JWT: {}", token);
```

대신 검증 결과나 오류 유형 등 필요한 범위의 정보만 기록하는 것이 좋다.

#### 16. HTTPS를 사용한다

JWT에 서명이 포함되어 있다고 해서 네트워크 전송 구간이 암호화되는 것은 아니다.

JWT가 탈취되면 유효기간 동안 악용될 수 있다.

따라서 실제 서비스에서는 반드시 HTTPS를 사용해야 한다.

#### 17. JWT 인증은 서버 간 확장에 유리할 수 있다

JWT 기반 인증에서는 각 서버가 동일한 검증 정책과 키를 사용하면 전달받은 JWT를 독립적으로 검증할 수 있다.

예를 들어 다음과 같은 구조다.

```text
Load Balancer
    ├── Application A
    ├── Application B
    └── Application C
```

Application A에서 JWT를 발급하더라도 Application B가 해당 JWT를 검증할 수 있다.

다만 HS256을 사용한다면 서명과 검증에 필요한 비밀키를 안전하고 일관되게 관리해야 한다.

#### 18. 비동기 처리에서 SecurityContext 전파를 고려한다

SecurityContextHolder는 기본적으로 ThreadLocal 기반으로 동작한다.

따라서 요청을 처리하는 스레드에서 별도의 비동기 스레드를 실행하면 SecurityContext가 자동으로 전달되지 않을 수 있다.

예를 들어 다음과 같은 상황이다.

```text
HTTP 요청 스레드
    ↓
JWT 인증 성공
    ↓
SecurityContext 설정
    ↓
@Async
    ↓
별도 스레드 실행
```

이때 비동기 스레드에서 인증 정보가 필요하다면 Spring Security의 컨텍스트 전파 기능 등을 검토해야 한다.

하지만 무분별하게 ThreadLocal을 공유하면 스레드 간 인증 정보가 잘못 전달될 수 있으므로 주의해야 한다.

#### 19. JWTFilter에서 비즈니스 로직을 처리하지 않는다

JWTFilter는 JWT 인증을 담당한다.

사용자 주문 조회, 결제 처리, 게시글 수정 같은 비즈니스 로직까지 JWTFilter에 구현해서는 안 된다.

인증과 인가에 필요한 정보를 구성한 뒤 Controller와 Service에 요청 처리를 위임하는 것이 적절하다.

#### 20. 인증 필터 테스트와 전체 인가 테스트를 함께 수행한다

JWTFilter의 단위 테스트는 JWT 검증과 Authentication 생성 과정을 확인한다.

반면 전체 인증 시스템을 검증하려면 실제 SecurityFilterChain을 포함한 통합 테스트가 필요하다.

다음과 같은 상황을 검증하는 것이 좋다.

| 상황 | 기대 결과 |
|---|---|
| JWT 없는 공개 API | 200 |
| JWT 없는 보호 API | 401 |
| 정상 일반 사용자 JWT | 인증 성공 |
| 정상 관리자 JWT | 관리자 API 200 |
| 일반 사용자 JWT로 관리자 API | 403 |
| 만료된 JWT | 401 |
| 변조된 JWT | 401 |
| 잘못된 Bearer 형식 | 인증 실패 |
| 비활성 계정 | 서비스 정책에 따른 차단 |

이러한 테스트를 통해 JWT 검증과 URL별 권한 정책이 함께 정상적으로 동작하는지 확인할 수 있다.

---

### 정리

Spring Security에서 JWT 기반 Stateless 인증을 구현하려면 클라이언트가 전달한 JWT를 검증하고 현재 요청의 인증 정보를 구성해야 한다.

이를 위해 `OncePerRequestFilter`를 상속한 JWTFilter를 구현할 수 있다.

먼저 JWTFilter에서 Authorization 헤더를 추출한다.

```java
String authorization =
        request.getHeader(HttpHeaders.AUTHORIZATION);
```

Authorization 헤더가 없다면 다음 필터로 전달한다.

```java
if (authorization == null) {

    filterChain.doFilter(request, response);

    return;
}
```

Bearer 인증 형식인지 확인한다.

```java
if (!authorization.startsWith("Bearer ")) {

    filterChain.doFilter(request, response);

    return;
}
```

다음으로 실제 JWT 문자열을 추출한다.

```java
String token =
        authorization.substring(7);
```

JWTUtil을 이용해 JWT를 검증하고 사용자 정보를 가져온다.

```java
JWTUtil.JwtUserInfo userInfo =
        jwtUtil.verifyAndExtract(token);
```

사용자 이름과 권한을 추출한다.

```java
String username =
        userInfo.username();

String role =
        userInfo.role();
```

다음으로 권한 객체를 생성한다.

```java
List<SimpleGrantedAuthority> authorities =
        List.of(
                new SimpleGrantedAuthority(role)
        );
```

인증된 Authentication 객체를 생성한다.

```java
UsernamePasswordAuthenticationToken authentication =
        UsernamePasswordAuthenticationToken.authenticated(
                username,
                null,
                authorities
        );
```

이후 SecurityContext를 생성하고 Authentication을 등록한다.

```java
SecurityContext context =
        SecurityContextHolder.createEmptyContext();

context.setAuthentication(authentication);

SecurityContextHolder.setContext(context);
```

마지막으로 다음 필터를 실행한다.

```java
filterChain.doFilter(request, response);
```

이렇게 하면 이후 Spring Security의 인가 과정에서 현재 요청의 인증 정보를 사용할 수 있다.

전체 흐름은 다음과 같다.

```mermaid
flowchart TD
    A["JWT 인증 요청"] --> B["JWTFilter"]

    B --> C["Authorization 헤더 확인"]

    C --> D["Bearer JWT 추출"]

    D --> E["JWTUtil 검증"]

    E --> F{"JWT 유효?"}

    F -->|"No"| G["HTTP 401"]

    F -->|"Yes"| H["username / role 추출"]

    H --> I["GrantedAuthority 생성"]

    I --> J["Authentication 생성"]

    J --> K["SecurityContext 생성"]

    K --> L["SecurityContextHolder 등록"]

    L --> M["AuthorizationFilter"]

    M --> N{"접근 권한 충족?"}

    N -->|"Yes"| O["Controller 실행"]

    N -->|"No"| P["HTTP 403"]
```

이번 구현에서 반드시 기억해야 할 핵심은 네 가지다.

**첫째, JWT 검증과 Spring Security 인증은 서로 다른 단계다.**

JWTUtil을 이용해 JWT를 검증한 뒤, Spring Security의 Authentication을 생성해야 한다.

**둘째, JWT 인증에서는 매번 비밀번호를 검증할 필요가 없다.**

JWT의 서명과 만료 시간 등을 검증한 뒤 필요한 사용자 정보를 추출할 수 있다. 다만 최신 계정 상태나 권한 확인이 필요한 서비스에서는 추가적인 검증 정책이 필요하다.

**셋째, SecurityContextHolder는 HttpSession과 다르다.**

Stateless 인증에서도 현재 요청의 Authentication을 SecurityContext에 저장할 수 있다. 이 과정에서 임시 HttpSession을 생성하는 것은 아니다.

**넷째, JWTFilter는 인증 정보를 구성하고 AuthorizationFilter는 접근 권한을 판단한다.**

이 두 역할을 분리하면 JWT 검증 로직과 URL별 인가 정책을 독립적으로 관리할 수 있다.

이번 구현을 통해 다음 기능이 연결되었다.

```text
회원가입
    ↓
MySQL 사용자 저장
    ↓
로그인
    ↓
아이디 및 비밀번호 검증
    ↓
JWT 발급
    ↓
클라이언트에 JWT 전달
    ↓
다음 HTTP 요청
    ↓
JWTFilter
    ↓
JWT 서명 및 만료 검증
    ↓
Authentication 생성
    ↓
SecurityContextHolder 등록
    ↓
인가 처리
    ↓
Controller 실행
```

이렇게 하면 Spring Security 6과 JWT를 이용해 서버 세션에 로그인 상태를 유지하지 않는 기본적인 Stateless 인증·인가 시스템을 구현할 수 있다.

#### 한 줄 요약

Spring Security JWT 인증 필터는 `OncePerRequestFilter`를 상속하여 구현하며, Authorization 헤더에서 Bearer JWT를 추출한 뒤 `JWTUtil`로 서명과 만료 시간을 검증한다. 검증에 성공하면 JWT에 포함된 사용자 이름과 권한으로 `UsernamePasswordAuthenticationToken`을 생성하고, `SecurityContextHolder`에 등록하여 현재 HTTP 요청을 인증한다. 이후 `AuthorizationFilter`가 사용자의 권한을 확인하므로, JWT 인증과 인가를 분리한 Stateless 인증 시스템을 구현할 수 있다.
