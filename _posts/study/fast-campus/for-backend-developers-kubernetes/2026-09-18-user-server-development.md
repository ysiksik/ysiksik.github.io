---
layout: post
bigtitle: 'Part 3. 실전 Kubernetes 프로젝트'
subtitle: Ch 3. User 서버 개발 
date: '2026-09-18 00:00:11 +0900'
categories:
    - for-backend-developers-kubernetes
comments: true
---

# Ch 3. User 서버 개발

# Ch 3. User 서버 개발
* toc
{:toc}

---

## 01. 사용자 가입, 로그인 기능 개발 

### Spring Boot User Server 회원가입과 로그인 API 구현하기

User Server는 사용자 계정과 팔로우 관계를 관리하는 마이크로서비스다. SNS에서는 회원가입과 로그인뿐 아니라 사용자 조회, 팔로우, 언팔로우, 팔로워 및 팔로잉 목록 조회 등의 기능을 담당한다.

이번 실습에서는 먼저 다음과 같은 사용자 계정 기능을 구현한다.

- 회원가입
- 사용자 ID를 이용한 사용자 조회
- 사용자 이름을 이용한 사용자 조회
- 사용자 이름과 비밀번호를 이용한 로그인 검증
- BCrypt를 이용한 비밀번호 해시
- Kubernetes 배포 및 API 테스트

팔로우와 언팔로우 기능은 사용자 계정 기능이 완성된 다음 단계에서 추가한다.

#### User Server의 책임

User Server는 사용자의 인증 정보와 공개 프로필 정보를 관리한다.

```mermaid
flowchart TD
    A["Client"] --> B["User Server"]
    B --> C["회원가입"]
    B --> D["로그인 검증"]
    B --> E["사용자 조회"]
    B --> F["팔로우 관계 관리"]
    B --> G["MySQL"]

    H["Feed Server"] -. "uploaderId로 사용자 조회" .-> B
    I["Timeline Server"] -. "팔로우 관계 조회" .-> B
```

각 마이크로서비스는 사용자 상세 정보를 자체 데이터베이스에 복제하지 않고 `userId`만 저장한다. 사용자 이름이나 이메일 같은 상세 정보가 필요하면 User Server를 호출한다.

#### 전체 구현 흐름

User Server도 Feed Server와 동일한 계층 구조를 사용한다.

```mermaid
flowchart LR
    A["HTTP Request"] --> B["UserController"]
    B --> C["Request DTO"]
    B --> D["UserService"]
    D --> E["UserRepository"]
    E --> F["MySQL users"]
    D --> G["UserResponse"]
    G --> A
```

| 계층 | 역할 |
|---|---|
| Controller | HTTP 요청과 응답 상태 코드 처리 |
| Request DTO | 회원가입 및 로그인 입력값 검증 |
| Service | 비밀번호 해시, 중복 검사, 로그인 검증 |
| Repository | Spring Data JPA를 이용한 사용자 조회 및 저장 |
| Entity | `users` 테이블과 Java 객체 매핑 |
| Response DTO | 비밀번호를 제외한 사용자 정보 반환 |

#### 프로젝트 의존성 설정

User Server에는 다음 의존성이 필요하다.

```groovy
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'

    implementation 'org.springframework.security:spring-security-crypto'

    runtimeOnly 'com.mysql:mysql-connector-j'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}
```

비밀번호 해시만 필요하다면 `spring-boot-starter-security` 전체를 추가하는 대신 `spring-security-crypto` 모듈만 사용하는 것이 간단하다.

`spring-boot-starter-security`를 추가하면 기본 보안 자동 설정이 활성화되어 모든 API가 인증 대상으로 바뀔 수 있다. 단순히 이를 피하기 위해 `SecurityAutoConfiguration` 전체를 제외하면 이후 실제 인증 기능을 추가할 때 구성이 혼란스러워질 수 있다.

이번 단계에서는 다음과 같이 역할을 제한한다.

- Spring Security의 웹 인증 기능은 아직 사용하지 않는다.
- `PasswordEncoder`와 BCrypt 구현만 사용한다.
- JWT 또는 Session 인증은 이후 인증 체계에서 추가한다.

