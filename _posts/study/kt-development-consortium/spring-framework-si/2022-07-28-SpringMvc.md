---
layout: post
bigtitle: 'Spring 전자정부 프레임워크 기반 SI 실무'
subtitle: Spring MVC
date: '2022-07-28 00:00:00 +0900'
categories:
    - study
    - kt-development-consortium
    - spring-framework-si
tags: spring
comments: true
---

# Spring MVC

# Spring MVC
* toc
{:toc}

## MVC Pattern 개념
+ MVC(Model-View-Controller) Pattern
  + Model
    + 어플리케이션 상태의 캡슐화
    + 상태 쿼리에 대한 응답
    + 어플레케이션의 기능 표현
    + 변경을 view에 통지
  + View
    + 모델을 화면에 시각적으로 표현
    + 모델에게 업데이트 요청
    + 사용자 입력을 컨트롤러에 전달
    + 컨트롤러가 view를 선태하도록 허용
  + Controller
    + 어플리케이션 행위 정의
    + 사용자 액션을 모델 업데이트와 mapping
    + 응답에 대한 view 선택
  + 어플리케이션의 확장을 위해 Model, View, Controller 세가지 영역으로 분리
  + 컴포넌트의 변경이 다른 영역 컴포넌트에 영향을 미치지 않음(유지보수 용이)
  + 컴포넌트 간의 결합성이 낮아 프로그램 수정이 용이(확장성이 뛰어남)
  + 장점
    + 화면과 비지니스 로직을 분리해서 작업 가능
    + 영역별 개발로 인하여 확장성이 뛰어남
    + 표준화된 코드를 사용하므로 공동작업이 용이하고 유지보수성이 좋음
  + 단점
    + 개발과정이 복잡해 초기 개발속도가 늦음
    + 초보자가 이해하고 개발하기에 다소 어려움
+ Model 2 (Web MVC) 요청 흐름
![MVC](/assets/img/springFramework/mvc.png)

## Spring MVC
+ Spring MVC 특징
  + Spring은 DI나 AOP같은 기능뿐만 아니라 Servlet 기반의 WEB 개발을 위한 MVC Framework를 제공 
  + Spring MVC는 Model2 Architecture와 Front Controller Pattern을 Framework 차원에서 제공
  + Spring MVC는 Framework는 Spring을 기반으로 하고 있기 때문에 Spring이 제공하는 Transaction 처리나 DI 및 AOP등을 손쉽게 사용
+ Spring MVC와 Front Controller Pattern
  + 대부분의 MVC Framework들은 Front Controller Pattern을 적용해서 구현
  + Spring MVC도 Front Controller 역할을 하는 DispatcherServlet이라는 Class를 계층 맨 앞단에 놓고, 서버로 들어오는 모든 요청을 받아서 처리하도록 구성.
  + 예외가 발생했을 때 일관된 방식으로 처리하는 것도 Front Controller의 역할
+ Spring MVC의 구성요소
  + DispatcherServlet (Front Controller)
    + 모든 클라이언트 요청을 전달받음
    + Controller에게 클라이언트의 요청을 전달하고, Controller가 리턴한 결과값을 View에게 전달하여 알맞은 응답을 생성
  + HandlerMapping
    + 클라이언트의 요청 URL을 어떤 Controller가 처리할지를 결정
    + URL과 요청 정보를 기준으로 어떤 핸들러 객체를 사용할지 결정하는 객체이며, DispatcherServlet은 하나 이상의 핸들러 매핑을 가질 수 있음
  + Controller
    + 클라이너트의 요청을 처리한 뒤 Model을 호출하고 그 결과를 DispatcherServlet에 알려준다.
  + ModelAndView
    + Controller가 처리한 데이터 및 화면에 대한 정보를 보유한 객체.
  + ViewResolver
    + Controller가 리턴한 뷰 이름을 기반으로 Controller의 처리 결과를 보여줄 View를 결정
  + View
    + Controller의 처리결과를 보여줄 응답화면을 생성
