---
layout: post
bigtitle: '스프링 시큐리티 JWT'
subtitle: 스프링 시큐리티 JWT - 10. 로그인 성공 JWT 발급
date: '2026-11-03 00:00:03 +0900'
categories:
    - spring-security-jwt
comments: true


---

# 스프링 시큐리티 JWT - 10. 로그인 성공 JWT 발급
[https://youtu.be/nH3A22izjY0?si=8eArF1iEymyOmKII](https://youtu.be/nH3A22izjY0?si=8eArF1iEymyOmKII)

# 스프링 시큐리티 JWT - 10. 로그인 성공 JWT 발급
* toc
{:toc}

---

### Spring Security 6 JWT 로그인 성공 시 토큰 발급 구현: LoginFilter, successfulAuthentication, Authorization Bearer 완벽 정리

Spring Security와 JWT를 이용해 인증 시스템을 구현하려면 사용자의 아이디와 비밀번호를 검증하는 것뿐만 아니라, 인증에 성공한 사용자에게 JWT를 발급하는 과정이 필요하다.

기존에 구성한 로그인 인증 흐름은 다음과 같다.

```text
POST /login
    ↓
LoginFilter
    ↓
UsernamePasswordAuthenticationToken
    ↓
AuthenticationManager
    ↓
DaoAuthenticationProvider
    ↓
CustomUserDetailsService
    ↓
UserRepository
    ↓
MySQL
    ↓
PasswordEncoder.matches()
    ↓
인증 성공
```

이 구조를 통해 데이터베이스에 저장된 사용자 정보와 클라이언트가 전달한 아이디·비밀번호를 비교할 수 있다.

하지만 현재 프로젝트는 JWT 기반의 Stateless 인증을 사용한다.

따라서 로그인에 성공했다고 해서 서버가 해당 사용자의 로그인 상태를 세션에 저장하고 계속 유지하는 것은 아니다.

예를 들어 사용자가 다음 요청으로 로그인한다고 생각해보자.

```http
POST /login HTTP/1.1
Host: localhost:8080
Content-Type: application/x-www-form-urlencoded

username=user01&password=password123%21
```

서버가 아이디와 비밀번호를 검증하고 로그인에 성공했다.

그런데 클라이언트가 이어서 다음 요청을 보낸다면 어떻게 될까?

```http
GET /admin HTTP/1.1
Host: localhost:8080
```

서버가 이전 로그인 상태를 세션에 저장하지 않는다면 해당 요청이 누구에게서 발생했는지 확인하기 어렵다.

이를 해결하기 위해 **로그인 성공 시 JWT를 발급하고, 이후 HTTP 요청에서 해당 JWT를 전달받아 인증하는 구조**를 사용할 수 있다.

로그인에 성공하면 서버는 JWT를 생성한다.

그리고 다음과 같이 HTTP 응답 헤더에 전달한다.

```http
HTTP/1.1 200 OK
Authorization: Bearer <ACCESS_TOKEN>
```

클라이언트는 발급받은 JWT를 보관하고 이후 API 요청에 포함한다.

```http
GET /admin HTTP/1.1
Host: localhost:8080
Authorization: Bearer <ACCESS_TOKEN>
```

이렇게 하면 서버는 각 요청에서 JWT를 검증하여 사용자를 인증할 수 있다.

이번에는 **LoginFilter의 로그인 성공 처리와 JWTUtil의 JWT 생성 기능을 연결하는 과정**을 구현한다.

전체적인 구조는 다음과 같다.

```mermaid
sequenceDiagram
    participant Client
    participant LoginFilter
    participant AuthenticationManager
    participant UserDetailsService
    participant JWTUtil

    Client->>LoginFilter: POST /login
    Note over Client,LoginFilter: username, password

    LoginFilter->>AuthenticationManager: authenticate()

    AuthenticationManager->>UserDetailsService: 사용자 조회 및 검증

    UserDetailsService-->>AuthenticationManager: UserDetails

    AuthenticationManager-->>LoginFilter: 인증된 Authentication

    LoginFilter->>LoginFilter: successfulAuthentication()

    LoginFilter->>LoginFilter: username, role 추출

    LoginFilter->>JWTUtil: createJwt(username, role, expiredMs)

    JWTUtil-->>LoginFilter: JWT 문자열 반환

    LoginFilter-->>Client: HTTP 200 + Authorization Bearer JWT
```

이 과정에서 가장 중요한 구성요소는 다음과 같다.

| 구성요소                    | 역할               |
| ----------------------- | ---------------- |
| `LoginFilter`           | 로그인 요청과 인증 결과 처리 |
| `AuthenticationManager` | 로그인 인증 요청        |
| `Authentication`        | 인증에 성공한 사용자 정보   |
| `CustomUserDetails`     | 사용자 이름과 인증 정보 제공 |
| `GrantedAuthority`      | 인증된 사용자 권한       |
| `JWTUtil`               | JWT 생성 및 검증      |
| `HttpServletResponse`   | JWT를 응답 헤더에 전달   |

이제 각 구성요소를 연결해보자.

---

### 개념

#### 로그인 인증과 JWT 발급의 차이

로그인 인증과 JWT 발급은 서로 다른 작업이다.

**로그인 인증은 사용자가 누구인지 확인하는 과정**이다.

예를 들어 다음 정보를 검증한다.

```text
username = user01

password = password123!
```

서버는 MySQL에서 사용자 정보를 조회하고, BCrypt로 저장된 비밀번호 해시와 입력한 비밀번호를 비교한다.

검증에 성공하면 Spring Security는 인증된 `Authentication` 객체를 반환한다.

반면 **JWT 발급은 검증된 사용자 정보를 토큰으로 표현하여 클라이언트에 전달하는 과정**이다.

```text
로그인 인증
    ↓
아이디 및 비밀번호 검증
    ↓
인증된 Authentication 반환
    ↓
JWT 생성
    ↓
클라이언트에 전달
```

두 작업을 구분하면 다음과 같다.

| 구분      | 로그인 인증                | JWT 발급               |
| ------- | --------------------- | -------------------- |
| 목적      | 사용자 신원 검증             | 이후 요청에서 사용할 인증 정보 제공 |
| 주요 구성요소 | AuthenticationManager | JWTUtil              |
| 입력      | username, password    | 인증된 username, role   |
| 결과      | Authentication        | JWT 문자열              |
| 실패 원인   | 사용자 없음, 비밀번호 불일치      | 서명 키 오류, 토큰 생성 오류 등  |

여기서 중요한 점이 있다.

**아이디와 비밀번호 인증에 성공했다고 JWT 발급까지 자동으로 완료되는 것은 아니다.**

로그인 인증이 성공한 이후 JWT를 생성하는 코드를 별도로 작성해야 한다.

---

### 왜 successfulAuthentication()에서 JWT를 발급할까?

기존 LoginFilter는 `UsernamePasswordAuthenticationFilter`를 상속받아 구현했다.

```java
public class LoginFilter
        extends UsernamePasswordAuthenticationFilter {

}
```

`UsernamePasswordAuthenticationFilter`는 사용자 이름과 비밀번호를 이용한 인증을 처리하는 필터다.

이 필터의 상위 클래스인 `AbstractAuthenticationProcessingFilter`는 인증 결과에 따라 성공 또는 실패 처리 메서드를 실행한다.

대표적인 메서드는 다음과 같다.

```java
attemptAuthentication()
```

```java
successfulAuthentication()
```

```java
unsuccessfulAuthentication()
```

각 메서드는 다음과 같은 역할을 담당한다.

| 메서드                            | 역할       | 실행 시점  |
| ------------------------------ | -------- | ------ |
| `attemptAuthentication()`      | 인증 요청    | 로그인 시도 |
| `successfulAuthentication()`   | 인증 성공 처리 | 인증 성공  |
| `unsuccessfulAuthentication()` | 인증 실패 처리 | 인증 실패  |

전체 흐름은 다음과 같다.

```mermaid
flowchart TD
    A["POST /login"] --> B["LoginFilter"]

    B --> C["attemptAuthentication"]

    C --> D["AuthenticationManager.authenticate"]

    D --> E{"인증 결과"}

    E -->|"성공"| F["successfulAuthentication"]

    E -->|"실패"| G["unsuccessfulAuthentication"]

    F --> H["JWT 생성"]
    H --> I["Authorization 응답 헤더"]

    G --> J["HTTP 401"]
```

Spring Security의 기본 인증 처리 구조에서는 인증 성공 시 `successfulAuthentication()`이 호출되고, 이후 설정된 `AuthenticationSuccessHandler`가 성공 후처리를 담당할 수 있다.

반대로 인증 실패 시에는 `unsuccessfulAuthentication()`과 `AuthenticationFailureHandler`가 처리에 관여한다.

JWT 기반 로그인에서는 이 성공 처리 지점에서 토큰을 생성하면 된다.

```text
successfulAuthentication()
    ↓
인증된 사용자 정보 추출
    ↓
JWT 생성
    ↓
HTTP 응답에 JWT 포함
```

---

### 주요 특징

#### Authentication 객체에는 어떤 정보가 있을까?

로그인 인증에 성공하면 Spring Security는 인증된 `Authentication` 객체를 반환한다.

`Authentication`은 다음과 같은 정보를 제공한다.

| 메서드                 | 역할            |
| ------------------- | ------------- |
| `getPrincipal()`    | 인증된 사용자 정보    |
| `getCredentials()`  | 인증에 사용된 자격 증명 |
| `getAuthorities()`  | 사용자 권한        |
| `getName()`         | 사용자 식별 이름     |
| `isAuthenticated()` | 인증 성공 여부      |

예를 들어 로그인에 성공한 사용자의 정보가 다음과 같다고 생각해보자.

```text
username = user01

role = ROLE_USER
```

인증 이후 `Authentication` 객체는 개념적으로 다음과 같은 정보를 가진다.

```text
Authentication
    │
    ├── Principal
    │     └── CustomUserDetails
    │
    ├── Credentials
    │     └── 인증 이후 제거될 수 있음
    │
    ├── Authorities
    │     └── ROLE_USER
    │
    └── Authenticated
          └── true
```

이 정보를 이용하면 JWT를 발급할 수 있다.

다만 `getPrincipal()`이 언제나 `CustomUserDetails`를 반환하는 것은 아니다.

실제 Principal의 타입은 사용하는 인증 방식과 `AuthenticationProvider`의 설정에 따라 달라질 수 있다.

현재 프로젝트에서는 `CustomUserDetailsService`가 `CustomUserDetails`를 반환하도록 구현했으므로 이를 이용한다.

---

### CustomUserDetails에서 사용자 이름 가져오기

먼저 `Authentication`에서 Principal을 가져온다.

```java
Authentication authentication = ...;

Object principal =
        authentication.getPrincipal();
```

현재 프로젝트에서는 Principal이 `CustomUserDetails` 타입이다.

따라서 다음과 같이 변환할 수 있다.

```java
CustomUserDetails userDetails =
        (CustomUserDetails) authentication.getPrincipal();
```

이제 사용자 이름을 추출한다.

```java
String username =
        userDetails.getUsername();
```

예를 들어 다음과 같은 결과를 얻는다.

```text
user01
```

이는 `CustomUserDetails` 내부에 구현한 다음 메서드를 이용한다.

```java
@Override
public String getUsername() {

    return userEntity.getUsername();
}
```

즉 전체 데이터 흐름은 다음과 같다.

```text
MySQL
    ↓
UserEntity.username
    ↓
CustomUserDetails.getUsername()
    ↓
Authentication.getPrincipal()
    ↓
username
```

이렇게 추출한 사용자 이름을 JWT 생성에 사용할 수 있다.

#### Authentication.getName()을 사용하는 방법

사용자 이름만 필요한 경우에는 다음 방법도 사용할 수 있다.

```java
String username =
        authentication.getName();
```

일반적인 `UsernamePasswordAuthenticationToken`에서는 인증된 Principal의 사용자 이름을 반환할 수 있다.

따라서 현재처럼 Principal을 `CustomUserDetails`로 직접 변환하는 방법과 `authentication.getName()`을 사용하는 방법이 모두 가능하다.

| 방식                       | 장점                  | 주의 사항             |
| ------------------------ | ------------------- | ----------------- |
| CustomUserDetails 캐스팅    | 사용자 객체의 추가 정보 접근 가능 | Principal 타입에 의존  |
| Authentication.getName() | 간결하고 타입 의존성이 낮음     | 추가 사용자 정보 접근은 제한적 |

현재는 기존 `CustomUserDetails` 구현을 활용하기 위해 첫 번째 방법을 사용한다.

---

### Authentication에서 사용자 권한 가져오기

JWT에는 사용자 이름뿐 아니라 권한 정보도 포함할 수 있다.

현재 프로젝트에서는 사용자에게 하나의 역할이 부여되는 구조다.

예를 들어 다음과 같다.

```text
ROLE_USER
```

또는 다음과 같다.

```text
ROLE_ADMIN
```

Spring Security에서는 사용자 권한을 `GrantedAuthority` 객체로 표현한다.

`Authentication`에서는 다음 메서드로 권한 정보를 조회한다.

```java
authentication.getAuthorities();
```

반환 타입은 다음과 같다.

```java
Collection<? extends GrantedAuthority>
```

따라서 단순한 문자열이 아니라 권한 객체들의 컬렉션을 반환한다.

#### Iterator를 사용하는 방법

권한을 하나씩 가져오려면 Iterator를 사용할 수 있다.

```java
Collection<? extends GrantedAuthority> authorities =
        authentication.getAuthorities();

Iterator<? extends GrantedAuthority> iterator =
        authorities.iterator();

GrantedAuthority authority =
        iterator.next();

String role =
        authority.getAuthority();
```

이 코드는 컬렉션에서 첫 번째 권한을 가져온다.

다만 권한이 하나도 없다면 `next()` 호출 시 예외가 발생할 수 있다.

따라서 실제 코드에서는 빈 컬렉션 여부를 확인해야 한다.

#### Stream을 사용하는 방법

Java 17에서는 Stream을 이용해 좀 더 간결하게 작성할 수 있다.

```java
String role = authentication
        .getAuthorities()
        .stream()
        .map(GrantedAuthority::getAuthority)
        .findFirst()
        .orElseThrow(() ->
                new IllegalStateException(
                        "사용자 권한이 존재하지 않습니다."
                )
        );
```

각 메서드의 의미는 다음과 같다.

| 메서드                | 역할                        |
| ------------------ | ------------------------- |
| `getAuthorities()` | 인증된 사용자 권한 조회             |
| `stream()`         | 권한 컬렉션을 Stream으로 변환       |
| `map()`            | GrantedAuthority를 문자열로 변환 |
| `findFirst()`      | 첫 번째 권한 추출                |
| `orElseThrow()`    | 권한이 없으면 예외 발생             |

예를 들어 다음 권한을 가진 사용자라면:

```text
ROLE_ADMIN
```

최종적으로 다음 값이 반환된다.

```java
String role = "ROLE_ADMIN";
```

이 값을 JWT에 포함할 수 있다.

#### 여러 권한을 가진 사용자는 어떻게 처리할까?

현재 프로젝트에서는 사용자마다 하나의 `role`을 저장한다.

따라서 첫 번째 권한을 가져오는 구현이 적합할 수 있다.

하지만 실제 서비스에서는 사용자가 여러 권한을 가질 수 있다.

```text
ROLE_USER

ROLE_ADMIN

ORDER_READ

ORDER_WRITE
```

이런 환경에서 `findFirst()`만 사용하면 다른 권한 정보가 누락된다.

따라서 여러 권한이 필요한 시스템에서는 JWT에 권한 목록을 포함하거나, 토큰에 역할을 최소한으로 담고 서버에서 추가 권한을 확인하는 구조를 고려해야 한다.

현재 구현은 **하나의 사용자에게 하나의 역할만 부여하는 단순한 권한 모델**을 전제로 한다.

---

### JWTUtil에서 JWT 생성하기

이제 사용자 이름과 권한을 추출했다.

다음과 같은 정보가 준비된 상태다.

```text
username = user01

role = ROLE_USER
```

앞서 구현한 `JWTUtil`에는 JWT를 생성하는 메서드가 존재한다.

```java
public String createJwt(
        String username,
        String role,
        long expiredMs
)
```

각 인자는 다음과 같다.

| 인자        | 설명            |
| --------- | ------------- |
| username  | 사용자 이름        |
| role      | 사용자 권한        |
| expiredMs | JWT 유효기간(밀리초) |

이 메서드는 다음 정보를 포함한 JWT를 생성한다.

```json
{
  "username": "user01",
  "role": "ROLE_USER",
  "iat": 1790000000,
  "exp": 1790003600
}
```

위 시간 값은 Payload 구조를 설명하기 위한 예시다.

실제 발급 시각과 만료 시각은 JWT 생성 시점에 따라 달라진다.

JWT 생성 호출은 다음과 같다.

```java
String token = jwtUtil.createJwt(
        username,
        role,
        3600000L
);
```

여기서 `3600000L`은 1시간을 밀리초로 표현한 값이다.

```text
1초 = 1,000ms

1분 = 60,000ms

1시간 = 3,600,000ms
```

JWTUtil은 전달받은 사용자 정보를 Payload에 포함하고 SecretKey를 이용해 HS256 서명을 생성한다.

```text
username
    +
role
    +
발급 시간
    +
만료 시간
    ↓
JWTUtil.createJwt()
    ↓
HS256 서명 생성
    ↓
JWT 문자열
```

이제 생성된 JWT를 HTTP 응답으로 전달하면 된다.

---

### Authorization 헤더로 JWT 반환하기

HTTP 응답 헤더는 `HttpServletResponse`를 통해 설정할 수 있다.

대표적인 메서드는 다음과 같다.

```java
response.setHeader(
        String name,
        String value
);
```

첫 번째 인자는 HTTP 헤더 이름이다.

두 번째 인자는 헤더에 저장할 값이다.

이번에는 다음 헤더를 사용한다.

```http
Authorization: Bearer <ACCESS_TOKEN>
```

Java 코드에서는 다음과 같이 작성할 수 있다.

```java
response.setHeader(
        "Authorization",
        "Bearer " + token
);
```

Spring의 `HttpHeaders` 상수를 사용하면 다음과 같이 작성할 수도 있다.

```java
response.setHeader(
        HttpHeaders.AUTHORIZATION,
        "Bearer " + token
);
```

이 방식은 헤더 이름을 문자열로 직접 작성하지 않아도 된다는 장점이 있다.

#### Bearer 접두사가 필요한 이유

`Bearer`는 HTTP 인증에서 사용하는 인증 방식 중 하나다.

Bearer Token은 해당 토큰을 보유한 주체가 인증에 사용할 수 있는 형태의 토큰이다.

Authorization 헤더를 이용한 Bearer Token 전달 방식은 RFC 6750에서 정의한다.

대표적인 형태는 다음과 같다.

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

여기서 각 부분의 의미는 다음과 같다.

| 구성요소          | 의미            |
| ------------- | ------------- |
| Authorization | HTTP 인증 정보 헤더 |
| Bearer        | 인증 방식         |
| 공백            | 인증 방식과 토큰 구분  |
| JWT 문자열       | 실제 인증 토큰      |

다음과 같이 `Bearer`와 JWT 사이에 공백이 필요하다.

```text
Bearer <JWT>
```

따라서 다음과 같이 작성하면 안 된다.

```java
response.setHeader(
        "Authorization",
        "Bearer" + token
);
```

이렇게 하면 다음과 같은 값이 생성된다.

```text
BearereyJhbGciOiJIUzI1NiJ9...
```

표준적인 Bearer 인증 형식과 다르므로 클라이언트나 서버의 토큰 파싱 과정에서 문제가 발생할 수 있다.

올바른 방식은 다음과 같다.

```java
response.setHeader(
        "Authorization",
        "Bearer " + token
);
```

---

### 예제

#### 프로젝트 구성

이번 구현에서 사용하는 주요 환경은 다음과 같다.

| 항목              | 기술              |
| --------------- | --------------- |
| Java            | 17              |
| Spring Boot     | 3.2.1           |
| Spring Security | 6.2.1           |
| JWT             | JJWT 0.12.3     |
| Database        | MySQL           |
| ORM             | Spring Data JPA |
| Password Hash   | BCrypt          |
| Build Tool      | Gradle          |

기존 프로젝트에는 다음 클래스가 존재한다.

```text
src/main/java/com/example/jwt
│
├── config
│   └── SecurityConfig.java
│
├── dto
│   └── CustomUserDetails.java
│
├── service
│   └── CustomUserDetailsService.java
│
├── repository
│   └── UserRepository.java
│
└── jwt
    ├── LoginFilter.java
    └── JWTUtil.java
```

이번에는 두 클래스를 변경한다.

```text
LoginFilter.java

SecurityConfig.java
```

`JWTUtil`은 기존에 구현한 JWT 생성 기능을 그대로 사용한다.

전체 작업은 다음과 같이 진행한다.

```mermaid
flowchart TD
    A["기존 JWTUtil"] --> B["LoginFilter에 의존성 주입"]

    B --> C["SecurityConfig에서 생성자 인자 전달"]

    C --> D["successfulAuthentication 구현"]

    D --> E["Authentication에서 username 추출"]

    E --> F["Authentication에서 role 추출"]

    F --> G["JWTUtil.createJwt 호출"]

    G --> H["Authorization 헤더 설정"]

    H --> I["HTTP 200 응답"]
```

---

### LoginFilter에 JWTUtil 주입하기

먼저 기존 LoginFilter를 살펴보자.

이전에는 AuthenticationManager만 생성자로 전달받았다.

```java
public LoginFilter(
        AuthenticationManager authenticationManager
) {

    setAuthenticationManager(authenticationManager);
}
```

이제 JWT를 발급하려면 `JWTUtil`도 필요하다.

따라서 필드를 추가한다.

```java
private final JWTUtil jwtUtil;
```

그리고 생성자에 인자를 추가한다.

```java
public LoginFilter(
        AuthenticationManager authenticationManager,
        JWTUtil jwtUtil
) {

    setAuthenticationManager(authenticationManager);

    this.jwtUtil = jwtUtil;
}
```

이렇게 하면 LoginFilter에서 JWTUtil의 메서드를 사용할 수 있다.

```java
jwtUtil.createJwt(...);
```

이것이 생성자 주입 방식이다.

#### 왜 생성자 주입을 사용할까?

생성자 주입은 객체가 생성될 때 필요한 의존성을 전달하는 방식이다.

```text
SecurityConfig
    ↓
new LoginFilter(
    authenticationManager,
    jwtUtil
)
    ↓
LoginFilter
```

LoginFilter는 JWTUtil을 직접 생성하지 않는다.

대신 외부에서 전달받는다.

이 구조에는 다음과 같은 장점이 있다.

| 장점          | 설명                                  |
| ----------- | ----------------------------------- |
| 의존성 명확화     | LoginFilter가 필요한 객체를 생성자에 표현        |
| 테스트 용이성     | 테스트용 JWTUtil을 전달 가능                 |
| 객체 생성 책임 분리 | JWTUtil 생성과 사용을 분리                  |
| 코드 결합도 감소   | LoginFilter가 JWTUtil 생성 방식에 의존하지 않음 |

다만 LoginFilter를 생성하는 코드에도 새로운 인자를 추가해야 한다.

---

### SecurityConfig에서 JWTUtil 전달하기

기존 SecurityConfig에서는 다음과 같이 LoginFilter를 생성했다.

```java
LoginFilter loginFilter =
        new LoginFilter(authenticationManager);
```

그런데 LoginFilter 생성자가 다음과 같이 변경되었다.

```java
public LoginFilter(
        AuthenticationManager authenticationManager,
        JWTUtil jwtUtil
)
```

따라서 기존 생성자 호출은 더 이상 일치하지 않는다.

다음과 같이 변경해야 한다.

```java
LoginFilter loginFilter =
        new LoginFilter(
                authenticationManager,
                jwtUtil
        );
```

이때 SecurityConfig에서도 JWTUtil을 전달받을 수 있어야 한다.

Spring Bean으로 등록된 JWTUtil은 생성자 주입 또는 Bean 메서드의 매개변수 주입을 통해 사용할 수 있다.

이번에는 `SecurityFilterChain`을 생성하는 Bean 메서드에서 직접 전달받는 방식을 사용한다.

```java
@Bean
public SecurityFilterChain filterChain(
        HttpSecurity http,
        AuthenticationManager authenticationManager,
        JWTUtil jwtUtil
) throws Exception {

    LoginFilter loginFilter =
            new LoginFilter(
                    authenticationManager,
                    jwtUtil
            );

    // SecurityFilterChain 구성

    return http.build();
}
```

Spring은 Bean 메서드의 매개변수를 통해 필요한 의존성을 주입할 수 있다.

따라서 SecurityConfig에 별도의 JWTUtil 필드를 반드시 선언할 필요는 없다.

#### 클래스 생성자에서 주입받는 방법

다음과 같은 방식도 가능하다.

```java
@Configuration
public class SecurityConfig {

    private final JWTUtil jwtUtil;

    public SecurityConfig(JWTUtil jwtUtil) {

        this.jwtUtil = jwtUtil;
    }
}
```

두 방식 모두 사용할 수 있다.

| 방식                | 특징                      |
| ----------------- | ----------------------- |
| 클래스 생성자 주입        | 설정 클래스 전체에서 공유하는 의존성 표현 |
| @Bean 메서드 매개변수 주입 | 해당 Bean 생성에 필요한 의존성만 명시 |

이번에는 Bean 메서드 매개변수 주입을 사용한다.

---

### JWT 유효기간을 설정 파일에서 관리하기

JWT 생성 시 유효기간을 다음과 같이 직접 작성할 수도 있다.

```java
jwtUtil.createJwt(
        username,
        role,
        3600000L
);
```

하지만 실제 서비스에서는 유효기간을 변경해야 할 수 있다.

따라서 설정 파일에서 관리하는 편이 좋다.

`application.properties`에 다음 설정을 추가한다.

```properties
# JWT 비밀키
jwt.secret=${JWT_SECRET_BASE64}

# Access Token 만료 시간: 1시간
jwt.access-token-expiration-ms=3600000
```

현재는 JWT 유효기간을 1시간으로 설정했다.

이 값을 SecurityConfig에서 주입받는다.

```java
@Value("${jwt.access-token-expiration-ms}")
long accessTokenExpirationMs
```

이후 LoginFilter 생성자에 함께 전달한다.

```java
LoginFilter loginFilter =
        new LoginFilter(
                authenticationManager,
                jwtUtil,
                accessTokenExpirationMs
        );
```

따라서 LoginFilter 생성자는 다음과 같이 변경된다.

```java
public LoginFilter(
        AuthenticationManager authenticationManager,
        JWTUtil jwtUtil,
        long accessTokenExpirationMs
) {

    setAuthenticationManager(authenticationManager);

    this.jwtUtil = jwtUtil;

    this.accessTokenExpirationMs =
            accessTokenExpirationMs;
}
```

이렇게 하면 JWT 유효기간을 Java 코드와 분리하여 관리할 수 있다.

---

### successfulAuthentication() 구현

이제 로그인 성공 시 JWT를 발급하는 코드를 작성해보자.

`successfulAuthentication()`은 다음 매개변수를 전달받는다.

```java
@Override
protected void successfulAuthentication(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain chain,
        Authentication authentication
) throws IOException, ServletException {

}
```

각 매개변수의 역할은 다음과 같다.

| 매개변수           | 역할                   |
| -------------- | -------------------- |
| request        | 로그인 HTTP 요청          |
| response       | 클라이언트에 반환할 HTTP 응답   |
| chain          | Servlet Filter Chain |
| authentication | 인증에 성공한 사용자 정보       |

이번 구현에서는 `authentication`과 `response`가 중요하다.

`authentication`에서는 사용자 이름과 권한을 추출한다.

`response`에는 발급한 JWT를 넣는다.

#### 1. CustomUserDetails 가져오기

먼저 Principal을 가져온다.

```java
CustomUserDetails userDetails =
        (CustomUserDetails) authentication.getPrincipal();
```

현재 프로젝트에서는 `DaoAuthenticationProvider`가 반환한 인증 결과의 Principal을 `CustomUserDetails`로 사용한다.

#### 2. 사용자 이름 추출하기

다음과 같이 사용자 이름을 가져온다.

```java
String username =
        userDetails.getUsername();
```

예상 결과는 다음과 같다.

```text
user01
```

#### 3. 사용자 권한 추출하기

다음 코드를 사용한다.

```java
String role = authentication
        .getAuthorities()
        .stream()
        .map(GrantedAuthority::getAuthority)
        .findFirst()
        .orElseThrow(() ->
                new IllegalStateException(
                        "사용자 권한이 존재하지 않습니다."
                )
        );
```

예상 결과는 다음과 같다.

```text
ROLE_USER
```

#### 4. JWT 생성하기

이제 JWTUtil을 호출한다.

```java
String token = jwtUtil.createJwt(
        username,
        role,
        accessTokenExpirationMs
);
```

JWTUtil은 사용자 이름과 권한, 만료 시간을 이용해 JWT를 생성한다.

#### 5. Authorization 헤더 설정하기

JWT를 HTTP 응답 헤더에 저장한다.

```java
response.setHeader(
        HttpHeaders.AUTHORIZATION,
        "Bearer " + token
);
```

이렇게 하면 클라이언트는 다음 헤더를 전달받는다.

```http
Authorization: Bearer <ACCESS_TOKEN>
```

이것이 로그인 성공 시 JWT를 발급하는 핵심 구현이다.

---

### Spring Security 기본 성공 처리 흐름 유지하기

여기서 한 가지 더 고려해야 한다.

`successfulAuthentication()`을 재정의하고 JWT 발급 코드만 작성할 수도 있다.

하지만 이 경우 Spring Security 상위 클래스가 제공하는 기본 성공 처리 동작을 건너뛰게 된다.

상위 클래스의 기본 성공 처리에는 현재 요청의 SecurityContext 설정과 인증 성공 Handler 실행 등이 포함된다.

따라서 기존 성공 처리 구조를 유지하면서 JWT를 발급하려면 다음과 같이 작성할 수 있다.

```java
@Override
protected void successfulAuthentication(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain chain,
        Authentication authentication
) throws IOException, ServletException {

    // 1. 사용자 정보 추출
    CustomUserDetails userDetails =
            (CustomUserDetails) authentication.getPrincipal();

    String username =
            userDetails.getUsername();

    String role = authentication
            .getAuthorities()
            .stream()
            .map(GrantedAuthority::getAuthority)
            .findFirst()
            .orElseThrow();

    // 2. JWT 생성
    String token = jwtUtil.createJwt(
            username,
            role,
            accessTokenExpirationMs
    );

    // 3. Authorization 헤더 설정
    response.setHeader(
            HttpHeaders.AUTHORIZATION,
            "Bearer " + token
    );

    // 4. Spring Security 기본 성공 처리
    super.successfulAuthentication(
            request,
            response,
            chain,
            authentication
    );
}
```

다만 여기서 주의할 점이 있다.

Spring Security의 기본 `AuthenticationSuccessHandler`는 브라우저 기반 로그인에 적합한 리다이렉션을 수행할 수 있다.

따라서 REST API에서는 성공 Handler도 명시적으로 구성해야 한다.

이번에는 성공 Handler에서 HTTP 200과 JSON 응답을 반환하도록 설정한다.

```java
setAuthenticationSuccessHandler(
        (request, response, authentication) -> {

            response.setStatus(
                    HttpServletResponse.SC_OK
            );

            response.setContentType(
                    "application/json;charset=UTF-8"
            );

            response.getWriter().write(
                    "{\"message\":\"LOGIN_SUCCESS\"}"
            );
        }
);
```

이렇게 하면 로그인 성공 시 다음 순서로 동작한다.

```mermaid
flowchart TD
    A["로그인 인증 성공"] --> B["successfulAuthentication"]

    B --> C["username 추출"]
    C --> D["role 추출"]

    D --> E["JWTUtil.createJwt"]

    E --> F["Authorization 헤더 설정"]

    F --> G["super.successfulAuthentication"]

    G --> H["SecurityContext 설정"]

    H --> I["AuthenticationSuccessHandler"]

    I --> J["HTTP 200 + JSON 응답"]
```

현재 프로젝트는 Stateless 인증을 사용하므로 이 과정에서 구성된 SecurityContext를 이후 요청의 영구적인 로그인 상태로 사용하는 것은 아니다.

이후 요청에서는 JWT 인증 필터가 별도로 인증 정보를 구성해야 한다.

---

### 로그인 실패 시 HTTP 401 반환하기

로그인 인증은 항상 성공하는 것이 아니다.

예를 들어 다음과 같은 상황이 발생할 수 있다.

| 상황          | 설명                   |
| ----------- | -------------------- |
| 존재하지 않는 아이디 | MySQL에서 사용자를 찾을 수 없음 |
| 비밀번호 불일치    | BCrypt 검증 실패         |
| 계정 잠금       | 계정이 잠긴 상태            |
| 계정 비활성화     | 인증을 허용하지 않는 계정       |
| 계정 만료       | 계정 유효기간 종료           |

이런 상황에서는 `AuthenticationManager`가 `AuthenticationException` 계열 예외를 발생시킬 수 있다.

그러면 LoginFilter의 인증 실패 처리 흐름이 실행된다.

```java
@Override
protected void unsuccessfulAuthentication(
        HttpServletRequest request,
        HttpServletResponse response,
        AuthenticationException failed
) throws IOException, ServletException {

}
```

로그인 실패 응답으로는 일반적으로 HTTP 401 Unauthorized를 사용한다.

```http
HTTP/1.1 401 Unauthorized
```

Spring Security의 실패 처리 흐름을 유지하면서 REST API 응답을 반환하려면 Failure Handler를 등록할 수 있다.

```java
setAuthenticationFailureHandler(
        (request, response, exception) -> {

            response.setStatus(
                    HttpServletResponse.SC_UNAUTHORIZED
            );

            response.setContentType(
                    "application/json;charset=UTF-8"
            );

            response.getWriter().write(
                    "{\"message\":\"LOGIN_FAILED\"}"
            );
        }
);
```

이후 `unsuccessfulAuthentication()`에서는 상위 클래스의 메서드를 호출한다.

```java
@Override
protected void unsuccessfulAuthentication(
        HttpServletRequest request,
        HttpServletResponse response,
        AuthenticationException failed
) throws IOException, ServletException {

    super.unsuccessfulAuthentication(
            request,
            response,
            failed
    );
}
```

이렇게 하면 Spring Security의 기본 실패 처리 과정과 등록된 Failure Handler를 함께 사용할 수 있다.

#### 실패 사유를 그대로 반환하지 않는 이유

로그인에 실패했을 때 다음처럼 구체적인 오류를 반환하는 것은 신중해야 한다.

```text
존재하지 않는 아이디입니다.
```

```text
비밀번호가 올바르지 않습니다.
```

두 오류를 구분하면 공격자가 특정 아이디가 존재하는지 확인할 수 있기 때문이다.

따라서 외부 응답에서는 일반적인 인증 실패 메시지를 사용할 수 있다.

```json
{
  "message": "LOGIN_FAILED"
}
```

서버 내부에서는 장애 분석과 보안 모니터링에 필요한 범위에서 실패 원인을 구분할 수 있다.

---

### LoginFilter 전체 코드

이제 지금까지의 내용을 하나로 합쳐보자.

이번 LoginFilter는 다음 기능을 수행한다.

1. POST `/login` 요청 처리
2. 사용자 이름과 비밀번호 추출
3. AuthenticationManager 호출
4. 인증 성공 시 사용자 정보 추출
5. JWTUtil을 이용한 JWT 발급
6. Authorization 응답 헤더 설정
7. 로그인 성공 시 HTTP 200 반환
8. 로그인 실패 시 HTTP 401 반환

다음은 전체 코드다.

```java
package com.example.jwt.jwt;

import com.example.jwt.dto.CustomUserDetails;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.http.HttpHeaders;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationServiceException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.GrantedAuthority;

import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import java.io.IOException;

public class LoginFilter
        extends UsernamePasswordAuthenticationFilter {

    private final JWTUtil jwtUtil;

    private final long accessTokenExpirationMs;

    public LoginFilter(
            AuthenticationManager authenticationManager,
            JWTUtil jwtUtil,
            long accessTokenExpirationMs
    ) {

        super();

        // AuthenticationManager 등록
        setAuthenticationManager(authenticationManager);

        // JWT 생성 유틸리티 주입
        this.jwtUtil = jwtUtil;

        // Access Token 유효기간
        this.accessTokenExpirationMs =
                accessTokenExpirationMs;

        // 로그인 요청 URL
        setFilterProcessesUrl("/login");

        // 로그인 성공 응답
        setAuthenticationSuccessHandler(
                (request, response, authentication) -> {

                    response.setStatus(
                            HttpServletResponse.SC_OK
                    );

                    response.setContentType(
                            "application/json;charset=UTF-8"
                    );

                    response.getWriter().write(
                            "{\"message\":\"LOGIN_SUCCESS\"}"
                    );
                }
        );

        // 로그인 실패 응답
        setAuthenticationFailureHandler(
                (request, response, exception) -> {

                    response.setStatus(
                            HttpServletResponse.SC_UNAUTHORIZED
                    );

                    response.setContentType(
                            "application/json;charset=UTF-8"
                    );

                    response.getWriter().write(
                            "{\"message\":\"LOGIN_FAILED\"}"
                    );
                }
        );
    }

    /**
     * 로그인 인증 시도
     */
    @Override
    public Authentication attemptAuthentication(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws AuthenticationException {

        // 1. POST 요청 확인
        if (!"POST".equals(request.getMethod())) {

            throw new AuthenticationServiceException(
                    "지원하지 않는 인증 요청 방식입니다."
            );
        }

        // 2. 사용자 이름과 비밀번호 추출
        String username = obtainUsername(request);

        String password = obtainPassword(request);

        // 3. null 처리
        username = username == null
                ? ""
                : username.trim();

        password = password == null
                ? ""
                : password;

        // 4. 인증 요청 객체 생성
        UsernamePasswordAuthenticationToken authenticationToken =
                UsernamePasswordAuthenticationToken.unauthenticated(
                        username,
                        password
                );

        // 5. 요청 부가 정보 설정
        setDetails(
                request,
                authenticationToken
        );

        // 6. AuthenticationManager 인증 요청
        return getAuthenticationManager().authenticate(
                authenticationToken
        );
    }

    /**
     * 로그인 인증 성공
     */
    @Override
    protected void successfulAuthentication(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain chain,
            Authentication authentication
    ) throws IOException, ServletException {

        // 1. Principal 타입 확인
        if (!(authentication.getPrincipal()
                instanceof CustomUserDetails userDetails)) {

            throw new IllegalStateException(
                    "지원하지 않는 Principal 타입입니다."
            );
        }

        // 2. 사용자 이름 추출
        String username =
                userDetails.getUsername();

        // 3. 인증된 사용자 권한 추출
        String role = authentication
                .getAuthorities()
                .stream()
                .map(GrantedAuthority::getAuthority)
                .findFirst()
                .orElseThrow(() ->
                        new IllegalStateException(
                                "사용자 권한이 존재하지 않습니다."
                        )
                );

        // 4. JWT 생성
        String token = jwtUtil.createJwt(
                username,
                role,
                accessTokenExpirationMs
        );

        // 5. Authorization 응답 헤더 설정
        response.setHeader(
                HttpHeaders.AUTHORIZATION,
                "Bearer " + token
        );

        // 6. 토큰 포함 응답의 캐싱 방지
        response.setHeader(
                HttpHeaders.CACHE_CONTROL,
                "no-store"
        );

        response.setHeader(
                HttpHeaders.PRAGMA,
                "no-cache"
        );

        // 7. Spring Security 기본 성공 처리
        super.successfulAuthentication(
                request,
                response,
                chain,
                authentication
        );
    }

    /**
     * 로그인 인증 실패
     */
    @Override
    protected void unsuccessfulAuthentication(
            HttpServletRequest request,
            HttpServletResponse response,
            AuthenticationException failed
    ) throws IOException, ServletException {

        // Spring Security 기본 실패 처리
        super.unsuccessfulAuthentication(
                request,
                response,
                failed
        );
    }
}
```

이 코드에서 핵심은 다음 부분이다.

```java
String token = jwtUtil.createJwt(
        username,
        role,
        accessTokenExpirationMs
);
```

로그인 인증에 성공한 사용자 정보로 JWT를 생성한다.

그리고 다음 코드로 응답 헤더에 포함한다.

```java
response.setHeader(
        HttpHeaders.AUTHORIZATION,
        "Bearer " + token
);
```

이렇게 하면 로그인 성공 시 JWT가 발급된다.

#### JWT 생성이 실패하면 어떻게 될까?

이번 구현에서는 `JWTUtil.createJwt()`가 정상적으로 JWT를 반환해야 성공 응답이 진행된다.

만약 SecretKey 설정이나 JWT 생성 과정에서 예외가 발생한다면 `super.successfulAuthentication()`까지 도달하지 못할 수 있다.

이 경우 JWT 발급 실패를 단순한 로그인 비밀번호 오류로 처리해서는 안 된다.

사용자 인증 자체는 성공했지만 토큰 발급 과정에서 시스템 오류가 발생한 상황이기 때문이다.

실제 서비스에서는 이러한 오류를 별도로 기록하고, 클라이언트에 내부 비밀키 정보나 상세한 예외 메시지를 노출하지 않도록 처리해야 한다.

---

### SecurityConfig 전체 코드

이제 변경된 LoginFilter를 SecurityFilterChain에 등록한다.

기존 프로젝트에는 다음 설정이 존재한다고 가정한다.

```java
@Bean
public AuthenticationManager authenticationManager(
        AuthenticationConfiguration authenticationConfiguration
) throws Exception {

    return authenticationConfiguration.getAuthenticationManager();
}
```

또한 `CustomUserDetailsService`와 `PasswordEncoder`가 Spring Security 인증 구성에 정상적으로 연결되어 있어야 한다.

현재 프로젝트에서는 하나의 UserDetailsService와 PasswordEncoder를 사용하는 구조를 전제로 한다.

SecurityConfig의 전체 코드는 다음과 같다.

```java
package com.example.jwt.config;

import com.example.jwt.jwt.JWTUtil;
import com.example.jwt.jwt.LoginFilter;

import jakarta.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Value;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

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

                        // 로그인 및 회원가입 허용
                        .requestMatchers(
                                "/login",
                                "/join"
                        ).permitAll()

                        // 관리자 API
                        .requestMatchers(
                                "/admin",
                                "/admin/**"
                        ).hasRole("ADMIN")

                        // 나머지 API
                        .anyRequest().authenticated()
                )

                // 미인증 및 접근 거부 처리
                .exceptionHandling(exception -> exception

                        .authenticationEntryPoint(
                                (request, response, authException) ->
                                        response.sendError(
                                                HttpServletResponse.SC_UNAUTHORIZED
                                        )
                        )

                        .accessDeniedHandler(
                                (request, response, accessDeniedException) ->
                                        response.sendError(
                                                HttpServletResponse.SC_FORBIDDEN
                                        )
                        )
                )

                // 커스텀 로그인 필터 등록
                .addFilterAt(
                        loginFilter,
                        UsernamePasswordAuthenticationFilter.class
                );

        return http.build();
    }

    /**
     * BCrypt PasswordEncoder
     */
    @Bean
    public PasswordEncoder passwordEncoder() {

        return new BCryptPasswordEncoder();
    }
}
```

이렇게 하면 다음 세 가지 구성요소가 연결된다.

```text
SecurityConfig
    │
    ├── AuthenticationManager
    │
    ├── JWTUtil
    │
    └── LoginFilter
          │
          ├── 인증 요청
          │
          └── JWT 발급
```

#### addFilterAt()의 역할

다음 코드를 살펴보자.

```java
.addFilterAt(
        loginFilter,
        UsernamePasswordAuthenticationFilter.class
)
```

이 설정은 LoginFilter를 Spring Security의 사용자 이름·비밀번호 인증 필터에 해당하는 위치에 배치한다.

`addFilterAt()`은 기존 필터를 반드시 찾아 제거하는 메서드로 이해해서는 안 된다.

지정된 필터의 순서 위치에 새로운 필터를 추가하는 기능이다.

현재 프로젝트에서는 기본 Form Login을 비활성화했기 때문에 커스텀 LoginFilter를 해당 위치에 등록한다.

만약 기본 로그인 필터와 커스텀 로그인 필터가 함께 존재한다면 중복 처리 문제가 발생할 수 있으므로 주의해야 한다.

---

### JWTUtil 구현 확인

LoginFilter에서 사용하는 JWT 생성 메서드는 다음과 같다.

```java
jwtUtil.createJwt(
        username,
        role,
        accessTokenExpirationMs
);
```

따라서 JWTUtil에는 해당 메서드가 존재해야 한다.

앞에서 구현한 JWTUtil의 주요 기능을 다시 정리하면 다음과 같다.

```java
package com.example.jwt.jwt;

import io.jsonwebtoken.Claims;
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

    public JWTUtil(
            @Value("${jwt.secret}") String secret
    ) {

        byte[] keyBytes =
                Decoders.BASE64.decode(secret);

        this.secretKey =
                Keys.hmacShaKeyFor(keyBytes);
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
     * JWT 사용자 이름 추출
     */
    public String getUsername(String token) {

        Claims claims = Jwts.parser()
                .verifyWith(secretKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();

        return claims.get(
                "username",
                String.class
        );
    }

    /**
     * JWT 사용자 권한 추출
     */
    public String getRole(String token) {

        Claims claims = Jwts.parser()
                .verifyWith(secretKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();

        return claims.get(
                "role",
                String.class
        );
    }
}
```

이 코드는 JJWT 0.12.3을 기준으로 작성했다.

`Jwts.builder()`를 이용해 JWT를 생성하고, `signWith()`로 HS256 서명을 추가한다.

그리고 `compact()`를 호출하여 JWT 문자열을 반환한다.

JWT를 검증할 때는 `verifyWith()`와 `parseSignedClaims()`를 이용한다.

현재 핵심 구현은 JWT 발급이지만, 이후 JWT 인증 필터에서 동일한 JWTUtil을 이용해 토큰을 검증할 수 있다.

---

### application.properties 전체 설정

JWTUtil을 사용하려면 비밀키와 만료 시간 설정이 필요하다.

다음과 같이 작성한다.

```properties
# Application
spring.application.name=jwt
server.port=8080

# MySQL
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.url=${DB_URL:jdbc:mysql://localhost:3306/jwt_db}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}

# JPA
spring.jpa.hibernate.ddl-auto=none
spring.jpa.open-in-view=false

# JWT
jwt.secret=${JWT_SECRET_BASE64}
jwt.access-token-expiration-ms=3600000
```

여기서 실제 SecretKey는 환경변수로 전달받는다.

로컬 개발 환경에서는 다음 명령으로 생성할 수 있다.

```bash
export JWT_SECRET_BASE64="$(openssl rand -base64 32)"
```

이 명령은 32바이트의 무작위 키를 생성하고 Base64로 인코딩하여 환경변수에 저장한다.

HS256은 최소 256비트의 키가 필요하므로 충분한 길이와 무작위성을 가진 키를 사용해야 한다.

운영 환경에서는 실행할 때마다 키를 새로 생성하지 않고 안전하게 관리되는 기존 키를 불러오도록 구성해야 한다.

---

### 실행 및 확인

#### MySQL 사용자 정보 확인

먼저 데이터베이스에 사용자가 존재하는지 확인한다.

```sql
SELECT
    id,
    username,
    role
FROM users;
```

예를 들어 다음과 같은 결과가 있다고 생각해보자.

```text
+----+----------+-----------+
| id | username | role      |
+----+----------+-----------+
|  1 | user01   | ROLE_USER |
|  2 | admin01  | ROLE_ADMIN|
+----+----------+-----------+
```

이 사용자는 기존 회원가입 기능을 통해 등록된 사용자라고 가정한다.

비밀번호는 BCrypt 해시 형태로 저장되어 있어야 한다.

#### Spring Boot 실행

다음 명령을 실행한다.

```bash
./gradlew bootRun
```

정상적으로 실행되었다면 다음과 유사한 로그가 출력된다.

```text
Tomcat started on port 8080 (http)

Started JwtApplication
```

이제 실제 로그인 요청을 전송할 수 있다.

---

### Postman으로 로그인 테스트하기

Postman에서 새로운 요청을 생성한다.

HTTP 메서드는 POST로 지정한다.

```http
POST http://localhost:8080/login
```

Body에서는 `x-www-form-urlencoded`를 선택한다.

다음 값을 설정한다.

| Key      | Value        |
| -------- | ------------ |
| username | user01       |
| password | password123! |

`Send`를 실행한다.

정상적으로 인증에 성공하면 다음 응답을 받을 수 있다.

```http
HTTP/1.1 200 OK
Authorization: Bearer <ACCESS_TOKEN>
Cache-Control: no-store
Pragma: no-cache
Content-Type: application/json;charset=UTF-8

{
  "message": "LOGIN_SUCCESS"
}
```

이 응답에서 가장 중요한 부분은 다음 헤더다.

```http
Authorization: Bearer <ACCESS_TOKEN>
```

여기에는 실제 JWT 문자열이 들어간다.

JWT는 일반적으로 다음과 같은 구조를 가진다.

```text
Header.Payload.Signature
```

각 부분은 마침표로 구분된다.

정상적으로 JWT가 발급되었다면 Header와 Payload, Signature를 포함한 문자열을 확인할 수 있다.

---

### curl로 로그인 요청 보내기

Postman을 사용하지 않더라도 curl을 이용해 로그인할 수 있다.

다음 명령을 실행한다.

```bash
curl -i -X POST \
  http://localhost:8080/login \
  --data-urlencode "username=user01" \
  --data-urlencode "password=password123!"
```

각 옵션의 의미는 다음과 같다.

| 옵션                 | 의미                |
| ------------------ | ----------------- |
| `-i`               | HTTP 응답 헤더 출력     |
| `-X POST`          | POST 방식으로 요청      |
| `--data-urlencode` | 데이터를 URL 인코딩하여 전송 |

정상적으로 인증에 성공하면 다음과 유사한 결과를 확인할 수 있다.

```http
HTTP/1.1 200 OK
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
Cache-Control: no-store
Pragma: no-cache

{"message":"LOGIN_SUCCESS"}
```

위 JWT 문자열은 출력 형태를 설명하기 위한 예시다.

실제 토큰은 사용자의 정보와 발급 시각, 서명 키 등에 따라 달라진다.

#### 실제 JWT 확인하기

JWTUtil의 `getUsername()` 메서드를 이용하면 발급된 토큰에서 사용자 이름을 확인할 수 있다.

```java
String username =
        jwtUtil.getUsername(token);
```

예상 결과는 다음과 같다.

```text
user01
```

권한 역시 확인할 수 있다.

```java
String role =
        jwtUtil.getRole(token);
```

예상 결과는 다음과 같다.

```text
ROLE_USER
```

이 과정에서 JWTUtil은 서명을 검증하고 Claims를 추출한다.

따라서 발급한 JWT에 의도한 사용자 이름과 권한이 포함되었는지 확인할 수 있다.

---

### 잘못된 비밀번호로 로그인하기

이번에는 비밀번호를 잘못 입력해보자.

```bash
curl -i -X POST \
  http://localhost:8080/login \
  --data-urlencode "username=user01" \
  --data-urlencode "password=wrong-password"
```

이 요청에서는 사용자 이름은 일치하지만 비밀번호가 다르다.

따라서 인증 과정에서 다음 흐름이 발생한다.

```text
POST /login
    ↓
LoginFilter
    ↓
AuthenticationManager
    ↓
CustomUserDetailsService
    ↓
MySQL
    ↓
PasswordEncoder.matches()
    ↓
비밀번호 불일치
    ↓
AuthenticationException
    ↓
unsuccessfulAuthentication()
    ↓
HTTP 401
```

응답은 다음과 같다.

```http
HTTP/1.1 401 Unauthorized
Content-Type: application/json;charset=UTF-8

{
  "message": "LOGIN_FAILED"
}
```

로그인에 실패했으므로 JWT를 발급하지 않는다.

따라서 정상적인 Authorization 응답 헤더도 생성되지 않는다.

---

### 로그인 성공과 실패의 차이

전체 흐름을 비교하면 다음과 같다.

| 항목               | 로그인 성공                   | 로그인 실패                     |
| ---------------- | ------------------------ | -------------------------- |
| 사용자 조회           | 성공                       | 실패하거나 성공                   |
| 비밀번호 검증          | 성공                       | 실패 가능                      |
| Authentication   | 인증된 결과 반환                | 인증 예외                      |
| 실행 메서드           | successfulAuthentication | unsuccessfulAuthentication |
| JWT 생성           | 수행                       | 수행하지 않음                    |
| Authorization 헤더 | JWT 포함                   | 없음                         |
| HTTP 응답          | 200 OK                   | 401 Unauthorized           |

핵심은 JWT 발급 시점이다.

**JWT는 사용자의 인증이 완료된 이후에만 생성해야 한다.**

사용자가 요청한 username과 role을 그대로 사용해 JWT를 발급해서는 안 된다.

반드시 인증된 `Authentication`에서 정보를 가져와야 한다.

---

### 구조

#### 로그인부터 JWT 발급까지의 전체 흐름

지금까지 구현한 내용을 하나로 정리해보자.

```mermaid
flowchart TD
    A["Client"] -->|"POST /login"| B["LoginFilter"]

    B --> C["attemptAuthentication"]

    C --> D["username / password 추출"]

    D --> E["UsernamePasswordAuthenticationToken"]

    E --> F["AuthenticationManager"]

    F --> G["DaoAuthenticationProvider"]

    G --> H["CustomUserDetailsService"]

    H --> I["UserRepository"]

    I --> J[("MySQL")]

    J --> I
    I --> H
    H --> K["CustomUserDetails"]

    K --> G

    G --> L["PasswordEncoder.matches"]

    L --> M{"인증 성공?"}

    M -->|"No"| N["unsuccessfulAuthentication"]

    N --> O["HTTP 401"]

    M -->|"Yes"| P["successfulAuthentication"]

    P --> Q["Authentication.getPrincipal"]

    Q --> R["username 추출"]

    R --> S["GrantedAuthority 조회"]

    S --> T["role 추출"]

    T --> U["JWTUtil.createJwt"]

    U --> V["HS256 서명"]

    V --> W["JWT 생성"]

    W --> X["Authorization: Bearer JWT"]

    X --> Y["HTTP 200"]
```

여기서 가장 중요한 책임 분리는 다음과 같다.

**LoginFilter**

사용자의 로그인 요청과 인증 결과를 처리한다.

**AuthenticationManager**

인증 요청을 적절한 AuthenticationProvider에 전달한다.

**DaoAuthenticationProvider**

데이터베이스에서 조회한 사용자 정보와 입력한 비밀번호를 검증한다.

**CustomUserDetails**

인증된 사용자 이름과 권한 정보를 제공한다.

**JWTUtil**

검증된 사용자 정보를 이용해 JWT를 생성한다.

**HttpServletResponse**

생성된 JWT를 클라이언트에 전달한다.

이렇게 각 구성요소가 서로 다른 책임을 담당하도록 구현하면 인증 로직과 토큰 생성 로직을 분리할 수 있다.

---

### 로그인 성공 시 SecurityContext는 어떻게 처리될까?

여기서 자주 혼동하는 부분이 있다.

현재 SecurityConfig에는 다음 설정이 존재한다.

```java
.sessionManagement(session -> session
        .sessionCreationPolicy(
                SessionCreationPolicy.STATELESS
        )
)
```

이 설정은 Spring Security가 인증 상태를 유지하기 위한 HttpSession을 생성하거나 사용하지 않도록 구성한다.

그런데 로그인에 성공하면 `successfulAuthentication()`에서 `SecurityContext`에 인증 정보를 설정할 수 있다.

그렇다면 Stateless가 아닌 것일까?

그렇지 않다.

**SecurityContext와 HttpSession은 서로 다른 개념이다.**

SecurityContext는 현재 보안 처리 과정에서 사용하는 인증 정보를 담는 객체다.

반면 HttpSession은 여러 HTTP 요청에 걸쳐 상태를 유지하는 데 사용할 수 있는 서버 측 세션이다.

Stateless 인증에서도 현재 요청을 처리하는 동안 SecurityContext를 사용할 수 있다.

```text
POST /login
    ↓
인증 성공
    ↓
SecurityContext에 Authentication 설정
    ↓
JWT 발급
    ↓
HTTP 응답 종료
```

하지만 이 인증 정보가 다음 요청까지 서버 세션으로 유지되는 것은 아니다.

다음 요청에서는 다시 JWT를 검증해야 한다.

```text
GET /admin
    ↓
Authorization 헤더
    ↓
JWT 검증
    ↓
Authentication 구성
    ↓
SecurityContext 설정
    ↓
인가 처리
```

따라서 **JWT 발급과 JWT 검증 필터는 서로 다른 역할**을 담당한다.

이번에는 로그인 성공 시 JWT를 발급하는 기능까지 구현했다.

이후 JWT를 전달받아 사용자 인증을 구성하는 기능은 별도로 필요하다.

---

### 발급한 JWT로 바로 관리자 API에 접근할 수 있을까?

현재 구현 단계에서 반드시 이해해야 할 부분이다.

로그인에 성공하면 다음 헤더를 전달받는다.

```http
Authorization: Bearer <ACCESS_TOKEN>
```

이 JWT를 복사하여 다음 요청에 포함했다고 생각해보자.

```http
GET /admin HTTP/1.1
Host: localhost:8080
Authorization: Bearer <ACCESS_TOKEN>
```

하지만 아직 JWT 인증 필터를 구현하지 않았다면 Spring Security는 이 토큰을 이용해 자동으로 사용자를 인증하지 않는다.

즉 JWT를 발급하는 기능과 검증하는 기능은 별개다.

```text
로그인 성공
    ↓
JWT 발급
    ↓
클라이언트가 토큰 보관
```

여기까지 구현했다고 다음 기능이 자동으로 완성되는 것은 아니다.

```text
JWT 수신
    ↓
서명 검증
    ↓
만료 시간 검증
    ↓
username / role 추출
    ↓
Authentication 생성
    ↓
SecurityContextHolder 등록
```

따라서 지금은 로그인 성공 후 JWT가 발급되는지 확인하는 것이 핵심이다.

발급된 JWT로 보호된 API에 접근하려면 JWT 인증 필터가 추가되어야 한다.

---

### 로그인 성공 시 JWTUtil의 getUsername()을 다시 호출해야 할까?

로그인 성공 시 JWTUtil을 이용해 토큰을 생성한다.

```java
String token = jwtUtil.createJwt(
        username,
        role,
        accessTokenExpirationMs
);
```

그런데 JWT를 생성한 직후 다음 코드를 다시 실행해야 할까?

```java
jwtUtil.getUsername(token);
```

일반적으로 필요하지 않다.

이미 인증된 `Authentication`에서 사용자 정보를 가져왔기 때문이다.

```text
Authentication
    ↓
username
    ↓
role
    ↓
JWT 생성
```

따라서 로그인 성공 처리에서는 JWT를 생성하고 응답하는 것으로 충분하다.

반면 이후 클라이언트가 JWT를 전달한 요청에서는 JWT를 검증하고 Claims를 추출해야 한다.

```text
클라이언트가 JWT 전달
    ↓
JWT 서명 검증
    ↓
Claims 추출
    ↓
username / role 확인
```

이 차이를 구분하면 JWT의 발급 로직과 검증 로직을 명확하게 설계할 수 있다.

---

### 실무에서의 활용

#### 1. JWT 발급에는 인증된 사용자 정보만 사용한다

JWT에 포함할 사용자 이름과 권한은 반드시 인증된 `Authentication`에서 가져와야 한다.

다음과 같이 클라이언트가 전달한 권한을 신뢰해서는 안 된다.

```text
role = ROLE_ADMIN
```

사용자가 직접 관리자 권한을 요청했다고 해서 해당 권한을 JWT에 포함하면 권한 상승 취약점이 발생할 수 있다.

따라서 다음 구조를 유지해야 한다.

```text
AuthenticationManager
    ↓
인증 성공
    ↓
Authentication.getAuthorities()
    ↓
검증된 권한
    ↓
JWT 발급
```

#### 2. JWT는 로그인 성공 후에만 발급한다

아이디와 비밀번호 검증이 완료되기 전에 JWT를 생성해서는 안 된다.

JWT 발급은 인증 성공에 종속되는 작업이다.

따라서 JWT 생성 메서드 호출 위치는 로그인 인증이 성공한 이후여야 한다.

#### 3. Authentication의 Principal 타입을 확인한다

현재 프로젝트에서는 Principal이 `CustomUserDetails` 타입이다.

```java
CustomUserDetails userDetails =
        (CustomUserDetails) authentication.getPrincipal();
```

하지만 다른 인증 방식을 추가하면 Principal 타입이 변경될 수 있다.

따라서 실무에서는 `instanceof`를 이용해 타입을 확인하거나 `authentication.getName()`을 활용하는 방식도 고려해야 한다.

#### 4. 여러 권한이 존재한다면 첫 번째 권한만 사용하지 않는다

현재 프로젝트에서는 하나의 역할만 저장한다.

하지만 실제 서비스에서는 여러 권한이 존재할 수 있다.

```text
ROLE_USER
ORDER_READ
ORDER_WRITE
```

이 경우 다음 코드는 일부 권한만 가져온다.

```java
authentication.getAuthorities()
        .stream()
        .findFirst();
```

따라서 권한 모델이 확장된다면 JWT Claim 구조도 함께 변경해야 한다.

#### 5. JWT 유효기간은 설정으로 관리한다

JWT 유효기간을 Java 코드에 직접 작성하면 변경할 때마다 코드 수정이 필요하다.

따라서 다음과 같이 외부 설정으로 분리할 수 있다.

```properties
jwt.access-token-expiration-ms=3600000
```

이렇게 하면 환경별로 서로 다른 유효기간 정책을 적용하기 쉽다.

단, 설정 변경이 기존에 발급된 JWT의 만료 시간을 변경하는 것은 아니다.

이미 발급된 JWT에는 발급 당시의 만료 시간이 포함되어 있다.

#### 6. Authorization 헤더에 Bearer 접두사를 포함한다

JWT를 전달할 때는 다음 형식을 사용한다.

```http
Authorization: Bearer <ACCESS_TOKEN>
```

Bearer와 실제 토큰 문자열은 공백으로 구분한다.

이 형식은 HTTP Bearer Token 사용 방식에 해당한다.

#### 7. JWT가 포함된 응답의 캐싱을 제한한다

로그인 응답에는 인증에 사용할 수 있는 민감한 토큰이 포함된다.

따라서 응답이 불필요하게 캐시되지 않도록 다음 헤더를 설정할 수 있다.

```java
response.setHeader(
        "Cache-Control",
        "no-store"
);
```

```java
response.setHeader(
        "Pragma",
        "no-cache"
);
```

이는 토큰이 HTTP 캐시에 저장되는 위험을 줄이는 데 도움이 된다.

다만 응답 캐시 제어만으로 모든 형태의 토큰 저장이나 유출을 방지할 수 있는 것은 아니다.

#### 8. 브라우저에서 Authorization 응답 헤더가 보이지 않을 수 있다

Postman에서는 응답 헤더를 쉽게 확인할 수 있다.

하지만 프론트엔드가 다른 Origin에서 실행되는 경우에는 상황이 다르다.

예를 들어 다음과 같은 구조를 생각해보자.

```text
Frontend
http://localhost:3000
```

```text
Backend
http://localhost:8080
```

두 주소는 Origin이 서로 다르다.

따라서 브라우저에서는 CORS 정책이 적용된다.

특히 JavaScript에서 응답의 Authorization 헤더를 읽으려면 해당 헤더를 노출하도록 설정해야 할 수 있다.

이때 사용하는 응답 헤더가 다음과 같다.

```http
Access-Control-Expose-Headers: Authorization
```

`Access-Control-Expose-Headers`는 교차 출처 요청에서 브라우저 JavaScript가 접근할 수 있는 응답 헤더를 지정하는 역할을 한다.

Spring Security에서 CORS를 사용한다면 다음과 같은 설정을 구성할 수 있다.

```java
@Bean
public CorsConfigurationSource corsConfigurationSource() {

    CorsConfiguration configuration =
            new CorsConfiguration();

    configuration.setAllowedOrigins(
            List.of("http://localhost:3000")
    );

    configuration.setAllowedMethods(
            List.of(
                    "GET",
                    "POST",
                    "PUT",
                    "DELETE",
                    "OPTIONS"
            )
    );

    configuration.setAllowedHeaders(
            List.of(
                    "Authorization",
                    "Content-Type"
            )
    );

    configuration.setExposedHeaders(
            List.of("Authorization")
    );

    UrlBasedCorsConfigurationSource source =
            new UrlBasedCorsConfigurationSource();

    source.registerCorsConfiguration(
            "/**",
            configuration
    );

    return source;
}
```

필요한 import는 다음과 같다.

```java
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;
```

그리고 SecurityFilterChain에서 CORS를 활성화한다.

```java
.cors(Customizer.withDefaults())
```

필요한 import는 다음과 같다.

```java
import org.springframework.security.config.Customizer;
```

이 설정은 `http://localhost:3000`에서 실행하는 프론트엔드가 API 서버에 접근하는 개발 환경을 가정한 예시다.

운영 환경에서는 실제 허용할 Origin을 명확하게 지정해야 한다.

또한 `Access-Control-Expose-Headers`와 `Access-Control-Allow-Headers`는 서로 다른 역할을 가진다.

| 설정                            | 역할                                 |
| ----------------------------- | ---------------------------------- |
| Access-Control-Allow-Headers  | 클라이언트가 요청에 포함할 수 있는 헤더 허용          |
| Access-Control-Expose-Headers | 클라이언트 JavaScript가 읽을 수 있는 응답 헤더 지정 |

이 두 개념을 혼동하지 않아야 한다.

#### 9. JWT를 URL 파라미터로 전달하지 않는다

JWT는 Bearer Token이다.

토큰을 가진 주체가 사용할 수 있기 때문에 유출에 주의해야 한다.

따라서 다음과 같은 요청은 피하는 것이 좋다.

```http
GET /admin?token=<ACCESS_TOKEN>
```

URL에 포함된 토큰은 브라우저 기록이나 서버 로그 등에 남을 수 있다.

일반적인 API 요청에서는 Authorization 헤더를 이용하는 방식이 적절하다.

#### 10. HTTPS를 사용한다

JWT 자체에 서명이 포함되어 있다고 해서 네트워크 구간이 암호화되는 것은 아니다.

JWT는 전송 중 탈취될 수 있다.

따라서 실제 서비스에서는 HTTPS를 사용하여 로그인 요청과 JWT 전달 구간을 보호해야 한다.

특히 로그인 요청에는 사용자의 원문 비밀번호가 포함될 수 있으므로 HTTPS가 중요하다.

#### 11. 로그인 실패와 JWT 발급 실패를 구분한다

아이디와 비밀번호가 일치하지 않는 경우와 JWT 생성 도중 오류가 발생한 경우는 다르다.

```text
비밀번호 불일치
    ↓
인증 실패
    ↓
HTTP 401
```

```text
사용자 인증 성공
    ↓
JWT 생성 오류
    ↓
서버 내부 오류
```

이러한 오류를 모두 HTTP 401로 처리하면 실제 장애 원인을 파악하기 어려워진다.

따라서 인증 실패와 토큰 발급 실패는 별도로 모니터링하는 것이 좋다.

#### 12. JWT 원문을 로그에 출력하지 않는다

다음과 같은 로그는 피해야 한다.

```java
log.info("JWT = {}", token);
```

JWT가 로그 시스템에 저장되면 해당 로그를 조회할 수 있는 사용자가 토큰을 획득할 수 있다.

따라서 JWT 원문은 일반적인 애플리케이션 로그에 기록하지 않는 것이 좋다.

#### 13. 로그인 성공했다고 이후 모든 API가 인증되는 것은 아니다

JWT 발급과 JWT 검증은 서로 다른 단계다.

이번 구현은 다음 기능을 완성한다.

```text
로그인 성공
    ↓
JWT 발급
```

하지만 다음 기능은 별도로 구현해야 한다.

```text
JWT 수신
    ↓
JWT 검증
    ↓
Authentication 생성
    ↓
SecurityContext 설정
```

따라서 JWT 검증 필터가 없다면 보호된 API에서 인증 정보를 사용할 수 없다.

#### 14. JWT에 포함된 권한이 오래된 정보가 될 수 있다

JWT 발급 당시 사용자가 관리자였다고 생각해보자.

```text
ROLE_ADMIN
```

이후 관리자가 해당 사용자의 권한을 회수했다.

하지만 이미 발급된 JWT에는 기존 권한이 남아 있을 수 있다.

따라서 권한 변경을 즉시 반영해야 하는 서비스에서는 추가적인 권한 확인이나 토큰 무효화 정책이 필요할 수 있다.

#### 15. Access Token과 Refresh Token은 목적이 다르다

현재 프로젝트에서는 Access Token 하나만 발급한다.

Access Token은 보호된 API에 접근하기 위한 토큰이다.

반면 Refresh Token은 일반적으로 새로운 Access Token을 발급받기 위한 자격 증명으로 사용한다.

두 토큰을 사용하면 사용자 경험과 보안 정책을 더 세밀하게 설계할 수 있다.

다만 Refresh Token은 별도의 저장·회전·폐기·재사용 탐지 등의 정책이 필요할 수 있으므로 단순히 토큰 하나를 추가하는 문제로 이해해서는 안 된다.

#### 16. JWT를 여러 서버에서 발급한다면 SecretKey를 일관되게 관리한다

서버가 여러 대인 환경을 생각해보자.

```text
Load Balancer
    ├── Application A
    ├── Application B
    └── Application C
```

Application A에서 발급한 JWT를 Application B에서도 검증해야 할 수 있다.

HS256을 사용한다면 서명과 검증에 동일한 SecretKey가 필요하다.

서버마다 서로 다른 SecretKey를 사용하면 정상적인 JWT도 검증에 실패할 수 있다.

따라서 분산 환경에서는 서명 키 관리 정책을 명확하게 구성해야 한다.

---

### 테스트 코드 작성

JWT 발급은 로그인 성공 처리의 핵심 기능이므로 자동화 테스트로 검증하는 것이 좋다.

이번에는 다음 기능을 확인한다.

| 테스트              | 기대 결과               |
| ---------------- | ------------------- |
| 로그인 성공           | HTTP 200            |
| 로그인 성공           | Authorization 헤더 존재 |
| Authorization 헤더 | Bearer 접두사 포함       |
| 발급한 JWT          | 사용자 이름 일치           |
| 발급한 JWT          | 권한 일치               |
| 로그인 실패           | HTTP 401            |
| 로그인 실패           | JWT 미발급             |

#### LoginFilterTest 전체 코드

다음은 Mockito와 Spring Mock 객체를 이용한 테스트다.

```java
package com.example.jwt.jwt;

import com.example.jwt.dto.CustomUserDetails;
import com.example.jwt.entity.UserEntity;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Encoders;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import org.springframework.security.core.context.SecurityContextHolder;

import javax.crypto.SecretKey;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class LoginFilterTest {

    private AuthenticationManager authenticationManager;

    private JWTUtil jwtUtil;

    private LoginFilter loginFilter;

    @BeforeEach
    void setUp() {

        // AuthenticationManager Mock
        authenticationManager =
                mock(AuthenticationManager.class);

        // 테스트 전용 SecretKey
        SecretKey secretKey = Jwts.SIG.HS256
                .key()
                .build();

        String encodedSecret =
                Encoders.BASE64.encode(
                        secretKey.getEncoded()
                );

        jwtUtil = new JWTUtil(encodedSecret);

        // LoginFilter 생성
        loginFilter = new LoginFilter(
                authenticationManager,
                jwtUtil,
                3600000L
        );
    }

    @AfterEach
    void tearDown() {

        SecurityContextHolder.clearContext();
    }

    @Test
    void 로그인_성공시_JWT를_발급한다() throws Exception {

        // given
        UserEntity userEntity =
                mock(UserEntity.class);

        when(userEntity.getUsername())
                .thenReturn("user01");

        when(userEntity.getRole())
                .thenReturn("ROLE_USER");

        CustomUserDetails userDetails =
                new CustomUserDetails(userEntity);

        Authentication authenticated =
                UsernamePasswordAuthenticationToken.authenticated(
                        userDetails,
                        null,
                        List.of(
                                new SimpleGrantedAuthority(
                                        "ROLE_USER"
                                )
                        )
                );

        when(
                authenticationManager.authenticate(
                        any(Authentication.class)
                )
        ).thenReturn(authenticated);

        MockHttpServletRequest request =
                new MockHttpServletRequest(
                        "POST",
                        "/login"
                );

        request.setServletPath("/login");

        request.addParameter(
                "username",
                "user01"
        );

        request.addParameter(
                "password",
                "password123!"
        );

        MockHttpServletResponse response =
                new MockHttpServletResponse();

        // when
        loginFilter.doFilter(
                request,
                response,
                (req, res) -> {
                }
        );

        // then
        assertEquals(
                200,
                response.getStatus()
        );

        String authorization =
                response.getHeader("Authorization");

        assertNotNull(authorization);

        assertTrue(
                authorization.startsWith("Bearer ")
        );

        String token =
                authorization.substring(7);

        assertFalse(token.isBlank());

        assertEquals(
                "user01",
                jwtUtil.getUsername(token)
        );

        assertEquals(
                "ROLE_USER",
                jwtUtil.getRole(token)
        );
    }

    @Test
    void 로그인_실패시_JWT를_발급하지_않는다()
            throws Exception {

        // given
        when(
                authenticationManager.authenticate(
                        any(Authentication.class)
                )
        ).thenThrow(
                new BadCredentialsException(
                        "Invalid credentials"
                )
        );

        MockHttpServletRequest request =
                new MockHttpServletRequest(
                        "POST",
                        "/login"
                );

        request.setServletPath("/login");

        request.addParameter(
                "username",
                "user01"
        );

        request.addParameter(
                "password",
                "wrong-password"
        );

        MockHttpServletResponse response =
                new MockHttpServletResponse();

        // when
        loginFilter.doFilter(
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
                response.getHeader("Authorization")
        );
    }
}
```

이 테스트는 실제 MySQL을 사용하지 않는다.

AuthenticationManager를 Mock 객체로 대체하여 LoginFilter의 성공·실패 처리만 검증한다.

첫 번째 테스트에서는 로그인 성공 시 JWT가 발급되고 사용자 이름과 권한이 올바르게 포함되는지 확인한다.

두 번째 테스트에서는 인증 실패 시 HTTP 401이 반환되고 JWT가 발급되지 않는지 확인한다.

#### 테스트 실행

다음 명령을 실행한다.

```bash
./gradlew test --tests "com.example.jwt.jwt.LoginFilterTest"
```

각 부분의 의미는 다음과 같다.

| 명령          | 의미                |
| ----------- | ----------------- |
| `./gradlew` | Gradle Wrapper 실행 |
| `test`      | 테스트 실행            |
| `--tests`   | 특정 테스트 클래스 실행     |

테스트가 정상적으로 통과하면 다음과 유사한 결과를 확인할 수 있다.

```text
BUILD SUCCESSFUL
```

다만 이것은 LoginFilter 단위 테스트다.

실제 데이터베이스 사용자 조회, 비밀번호 검증, SecurityFilterChain 등록까지 모두 확인하려면 통합 테스트를 별도로 수행해야 한다.

---

### 정리

Spring Security에서 JWT 기반 로그인을 구현하려면 로그인 인증과 JWT 발급 과정을 연결해야 한다.

앞서 구현한 LoginFilter는 `AuthenticationManager`를 이용해 사용자 인증을 수행한다.

인증에 성공하면 `successfulAuthentication()`이 실행된다.

이때 인증된 사용자 정보를 추출할 수 있다.

```java
CustomUserDetails userDetails =
        (CustomUserDetails) authentication.getPrincipal();
```

사용자 이름을 가져온다.

```java
String username =
        userDetails.getUsername();
```

권한을 가져온다.

```java
String role = authentication
        .getAuthorities()
        .stream()
        .map(GrantedAuthority::getAuthority)
        .findFirst()
        .orElseThrow();
```

그다음 JWTUtil을 이용해 JWT를 생성한다.

```java
String token = jwtUtil.createJwt(
        username,
        role,
        accessTokenExpirationMs
);
```

생성된 JWT는 HTTP 응답의 Authorization 헤더로 전달한다.

```java
response.setHeader(
        HttpHeaders.AUTHORIZATION,
        "Bearer " + token
);
```

로그인 인증에 실패했다면 HTTP 401을 반환한다.

```java
response.setStatus(
        HttpServletResponse.SC_UNAUTHORIZED
);
```

전체 흐름을 정리하면 다음과 같다.

```mermaid
flowchart TD
    A["로그인 요청"] --> B["LoginFilter"]

    B --> C["AuthenticationManager"]

    C --> D["사용자 정보 검증"]

    D --> E{"인증 성공?"}

    E -->|"No"| F["HTTP 401"]

    E -->|"Yes"| G["Authentication 반환"]

    G --> H["successfulAuthentication"]

    H --> I["CustomUserDetails"]

    I --> J["username 추출"]

    J --> K["role 추출"]

    K --> L["JWTUtil.createJwt"]

    L --> M["HS256 서명"]

    M --> N["JWT 생성"]

    N --> O["Authorization: Bearer JWT"]

    O --> P["HTTP 200"]
```

이렇게 하면 로그인 인증에 성공한 사용자에게 JWT를 발급할 수 있다.

여기서 가장 중요한 점은 다음과 같다.

**첫째, JWT는 반드시 사용자 인증에 성공한 이후 발급해야 한다.**

사용자가 전달한 값이 아니라 인증된 `Authentication` 객체의 정보를 이용해야 한다.

**둘째, JWT를 발급하기 위해 LoginFilter에 JWTUtil을 주입해야 한다.**

그리고 SecurityConfig에서 LoginFilter를 생성할 때 AuthenticationManager와 JWTUtil을 전달해야 한다.

**셋째, JWT는 Authorization 헤더에 Bearer 인증 형식으로 전달할 수 있다.**

```http
Authorization: Bearer <ACCESS_TOKEN>
```

**넷째, JWT 발급과 이후 요청의 JWT 검증은 서로 다른 기능이다.**

현재 구현에서는 로그인 성공 시 JWT를 발급하는 부분까지 완성했다.

하지만 발급한 JWT를 이용해 보호된 API에 접근하려면 JWT 인증 필터가 필요하다.

해당 필터는 Authorization 헤더에서 JWT를 추출하고 서명과 만료 시간을 검증한 뒤, 사용자 정보를 바탕으로 `Authentication`을 구성하여 `SecurityContextHolder`에 설정하는 역할을 담당한다.

이를 통해 각 HTTP 요청을 독립적으로 인증하는 Stateless 인증 시스템을 구현할 수 있다.

#### 한 줄 요약

Spring Security JWT 로그인은 `LoginFilter`에서 `AuthenticationManager`를 통해 사용자를 인증하고, 인증에 성공하면 `successfulAuthentication()`에서 `CustomUserDetails`와 `GrantedAuthority`를 이용해 사용자 이름과 권한을 추출한 뒤 `JWTUtil.createJwt()`로 JWT를 발급하는 구조다. 발급된 JWT는 `Authorization: Bearer <JWT>` 형식으로 응답하며, 로그인 실패 시에는 HTTP 401을 반환한다. 이후 보호된 API의 인증과 인가를 위해서는 JWT를 검증하고 SecurityContext에 인증 정보를 구성하는 별도의 JWT 인증 필터가 필요하다.
