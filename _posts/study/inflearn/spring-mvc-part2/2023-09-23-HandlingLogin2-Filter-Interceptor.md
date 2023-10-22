---
layout: post
bigtitle: '스프링 MVC 2편 - 백엔드 웹 개발 핵심 기술'
subtitle: 로그인 처리2 - 필터, 인터셉터
date: '2023-09-23 00:00:00 +0900'
categories:
- spring-mvc-part2
comments: true

---

# 로그인 처리2 - 필터, 인터셉터

# 로그인 처리2 - 필터, 인터셉터

* toc
{:toc}

## 서블릿 필터 - 소개

### 공통 관심 사항
+ 요구사항을 보면 로그인 한 사용자만 상품 관리 페이지에 들어갈 수 있어야 한다
+ 문제는 로그인 하지 않은 사용자도 다음 URL을 직접 호출하면 상품 관리 화면에 들어갈 수 있다는 점이다.
+ 상품 관리 컨트롤러에서 로그인 여부를 체크하는 로직을 하나하나 작성하면 되겠지만, 등록, 수정, 삭제, 조회 등등 상품관리의 모든 컨트롤러 로직에 공통으로 로그인 여부를 확인해야 한다.
+ 더 큰 문제는 향후 로그인과 관련된 로직이 변경될 때 이다. 작성한 모든 로직을 다 수정해야 할 수 있다.
+ 이렇게 애플리케이션 여러 로직에서 공통으로 관심이 있는 있는 것을 공통 관심사(cross-cutting concern)라고 한다.
+ 여기서는 등록, 수정, 삭제, 조회 등등 여러 로직에서 공통으로 인증에 대해서 관심을 가지고 있다.
+ 이러한 공통 관심사는 스프링의 AOP로도 해결할 수 있지만, 웹과 관련된 공통 관심사는 서블릿 필터 또는 스프링 인터셉터를 사용하는 것이 좋다.
+ 웹과 관련된 공통 관심사를 처리할 때는 HTTP의 헤더나 URL의 정보들이 필요한데, 서블릿 필터나 스프링 인터셉터는 ```HttpServletRequest``` 를 제공한다.

### 서블릿 필터 소개
+ 필터는 서블릿이 지원하는 수문장이다. 필터의 특성은 다음과 같다.

#### 필터 흐름
~~~

HTTP 요청 -> WAS -> 필터 -> 서블릿 -> 컨트롤러

~~~

+ 필터를 적용하면 필터가 호출 된 다음에 서블릿이 호출된다.
+ 그래서 모든 고객의 요청 로그를 남기는 요구사항이 있다면 필터를 사용하면 된다.
+ 참고로 필터는 특정 URL 패턴에 적용할 수 있다. ```/*``` 이라고 하면 모든 요청에 필터가 적용된다.
+ 참고로 스프링을 사용하는 경우 여기서 말하는 서블릿은 스프링의 디스패처 서블릿으로 생각하면 된다.

#### 필터 제한

~~~

HTTP 요청 -> WAS -> 필터 -> 서블릿 -> 컨트롤러 //로그인 사용자
HTTP 요청 -> WAS -> 필터(적절하지 않은 요청이라 판단, 서블릿 호출X) //비 로그인 사용자

~~~

+ 필터에서 적절하지 않은 요청이라고 판단하면 거기에서 끝을 낼 수도 있다. 그래서 로그인 여부를 체크하기에 딱 좋다.

#### 필터 체인

~~~

HTTP 요청 -> WAS -> 필터1 -> 필터2 -> 필터3 -> 서블릿 -> 컨트롤러

~~~

+ 필터는 체인으로 구성되는데, 중간에 필터를 자유롭게 추가할 수 있다. 예를 들어서 로그를 남기는 필터를 먼저 적용하고, 그 다음에 로그인 여부를 체크하는 필터를 만들 수 있다.

#### 필터 인터페이스

~~~java

public interface Filter {
 public default void init(FilterConfig filterConfig) throws ServletException
{}
 public void doFilter(ServletRequest request, ServletResponse response,
 FilterChain chain) throws IOException, ServletException;
 public default void destroy() {}
}

~~~