#### 사용자 테이블 설계

사용자 테이블에는 다음 데이터를 저장한다.

| 컬럼 | 설명 |
|---|---|
| `user_id` | 내부에서 사용하는 자동 증가 사용자 ID |
| `username` | 로그인과 사용자 검색에 사용하는 고유 이름 |
| `email` | 사용자 이메일 |
| `password_hash` | BCrypt로 해시한 비밀번호 |
| `created_at` | 가입 시각 |

```sql
CREATE TABLE users (
    user_id BIGINT NOT NULL AUTO_INCREMENT,
    username VARCHAR(30) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(100) NOT NULL,
    created_at DATETIME(6) NOT NULL,
    PRIMARY KEY (user_id),
    CONSTRAINT uk_users_username UNIQUE (username),
    CONSTRAINT uk_users_email UNIQUE (email)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;
```

`USER`는 데이터베이스 제품에 따라 예약어나 시스템 객체 이름과 충돌할 수 있으므로 테이블 이름은 `users`처럼 명확하게 지정하는 편이 안전하다.

사용자 이름과 이메일에는 반드시 데이터베이스 Unique Constraint를 설정해야 한다. 애플리케이션에서 중복을 먼저 확인하더라도 동시에 두 요청이 들어오면 둘 다 중복 확인을 통과할 수 있기 때문이다.

```mermaid
flowchart TD
    A["회원가입 요청 A"] --> C["username 중복 확인"]
    B["회원가입 요청 B"] --> C
    C --> D["두 요청 모두 중복 없음 확인"]
    D --> E["동시에 INSERT 시도"]
    E --> F["데이터베이스 Unique Constraint"]
    F --> G["하나만 성공"]
    F --> H["나머지는 중복 오류"]
```

따라서 애플리케이션 중복 확인은 사용자에게 빠르고 친절한 오류를 제공하는 용도이며, 최종 데이터 정합성은 데이터베이스 제약 조건으로 보장해야 한다.

#### UserAccount Entity 작성

Spring Security에도 `User`라는 클래스가 있으므로 이름 충돌을 줄이기 위해 Entity 이름을 `UserAccount`로 정의한다.

```java
package com.sns.user.domain.user;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.Instant;

@Entity
@Table(
    name = "users",
    uniqueConstraints = {
        @UniqueConstraint(
            name = "uk_users_username",
            columnNames = "username"
        ),
        @UniqueConstraint(
            name = "uk_users_email",
            columnNames = "email"
        )
    }
)
public class UserAccount {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long id;

    @Column(
        name = "username",
        nullable = false,
        length = 30
    )
    private String username;

    @Column(
        name = "email",
        nullable = false,
        length = 255
    )
    private String email;

    @Column(
        name = "password_hash",
        nullable = false,
        length = 100
    )
    private String passwordHash;

    @Column(
        name = "created_at",
        nullable = false,
        updatable = false
    )
    private Instant createdAt;

    protected UserAccount() {
    }

    private UserAccount(
        String username,
        String email,
        String passwordHash
    ) {
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
    }

    public static UserAccount create(
        String username,
        String email,
        String passwordHash
    ) {
        return new UserAccount(username, email, passwordHash);
    }

    @PrePersist
    private void initializeCreatedAt() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }

    public boolean matchesPassword(
        String rawPassword,
        PasswordEncoder passwordEncoder
    ) {
        return passwordEncoder.matches(
            rawPassword,
            passwordHash
        );
    }

    public Long getId() {
        return id;
    }

    public String getUsername() {
        return username;
    }

    public String getEmail() {
        return email;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
```

외부 계층에서 해시 값을 실수로 사용하지 않도록 `passwordHash` Getter를 만들지 않았다. 로그인 검증은 Entity가 제공하는 `matchesPassword()`를 통해 수행한다.

`passwordHash`는 암호화된 비밀번호가 아니다. 암호화는 복호화를 전제로 하지만 비밀번호 해시는 원래 값을 복원하지 않고 입력값이 같은지만 검증하는 단방향 처리다.

#### BCrypt의 동작 방식

