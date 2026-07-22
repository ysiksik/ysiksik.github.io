---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 투핸더의 바이브 코딩, 보안 괜찮을까?
date: '2026-07-22 00:00:01 +0900'
categories:
    - elegant-tekotok
comments: true

---

# 투핸더의 바이브 코딩, 보안 괜찮을까?
[https://youtu.be/WVTHJCCWt-E?si=-FgmUhKpr56-U0V1](https://youtu.be/WVTHJCCWt-E?si=-FgmUhKpr56-U0V1)

# 투핸더의 바이브 코딩, 보안 괜찮을까?
* toc
{:toc}

---

## 바이브 코딩, 보안까지 맡겨도 괜찮을까?

AI에게 자연어로 원하는 기능을 설명하고, 생성된 코드를 빠르게 조립해 애플리케이션을 만드는 방식이 널리 사용되고 있다. 이러한 개발 방식을 흔히 **바이브 코딩(Vibe Coding)** 이라고 부른다.

바이브 코딩은 개발 속도를 크게 높여준다. 반복적인 코드 작성, 기본 CRUD 구현, 화면 구성, 테스트 초안 작성 같은 작업을 빠르게 처리할 수 있다.

하지만 기능이 정상적으로 동작한다는 것과 안전한 코드라는 것은 전혀 다른 문제다.

AI에게 다음과 같이 요청했다고 가정해보자.

```text
주문의 배송지 주소를 변경하는 API를 만들어줘.
```

AI는 요청한 기능을 빠르게 구현할 가능성이 높다.

```text
주문 ID 조회
→ 새로운 주소로 변경
→ 데이터베이스 저장
→ 성공 응답 반환
```

겉으로 보면 요구사항을 충족한다.

하지만 다음 질문은 빠져 있을 수 있다.

```text
로그인한 사용자만 접근할 수 있는가?
해당 주문이 요청자의 주문인지 확인했는가?
배송이 시작된 뒤에도 주소를 바꿀 수 있는가?
입력된 주소는 안전한가?
존재하지 않는 주문은 어떻게 처리하는가?
내부 오류 정보가 외부에 노출되지는 않는가?
```

바이브 코딩에서 가장 위험한 지점은 코드가 동작하지 않는 것이 아니라, **동작은 하지만 안전하지 않은 코드가 자연스럽게 만들어질 수 있다는 점**이다.

---

## 바이브 코딩이란 무엇인가

바이브 코딩은 개발자가 모든 코드를 직접 작성하기보다, 원하는 결과와 기능의 방향을 자연어로 설명하고 AI가 구현을 담당하게 하는 개발 방식이다.

전통적인 개발에서는 개발자가 직접 다음 과정을 수행한다.

```text
요구사항 분석
→ 설계
→ 코드 작성
→ 테스트
→ 오류 수정
→ 보안 검토
```

바이브 코딩에서는 일부 과정이 다음처럼 단축된다.

```text
자연어 요구사항 입력
→ AI 코드 생성
→ 실행
→ 결과 확인
→ 추가 요청
```

예를 들어 다음과 같이 요청할 수 있다.

```text
Spring Boot로 게시글 작성 API를 만들어줘.
```

AI는 Controller, Service, Repository, Entity, DTO까지 빠르게 생성할 수 있다.

이 방식은 생산성이 매우 높지만, 사용자가 요구하지 않은 품질 속성은 누락될 가능성이 있다.

```text
보안
트랜잭션
동시성
감사 로그
운영 환경 설정
장애 복구
입력값 검증
```

AI는 기본적으로 사용자가 명시한 결과를 빠르게 만족시키려는 방향으로 동작하기 때문이다.

---

## 기능 구현과 보안 구현은 다르다

기능 요구사항은 대체로 눈에 잘 보인다.

```text
글을 저장한다
주문을 조회한다
배송지를 변경한다
결제를 승인한다
```

반면 보안 요구사항은 정상적인 사용 흐름에서는 잘 드러나지 않는다.

```text
다른 사용자의 주문은 변경하지 못해야 한다
잘못된 입력은 거부해야 한다
민감한 정보는 응답에 노출하지 않아야 한다
인증되지 않은 요청은 차단해야 한다
```

AI에게 단순히 기능만 요청하면 정상 흐름을 중심으로 코드가 생성될 수 있다.

```text
Happy Path
→ 정상 입력
→ 정상 사용자
→ 정상 데이터
→ 정상 응답
```

하지만 실제 공격은 정상 흐름 바깥에서 발생한다.

```text
다른 사용자의 ID 입력
존재하지 않는 주문 ID 입력
스크립트가 포함된 주소 입력
인증 없이 직접 API 호출
배송 완료 주문 변경 시도
```

따라서 바이브 코딩에서는 기능이 만들어졌다는 이유만으로 구현이 끝났다고 판단하면 안 된다.

---

## AI가 보안보다 기능에 집중하는 이유

AI는 사용자의 요청을 가능한 한 직접적으로 만족시키려고 한다.

다음 요청을 보자.

```text
주문 ID를 받아 배송지 주소를 변경하는 API를 만들어줘.
```

이 요청에 명시된 핵심 동작은 두 가지다.

```text
주문을 찾는다
주소를 변경한다
```

사용자가 보안 조건을 명시하지 않았다면 AI가 다음 내용을 반드시 추가한다고 보장할 수 없다.

```text
인증
인가
소유권 검증
상태 검증
입력값 검증
예외 응답 표준화
감사 로그
```

방어 코드는 기능을 완성하는 데 추가적인 조건과 분기를 만든다.

```text
정상 기능만 구현
→ 짧고 빠름

보안까지 구현
→ 검증 조건 증가
→ 예외 흐름 증가
→ 코드량 증가
```

따라서 결과 중심의 짧은 프롬프트는 동작하는 코드를 얻기에는 좋지만, 운영 가능한 코드를 얻기에는 부족할 수 있다.

---

## 예제: AI가 생성할 수 있는 단순한 배송지 변경 코드

다음은 기능에만 집중한 코드의 예시다.

```java
@PatchMapping("/orders/{orderId}/address")
public ResponseEntity<Void> changeAddress(
        @PathVariable Long orderId,
        @RequestBody ChangeAddressRequest request
) {
    Order order = orderRepository.findById(orderId).orElse(null);

    order.changeAddress(request.address());
    orderRepository.save(order);

    return ResponseEntity.ok().build();
}
```

코드가 짧고 이해하기 쉽다.

하지만 운영 환경에서는 여러 문제가 발생할 수 있다.

---

## 문제 1: 인증되지 않은 사용자도 접근할 수 있다

엔드포인트에 인증 제어가 없다면 누구든 API를 호출할 수 있다.

```http
PATCH /orders/100/address
```

클라이언트가 주문 ID만 알면 요청을 보낼 수 있다.

Spring Security 설정에서 해당 경로가 보호되지 않았다면 로그인하지 않은 사용자도 접근할 가능성이 있다.

보안이 적용된 구조에서는 최소한 현재 인증된 사용자를 확인해야 한다.

```java
@PatchMapping("/orders/{orderId}/address")
public ResponseEntity<Void> changeAddress(
        @AuthenticationPrincipal LoginUser loginUser,
        @PathVariable Long orderId,
        @Valid @RequestBody ChangeAddressRequest request
) {
    orderService.changeAddress(
            loginUser.userId(),
            orderId,
            request.address()
    );

    return ResponseEntity.noContent().build();
}
```

여기서 중요한 것은 인증과 인가를 구분하는 것이다.

```text
인증
→ 사용자가 누구인지 확인

인가
→ 해당 사용자가 이 주문을 변경할 권한이 있는지 확인
```

로그인 여부만 확인해서는 충분하지 않다.

---

## 문제 2: 다른 사용자의 주문을 변경할 수 있다

주문 ID만 이용해 주문을 조회하면 소유권 검증이 빠질 수 있다.

```java
Order order = orderRepository.findById(orderId)
        .orElseThrow(OrderNotFoundException::new);
```

이 코드는 주문이 존재하는지만 확인한다.

요청자가 해당 주문의 주인인지는 확인하지 않는다.

공격자가 주문 ID를 100에서 101로 바꿔 요청한다면 다른 사용자의 주문에 접근할 수 있다.

이런 취약점을 흔히 **IDOR(Insecure Direct Object Reference)** 또는 객체 수준 권한 검증 실패로 설명한다.

```text
/orders/100
/orders/101
/orders/102
```

식별자가 예측 가능하다는 사실 자체가 문제의 전부는 아니다.

핵심 문제는 식별자로 리소스를 조회한 뒤 요청자의 권한을 확인하지 않는 것이다.

더 안전한 조회는 사용자 ID와 주문 ID를 함께 조건으로 사용한다.

```java
Order order = orderRepository
        .findByIdAndUserId(orderId, userId)
        .orElseThrow(OrderNotFoundException::new);
```

또는 도메인 객체에서 소유권을 검증할 수 있다.

```java
public void validateOwner(Long userId) {
    if (!this.userId.equals(userId)) {
        throw new OrderAccessDeniedException();
    }
}
```

---

## 문제 3: 존재하지 않는 주문에서 예외가 발생한다

다음 코드는 주문이 없으면 `null`을 반환한다.

```java
Order order = orderRepository.findById(orderId).orElse(null);
```

이후 바로 메서드를 호출하면 `NullPointerException`이 발생한다.

```java
order.changeAddress(request.address());
```

존재하지 않는 리소스는 의도된 비즈니스 예외로 처리해야 한다.

```java
Order order = orderRepository.findById(orderId)
        .orElseThrow(() -> new OrderNotFoundException(orderId));
```

그리고 전역 예외 처리기를 통해 일관된 응답을 내려줄 수 있다.

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(OrderNotFoundException.class)
    public ResponseEntity<ErrorResponse> handle(
            OrderNotFoundException exception
    ) {
        ErrorResponse response = new ErrorResponse(
                "ORDER_NOT_FOUND",
                "주문을 찾을 수 없습니다."
        );

        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(response);
    }
}
```

클라이언트에는 필요한 정보만 제공하고 내부 클래스명이나 스택 트레이스는 숨겨야 한다.

---

## 문제 4: 스택 트레이스가 외부에 노출될 수 있다

개발 환경에서는 상세한 오류 정보가 문제 해결에 도움이 된다.

하지만 운영 환경에서 다음 정보가 클라이언트에 노출되면 위험하다.

```text
패키지 구조
클래스 이름
내부 메서드 이름
SQL 오류
데이터베이스 종류
파일 경로
라이브러리 버전
```

예를 들어 다음과 같은 응답은 공격자에게 내부 구조를 알려줄 수 있다.

```json
{
  "exception": "java.lang.NullPointerException",
  "trace": "com.example.order.OrderController.changeAddress..."
}
```

운영 환경에서는 상세 오류를 서버 로그에만 남기고, 클라이언트에는 일반화된 메시지를 반환해야 한다.

```json
{
  "code": "INTERNAL_SERVER_ERROR",
  "message": "요청 처리 중 오류가 발생했습니다."
}
```

Spring Boot 설정에서도 오류 상세 노출 여부를 환경별로 구분해야 한다.

```yaml
server:
  error:
    include-message: never
    include-stacktrace: never
    include-exception: false
