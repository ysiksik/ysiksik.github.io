---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 조시 쿤의 스프링 필터 그리고 스프링 인터셉터
date: '2022-09-02 00:00:00 +0900'
categories:
    - study
    - inflearn
    - elegant-tekotok
comments: true
---

# 조시 쿤의 스프링 필터 그리고 스프링 인터셉터
+ [https://youtu.be/v86B35pwk6s](https://youtu.be/v86B35pwk6s)

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

~~~java

/**
 * filterConfig : Filter 정보를 담고 있는 객체, xml 로 등록시 xml 정보를 담고 있다. 초기화 시 사용
 */
@Override
public void init(final FilterConfig filterConfig) throw ServletException{
    
}

~~~

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
  + 필터를 목킹해서 테스트를 돌리면 목 필터 체인이 실행
  1. doFilter 메서드에 들어와서 Security 정책 존재 여부 확인
  2. internalDoFilter 들어가면 if 문에 pos(position)과 n이 보인다.
     + n 총 등록된 필터의 갯수
     + pos 배열 인덱스
  3. doFilter 메서드 호출로 다음 필터 호출
  4. 로직 실행 
  5. 모들 필터가 다 실행되면 servlet.service