BCrypt는 비밀번호 저장을 위해 설계된 해시 알고리즘이다.

```mermaid
flowchart LR
    A["사용자가 입력한 비밀번호"] --> B["임의의 Salt 생성"]
    B --> C["BCrypt 연산"]
    C --> D["Cost와 Salt가 포함된 해시"]
    D --> E["데이터베이스 저장"]
```

BCrypt의 주요 특징은 다음과 같다.

- 비밀번호마다 임의의 Salt를 생성한다.
- 같은 비밀번호를 여러 번 해시해도 서로 다른 결과가 생성된다.
- 연산 비용인 Cost를 조정할 수 있다.
- 저장된 해시 안에 검증에 필요한 알고리즘 정보, Cost, Salt가 포함된다.
- 로그인할 때 `matches()`를 이용해 평문 비밀번호와 저장된 해시를 비교한다.

MD5, SHA-1, SHA-256 같은 일반 해시 함수를 한 번 적용하는 방식은 비밀번호 저장에 적합하지 않다. 이러한 알고리즘은 빠르게 계산하도록 설계되어 있어 공격자가 대량의 비밀번호 후보를 빠르게 대입할 수 있기 때문이다.

BCrypt도 무조건 안전한 것은 아니다. 충분한 비밀번호 길이, 로그인 시도 제한, 다중 인증, 유출 비밀번호 검사 같은 보완책이 함께 필요하다.

#### PasswordEncoder 설정

`BCryptPasswordEncoder`를 Service 내부에서 직접 생성하지 않고 Spring Bean으로 등록한다.

```java
package com.sns.user.config;

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

Service는 구체적인 BCrypt 구현보다 `PasswordEncoder` 인터페이스에 의존한다. 이를 통해 향후 비밀번호 정책이나 구현체를 변경하기 쉬워진다.

BCrypt Cost를 무조건 높이면 보안성이 좋아지는 대신 회원가입과 로그인 요청의 CPU 사용량도 증가한다. 운영 환경에서는 실제 서버 사양과 예상 로그인 트래픽을 기준으로 부하 테스트 후 값을 결정해야 한다.

#### UserRepository 작성

```java
package com.sns.user.domain.user;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository
    extends JpaRepository<UserAccount, Long> {

    Optional<UserAccount> findByUsername(String username);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);
}
```

사용자가 직접 입력하는 로그인 식별자는 `userId`보다 `username`인 경우가 많다.

- `userId`: 데이터베이스와 서비스 간 통신에서 사용하는 내부 식별자
- `username`: 로그인과 사용자 검색에서 사용하는 외부 식별자

조회 결과가 없을 수 있는 메서드는 `null` 대신 `Optional<UserAccount>`를 반환한다.

#### 회원가입 요청 DTO 작성

회원가입과 로그인은 필요한 필드가 다르므로 하나의 요청 DTO를 재사용하지 않는다.

```java
package com.sns.user.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record SignUpRequest(

    @NotBlank
    @Size(min = 3, max = 30)
    @Pattern(regexp = "^[a-zA-Z0-9._-]+$")
    String username,

    @NotBlank
    @Email
    @Size(max = 255)
    String email,

    @NotBlank
    @Size(min = 8, max = 64)
    String password
) {
}
```

사용자 이름은 URL 경로와 검색 조건에 사용될 수 있으므로 허용 문자를 명확하게 제한한다. 비밀번호의 복잡도 규칙을 지나치게 강제하기보다는 충분한 길이를 허용하고 로그인 시도 제한이나 유출 비밀번호 검사 등을 함께 적용하는 편이 효과적이다.

BCrypt는 입력 비밀번호의 앞부분 72바이트만 처리하므로 서버에서는 UTF-8 기준 바이트 길이도 검증해야 한다.

#### 로그인 요청 DTO 작성

```java
package com.sns.user.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SignInRequest(

    @NotBlank
    String username,

    @NotBlank
    @Size(max = 64)
    String password
) {
}
```

회원가입 DTO를 로그인에 재사용하면 로그인에서 필요하지 않은 이메일까지 전달해야 하거나 검증 조건이 뒤섞인다. API의 목적에 맞게 DTO를 분리하는 것이 좋다.

#### 사용자 응답 DTO 작성

Entity를 API 응답으로 직접 반환하면 `passwordHash`가 외부에 노출될 수 있다. 해시도 민감한 인증 정보이므로 절대 응답, 로그, 예외 메시지에 포함하면 안 된다.

```java
package com.sns.user.api.dto;

