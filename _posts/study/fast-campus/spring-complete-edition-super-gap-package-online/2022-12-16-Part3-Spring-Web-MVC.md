---
layout: post
bigtitle: '한 번에 끝내는 Spring 완.전.판 초격차 패키지 Online.'
subtitle: Part 3. Spring Web MVC
date: '2022-12-16 00:00:00 +0900'
categories:
    - study
    - fast-campus
    - spring-complete-edition-super-gap-package-online
comments: true
---

# Part 3. Spring Web MVC

# Part 3. Spring Web MVC
* toc
{:toc}


## API 설계

### 어노테이션 기반 설계 - @Controller, @RestController
+ 컨트롤러 클래스 
  + MVC 패턴 중 핸들러 메소드를 포함하는 컨트롤러 빈을 만드는 과정
  + @Controller
  + @RestController = @ResponseBody + @Controller
+ 핸들러 메소드 (Handler Method)
  + 스프링 웹서비스가 받는 URI 요청을 컨트롤러 클래스의 특정 메소드에 매핑하는 과정
  + @RequestMapping
  + @GetMapping
  + @PostMapping
  + @PutMapping
  + @DeleteMapping
  + @PatchMapping
+ 자동 에러페이지 제거: server.error.whitelabel.enabled=false 
+ 에러 컨트롤러 구현시 implements ErrorController

~~~java

@Controller
public class BaseController implements ErrorController {

    @GetMapping("/")
    public String root() {
        return "index";
    }

    @RequestMapping("/error")
    public String error() {
        return "error";
    }

}

~~~

+ __management.endpoints.web.exposure.include=*__ 같은 경우에는 실제 배포시 성능과 보안 때문에 정리 해주어야 한다.


### 함수 기반 설계

#### 함수형 프로그래밍
+ 함수형 프로그래밍?
  + 함수형 프로그래밍(函數型 프로그래밍, 영어: functional programming)은 자료 처리를 수학적 함수의 계산으로 취급하고 상태와 가변 데이터를 멀리하는 프로그래밍 패러다임의 하나이다.
  + Functional programming is programming without assignment statements.
    + 함수형 프로그래밍은 대입문 없이 프로그래밍하는 것입니다.
  + 특징
    + 상태가 없다.
    + 대입문이 없다.
    + 부작용(side effect)이 없는 순수 함수
    + 불변성(immutability)
  + 역사: 오래되었다
    + 1930 람다 대수
    + 1954 IPL
    + 1958 LISP
    + 1990 Haskell
    
#### 함수 기반 설계
+ 함수형 엔드포인트
  + Spring Web 의 엔드포인트를 함수형 스타일로 작성하는 방법 제공
  + WebMvc.fn
  + routing, request handling
  + 불변성을 고려하여 설계되었다.
  + 기존의 DispatcherServlet 위에서 동작
  + 애노테이션 스타일과 함께 사용 가능
+ 주요 키워드
  + HandlerFunction == @RequestMapping
    + 입력: ServerRequest
    + 출력: ServerResponse
  + RouterFunction == @RequestMapping
    + 입력: ServerRequest
    + 출력: Optional<HandlerFunction>
  + HandlerFunction VS RouterFunction
    + HandlerFunction의 결과: data
    + RouterFunction의 결과: data + behavior (ex: url mapping)
  + 기타 세부 키워드
    + RequestPredicates
    + RouterFunctions.route().nest()
    + RouterFunctions.route().before()
    + RouterFunctions.route().after()
    + RouterFunctions.Builder.onError()
    + RouterFunctions.Builder.filter()

#### Reference
+ [https://ko.wikipedia.org/wiki/%ED%95%A8%EC%88%98%ED%98%95_%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%98%EB%B0%8D](https://ko.wikipedia.org/wiki/%ED%95%A8%EC%88%98%ED%98%95_%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%98%EB%B0%8D)
+ [https://en.wikipedia.org/wiki/Functional_programming](https://en.wikipedia.org/wiki/Functional_programming)
+ [https://blog.cleancoder.com/uncle-bob/2012/12/22/FPBE1-Whats-it-all-about.html](https://blog.cleancoder.com/uncle-bob/2012/12/22/FPBE1-Whats-it-all-about.html)
+ [https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#webmvc-fn](https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#webmvc-fn)