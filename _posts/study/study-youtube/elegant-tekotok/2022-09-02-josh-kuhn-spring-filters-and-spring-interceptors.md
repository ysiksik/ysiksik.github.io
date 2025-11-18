---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 조시 쿤의 서블릿 필터 그리고 스프링 인터셉터
date: '2022-09-02 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 조시 쿤의 스프링 필터 그리고 스프링 인터셉터
[https://youtu.be/v86B35pwk6s](https://youtu.be/v86B35pwk6s)

# 조시 쿤의 스프링 필터 그리고 스프링 인터셉터
* toc
{:toc}

## 공통 관심 사항
+ 공통 관심 사항 추출 해서 한번에 처리
+ AOP, 필터, 인터셉터
+ WEB 과 관련된 관심사항은 Filter 나 Interceptor 를 사용하는게 좋다.
  + servlet request, servlet response 를 제공해줘서 url 정보라던가 http header 를 직접 조작이 가능하다.

## 서블릿 필터
+ Filter 는 J2EE 표준 스펙으로 Servlet API 2.3 부터 등장하였고 Dispatcher Servlet 에 요청이 전달되기 전, 후에 부가작업을 처리하는 객체이다.

### 서블릿 필터가 제공하는 메서드
+ init 
  + 필터가 생성이 될때 
  + 오버라이드 : 선택적
  + 파라미터 : 
    + FilterConfig : Filter 정보를 담고 있는 객체, xml 로 등록시 xml 정보를 담고 있다. 초기화 시 사용
+ doFilter
  + 필터 작업 
  + 오버라이드 : 필수
  + 파라미터 
    + ServletRequest
    + ServletResponse
    + filterConfig : Filter 가 여러개 모여 형성된 체인
  + chin.doFilter 호출 해줘야 다음 단계로 넘어간다.
+ destory
  + 필터가 소멸이 될때 
  + 오버라이드 : 선택적

### 서블릿 필터 등록하는 방법 
+ @Component
  + 모든 URL 적용 
  + 개별 적 URL 적용 시 추천하지 않는다.
+ @WebFilter + @ServletComponentScan
  + @WebFilter - url 패턴으로 분리 가능
  + @ServletComponentScan - 붙여 줘야지 등록 가능, 빈을 등록해주는 것인데 대상이 웹 서블릿이나, 웹필터, 웹 리스너 서블릿 객체들을 서블릿 컨테이너 위에 올려준다.
  + 스프링 컨테이너에 등록되는 것이 아니라 서블릿 컨테이너에 등록되는 것이기 때문에 @Order() 이 작동 안 된다. 순서를 지정해 줄 수 없다.
+ FilterRegistrationBean
  + 옵션이 많다
  + 순서와 URL 을 지정해 주고 싶은 면 FilterRegistrationBean 등록 방식 사용

### 서블릿 필터의 동작 방식
+ ApplicationFilterCain
  + FilterCain 구현체 중 하나
  + 진짜 필터 체인이 실행될 때는 ApplicationFilterCain 실행
  + 필터를 Mocking 해서 테스트를 돌리면 MockFilterChain 이 실행
  1. doFilter 메서드에 들어와서 Security 정책 존재 여부 확인
  2. internalDoFilter 들어가면 if 문에 pos(position)과 n이 보인다.
     + n 총 등록된 필터의 갯수
     + pos 배열 인덱스
  3. Filter 객체 정보를 가지고 있는 FilterCoing 배열 생성
  4. Filter 객체 반환
  5. doFilter 메서드 호출로 다음 필터 호출
  6. 로직 실행 
  7. 모들 필터가 다 실행되면 servlet.service, FrameworkServlet 의 service 호출해서 DispatcherServlet 동작
+ 정리

<div class="language-mermaid">
graph LR;
    A[FilterCain 의 doFilter 실행]--POS 0 으로 초기화 -->B[POS 가 0인 Filter의 doFilter 실행];
    B--chain.doFilter 호출-->A;
    A--POS 증가-->C[POS 가 1인 Filter의 doFilter 실행];
    C--chain.doFilter 호출-->A;
    A--POS 증가-->D[POS 가 2인 Filter의 doFilter 실행];
    D--chain.doFilter 호출-->A;
    A--POS 증가-->E[POS 가 3인 Filter의 doFilter 실행];
    E--chain.doFilter 호출-->A;
    A--POS 증가-->F[POS 가 4인 Filter의 doFilter 실행];
    F--chain.doFilter 호출-->A;
    A--POS 증가-->G[POS 가 5인 Filter의 doFilter 실행];
    G--chain.doFilter 호출-->A;
</div>

## 스프링 인터셉터
+ 인터셉터는 Spring 이 제공하는 기술로, 디스패처 서블릿이 컨트롤러를 호출하기 전/후 요청에 대해 부가적인 작업을 처리하는 객체이다.

### 스프링 인터셉터 인터페이스에서 제공하는 메서드
+ preHandle
  + Handler 가 실행되기 전에 실행되는 메서드
  + 비즈니스 로직에서 공통적으로 처리할 사항이 있으면 preHandle 이용
+ postHandle
  + Handler 가 실행된 이후에 실행되는 메서드
  + ModelAndView 에 대해서 추가 적인 작업을 하고 싶으면 postHandle 이용 
+ afterCompletion
  + Handler 가 실행된 이후에 실행되는 메서드
  + 파라미터로 Exception 이 넘어오게 되는데 비즈니스 로직에서 예외가 발행하면 afterCompletion 을 이용해서 처리할 수 있다
  + 어떠한 리소스들을 정리할 때도 사용할 수 있다.
+ preHandle, postHandle, afterCompletion 는 default 메서드 이기 때문에 필요한 것을 선택해서 사용하면 된다.

### 스프링 인터셉터 등록 방법
+ WebMvcConfigurer 인터페이스를 구현한 클래스 내부에서 addInterceptors 라는 메서드를 오버라이드해서 추가할 수 있다.

### 호출 시점

<div class="language-mermaid">
graph LR;
    A[핸들러 조회]--알 맞은 핸들러 어댑터 조회-->B[preHandle];
    B--핸들러 어댑터를 통해 핸들러 실행-->C[postHandle];
    C--view 관련 처리-->afterCompletion;
</div>

### 스프링 인터셉터 동작 방식
1. 필터가 다 끝난 뒤에 servlet.service 메서드 호출해서 DispatcherServlet 호출 하는 사이의 약간의 과정을 거치게 되면 DispatcherServlet 의 doService 라는 메서드가 호출 된다.
2. doService 가 doDispatch 메서드 호출
3. getHandler 알맞은 핸들러를 찾아옴 
4. getHandlerAdapter 핸들러에 맞는 핸들러 어뎁터를 찾아옴
5. applyPreHandle 메서드 호출
6. 반복문을 돌면서 interceptorList 에서 인터셉터를 하나씩 가지고 옴
7. 인터셉터의 preHandle 실행 
8. HandlerAdapter 를 통해 handler 실행
9. 인터셉터의 postHandle 실행 
10. 반복문을 돌면서 interceptorList 에서 인터셉터를 하나씩 가지고 옴  - 역순 으로 가지고옴
11. view 관련 로직 실행
12. afterCompletion 실행
13. 반복문을 돌면서 interceptorList 에서 인터셉터를 하나씩 가지고 옴  - 역순 으로 가지고옴

## 필터와 인터셉터 차이

| 필터                                                             | 인터셉터                                                             |
|----------------------------------------------------------------|------------------------------------------------------------------|
| 자바 표준 스펙                                                       | 스프링이 제공하는 기술                                                     |
| 다음 필터를 실행하기 위해 개발자가 명시적으로 작성해 줘야한다.                            | 다음 인터셉터를 실행하기 위해 개발자가 신경써야 하는 부분이 없다.                            |
| ServletRequest. ServletResponse 를 필터 체이닝 중간에 새로운 객체로 바꿀 수 있다.  | ServletRequest. ServletResponse 를 인터셉터 체이닝 중간에 새로운 객체로 바꿀 수 없다.  |
| 필터에서 예외가 발생하면 @ControllerAdvice 에서 처리하지 못한다.                   | 인터셉터에서 예외가 발생하면 @ControllerAdvice 에서 처리가 가능하다.                   |

## 필터와 인터셉터 언제 사용해야 할까?
+ 옛날에는 서블릿필터를 스프링 빈으로 등록할 수 없었다. 시간이 지나면서 서블릿필터도 빈으로 등록이 가능해지면서 둘이 차이가 모호해 졋을 가능성이 있다.
+ 필터 4개는 스프리에서 기본적으로 제공하는 필터들인데 그 필터들의 공토점은 인코딩을 해주거나 POST 처리 뿐만 아니라 Put, Patch, Delete HTTP 메서드를 서블릿 할 수 있도록 
Wrapping 해주는 스프링 관련이 아닌 전반적인 웹에 관련된 것들을 한다.
+ 인터셉터에서는 ModelAttribute 바인딩하는 속성들을 request에 넣어주거나, 스프링 기술에 관련된 작업을 해 준다.
+ 관심사 분리 라고 생각 
+ 큰 범위, 웹 범위는 서블릿 필터에서 해주면 좋을거 같다
+ 세세한 인가처리, 스프링에 관련된 기술이라면 인터셉터에서 해주는게 좋을거 같다