```

개발 환경과 운영 환경의 설정을 분리하는 것도 중요하다.

---

## 문제 5: 입력값 검증이 없다

주소 필드를 그대로 저장하면 예상하지 못한 입력이 데이터베이스에 들어갈 수 있다.

```text
빈 문자열
지나치게 긴 문자열
제어 문자
HTML 태그
스크립트 문자열
지원하지 않는 문자 형식
```

DTO 단계에서 기본적인 유효성 검사를 적용할 수 있다.

```java
public record ChangeAddressRequest(

        @NotBlank(message = "주소는 필수입니다.")
        @Size(max = 200, message = "주소는 200자 이하여야 합니다.")
        String address
) {
}
```

Controller에서는 `@Valid`를 사용한다.

```java
public ResponseEntity<Void> changeAddress(
        @Valid @RequestBody ChangeAddressRequest request
) {
    // ...
}
```

다만 입력값 검증과 XSS 방어를 동일하게 보면 안 된다.

XSS는 입력 단계에서 모든 특수 문자를 무조건 제거하는 것만으로 해결되지 않는다.

핵심은 출력되는 위치에 맞게 안전하게 인코딩하는 것이다.

```text
HTML 본문
HTML 속성
JavaScript 문자열
URL
CSS
```

각 컨텍스트에 따라 방어 방식이 달라진다.

백엔드에서는 다음 원칙이 중요하다.

```text
입력 형식과 길이를 제한한다
필요하지 않은 HTML 입력을 허용하지 않는다
출력 시 프론트엔드에서 안전하게 렌더링한다
신뢰할 수 없는 값을 innerHTML에 직접 넣지 않는다
```

---

## 문제 6: 비즈니스 상태 검증이 없다

보안 문제는 인증과 입력 검증에서 끝나지 않는다.

비즈니스 규칙도 중요한 방어선이다.

배송지 주소는 언제든 바꿀 수 있는 값이 아니다.

일반적으로 다음과 같은 상태에서만 변경할 수 있다.

```text
결제 완료
상품 준비 중
배송 시작 전
```

배송이 이미 시작된 상태에서 주소가 바뀌면 다음 문제가 생길 수 있다.

```text
잘못된 배송
상품 분실
물류 시스템 데이터 불일치
고객센터 책임 분쟁
```

따라서 도메인 객체가 상태 전이를 검증해야 한다.

```java
public void changeAddress(Address newAddress) {
    if (!deliveryStatus.canChangeAddress()) {
        throw new AddressChangeNotAllowedException(
                deliveryStatus
        );
    }

    this.address = newAddress;
}
```

배송 상태 열거형이 변경 가능 여부를 판단할 수도 있다.

```java
public enum DeliveryStatus {