+ Spring MVC 요청 흐름
+ ![MVC](/assets/img/springFramework/mvc2.png)
+ Spring MVC 실행 순서
+ ![MVC](/assets/img/springFramework/mvc3.png)
  1. DispatcherServlet이 요청을 수신
     + 단일 Front Controller Servlet
     + 요청을 수신하여 처리를 다른 컴포넌트에 위임
     + 어느 Controller에 요청을 전송할지 결정
  2. DispatcherServlet은 Handler Mapping에 어느 Controller를 사용할 것인지 문의
     + URL과 Mapping
  3. DispatcherServlet은 요청을 Controller에게 전송하고 Controller는 요청을 처리한 후 결과 리턴
     + Business Logic 수행 후 결과 정보(Model)가 생성되어 JSP와 같은 view에게 사용됨.
  4. ModelAndView Object에 수행결과가 포함되어 DispatcherServlet에 리턴
  5. ModelAndView는 실제 JSP정보를 갖고 있지 않으며, ViewResolver가 논리적 이름을 실제 JSP이름으로 변환
  6. View는 결과정보를 사용하여 화면을 표현함.

## @Controller
+ Controller method의 parameter type
  + Controller method의 parameter로 다양항 Object를 받을 수 있다

| Parameter Type                                        | 설명                                                                                                |
|-------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| HttpServletRequest, HttpServletResponse, HttpSession  | 필요시 Servlet API를 사용할 수 잇음                                                                         |
| Java.util.Locale                                      | 현재 요청에 대한 Locale                                                                                  |
| InputStream, Reader                                   | 요청 컨텐츠에 직접 접근할 때 사용                                                                               |
| OutputStream, Writer                                  | 응답 컨텐츠를 생성할 때 상용                                                                                  |
| @PathVariable annotation 적용 파라미터                      | URI 템플릿 변수에 접근할 때 사용                                                                              |
| @RequestParam annotation 적용 파라미터                      | HTTP 요청 파라미터를 매핑                                                                                  |
| @RequestHeader annotation 적용 파라미터                     | HTTP 요청 헤더를 매핑                                                                                    |
| @CookieValue annotation 적용 파라미터                       | HTTP 쿠키 매핑                                                                                        |
| @RequestBody annotation 적용 파라미터                       | HTTP 요청의 몸체 내용에 접근할 때 사용                                                                          |
| Map, Model, ModelMap                                  | view에 전달할 model data를 설정할 때 사용                                                                    |
| 커맨드 객체                                                | HTTP 요청 parameter를 저장 한 객체, 기본적으로 클래스 이름을 모델명으로 사용, @ModelAttribute annotation 설정으로 모델명을 설정할 수 있음 |
| Errors, BindingResult                                 | HTTP 요청 파라미터를 커맨드 객체에 저장한 결과, 커맨드 객체를 위한 파라미터 바로 다음에 위치                                           |
| SessionStatus                                         | 폼 처리를 완료 했음을 처리하기 위해 사용, @SessionAttributes annotation을 명시한 session속성을 제거하도록 이벤트를 발생 시킨다.         |


+ Servlet API 사용
  + HttpSession의 생성을 직접 제어해야 하는 경우
  + Controller가 Cookie를 생성해야 하는 경우
  + Servlet API를 선호하는 경우
+ Controller Class에서 method의 return type 종류

| Return Type                 | 설명                                                                                                                                                            |
|-----------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ModelAndView                | model정보 및 view 정보를 담고있는 ModelAndView 객체                                                                                                                       |
| Model                       | view에 전달할 객체 정보를 담고있는 Model을 반환한다. 이때 view 이름은 요청 URL로부터 결정된다.(RequestToViewNameTranslator)                                                                   |
| Map                         | view에 전달 할 객체 정보를 담고 있는 Map을 반환한다. 이때 view 이름은 요청 URL로부터 결정된다.(RequestToViewNameTranslator)                                                                   |
| String                      | view 이름을 반환한다                                                                                                                                                 |
| View                        | View 객체를 직접 리턴, 해당 View 객체를 이용해서 view를 생성                                                                                                                     |
| void                        | method가 ServletResponse나 HttpServletResponse 타입의 parameter를 갖는 경우 method가 직접 응답을 처리한다고 가정한다. 그렇지 않을 경우 요청 URL로부터 결정된 View를 보여준다.(RequestToViewNameTranslator) |
| @ResponseBody Annotation 적용 | method에서 @ResponseBody annotation이 적용된 경우, 리턴 객체를 Http 응답으로 전송한다. HttpMassageConverter를 이용해서 객체를 HTTP 응답 스트림으로 변환한다.                                          | 