+ 필터 인터페이스를 구현하고 등록하면 서블릿 컨테이너가 필터를 싱글톤 객체로 생성하고, 관리한다
+ ```init():``` 필터 초기화 메서드, 서블릿 컨테이너가 생성될 때 호출된다.
+ ```doFilter():``` 고객의 요청이 올 때 마다 해당 메서드가 호출된다. 필터의 로직을 구현하면 된다.
+ ```destroy()```: 필터 종료 메서드, 서블릿 컨테이너가 종료될 때 호출된다.

## 서블릿 필터 - 요청 로그

### LogFilter - 로그 필터

~~~java

package hello.login.web.filter;
import lombok.extern.slf4j.Slf4j;
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.UUID;
@Slf4j
public class LogFilter implements Filter {
 @Override
 public void init(FilterConfig filterConfig) throws ServletException {
 log.info("log filter init");
 }
 @Override
 public void doFilter(ServletRequest request, ServletResponse response,
FilterChain chain) throws IOException, ServletException {
 HttpServletRequest httpRequest = (HttpServletRequest) request;
 String requestURI = httpRequest.getRequestURI();
 String uuid = UUID.randomUUID().toString();
 try {
 log.info("REQUEST [{}][{}]", uuid, requestURI);
 chain.doFilter(request, response);
 } catch (Exception e) {
 throw e;
 } finally {
 log.info("RESPONSE [{}][{}]", uuid, requestURI);
 }
 }
 @Override
 public void destroy() {
 log.info("log filter destroy");
 }
}

~~~

+ ```public class LogFilter implements Filter {}```
  + 필터를 사용하려면 필터 인터페이스를 구현해야 한다.
+ ```doFilter(ServletRequest request, ServletResponse response, FilterChain chain)```
  + HTTP 요청이 오면 ```doFilter``` 가 호출된다.
  + ```ServletRequest request``` 는 HTTP 요청이 아닌 경우까지 고려해서 만든 인터페이스이다. HTTP를
    사용하면 ```HttpServletRequest httpRequest = (HttpServletRequest) request;``` 와 같이
    다운 케스팅 하면 된다.
+ ```String uuid = UUID.randomUUID().toString()```
  + HTTP 요청을 구분하기 위해 요청당 임의의 ```uuid``` 를 생성해둔다.
+ ```log.info("REQUEST [{}][{}]", uuid, requestURI);```
  + ```uuid``` 와 ```requestURI``` 를 출력한다
+ ```chain.doFilter(request, response);```
  + 이 부분이 가장 중요하다. 다음 필터가 있으면 필터를 호출하고, 필터가 없으면 서블릿을 호출한다. 만약 이 로직을 호출하지 않으면 다음 단계로 진행되지 않는다.

### WebConfig - 필터 설정

~~~java

package hello.login;
import hello.login.web.filter.LogFilter;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import javax.servlet.Filter;
@Configuration
public class WebConfig {
 @Bean
 public FilterRegistrationBean logFilter() {
 FilterRegistrationBean<Filter> filterRegistrationBean = new
FilterRegistrationBean<>();
 filterRegistrationBean.setFilter(new LogFilter());
 filterRegistrationBean.setOrder(1);
 filterRegistrationBean.addUrlPatterns("/*");
 return filterRegistrationBean;
 }
}

~~~

+ 필터를 등록하는 방법은 여러가지가 있지만, 스프링 부트를 사용한다면 FilterRegistrationBean 을 사용해서 등록하면 된다.
+ ```setFilter(new LogFilter())``` : 등록할 필터를 지정한다
+ ```setOrder(1)``` : 필터는 체인으로 동작한다. 따라서 순서가 필요하다. 낮을 수록 먼저 동작한다.
+ ```addUrlPatterns("/*")``` : 필터를 적용할 URL 패턴을 지정한다. 한번에 여러 패턴을 지정할 수 있다.

> 참고
> URL 패턴에 대한 룰은 필터도 서블릿과 동일하다. 자세한 내용은 서블릿 URL 패턴으로 검색해보자.

> 참고
> ```@ServletComponentScan @WebFilter(filterName = "logFilter", urlPatterns = "/*")``` 로
필터 등록이 가능하지만 필터 순서 조절이 안된다. 따라서 ```FilterRegistrationBean``` 을 사용하자.

+ 필터를 등록할 때 urlPattern 을 /* 로 등록했기 때문에 모든 요청에 해당 필터가 적용된다

> 참고
> 실무에서 HTTP 요청시 같은 요청의 로그에 모두 같은 식별자를 자동으로 남기는 방법은 logback mdc로 검색해보자.