import com.sns.user.domain.user.UserAccount;

import java.time.Instant;

public record UserResponse(
    Long userId,
    String username,
    String email,
    Instant createdAt
) {

    public static UserResponse from(UserAccount user) {
        return new UserResponse(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getCreatedAt()
        );
    }
}
```

응답 DTO에는 클라이언트가 실제로 필요한 정보만 포함한다.

#### 예외 클래스 작성

##### 사용자를 찾을 수 없는 경우

```java
package com.sns.user.domain.user;

public class UserNotFoundException extends RuntimeException {

    public UserNotFoundException() {
        super("사용자를 찾을 수 없습니다.");
    }
}
```

##### 사용자 이름 또는 이메일이 중복된 경우

```java
package com.sns.user.domain.user;

public class DuplicateUserException extends RuntimeException {

    public DuplicateUserException() {
        super("이미 사용 중인 사용자 이름 또는 이메일입니다.");
    }
}
```

##### 로그인 정보가 올바르지 않은 경우

```java
package com.sns.user.domain.user;

public class InvalidCredentialsException
    extends RuntimeException {

    public InvalidCredentialsException() {
        super("사용자 이름 또는 비밀번호가 올바르지 않습니다.");
    }
}
```

로그인 실패 응답에서 사용자 이름이 존재하는지 구분해 알려주면 계정 존재 여부를 수집하는 데 악용될 수 있다. 사용자가 존재하지 않는 경우와 비밀번호가 틀린 경우 모두 같은 메시지와 상태 코드를 반환한다.

#### UserService 작성

```java
package com.sns.user.domain.user;

import com.sns.user.api.dto.SignInRequest;
import com.sns.user.api.dto.SignUpRequest;
import com.sns.user.api.dto.UserResponse;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.util.Locale;

@Service
@Transactional(readOnly = true)
public class UserService {

