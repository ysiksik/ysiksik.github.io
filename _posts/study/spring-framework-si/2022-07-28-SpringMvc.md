---
layout: post
bigtitle: 'Spring 전자정부 프레임워크 기반 SI 실무'
subtitle: Spring MVC
date: '2022-07-28 00:00:00 +0900'
categories:
    - study
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
![MVC](/assets/img/springFramework/mvc2.png)
+ Spring MVC 실행 순서
![MVC](/assets/img/springFramework/mvc3.png)
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
  