## View 지정
+ View 자동 지정
  + RequestToViewNameTranslator를 이용해서 URL로 부터  view 이름을 지정한다.
  + 자동 지정 유형
    + return type이 Model이나 Map인 경우
    + return type이 void이면서 ServletResponse나 HttpServletResponse 타입의 parameter가 없는 경우
+ View에 전달하는 데이터
  + @RequestMapping annotation이 적옹된 method의 Map, Model, ModelMap
  + @RequestMapping method가 return하는 ModelAndView
  + @ModelAttribute annotation이 적용된 method가 return 한 객체

## HandlerInterceptor를 통한 요청 가로채기
+ Controller가 요청을 처리하기 전/후 처리
+ 로깅, 모니터링 정보 수집, 접근제어 처리 등의 실제 BusinessLogic과는 불리되어 처리해야 하는 기능들을 넣고 싶을 때 유용하다.
+ Interceptor를 여러개 설정 할 수 있음(순서주의)

## HandlerInterceptor 제공 method
+ boolean preHandle(HttpServletRequest request, HttpServletResponse reponse, Object handler) 
  + false를 반환하면  request를 바로 종료
+ void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView)
  + Controller 수행 후 호출
+ void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex)
  + view를 통해 클라이언트에 응답을 전송한 뒤 실행
  + 예외가 발생하여도 실행
 
## Exception Handling 
+ @RequestMapping 메서드는 모든 타입의 예외를 발생시킬 수 있다.
  + WebBrowser에는 500 응답코드와 Servlet Contatiner가 출력한 에러 페이지 출력
  + SpringMVC를 이용해서 원하는 에러 페이지를 보여주고 싶다면 SpringMVC가 제공하는 HandlerExceptionResolver 인터페이스를 사용한다.
  + SpringMVC가 제공하는 HandlerExceptionResolver 인터페이스의 구현체
    + AnnotationMethodHandlerExceptionResolver
      + @ExceptionHandler annotation이 적용된 method를 이용
    + DefaultHandlerExceptionResolver
      + 스프링 관련 예외 타입 처리
    + SimpleMappingExceptionResolver
      + 예외 타입 별로 뷰 이름을 지정
    + ResponseStatusExceptionResolver
      + 예외를 특정 HTTP 응답 상태코드로 전환하여 단순한 500에러가 아닌 의미 있는 HTTP 응답상태를 반환하는 방법
+ @ExceptionHandler 어노테이션을 이용한 예외처리
  + parameter로 받을 수 있는 type
    + HttpServletRequest , HttpServletResponse , HttpSession
    + Locale, InputStream / Reader, OutputStream / Writer
    + 예외타입
  + return type
    + ModelAndView Model, Map, View, String, void

## @RequestBody, @ResponseBody
+ HttpMessageConverter를 이용한 변환 처리
  + 주요 HttpMessageConverter 구현 Class - AnnotationMethodHandlerAdapter 는 (*) 표시된 클래스를 기본적으로 사용