    private static final int BCRYPT_MAX_PASSWORD_BYTES = 72;

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(
        UserRepository userRepository,
        PasswordEncoder passwordEncoder
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public UserResponse signUp(SignUpRequest request) {
        String username = normalizeUsername(
            request.username()
        );
        String email = normalizeEmail(request.email());

        validatePasswordLength(request.password());

        if (userRepository.existsByUsername(username)
            || userRepository.existsByEmail(email)) {
            throw new DuplicateUserException();
        }

        String passwordHash =
            passwordEncoder.encode(request.password());

        UserAccount user = UserAccount.create(
            username,
            email,
            passwordHash
        );

        try {
            UserAccount savedUser =
                userRepository.saveAndFlush(user);

            return UserResponse.from(savedUser);
        } catch (DataIntegrityViolationException exception) {
            throw new DuplicateUserException();
        }
    }

    public UserResponse getUser(Long userId) {
        UserAccount user = userRepository.findById(userId)
            .orElseThrow(UserNotFoundException::new);

        return UserResponse.from(user);
    }

    public UserResponse getUserByUsername(String username) {
        UserAccount user = userRepository
            .findByUsername(normalizeUsername(username))
            .orElseThrow(UserNotFoundException::new);

        return UserResponse.from(user);
    }

    public UserResponse signIn(SignInRequest request) {
        validatePasswordLength(request.password());

        UserAccount user = userRepository
            .findByUsername(
                normalizeUsername(request.username())
            )
            .orElseThrow(InvalidCredentialsException::new);

        if (!user.matchesPassword(
            request.password(),
            passwordEncoder
        )) {
            throw new InvalidCredentialsException();
        }

        return UserResponse.from(user);
    }

    private String normalizeUsername(String username) {
        return username
            .trim()
            .toLowerCase(Locale.ROOT);
    }

    private String normalizeEmail(String email) {
        return email
            .trim()
            .toLowerCase(Locale.ROOT);
    }

    private void validatePasswordLength(String password) {
        int passwordBytes = password.getBytes(
            StandardCharsets.UTF_8
        ).length;

        if (passwordBytes > BCRYPT_MAX_PASSWORD_BYTES) {
            throw new IllegalArgumentException(
                "비밀번호는 UTF-8 기준 72바이트 이하여야 합니다."
            );
        }
    }
}
```

##### 회원가입 동작 과정

```mermaid
flowchart TD
    A["회원가입 요청"] --> B["요청값 검증"]
    B --> C["username과 email 정규화"]
    C --> D["사용자 이름과 이메일 중복 확인"]
    D --> E{"중복 여부"}
    E -->|"중복" | F["409 Conflict"]
    E -->|"사용 가능" | G["BCrypt 비밀번호 해시"]
    G --> H["UserAccount 생성"]
    H --> I["데이터베이스 INSERT"]
    I --> J["비밀번호가 없는 UserResponse"]
    J --> K["201 Created"]
```

`saveAndFlush()`를 사용한 이유는 Unique Constraint 위반을 회원가입 메서드 안에서 확인하기 위해서다. 실제 운영에서는 예외 변환 정책과 트랜잭션 경계를 프로젝트 전체에서 일관되게 적용해야 한다.

##### 로그인 동작 과정

```mermaid
flowchart TD
    A["로그인 요청"] --> B["username으로 사용자 조회"]
    B --> C{"사용자 존재 여부"}
    C -->|"없음" | D["401 Unauthorized"]
    C -->|"있음" | E["PasswordEncoder matches 호출"]
    E --> F{"비밀번호 일치 여부"}
    F -->|"불일치" | D
    F -->|"일치" | G["비밀번호가 없는 UserResponse"]
    G --> H["200 OK"]
```

`matches()`는 입력된 평문 비밀번호를 저장된 BCrypt 해시와 비교한다. 저장된 해시를 복호화하거나 문자열끼리 직접 비교하는 것이 아니다.

#### 예외 응답 처리

```java
package com.sns.user.api;

import com.sns.user.domain.user.DuplicateUserException;
import com.sns.user.domain.user.InvalidCredentialsException;
import com.sns.user.domain.user.UserNotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class ApiExceptionHandler {

    @ExceptionHandler(UserNotFoundException.class)
    public ProblemDetail handleUserNotFound(
        UserNotFoundException exception
    ) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(
            HttpStatus.NOT_FOUND,
            exception.getMessage()
        );
        problem.setTitle("User Not Found");
        return problem;
    }

    @ExceptionHandler(DuplicateUserException.class)
    public ProblemDetail handleDuplicateUser(
        DuplicateUserException exception
    ) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(
            HttpStatus.CONFLICT,
            exception.getMessage()
        );
        problem.setTitle("Duplicate User");
        return problem;
    }

    @ExceptionHandler(InvalidCredentialsException.class)
    public ProblemDetail handleInvalidCredentials(
        InvalidCredentialsException exception
    ) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(
            HttpStatus.UNAUTHORIZED,
            exception.getMessage()
        );
        problem.setTitle("Invalid Credentials");
        return problem;
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ProblemDetail handleIllegalArgument(
        IllegalArgumentException exception
    ) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(
            HttpStatus.BAD_REQUEST,
            exception.getMessage()
        );
        problem.setTitle("Invalid Request");
        return problem;
    }
}
```

#### UserController 작성

```java
package com.sns.user.api;