    PAYMENT_COMPLETED(true),
    PREPARING(true),
    SHIPPING(false),
    DELIVERED(false),
    CANCELED(false);

    private final boolean addressChangeable;

    DeliveryStatus(boolean addressChangeable) {
        this.addressChangeable = addressChangeable;
    }

    public boolean canChangeAddress() {
        return addressChangeable;
    }
}
```

이렇게 하면 Controller가 아니라 도메인 규칙으로 보호할 수 있다.

---

## 더 안전한 배송지 변경 구조

앞선 문제를 반영하면 전체 흐름은 다음과 같이 구성할 수 있다.

```mermaid
flowchart LR
    A[인증된 사용자 요청] --> B[입력값 검증]
    B --> C[사용자 ID와 주문 ID로 조회]
    C --> D[주문 소유권 확인]
    D --> E[배송 상태 확인]
    E --> F[주소 값 객체 생성]
    F --> G[주소 변경]
    G --> H[트랜잭션 커밋]
    H --> I[안전한 응답 반환]
```

Service는 트랜잭션 안에서 전체 규칙을 처리한다.

```java
@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;

    @Transactional
    public void changeAddress(
            Long userId,
            Long orderId,
            String rawAddress
    ) {
        Order order = orderRepository
                .findByIdAndUserId(orderId, userId)
                .orElseThrow(OrderNotFoundException::new);

        Address address = Address.of(rawAddress);

        order.changeAddress(address);
    }
}
```

Repository 조회 단계에서 다른 사용자의 주문을 노출하지 않는다.

```java
public interface OrderRepository
        extends JpaRepository<Order, Long> {

    Optional<Order> findByIdAndUserId(
            Long orderId,
            Long userId
    );
}
```

주소 값 객체는 자체 불변식을 검증한다.

```java
@Embeddable
public class Address {

