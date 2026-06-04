---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 피트의 CORS 에러, 왜 우리를 괴롭힐까?
date: '2026-06-04 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true

---

# 피트의 CORS 에러, 왜 우리를 괴롭힐까?
[https://youtu.be/0jLxWJUlZLs?si=_knBsq3bCPqGc_YW](https://youtu.be/0jLxWJUlZLs?si=_knBsq3bCPqGc_YW)

# 피트의 CORS 에러, 왜 우리를 괴롭힐까?
* toc
{:toc}

---

## CORS 에러는 왜 발생할까?

웹 개발을 하다 보면 서버도 정상이고 코드도 문제없어 보이는데, 브라우저 콘솔에 이런 에러가 뜰 때가 있다.

```text
Blocked by CORS policy
```

이 에러는 API 자체가 반드시 잘못되었다는 뜻은 아니다.
대부분은 **브라우저의 보안 정책** 때문에 발생한다.

CORS를 이해하려면 먼저 **SOP(Same-Origin Policy, 동일 출처 정책)** 를 알아야 한다.

---

## CORS란 무엇인가

CORS는 **Cross-Origin Resource Sharing**의 약자다.

의미는 다음과 같다.

```text
브라우저가 자신의 출처가 아닌
다른 출처의 리소스를 가져올 수 있도록
서버가 허용해주는 메커니즘
```

여기서 중요한 점은 “허용”이라는 표현이다.

즉, 원래 브라우저는 다른 출처의 리소스 접근을 기본적으로 제한한다.
그리고 서버가 명시적으로 허용했을 때만 브라우저가 응답을 사용할 수 있다.

---

## SOP란 무엇인가

SOP는 **Same-Origin Policy**, 즉 동일 출처 정책이다.

브라우저의 기본 보안 정책으로, 같은 출처끼리만 리소스를 주고받을 수 있도록 제한한다.

```text
같은 출처 → 허용
다른 출처 → 기본 차단
```

결국 CORS 에러는 SOP 때문에 발생한다.

브라우저가 다른 출처의 리소스를 막고, 서버가 이를 허용하지 않았기 때문에 에러가 나는 것이다.

---

## Origin이란 무엇인가

Origin, 즉 출처는 다음 세 가지로 구성된다.

```text
프로토콜 + 호스트 + 포트
```

예를 들어 다음 URL이 있다고 하자.

```text
https://www.example.com:8000
```

이 경우 출처는 다음 세 가지다.

```text
프로토콜: https
호스트: www.example.com
포트: 8000
```

이 중 하나라도 다르면 브라우저는 다른 출처로 판단한다.

---

## 동일 출처와 다른 출처 예시

기준 출처가 다음과 같다고 하자.

```text
https://www.example.com:8000
```

아래는 동일 출처다.

```text
https://www.example.com:8000/page1
https://www.example.com:8000/page2
```

경로만 다르기 때문에 출처는 같다.

반면 아래는 다른 출처다.

```text
http://www.example.com:8000
https://sub.example.com:8000
https://www.example.com:8080
```

각각 프로토콜, 호스트, 포트가 다르기 때문이다.

---

## 왜 SOP가 필요할까?

SOP는 개발자를 괴롭히기 위한 정책이 아니다.
사용자를 보호하기 위한 브라우저 보안 정책이다.

예를 들어 사용자가 은행 사이트에 로그인한 상태라고 해보자.

```text
bank.com 로그인 완료
→ 브라우저에 인증 쿠키 존재
```

그 상태에서 악성 사이트인 `evil.com`에 접속했다.

악성 사이트 안에 이런 요청을 보내는 스크립트가 숨어 있다고 가정해보자.

```text
bank.com으로 송금 요청
```

만약 브라우저가 다른 출처 요청을 아무 제한 없이 허용한다면, 악성 사이트는 사용자의 인증 쿠키를 이용해 은행 서버로 요청을 보낼 수 있다.

은행 서버는 이를 로그인된 사용자의 정상 요청으로 오해할 수 있다.

즉 SOP가 없다면 다음과 같은 공격이 가능해진다.

```text
사용자 로그인 상태 악용
→ 악성 사이트에서 타 사이트로 요청
→ 인증 쿠키 자동 포함
→ 피해 발생
```

그래서 브라우저는 기본적으로 다른 출처 요청을 막는다.

---

## 그런데 왜 CORS가 필요할까?

현대 웹에서는 다른 출처의 리소스를 사용하는 일이 너무 흔하다.

예를 들면 다음과 같다.

```text
프론트엔드 서버와 백엔드 API 서버 분리
CDN 이미지 사용
Google Fonts 사용
외부 API 호출
```

만약 SOP가 모든 다른 출처 요청을 무조건 막는다면, 현대 웹 애플리케이션은 제대로 동작하기 어렵다.

그래서 등장한 것이 CORS다.

CORS는 SOP를 없애는 것이 아니라, **서버가 명시적으로 허용한 다른 출처 요청만 안전하게 허용하는 방식**이다.

---

## CORS는 에러가 아니라 해결 메커니즘이다

많은 개발자가 CORS를 “에러 이름”처럼 생각한다.

하지만 정확히는 CORS 자체가 에러가 아니다.

```text
SOP = 기본 차단 정책
CORS = 다른 출처 요청을 허용하기 위한 메커니즘
CORS 에러 = 허용 정보가 없거나 잘못되어 브라우저가 차단한 결과
```

즉 문제의 본질은 다음과 같다.

```text
브라우저가 다른 출처 요청을 보냈다
서버 응답에 허용 정보가 부족했다
브라우저가 응답 사용을 차단했다
```

---

## CORS 동작 시나리오 1: Preflight Request

첫 번째는 **Preflight Request**, 즉 예비 요청이다.

브라우저가 실제 요청을 보내기 전에 서버에 먼저 물어보는 방식이다.

```text
“이런 메서드와 헤더로 요청을 보내도 되나요?”
```

이때 브라우저는 `OPTIONS` 메서드로 예비 요청을 보낸다.

---

## Preflight Request 흐름

전체 흐름은 다음과 같다.

```text
1. JavaScript에서 fetch 또는 axios로 API 요청
2. 브라우저가 OPTIONS 예비 요청 전송
3. 서버가 허용 가능한 Origin, Method, Header 응답
4. 브라우저가 응답 검증
5. 허용되면 실제 요청 전송
6. 서버가 실제 응답 반환
```

예비 요청은 본 요청 전에 안전성을 확인하기 위한 절차다.

---

## Preflight 요청 예시

브라우저는 다음과 같은 요청을 먼저 보낼 수 있다.

```http
OPTIONS /likes HTTP/1.1
Origin: https://frontend.example.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type, Authorization
```

서버는 다음처럼 응답해야 한다.

```http
Access-Control-Allow-Origin: https://frontend.example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

이 응답을 보고 브라우저가 허용 여부를 판단한다.

---

## CORS 동작 시나리오 2: Simple Request

두 번째는 **Simple Request**, 즉 단순 요청이다.

단순 요청은 예비 요청 없이 바로 본 요청을 보내고, 서버 응답을 받은 뒤 CORS 위반 여부를 검사한다.

하지만 조건이 매우 까다롭다.

---

## Simple Request 조건

메서드는 다음 중 하나여야 한다.

```text
GET
HEAD
POST
```

그리고 `Content-Type`은 다음 중 하나여야 한다.

```text
text/plain
multipart/form-data
application/x-www-form-urlencoded
```

하지만 실제 API 개발에서는 대부분 다음을 사용한다.

```http
Content-Type: application/json
```

이 경우 단순 요청 조건을 만족하지 않기 때문에 Preflight 요청이 발생한다.

그래서 현대 웹 개발에서는 Simple Request를 자주 만나기 어렵다.

---

## CORS 동작 시나리오 3: Credentialed Request

세 번째는 **Credentialed Request**, 즉 인증된 요청이다.

쿠키나 인증 헤더 같은 자격 증명 정보를 포함하는 요청이다.

예를 들면 다음과 같다.

```text
세션 쿠키
JWT 쿠키
Authorization 헤더
```

인증 정보가 포함되기 때문에 더 엄격한 규칙이 적용된다.

---

## 클라이언트 설정

`fetch`를 사용한다면 다음 설정이 필요하다.

```javascript
fetch("https://api.example.com/me", {
  credentials: "include"
});
```

`axios`를 사용한다면 다음과 같다.

```javascript
axios.get("https://api.example.com/me", {
  withCredentials: true
});
```

이 설정을 해야 브라우저가 인증 정보를 함께 보낸다.

---

## 서버 설정

서버는 반드시 다음 헤더를 내려줘야 한다.

```http
Access-Control-Allow-Credentials: true
```

그리고 인증된 요청에서는 와일드카드 `*`를 사용할 수 없다.

잘못된 설정은 다음과 같다.

```http
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
```

올바른 설정은 다음처럼 구체적인 Origin을 명시하는 것이다.

```http
Access-Control-Allow-Origin: https://frontend.example.com
Access-Control-Allow-Credentials: true
```

인증 정보를 다루기 때문에 브라우저가 더 엄격하게 검사하는 것이다.

---

## CORS 에러 해결 방법 1: 프록시 서버 활용

첫 번째 해결 방법은 프록시 서버를 두는 것이다.

핵심 원리는 다음과 같다.

```text
SOP는 브라우저 정책이다
서버와 서버 간 통신에는 적용되지 않는다
```

구조는 다음과 같다.

```text
브라우저
→ 로컬 프록시 서버
→ 실제 타겟 서버
```

브라우저는 같은 출처의 로컬 프록시 서버로 요청한다.
프록시 서버가 대신 타겟 서버에 요청하고 응답을 받아 브라우저에게 전달한다.

브라우저 입장에서는 다른 출처에 직접 요청한 것이 아니므로 SOP를 위반하지 않는다.

---

## 프록시 방식이 적합한 경우

프록시 방식은 특히 개발 환경에서 자주 사용된다.

```text
프론트 개발 서버: localhost:3000
백엔드 서버: localhost:8080
```

이 둘은 포트가 다르므로 다른 출처다.

이때 프론트 개발 서버에서 프록시 설정을 해두면, 브라우저는 `localhost:3000`으로 요청하고, 개발 서버가 `localhost:8080`으로 우회 요청을 보내준다.

다만 운영 환경에서는 서버 CORS 설정을 명확히 하는 것이 더 정석적인 방법이다.

---

## CORS 에러 해결 방법 2: 서버 응답 헤더 설정

가장 정석적인 해결 방법은 서버에서 CORS 응답 헤더를 올바르게 설정하는 것이다.

핵심 헤더는 다음과 같다.

```http
Access-Control-Allow-Origin: https://frontend.example.com
```

추가로 필요한 헤더는 다음과 같다.

```http
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Allow-Credentials: true
```

서버는 “어떤 출처, 어떤 메서드, 어떤 헤더를 허용할지”를 명확히 알려줘야 한다.

---

## 서버에서 CORS를 설정하는 방식

대표적인 방법은 세 가지다.

## 1. 코드에서 직접 헤더 설정

서버 응답에 직접 CORS 헤더를 추가한다.

## 2. 프레임워크 기능 사용

예를 들어 Express라면 `cors` 미들웨어를 사용할 수 있다.

Spring Boot라면 `@CrossOrigin`, `CorsRegistry`, `CorsConfigurationSource` 등을 사용할 수 있다.

## 3. 허용 Origin을 동적으로 관리

허용할 출처 목록을 DB나 설정 파일에서 가져와 동적으로 검증할 수도 있다.

운영 환경에서 여러 프론트 도메인을 관리해야 할 때 유용하다.

---

## 프론트엔드와 백엔드가 맞춰야 하는 것

CORS 문제는 한쪽만의 문제가 아니다.

프론트엔드는 다음을 백엔드에 정확히 알려줘야 한다.

```text
배포 도메인
사용할 HTTP Method
사용할 Header
쿠키 또는 인증 정보 포함 여부
```

백엔드는 이를 기반으로 다음을 정확히 설정해야 한다.

```text
Access-Control-Allow-Origin
Access-Control-Allow-Methods
Access-Control-Allow-Headers
Access-Control-Allow-Credentials
```

특히 인증 요청에서는 프론트와 백엔드 설정이 반드시 같이 맞아야 한다.

---

## 자주 발생하는 CORS 실수

## 1. Origin에 와일드카드 사용

인증 정보를 포함하지 않는 요청에서는 가능할 수 있지만, 인증 요청에서는 사용할 수 없다.

```http
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
```

이 조합은 브라우저가 차단한다.

---

## 2. OPTIONS 요청을 서버가 막음

Preflight 요청은 `OPTIONS` 메서드를 사용한다.

그런데 서버나 보안 설정에서 `OPTIONS`를 막으면 본 요청까지 도달하지 못한다.

---

## 3. Authorization 헤더 허용 누락

JWT를 Authorization 헤더로 보낼 경우 서버가 다음을 허용해야 한다.

```http
Access-Control-Allow-Headers: Authorization
```

이 설정이 빠지면 Preflight에서 막힌다.

---

## 4. credentials 설정 불일치

프론트에서 `credentials: "include"`를 설정했는데 서버가 다음을 내려주지 않으면 실패한다.

```http
Access-Control-Allow-Credentials: true
```

반대로 서버는 credentials를 허용했는데 Origin을 `*`로 주면 역시 실패한다.

---

## CORS는 어디서 발생하는가

중요한 점은 CORS는 브라우저에서 발생한다는 것이다.

그래서 Postman이나 curl로 요청하면 정상인데, 브라우저에서만 실패할 수 있다.

```text
Postman: SOP 적용 안 됨
curl: SOP 적용 안 됨
서버 간 통신: SOP 적용 안 됨
브라우저: SOP 적용됨
```

이 차이를 이해하면 CORS 에러를 훨씬 빠르게 진단할 수 있다.

---

## CORS 디버깅 체크리스트

CORS 에러를 만나면 다음 순서로 확인하면 좋다.

```text
1. 요청 Origin이 무엇인지 확인한다
2. 서버 응답에 Access-Control-Allow-Origin이 있는지 확인한다
3. 실제 Origin과 Allow-Origin 값이 일치하는지 확인한다
4. Preflight OPTIONS 요청이 성공하는지 확인한다
5. 사용하는 Method가 Allow-Methods에 포함되어 있는지 확인한다
6. 사용하는 Header가 Allow-Headers에 포함되어 있는지 확인한다
7. 쿠키/인증 요청이면 Allow-Credentials가 true인지 확인한다
8. 인증 요청에서 Allow-Origin이 *가 아닌지 확인한다
```

---

## 마무리

CORS 에러는 서버가 무조건 잘못되었다는 뜻이 아니다.
브라우저가 SOP에 따라 다른 출처의 리소스 접근을 제한했고, 서버가 이를 명시적으로 허용하지 않았기 때문에 발생한다.

정리하면 다음과 같다.

```text
SOP는 다른 출처 요청을 기본적으로 막는 브라우저 보안 정책이다
CORS는 서버가 허용한 다른 출처 요청을 가능하게 하는 메커니즘이다
Origin은 프로토콜, 호스트, 포트로 구성된다
CORS 요청은 Preflight, Simple, Credentialed 시나리오로 나뉜다
해결 방법은 프록시 우회 또는 서버 응답 헤더 설정이다
```

결국 CORS 해결에서 가장 중요한 것은 프론트엔드와 백엔드가 요청 출처, 인증 여부, 허용 메서드와 헤더를 정확히 맞추는 것이다.