import com.sns.user.api.dto.SignInRequest;
import com.sns.user.api.dto.SignUpRequest;
import com.sns.user.api.dto.UserResponse;
import com.sns.user.domain.user.UserService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping
    public ResponseEntity<UserResponse> signUp(
        @Valid @RequestBody SignUpRequest request
    ) {
        UserResponse response = userService.signUp(request);

        URI location = ServletUriComponentsBuilder
            .fromCurrentRequest()
            .path("/{userId}")
            .buildAndExpand(response.userId())
            .toUri();

        return ResponseEntity
            .created(location)
            .body(response);
    }

    @GetMapping("/{userId}")
    public UserResponse getUser(
        @PathVariable Long userId
    ) {
        return userService.getUser(userId);
    }

    @GetMapping("/by-username/{username}")
    public UserResponse getUserByUsername(
        @PathVariable String username
    ) {
        return userService.getUserByUsername(username);
    }

    @PostMapping("/sign-in")
    public UserResponse signIn(
        @Valid @RequestBody SignInRequest request
    ) {
        return userService.signIn(request);
    }
}
```

API별 역할과 응답 상태는 다음과 같다.

| HTTP 요청 | 기능 | 정상 응답 |
|---|---|---:|
| `POST /api/users` | 회원가입 | `201 Created` |
| `GET /api/users/{userId}` | ID로 사용자 조회 | `200 OK` |
| `GET /api/users/by-username/{username}` | 사용자 이름으로 조회 | `200 OK` |
| `POST /api/users/sign-in` | 로그인 정보 검증 | `200 OK` |
| 중복 회원가입 | 가입 거절 | `409 Conflict` |
| 존재하지 않는 사용자 조회 | 조회 실패 | `404 Not Found` |
| 잘못된 로그인 정보 | 인증 실패 | `401 Unauthorized` |

현재 로그인 API는 사용자 이름과 비밀번호가 일치하는지만 확인한다. `200 OK`와 사용자 정보가 반환됐다고 해서 지속적인 인증 상태가 만들어지는 것은 아니다.

실제 인증 기능을 완성하려면 다음 중 하나가 추가되어야 한다.

- 서버 Session 생성 및 Session Cookie 발급
- Access Token과 Refresh Token 발급
- API Gateway 또는 인증 서버와 연동
- 이후 요청에서 Token 또는 Session 검증

#### API 테스트

Telepresence에 연결했다면 로컬에서 Kubernetes Service DNS로 User Server를 호출할 수 있다.

```shell
telepresence connect \
  --namespace sns \
  --mapped-namespaces sns
```

User Server의 Service 이름을 `user-service`라고 가정한다.

##### 회원가입

```shell
curl -i -X POST \
  http://user-service.sns.svc.cluster.local:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "developer01",
    "email": "developer01@example.com",
    "password": "StrongPassword123!"
  }'
```

정상 응답은 다음과 같다.

```http
HTTP/1.1 201 Created
Location: http://user-service.sns.svc.cluster.local:8080/api/users/1
Content-Type: application/json
```

```json
{
  "userId": 1,
  "username": "developer01",
  "email": "developer01@example.com",
  "createdAt": "2026-09-18T01:10:20.123Z"
}
```

응답에 `password`나 `passwordHash`가 포함되지 않았는지 반드시 확인한다.

##### 사용자 ID로 조회

```shell
curl -i \
  http://user-service.sns.svc.cluster.local:8080/api/users/1
```

##### 사용자 이름으로 조회

```shell
curl -i \
  http://user-service.sns.svc.cluster.local:8080/api/users/by-username/developer01
```

##### 로그인 성공

```shell
curl -i -X POST \
  http://user-service.sns.svc.cluster.local:8080/api/users/sign-in \
  -H "Content-Type: application/json" \
  -d '{
    "username": "developer01",
    "password": "StrongPassword123!"
  }'
```

사용자 이름과 비밀번호가 일치하면 `200 OK`와 사용자 정보가 반환된다.

##### 로그인 실패

```shell
curl -i -X POST \
  http://user-service.sns.svc.cluster.local:8080/api/users/sign-in \
  -H "Content-Type: application/json" \
  -d '{
    "username": "developer01",
    "password": "WrongPassword"
  }'
```

비밀번호가 일치하지 않으면 `401 Unauthorized`가 반환된다.

```json
{
  "title": "Invalid Credentials",
  "status": 401,
  "detail": "사용자 이름 또는 비밀번호가 올바르지 않습니다."
}
```

##### 중복 회원가입

동일한 사용자 이름이나 이메일로 다시 가입을 요청한다.

```shell
curl -i -X POST \
  http://user-service.sns.svc.cluster.local:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "developer01",
    "email": "developer01@example.com",
    "password": "AnotherPassword123!"
  }'