    private static final int MAX_LENGTH = 200;

    @Column(nullable = false, length = MAX_LENGTH)
    private String value;

    protected Address() {
    }

    private Address(String value) {
        validate(value);
        this.value = value;
    }

    public static Address of(String value) {
        return new Address(value);
    }

    private void validate(String value) {
        if (value == null || value.isBlank()) {
            throw new InvalidAddressException();
        }

        if (value.length() > MAX_LENGTH) {
            throw new InvalidAddressException();
        }
    }
}
```

이 구조는 단순한 주소 변경 기능보다 코드가 길다.

하지만 운영 환경에서 필요한 안전성은 정상 흐름 외의 조건을 코드로 명시하는 데서 만들어진다.

---

## 프롬프트 엔지니어링으로 보안을 보완하는 방법

AI가 항상 보안 요구사항을 추론해주기를 기대하기보다, 프롬프트에 보안 조건을 명시하는 것이 효과적이다.

중요한 것은 단순히 다음 문장을 추가하는 것이 아니다.

```text
보안도 고려해줘.
```

보안이라는 표현은 범위가 너무 넓다.

AI가 무엇을 확인해야 하는지 구체적으로 알려주는 것이 좋다.

---

## 전략 1: 처음부터 보안 요구사항을 포함한다

기능 프롬프트에 보안 조건을 함께 전달한다.

좋지 않은 프롬프트는 다음과 같다.

```text
Spring Boot로 주문 배송지 변경 API를 만들어줘.
```

더 나은 프롬프트는 다음과 같다.

```text
Spring Boot 3와 Java 21 환경에서
주문의 배송지 주소를 변경하는 API를 구현해줘.

