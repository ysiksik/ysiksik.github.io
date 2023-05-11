---
layout: post
bigtitle: '스프링 MVC 2편 - 백엔드 웹 개발 핵심 기술'
subtitle: 타임리프 - 기본 기능
date: '2023-05-11 00:00:00 +0900'
categories:
- spring-mvc-part2
comments: true

---

# 타임리프 - 기본 기능

# 타임리프 - 기본 기능 
* toc
{:toc}


## 프로젝트 생성
+ 스프링 부트 3.0
  + Java 17 이상을 사용해야 한다
  + javax 패키지 이름을 jakarta로 변경해야 한다
    + 오라클과 자바 라이센스 문제로 모든 javax 패키지를 jakarta로 변경하기로 했다
  + 스프링 부트 3.0 관련 자세한 내용 [https://bit.ly/springboot3](https://bit.ly/springboot3)
+ IntelliJ Gradle 대신에 자바 직접 실행
  + 최근 IntelliJ 버전은 Gradle을 통해서 실행 하는 것이 기본 설정이다. 이렇게 하면 실행속도가 느리다. 
  + Preferences -> Build, Execution, Deployment -> Build Tools -> Gradle
    + Build and run using: Gradle -> IntelliJ IDEA
    + Run tests using: Gradle -> IntelliJ IDEA

## 타임리프 특징
+ 서버 사이드 HTML 렌더링 (SSR)
  + 타임리프는 백엔드 서버에서 HTML을 동적으로 렌더링 하는 용도로 사용된다
+ 네츄럴 템플릿
  + 타임리프는 순수 HTML을 최대한 유지하는 특징이 있다
  + 타임리프로 작성한 파일은 HTML을 유지하기 때문에 웹 브라우저에서 파일을 직접 열어도 내용을 확인할 수 있고, 서버를 통해 뷰 템플릿을 거치면 동적으로 변경된 결과를 확인할 수 있다
  + JSP를 포함한 다른 뷰 템플릿들은 해당 파일을 열면, 예를 들어서 JSP 파일 자체를 그대로 웹 브라우저에서 열어보면 JSP 소스코드와 HTML이 뒤죽박죽 섞여서 웹 브라우저에서 정상적인 HTML 결과를 확인할 수 없다
  + 오직 서버를 통해서 JSP가 렌더링 되고 HTML 응답 결과를 받아야 화면을 확인할 수 있다
  + 반면에 타임리프로 작성된 파일은 해당 파일을 그대로 웹 브라우저에서 열어도 정상적인 HTML 결과를 확인할 수 있다
  + 물론 이 경우 동적으로 결과가 렌더링 되지는 않는다. 하지만 HTML 마크업 결과가 어떻게 되는지 파일만 열어도 바로 확인할 수 있다
  + 이렇게 순수 HTML을 그대로 유지하면서 뷰 템플릿도 사용할 수 있는 타임리프의 특징을 네츄럴 템플릿(natural templates)이라 한다
+ 스프링 통합 지원
  + 타임리프는 스프링과 자연스럽게 통합되고, 스프링의 다양한 기능을 편리하게 사용할 수 있게 지원한다

### 타임리프 기본 기능
+ 타임리프 사용 선언
  + ``` <html xmlns:th="http://www.thymeleaf.org"> ```
  
~~~
+ 기본 표현식
  + 간단한 표현:
    + 변수 표현식: ${...}
    + 선택 변수 표현식: *{...}
    + 메시지 표현식: #{...}
    + 링크 URL 표현식: @{...}
    + 조각 표현식: ~{...}
  + 리터럴
    + 텍스트: 'one text', 'Another one!',…
    + 숫자: 0, 34, 3.0, 12.3,…
    + 불린: true, false
    + 널: null
    + 리터럴 토큰: one, sometext, main,…
  + 문자 연산:
    + 문자 합치기: +
    + 리터럴 대체: |The name is ${name}|
  + 산술 연산:
    + Binary operators: +, -, *, /, %
    + Minus sign (unary operator): -
  + 불린 연산:
    + Binary operators: and, or
    + Boolean negation (unary operator): !, not
  + 비교와 동등:
    + 비교: >, <, >=, <= (gt, lt, ge, le)
    + 동등 연산: ==, != (eq, ne)
  + 조건 연산:
    + If-then: (if) ? (then)
    + If-then-else: (if) ? (then) : (else)
    + Default: (value) ?: (defaultvalue)
  + 특별한 토큰:
    + No-Operation: _
  + [https://www.thymeleaf.org/doc/tutorials/3.0/usingthymeleaf.html#standard-expression-syntax](https://www.thymeleaf.org/doc/tutorials/3.0/usingthymeleaf.html#standard-expression-syntax) 
~~~

## 텍스트 - text, utext
+ 타임리프는 기본적으로 HTML 테그의 속성에 기능을 정의해서 동작한다
+ HTML의 콘텐츠(content)에 데이터를 출력할 때는 다음과 같이 th:text 를 사용하면 된다
  + ```<span th:text="${data}">```  
+ HTML 테그의 속성이 아니라 HTML 콘텐츠 영역안에서 직접 데이터를 출력하고 싶으면 다음과 같이 ``` [[...]] ``` 를 사용하면 된다.
  + ``` 컨텐츠 안에서 직접 출력하기 = [[${data}]] ```
+ Escape
  + HTML 문서는 ```<``` , ```>``` 같은 특수 문자를 기반으로 정의된다. 따라서 뷰 템플릿으로 HTML 화면을 생성할 때는 출력하는 데이터에 이러한 특수 문자가 있는 것을 주의해서 사용해야 한다.
+ HTML 엔티티
  + 웹 브라우저는 ```<``` 를 HTML 테그의 시작으로 인식한다. 따라서 ```<``` 를 테그의 시작이 아니라 문자로 표현할 수 있는 방법이 필요한데, 이것을 HTML 엔티티라 한다
  + 그리고 이렇게 HTML에서 사용하는 특수 문자를 HTML 엔티티로 변경하는 것을 이스케이프(escape)라 한다. 그리고 타임리프가 제공하는 ```th:text``` ,```[[...]]``` 는 기본적으로 이스케이스(escape)를 제공한다
+ Unescape
  + 이스케이프 기능을 사용하지 않으려면 타임리프는 다음 두 기능을 제공한다
  + ```th:text``` -> ```th:utext```
  + ```[[...]]``` ->  ```[(...)]```
+ ```th:inline="none"``` : 타임리프는 ```[[...]]``` 를 해석하기 때문에, 화면에 ```[[...]]``` 글자를 보여줄 수 없다. 이 테그 안에서는 타임리프가 해석하지 말라는 옵션이다
+ 실제 서비스를 개발하다 보면 escape를 사용하지 않아서 HTML이 정상 렌더링 되지 않는 수 많은 문제가 발생한다. escape를 기본으로 하고, 꼭 필요한 때만 unescape를 사용하자

## 변수 - SpringEL

+ 변수 표현식 : ```${...}```
  + 이 변수 표현식에는 스프링 EL이라는 스프링이 제공하는 표현식을 사용할 수 있다.


~~~html

<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8">
  <title>Title</title>
</head>
<body>
<h1>SpringEL 표현식</h1>
<ul>Object
  <li>${user.username} = <span th:text="${user.username}"></span></li>
  <li>${user['username']} = <span th:text="${user['username']}"></span></li>
  <li>${user.getUsername()} = <span th:text="${user.getUsername()}"></span></li>
</ul>
<ul>List
  <li>${users[0].username} = <span th:text="${users[0].username}"></span></li>
  <li>${users[0]['username']} = <span th:text="${users[0]['username']}"></span></li>
  <li>${users[0].getUsername()} = <span th:text="${users[0].getUsername()}"></span></li>
</ul>
<ul>Map
  <li>${userMap['userA'].username} = <span th:text="${userMap['userA'].username}"></span></li>
  <li>${userMap['userA']['username']} = <span th:text="${userMap['userA']['username']}"></span></li>
  <li>${userMap['userA'].getUsername()} = <span th:text="${userMap['userA'].getUsername()}"></span></li>
</ul>
</body>
</html>

~~~

### SpringEL 다양한 표현식 사용
+ Object
  + ```user.username``` : user의 username을 프로퍼티 접근 -> ```user.getUsername()```
  + ```user['username']``` : 위와 같음 -> ```user.getUsername()```
  + ```user.getUsername()``` : user의 ```getUsername()``` 을 직접 호출
+ List
  + ```users[0].username``` : List에서 첫 번째 회원을 찾고 username 프로퍼티 접근 -> ```list.get(0).getUsername()```
  + ```users[0]['username']``` : 위와 같음
  + ```users[0].getUsername()``` : List에서 첫 번째 회원을 찾고 메서드 직접 호출
+ Map
  + ```userMap['userA'].username``` : Map에서 userA를 찾고, username 프로퍼티 접근 -> ```map.get("userA").getUsername()```
  + ```userMap['userA']['username']``` : 위와 같음
  + ```userMap['userA'].getUsername()``` : Map에서 userA를 찾고 메서드 직접 호출

### 지역 변수 선언
+ ```th:with``` 를 사용하면 지역 변수를 선언해서 사용할 수 있다. 지역 변수는 선언한 테그 안에서만 사용할 수 있다.

~~~html

<h1>지역 변수 - (th:with)</h1>
<div th:with="first=${users[0]}">
 <p>처음 사람의 이름은 <span th:text="${first.username}"></span></p>
</div>

~~~

## 기본 객체들
+ 타임리프는 기본 객체들을 제공한다.
+ ```${#request}``` - 스프링 부트 3.0부터 제공하지 않는다.
+ ```${#response}``` - 스프링 부트 3.0부터 제공하지 않는다.
+ ```${#session}``` - 스프링 부트 3.0부터 제공하지 않는다.
+ ```${#servletContext}``` - 스프링 부트 3.0부터 제공하지 않는다.
+ ```${#locale}```

+ 스프링 부트 3.0
  + 스프링 부트 3.0 부터는 ${#request} , ${#response} , ${#session} , ${#servletContext} 를 지원하지 않는다.
  + 스프링 부트 3.0이라면 직접 model 에 해당 객체를 추가해서 사용해야 한다. 
+ ```#request``` 는 ```HttpServletRequest``` 객체가 그대로 제공되기 때문에 데이터를 조회하려면 ```request.getParameter("data")``` 처럼 불편하게 접근해야 한다
+ 이런 점을 해결하기 위해 편의 객체도 제공한다
  + HTTP 요청 파라미터 접근: ```param```
    + 예) ```${param.paramData}```
  + HTTP 세션 접근: ```session```
    + 예) ```${session.sessionData}```
  + 스프링 빈 접근: ```@```
    + 예) ```${@helloBean.hello('Spring!')}```