```

정상적으로 중복이 차단되면 `409 Conflict`가 반환된다.

#### 데이터베이스의 비밀번호 저장 상태 확인

테스트 환경에서 다음 SQL로 저장된 데이터를 확인할 수 있다.

```sql
SELECT
    user_id,
    username,
    email,
    password_hash,
    created_at
FROM users;
```

`password_hash`에는 요청에서 전달한 평문 비밀번호가 저장되면 안 된다.

동일한 비밀번호로 서로 다른 계정을 생성하더라도 BCrypt가 사용자마다 다른 Salt를 사용하기 때문에 해시 결과는 달라진다. 애플리케이션이나 로그에는 평문 비밀번호와 전체 해시 값을 출력하지 않아야 한다.

#### 컨테이너 이미지 빌드

초기 이미지가 `0.0.1`이라면 사용자 기능을 포함한 이미지는 `0.0.2`로 빌드한다.

```powershell
.\gradlew.bat clean test jib `
  -Djib.to.image=<AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/user-server:0.0.2
```

ECR 인증이 만료됐다면 다시 로그인한다.

```powershell
aws ecr get-login-password --region <REGION> |
    docker login `
        --username AWS `
        --password-stdin `
        <AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com
```

#### Kubernetes Deployment 업데이트

Deployment의 컨테이너 이름이 `user-server`라고 가정하면 다음 명령으로 이미지를 변경할 수 있다.

```shell
kubectl set image deployment/user-server \
  user-server=<AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/user-server:0.0.2 \
  -n sns
```

Rollout 상태를 확인한다.

```shell
kubectl rollout status deployment/user-server -n sns
```

실제 적용된 이미지도 확인한다.

```shell
kubectl get deployment user-server \
  -n sns \
  -o jsonpath="{.spec.template.spec.containers[0].image}"
```

Pod와 EndpointSlice 상태를 확인한다.

```shell
kubectl get pods -n sns -l app=user-server
```

```shell
kubectl get endpointslice \
  -n sns \
  -l kubernetes.io/service-name=user-service
```

#### 실패 상황과 원인

##### 모든 API가 `401 Unauthorized`를 반환하는 경우

`spring-boot-starter-security`를 추가하면서 기본 보안 자동 설정이 활성화됐을 가능성이 있다.

비밀번호 해시만 사용한다면 다음 의존성을 사용했는지 확인한다.

```groovy
implementation 'org.springframework.security:spring-security-crypto'
```

Starter 전체가 필요한 프로젝트라면 `SecurityFilterChain`을 명시적으로 구성해야 한다. 다만 모든 요청을 무조건 `permitAll()`로 열어두는 설정은 초기 개발 단계에만 사용하고 실제 인증 기능을 구현할 때 반드시 변경해야 한다.

##### 평문 비밀번호가 데이터베이스에 저장되는 경우

다음과 같은 코드는 사용하면 안 된다.

```java
UserAccount user = UserAccount.create(
    request.username(),
    request.email(),
    request.password()
);
```

반드시 `PasswordEncoder.encode()` 결과를 저장해야 한다.

```java
String passwordHash =
    passwordEncoder.encode(request.password());
```

##### 사용자 이름 중복 데이터가 저장되는 경우

Service의 `existsByUsername()`만으로는 동시 요청을 완전히 차단할 수 없다. 데이터베이스에 Unique Constraint가 적용됐는지 확인한다.

```sql
SHOW INDEX FROM users;
```

##### 로그인 API가 항상 실패하는 경우

다음 항목을 확인한다.

- 회원가입 시 평문 비밀번호가 아니라 해시 값이 저장됐는가
- `matches()`의 첫 번째 인자로 평문, 두 번째 인자로 해시를 전달했는가
- 로그인 전에 비밀번호를 다시 `encode()`해서 문자열끼리 비교하지 않았는가
- 사용자 이름 정규화 정책이 가입과 로그인에서 동일한가

다음 비교 방식은 잘못된 구현이다.

```java
passwordEncoder.encode(request.password())
    .equals(userPasswordHash);