다음 조건을 반드시 지켜줘.

1. 인증된 사용자만 접근할 수 있어야 한다.
2. 요청자가 해당 주문의 소유자인지 검증해야 한다.
3. 배송이 시작되기 전 상태에서만 주소 변경을 허용해야 한다.
4. 주문이 없거나 권한이 없을 때 내부 정보가 노출되지 않는 예외 응답을 반환해야 한다.
5. 주소는 필수값이며 최대 200자로 제한해야 한다.
6. Controller, Service, Domain, Repository 책임을 분리해야 한다.
7. 트랜잭션 경계를 명확히 설정해야 한다.
8. 스택 트레이스나 SQL 정보가 응답에 포함되지 않도록 해야 한다.
9. 성공, 권한 실패, 존재하지 않는 주문, 배송 시작 후 변경 시도에 대한 테스트를 작성해야 한다.
10. 구현 후 보안상 남아 있는 위험을 별도로 설명해줘.
```

이렇게 작성하면 AI가 놓치기 쉬운 조건을 명시적으로 강제할 수 있다.

---

## 전략 2: 언어와 프레임워크를 구체적으로 지정한다

보안 모범 사례는 언어와 프레임워크마다 다르다.

```text
Java
Spring Boot
Spring Security
JPA
MySQL
```

환경이 명확하면 더 구체적인 결과를 얻을 수 있다.

예를 들어 다음 내용을 요청할 수 있다.

```text
Spring Security의 인증 객체를 사용해 현재 사용자를 식별해줘.
JPA Repository에서 userId와 orderId를 함께 조건으로 조회해줘.
Bean Validation으로 요청 DTO를 검증해줘.
@RestControllerAdvice로 오류 응답을 통일해줘.
```

반대로 환경을 설명하지 않으면 AI가 현재 프로젝트와 맞지 않는 라이브러리나 오래된 방식을 제안할 수 있다.

---

## 전략 3: 코드를 생성한 뒤 별도 보안 리뷰를 요청한다

처음부터 모든 요구사항을 한 번에 넣는 것도 좋지만, 생성 후 별도의 검토 단계를 두는 것이 더 효과적일 수 있다.

```text
1차: 기능 구현
2차: 보안 리뷰
3차: 수정
4차: 테스트 추가
```

보안 리뷰 프롬프트는 다음처럼 작성할 수 있다.

```text
당신은 Java와 Spring Security 경험이 풍부한 애플리케이션 보안 리뷰어다.

아래 코드를 기능 구현 관점이 아니라 공격자 관점에서 검토해줘.

다음 항목을 순서대로 확인해줘.

1. 인증 누락
2. 객체 수준 권한 검증 실패
3. IDOR 가능성
4. 입력값 검증 부족
5. SQL Injection 가능성
6. XSS 저장 가능성
7. 민감정보 및 스택 트레이스 노출
8. 비즈니스 상태 검증 누락
9. 트랜잭션 및 동시성 문제
10. 로그에 개인정보가 기록되는 문제
11. 테스트되지 않은 실패 시나리오

각 문제에 대해 다음 형식으로 답변해줘.