|               구현클래스                | 설명                                                                                                  |
|:----------------------------------:|:----------------------------------------------------------------------------------------------------|
|  ByteArrayHttpMessageConverter(*)  | HTTP 메세지와 byte 배열 사이의 변환을 처리 컨텐츠 타입은 application/octet-stream                                       |
|   StringHttpMessageConverter(*)    | HTTP 메세지와 String 사이의 변환을 처리 컨텐츠 타입은 text/plain:charset=ISO-8859-1                                   |
|    FromHttpMessageConverter(*)     | HTML 폼 데이터를 MultiValueMap으로 전달받을때 사용 컨텐츠 타입은  application/x-www-form-urlencoded                     |
|   SourceHttpMessageConverter(*)    | HTTP 메세지와 javax.xml.transform.Source 사이의 변환을 처리 컨테츠 타입은 application/xml 또는 text/xml                 |
|   MashallingHttpMessageConverter   | 스프링의 Marshaller와 Unmarshaller을 이용해서 XML HTTP 메시지와 객체 사이의 변환을 처리, 컨텐츠 타입은 application/xml 또는 text/xml|
| MappingJacksonHttpMessageConverter | Jackson 라이브러리를 이용해서 JSON HTTP 메시지와 객체 사이의 변환 처리 컨테츠 타입은 application/json                            |

+ Content-Type과 Accept헤더 기반의 변환처리
  + @AnnotationMethodHandlerAdapter가 HttpMessageConverter를 이용해서 요청 몸체 데이터를 @RequestBody Annotation이 적용된 자바 객체로 변환 할 때에는 HTTP요청헤더의 Content-Type헤더에 명시된 미디어 타입(MIME)을 지원하는 
  HttpMessageConverter를 구현체로 사용
  + @ResponseBody Annotation을 이용해서 리턴하는 객체를 HTTP 메시지의 body로 변환할 때에는 HTTP요청헤더의 Accept 헤더에 명시된 미디어타입을 지원하는 HttpMessageConverter 구현체를 선택 
+ WebSystem 간의 XML, JSON 형식의 Data 를 주고받는 경우
  + XML, JSON  Java Object (unmarshalling)
  + Java Object  XML, JSON (marshalling)
  + RequestBody , ResponseBody Annotation 은 HTTP 메시지 Body 에 Java 객체를 XML 이나 JSON 등의 타입으로 변환하여 담고 , 역으로 변환하는데 사용

        
    marshalling
    한 객체 의 메모리에서의 표현방식을 저장 또는 전송에 적합한 다른 데이터 형식으로 변환하는 과정이다
    또한 이는 데이터를 컴퓨터 프로그램의 서로 다른 부분 간에 혹은 한 프로그램에서 다른 프로그램으로 이동해야 할 때도 사용된다
    이는 대체로 어떤 한 언어로 작성된 프로그램의 출력 매개변수들을 , 다른 언어로 작성된 프로그램의 입력으로 전달해야 하는 경우에 필요하다
    마샬링은 직렬화와 유사하며 동일하게 간주되기도 하지만 매개변수를 바이트 스트림으로 변환하는 직렬화와는 차이가 있다

## WebApplication 동작 원리

![MVC](/assets/img/springFramework/mvc4.png)

+ 실행순서
  1. 웹 어플리케이션이 실행되면 Tomcat(WAS)에 의해 web.xml이 loading
  2. web.xml에 등록되어 있는 ContextLoaderListener (Java Class)가 생성
     ContextLoaderListener class 는 ServletContextListener interface 를 구현하고 있으며 , ApplicationContext 를 생성하는 역할을 수행
  3. 생성된 ContextLoaderListener는 root-context.xml을 loading
  4. root-context.xml에 등록되어 있는 Spring Container가 구동. 이 때 개발자가 작성한 Business Logic에 대한 부분과 Database Logic(DAO), VO 객체들이 생성
  5. Client로 부터 요청(request)가 들어옴
  6. DispatcherServlet (Servlet)이 생성 DispatcherServlet 은 FrontController 의 역할을 수행
     Client로부터 요청 온 메시지를 분석하여 알맞은 PageController 에게 전달하고 응답을 받아 요청에 따른
     응답을 어떻게 할 지 결정 . 실질적인 작업은 PageController 에서 이루어 진다
     이러한 클래스들을 HandlerMapping , ViewResolver Class 라고 함
  7. DispatcherServlet 은 servlet context.xml 을 loading.
  8. 두번째 Spring Container 가 구동되며 응답에 맞는 PageController 들이 동작 . 이 때 첫번째 Spring Container 가 구동되면서
     생성된 DAO, VO, ServiceImpl 클래스들과 협업하여 알맞은 작업을 처리