```

BCrypt는 호출할 때마다 새로운 Salt를 사용하므로 같은 비밀번호도 다른 해시가 생성될 수 있다. 반드시 다음 방식으로 비교한다.

```java
passwordEncoder.matches(
    request.password(),
    userPasswordHash
);
```

##### 존재하지 않는 사용자 조회에서 `200 OK`와 `null`이 반환되는 경우

Service에서 조회 실패 시 `null`을 반환하지 말고 예외를 발생시켜야 한다.

```java
return userRepository.findById(userId)
    .orElseThrow(UserNotFoundException::new);
```

존재하지 않는 리소스 조회는 `404 Not Found`로 응답하는 것이 명확하다.

#### 실무에서 추가로 고려할 사항

##### 로그인 시도 제한

BCrypt를 사용해도 공격자가 반복적으로 로그인을 시도하는 것은 막을 수 없다. 운영 환경에서는 다음 정책이 필요하다.

- 사용자 및 IP별 요청 제한
- 일정 횟수 이상 실패 시 일시 잠금
- 의심스러운 로그인 감지
- 다중 인증
- 로그인 감사 로그

비밀번호 자체는 로그에 남기지 않아야 한다.

##### HTTPS 사용

회원가입과 로그인 요청의 비밀번호는 서버에서 해시되기 전까지 평문 상태다. 따라서 외부 네트워크에서는 반드시 HTTPS를 사용해야 한다.

비밀번호 해시는 데이터베이스 유출에 대비한 저장 방식이며 네트워크 전송을 보호하지는 않는다.

##### 이메일 인증

이번 구현은 이메일 형식만 검증한다. 해당 이메일을 실제 사용자가 소유했는지는 확인하지 않는다.

운영 서비스에서는 이메일 인증 토큰, 만료 시간, 재발급 제한 등을 추가해야 한다.

##### 사용자 정보 공개 범위

이메일은 개인정보이므로 모든 사용자 조회 API에서 무조건 반환하는 것이 적절한지 검토해야 한다.

공개 사용자 조회와 본인 정보 조회의 응답을 분리할 수 있다.

| 응답 | 포함 가능한 정보 |
|---|---|
| 공개 프로필 | `userId`, `username`, 프로필 이미지 |
| 본인 프로필 | 공개 정보, 이메일, 계정 설정 |
| 내부 서비스 응답 | 서비스 간 통신에 필요한 최소 정보 |

##### 로그인 성공 응답

현재 API는 로그인 성공 시 `UserResponse`만 반환한다. 이는 비밀번호 검증 실습에는 충분하지만 인증 시스템으로는 완성되지 않았다.

다음 단계에서는 인증 성공 후 JWT 또는 Session을 발급하고 이후 요청에서 인증 정보를 검증해야 한다.

### 정리

User Server의 첫 단계로 회원가입, 사용자 조회, 로그인 검증 기능을 구현했다.

- User Server는 사용자 계정과 팔로우 관계를 관리한다.
- 내부 식별자인 `userId`와 외부 로그인 식별자인 `username`을 구분했다.
- 사용자 이름과 이메일에는 데이터베이스 Unique Constraint를 적용했다.
- 회원가입과 로그인 요청 DTO를 분리해 목적에 맞는 검증을 적용했다.
- 비밀번호는 평문으로 저장하지 않고 BCrypt로 해시했다.
- BCrypt 해시는 복호화하지 않고 `PasswordEncoder.matches()`로 검증한다.
- Entity를 API 응답으로 직접 반환하지 않고 `UserResponse`를 사용했다.
- 사용자 조회 실패는 `404 Not Found`, 중복 가입은 `409 Conflict`, 로그인 실패는 `401 Unauthorized`로 처리했다.
- 현재 로그인 API는 자격 증명만 검증하며 실제 인증 상태를 유지하려면 JWT 또는 Session이 추가로 필요하다.
- 변경된 애플리케이션을 새 이미지 태그로 빌드하고 Kubernetes Deployment에 반영했다.

사용자 계정 기능이 준비됐으므로 다음 단계에서는 사용자 간 팔로우 관계를 저장하고, 팔로우와 언팔로우 및 팔로워 목록 조회 기능을 구현할 수 있다.