- 위험도
- 문제가 되는 코드
- 공격 시나리오
- 수정 방법
- 수정된 코드
- 추가할 테스트
```

역할, 검토 기준, 출력 형식을 구체적으로 지정하면 결과가 더 체계적이 된다.

---

## 전략 4: 공격 시나리오를 먼저 만들게 한다

방어 코드를 바로 요청하기보다, 먼저 공격자가 어떻게 악용할 수 있는지 분석하게 할 수 있다.

```text
이 API를 공격자 관점에서 분석해줘.
사용자가 다른 사용자의 주문 ID를 추측할 수 있다고 가정해줘.
인증 우회, 권한 검증 실패, 입력값 조작, 상태 변경 우회를 중심으로 공격 시나리오를 만들어줘.
그 후 각 시나리오를 방어하는 코드와 테스트를 작성해줘.
```

이 방식은 정상 흐름 중심의 코드를 실패 흐름 중심으로 다시 바라보게 한다.

---

## 전략 5: 보안 체크리스트를 프로젝트 규칙으로 고정한다

매번 긴 프롬프트를 작성하기 어렵다면 프로젝트 공통 규칙으로 정리할 수 있다.

예를 들어 다음 내용을 AI 도구의 프로젝트 지침에 포함할 수 있다.

```text
모든 API 구현 시 다음을 기본 확인한다.

- 인증과 인가를 구분한다.
- 사용자 소유 리소스는 사용자 ID와 리소스 ID를 함께 검증한다.
- 요청 DTO에 Bean Validation을 적용한다.
- Entity를 직접 요청 및 응답 모델로 사용하지 않는다.
- 예외 응답에 스택 트레이스를 포함하지 않는다.
- 민감정보를 로그로 남기지 않는다.
- 상태 변경 API에는 허용 가능한 상태 전이를 검증한다.
- 데이터 변경은 적절한 트랜잭션 안에서 처리한다.
- 정상 흐름과 실패 흐름 테스트를 함께 작성한다.
- 생성 코드 마지막에 남은 보안 위험을 설명한다.
```

이런 규칙은 AI가 매번 같은 보안 원칙을 고려하도록 유도한다.

---

## 바이브 코딩 보안 프롬프트 예시

다음은 Spring Boot 백엔드 개발에 활용할 수 있는 보안 지향 프롬프트 예시다.

```text
Java 21, Spring Boot 3, Spring Security 6, JPA, MySQL 환경에서 코드를 작성한다.

기능 구현보다 보안과 데이터 무결성을 우선한다.

코드 생성 시 반드시 다음 원칙을 적용한다.