### 스프링 부트 3.0 미만이라면 다음과 같이 작성하자

~~~html

<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8">
  <title>Title</title>
</head>
<body>
<h1>식 기본 객체 (Expression Basic Objects)</h1>
<ul>
  <li>request = <span th:text="${#request}"></span></li>
  <li>response = <span th:text="${#response}"></span></li>
  <li>session = <span th:text="${#session}"></span></li>
  <li>servletContext = <span th:text="${#servletContext}"></span></li>
  <li>locale = <span th:text="${#locale}"></span></li>
</ul>
<h1>편의 객체</h1>
<ul>
  <li>Request Parameter = <span th:text="${param.paramData}"></span></li>
  <li>session = <span th:text="${session.sessionData}"></span></li>
  <li>spring bean = <span th:text="${@helloBean.hello('Spring!')}"></span></li>
</ul>
</body>
</html>

~~~

### 스프링 부트 3.0 이상이라면 다음과 같이 작성하자

~~~java

@GetMapping("/basic-objects")
public String basicObjects(Model model,HttpServletRequest request,
        HttpServletResponse response,HttpSession session){
        session.setAttribute("sessionData","Hello Session");
        model.addAttribute("request",request);
        model.addAttribute("response",response);
        model.addAttribute("servletContext",request.getServletContext());
        return"basic/basic-objects";
        }

@Component("helloBean")
static class HelloBean {
  public String hello(String data) {
    return "Hello " + data;
  }
}

~~~

~~~html

<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8">
  <title>Title</title>
</head>
<body>
<h1>식 기본 객체 (Expression Basic Objects)</h1>
<ul>
  <li>request = <span th:text="${request}"></span></li>
  <li>response = <span th:text="${response}"></span></li>
  <li>session = <span th:text="${session}"></span></li>
  <li>servletContext = <span th:text="${servletContext}"></span></li>
  <li>locale = <span th:text="${#locale}"></span></li>
</ul>
<h1>편의 객체</h1>
<ul>
  <li>Request Parameter = <span th:text="${param.paramData}"></span></li>
  <li>session = <span th:text="${session.sessionData}"></span></li>
  <li>spring bean = <span th:text="${@helloBean.hello('Spring!')}"></span></li>
</ul>
</body>
</html>

~~~