1. 인증과 인가를 분리한다.
2. 리소스 ID만으로 조회하지 말고 요청자의 소유권을 검증한다.
3. 모든 외부 입력에 길이, 형식, 필수값 검증을 적용한다.
4. 엔티티를 API 요청 및 응답에 직접 노출하지 않는다.
5. 비즈니스 상태 전이를 도메인 객체에서 검증한다.
6. 예외 응답에 내부 클래스명, SQL, 스택 트레이스를 노출하지 않는다.
7. 비밀번호, 토큰, 카드 정보, 개인정보를 로그에 남기지 않는다.
8. 데이터 변경 로직에 트랜잭션 경계를 명확히 적용한다.
9. 동시 요청으로 데이터 무결성이 깨질 수 있는지 검토한다.
10. OWASP 주요 취약점 관점에서 생성 코드를 재검토한다.
11. 정상 시나리오뿐 아니라 인증 실패, 권한 실패, 잘못된 입력, 존재하지 않는 리소스, 잘못된 상태에 대한 테스트를 작성한다.
12. 구현 완료 후 발견 가능한 보안 위험과 운영 시 추가 검토사항을 정리한다.
```

프롬프트만으로 안전성이 보장되지는 않지만, 아무 지시 없이 코드를 생성하는 것보다는 훨씬 나은 출발점이 된다.

---

## 프롬프트 엔지니어링의 효과와 한계

보안 지향 프롬프트는 AI가 입력 검증, 권한 확인, 예외 처리 같은 요소를 더 많이 고려하도록 유도할 수 있다.

특히 생성된 코드를 다시 보안 관점에서 검토하게 하는 방식은 최초 생성에서 누락된 문제를 발견하는 데 도움이 된다.

하지만 프롬프트는 보안 솔루션이 아니다.

다음 문제는 여전히 남는다.

```text
존재하지 않는 API를 제안할 수 있다
보안 설정을 잘못 이해할 수 있다
일부 취약점만 수정하고 다른 취약점을 놓칠 수 있다
프로젝트의 실제 인증 구조를 알지 못할 수 있다
라이브러리 버전에 맞지 않는 코드를 생성할 수 있다
코드와 설정 사이의 불일치를 발견하지 못할 수 있다
```

AI가 자신 있게 설명한다고 해서 코드가 안전하다는 뜻은 아니다.

---

## AI가 생성한 코드를 검증하는 실무 방법

보안 프롬프트와 함께 자동화된 검증 절차를 운영해야 한다.

---

## 정적 분석

코드를 실행하지 않고 잠재적인 취약점을 찾는다.

대표적으로 다음 항목을 탐지할 수 있다.

```text
하드코딩된 비밀값
취약한 암호화 방식
SQL 문자열 직접 조합
사용하지 않은 보안 설정
위험한 역직렬화
민감정보 로그 출력
```

CI 파이프라인에 정적 분석 도구를 포함하면 AI가 생성한 코드도 동일한 기준으로 검사할 수 있다.

---

## 의존성 취약점 검사

AI는 현재 취약한 버전이나 오래된 라이브러리를 제안할 수 있다.

따라서 다음 요소를 검사해야 한다.

```text
직접 의존성
전이 의존성
컨테이너 이미지
운영체제 패키지
Gradle 플러그인
```

취약점이 발견되면 자동으로 빌드를 실패시키거나 위험도를 기준으로 알림을 보낼 수 있다.

---

## 비밀정보 검사

다음 정보가 코드 저장소에 포함되지 않았는지 확인해야 한다.

```text
API Key
JWT Secret
DB Password
Access Token
Private Key
클라우드 자격 증명
```

AI가 예시 코드를 만들면서 실제처럼 보이는 값을 설정 파일에 넣는 경우도 있으므로 주의해야 한다.

---

## 보안 테스트

단위 테스트만으로는 권한과 네트워크 경계를 충분히 검증하기 어렵다.

다음 통합 테스트가 필요하다.

```text
인증 없이 요청하면 401인가?
다른 사용자의 주문을 변경하면 403 또는 404인가?
존재하지 않는 주문은 내부 오류 없이 처리되는가?
배송 시작 후 주소 변경이 차단되는가?
잘못된 입력이 400으로 처리되는가?
응답에 스택 트레이스가 포함되지 않는가?
```

Spring MockMvc를 이용하면 엔드포인트 수준에서 검증할 수 있다.

```java
@Test
void 다른_사용자의_주문은_변경할_수_없다() throws Exception {
    mockMvc.perform(
            patch("/orders/{orderId}/address", otherUserOrderId)
                    .with(user(loginUser))
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""
                            {
                              "address": "서울특별시 강남구"
                            }
                            """)
    )
    .andExpect(status().isNotFound());
}
```

리소스 존재 여부를 공격자에게 노출하지 않기 위해 권한 실패 상황에서도 `404 Not Found`를 선택하는 전략이 사용될 수 있다.

---

## 코드 리뷰

AI가 생성한 코드도 사람이 작성한 코드와 동일하게 리뷰해야 한다.

리뷰에서는 다음 질문이 중요하다.

```text
누가 이 기능을 호출할 수 있는가?
어떤 데이터를 변경할 수 있는가?
다른 사용자의 리소스에 접근할 수 있는가?
잘못된 상태에서 실행될 수 있는가?
실패할 때 어떤 정보가 노출되는가?
동시에 요청되면 데이터가 깨지지 않는가?
로그에 민감정보가 남는가?
```

기능 구현 리뷰와 보안 리뷰를 분리해 보는 것도 효과적이다.

---

## 바이브 코딩에서 특히 주의해야 할 보안 영역

AI 생성 코드를 사용할 때는 다음 영역을 우선적으로 검토하는 것이 좋다.

| 영역      | 주요 위험                     |
| ------- | ------------------------- |
| 인증      | 보호되어야 할 API가 공개될 수 있음     |
| 인가      | 다른 사용자의 리소스에 접근할 수 있음     |
| 입력 검증   | 악성값이나 비정상 데이터가 저장될 수 있음   |
| 예외 처리   | 스택 트레이스와 내부 구조가 노출될 수 있음  |
| 비즈니스 규칙 | 허용되지 않은 상태 변경이 가능할 수 있음   |
| 비밀정보    | 키와 비밀번호가 코드에 포함될 수 있음     |
| 로그      | 개인정보와 토큰이 기록될 수 있음        |
| 의존성     | 취약하거나 오래된 라이브러리가 사용될 수 있음 |
| 트랜잭션    | 일부 작업만 반영되어 데이터가 깨질 수 있음  |
| 동시성     | 중복 처리와 무결성 문제가 발생할 수 있음   |

---

## AI에게 맡기기 좋은 것과 맡기기 어려운 것

AI는 다음과 같은 작업에서 높은 생산성을 제공한다.

```text
반복 코드 생성
DTO 초안
테스트 시나리오 초안
리팩토링 후보 제안
코드 설명
문서화
기본 CRUD 구현
```

반면 다음 판단은 개발자가 직접 책임져야 한다.

```text
신뢰 경계 설정
권한 모델 설계
데이터 소유권 판단
암호화 방식 선택
비밀정보 관리
상태 전이 규칙
운영 환경 설정
최종 보안 승인
```

AI는 코드를 만들 수 있지만, 해당 서비스의 실제 위험과 책임 구조를 완전히 이해하지는 못한다.

---

## 구조

안전한 바이브 코딩은 한 번의 프롬프트로 끝나는 과정이 아니다.

```mermaid
flowchart LR
    A[요구사항 정의] --> B[보안 조건 추가]
    B --> C[AI 코드 생성]
    C --> D[AI 보안 자기 검토]
    D --> E[개발자 코드 리뷰]
    E --> F[정적 분석 및 의존성 검사]
    F --> G[보안 테스트]
    G --> H[배포]
    H --> I[모니터링과 감사 로그]
```

핵심은 AI 코드 생성을 개발 과정의 끝이 아니라 시작으로 보는 것이다.

---

## 실무에서의 활용

백엔드 개발자가 바이브 코딩을 활용한다면 다음 흐름이 현실적이다.

```text
1. 기능 요구사항과 보안 요구사항을 함께 작성한다.
2. AI에게 도메인 구조와 기존 인증 방식을 설명한다.
3. 구현 코드를 생성한다.
4. 같은 AI 또는 별도의 검토 단계에서 보안 리뷰를 요청한다.
5. 개발자가 권한, 트랜잭션, 상태 전이를 직접 검토한다.
6. 단위 테스트와 통합 테스트를 작성한다.
7. 정적 분석과 의존성 검사를 실행한다.
8. 코드 리뷰를 거친 뒤 배포한다.
```

AI가 생성한 코드를 그대로 복사해 배포하는 방식은 바이브 코딩이라기보다 검증되지 않은 코드 실행에 가깝다.

생산성을 얻으면서도 안정성을 유지하려면 생성 속도만큼 검증 체계도 강화해야 한다.

---

## 정리

바이브 코딩은 개발자가 원하는 기능을 자연어로 설명하고 AI가 구현을 담당하는 개발 방식이다.

빠르게 코드를 만들 수 있다는 장점이 있지만, AI는 사용자가 명시한 기능 완성에 집중하면서 다음 항목을 놓칠 수 있다.

```text
인증
인가
소유권 검증
입력값 검증
예외 처리
비즈니스 상태 검증
민감정보 보호
트랜잭션과 동시성
```

프롬프트에 보안 요구사항을 구체적으로 포함하고, 생성 후 별도의 보안 리뷰를 수행하면 누락을 줄일 수 있다.

하지만 프롬프트 엔지니어링만으로 보안을 완성할 수는 없다.

```text
AI 생성
+
개발자 검토
+
자동화된 보안 검사
+
통합 테스트
+
운영 모니터링
```

이 과정이 함께 있어야 한다.

바이브 코딩의 핵심 위험은 AI를 사용하는 데 있지 않다.

AI가 생성한 결과를 검증 없이 신뢰하는 데 있다.

### 한 줄 요약

**바이브 코딩은 개발 속도를 높여주지만 보안을 자동으로 보장하지 않으므로, 구체적인 보안 프롬프트와 개발자 검토, 자동화된 검사 체계를 함께 적용해야 한다.**

