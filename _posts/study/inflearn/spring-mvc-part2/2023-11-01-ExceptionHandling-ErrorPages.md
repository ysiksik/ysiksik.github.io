---
layout: post
bigtitle: '스프링 MVC 2편 - 백엔드 웹 개발 핵심 기술'
subtitle: 로그인 처리2 - 필터, 인터셉터
date: '2023-11-01 00:00:01 +0900'
categories:
- spring-mvc-part2
comments: true

---

# 예외 처리와 오류 페이지

# 예외 처리와 오류 페이지

* toc
{:toc}

## 서블릿 예외 처리 - 시작
+ 서블릿은 다음 2가지 방식으로 예외 처리를 지원한다
  + ```Exception``` (예외)
  + ```response.sendError(HTTP 상태 코드, 오류 메시지)```

### Exception(예외)
+ 자바 직접 실행
  + 자바의 메인 메서드를 직접 실행하는 경우 ```main``` 이라는 이름의 쓰레드가 실행된다.
  + 실행 도중에 예외를 잡지 못하고 처음 실행한 ```main()``` 메서드를 넘어서 예외가 던져지면, 예외 정보를 남기고 해당 쓰레드는 종료된다.
+ 웹 애플리케이션
  + 웹 애플리케이션은 사용자 요청별로 별도의 쓰레드가 할당되고, 서블릿 컨테이너 안에서 실행된다.
  + 애플리케이션에서 예외가 발생했는데, 어디선가 try ~ catch로 예외를 잡아서 처리하면 아무런 문제가 없다.
  + 그런데 만약에 애플리케이션에서 예외를 잡지 못하고, 서블릿 밖으로 까지 예외가 전달되면 결국 톰캣 같은 WAS 까지 예외가 전달된다.

~~~

WAS(여기까지 전파) <- 필터 <- 서블릿 <- 인터셉터 <- 컨트롤러(예외발생)

~~~

+ ```Exception``` 의 경우 서버 내부에서 처리할 수 없는 오류가 발생한 것으로 생각해서 HTTP 상태 코드 500을 반환한다.
+ 이번에는 아무사이트나 호출하면 톰캣이 기본으로 제공하는 404 오류 화면을 볼 수 있다.

### response.sendError(HTTP 상태 코드, 오류 메시지)
+ 오류가 발생했을 때 ```HttpServletResponse``` 가 제공하는 ```sendError``` 라는 메서드를 사용해도 된다. 
+ 이것을 호출한다고 당장 예외가 발생하는 것은 아니지만, 서블릿 컨테이너에게 오류가 발생했다는 점을 전달할 수 있다.
+ 이 메서드를 사용하면 HTTP 상태 코드와 오류 메시지도 추가할 수 있다.
  + ```response.sendError(HTTP 상태 코드)```
  + ```response.sendError(HTTP 상태 코드, 오류 메시지)```

sendError 흐름
~~~

WAS(sendError 호출 기록 확인) <- 필터 <- 서블릿 <- 인터셉터 <- 컨트롤러(response.sendError())

~~~

+ ```response.sendError()``` 를 호출하면 ```response``` 내부에는 오류가 발생했다는 상태를 저장해둔다.
+ 그리고 서블릿 컨테이너는 고객에게 응답 전에 ```response``` 에 ```sendError()``` 가 호출되었는지 확인한다. 
+ 그리고 호출되었다면 설정한 오류 코드에 맞추어 기본 오류 페이지를 보여준다.

### 정리
+ 서블릿 컨테이너가 제공하는 기본 예외 처리 화면은 사용자가 보기에 불편하다.

## 서블릿 예외 처리 - 오류 화면 제공
+ 서블릿은 Exception (예외)가 발생해서 서블릿 밖으로 전달되거나 또는 response.sendError() 가 호출 되었을 때 각각의 상황에 맞춘 오류 처리 기능을 제공한다.
+ 이 기능을 사용하면 친절한 오류 처리 화면을 준비해서 고객에게 보여줄 수 있다.

+ 과거에는 web.xml 이라는 파일에 다음과 같이 오류 화면을 등록했다

~~~xml

<web-app>
  <error-page>
    <error-code>404</error-code>
    <location>/error-page/404.html</location>
  </error-page>
  <error-page>
    <error-code>500</error-code>
    <location>/error-page/500.html</location>
  </error-page>
  <error-page>
    <exception-type>java.lang.RuntimeException</exception-type>
    <location>/error-page/500.html</location>
  </error-page>
</web-app>

~~~

+ 지금은 스프링 부트를 통해서 서블릿 컨테이너를 실행하기 때문에, 스프링 부트가 제공하는 기능을 사용해서 서블릿 오류 페이지를 등록하면 된다.

### 서블릿 오류 페이지 등록

~~~java

package hello.exception;

import org.springframework.boot.web.server.ConfigurableWebServerFactory;
import org.springframework.boot.web.server.ErrorPage;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

@Component
public class WebServerCustomizer implements WebServerFactoryCustomizer<ConfigurableWebServerFactory> {
  @Override
  public void customize(ConfigurableWebServerFactory factory) {
    ErrorPage errorPage404 = new ErrorPage(HttpStatus.NOT_FOUND, "/errorpage/404");
    ErrorPage errorPage500 = new ErrorPage(HttpStatus.INTERNAL_SERVER_ERROR, "/error-page/500");
    ErrorPage errorPageEx = new ErrorPage(RuntimeException.class, "/errorpage/500");
    factory.addErrorPages(errorPage404, errorPage500, errorPageEx);
  }
}

~~~

+ ```response.sendError(404)``` : ```errorPage404``` 호출
+ ```response.sendError(500)``` : ```errorPage500``` 호출
+ ```RuntimeException``` 또는 그 자식 타입의 예외: ```errorPageEx``` 호출
+ 오류 페이지는 예외를 다룰 때 해당 예외와 그 자식 타입의 오류를 함께 처리한다. 예를 들어서 위의 경우 ```RuntimeException``` 은 물론이고 ```RuntimeException``` 의 자식도 함께 처리한다.
+ 오류가 발생했을 때 처리할 수 있는 컨트롤러가 필요하다. 예를 들어서 ```RuntimeException``` 예외가 발생하면 ```errorPageEx``` 에서 지정한 ```/error-page/500``` 이 호출된다.

~~~java

package hello.exception.servlet;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@Slf4j
@Controller
public class ErrorPageController {
  @RequestMapping("/error-page/404")
  public String errorPage404(HttpServletRequest request, HttpServletResponse response) {
    log.info("errorPage 404");
    return "error-page/404";
  }

  @RequestMapping("/error-page/500")
  public String errorPage500(HttpServletRequest request, HttpServletResponse response) {
    log.info("errorPage 500");
    return "error-page/500";
  }
}

~~~

## 서블릿 예외 처리 - 오류 페이지 작동 원리
+ 서블릿은 ```Exception```(예외)가 발생해서 서블릿 밖으로 전달되거나 또는 ```response.sendError()``` 가 호출 되었을 때 설정된 오류 페이지를 찾는다.
+ 예외 발생 흐름

~~~

WAS(여기까지 전파) <- 필터 <- 서블릿 <- 인터셉터 <- 컨트롤러(예외발생)

~~~

+ sendError 흐름

~~~

WAS(sendError 호출 기록 확인) <- 필터 <- 서블릿 <- 인터셉터 <- 컨트롤러(response.sendError())

~~~

+ WAS는 해당 예외를 처리하는 오류 페이지 정보를 확인한다.
  + ```new ErrorPage(RuntimeException.class, "/error-page/500")```
+ 예를 들어서 RuntimeException 예외가 WAS까지 전달되면, WAS는 오류 페이지 정보를 확인한다.
  확인해보니 RuntimeException 의 오류 페이지로 /error-page/500 이 지정되어 있다. WAS는 오류
  페이지를 출력하기 위해 /error-page/500 를 다시 요청한다.

+ 오류 페이지 요청 흐름

~~~

WAS `/error-page/500` 다시 요청 -> 필터 -> 서블릿 -> 인터셉터 -> 컨트롤러(/error-page/500) -> View

~~~

+ 예외 발생과 오류 페이지 요청 흐름

~~~

1. WAS(여기까지 전파) <- 필터 <- 서블릿 <- 인터셉터 <- 컨트롤러(예외발생)
2. WAS `/error-page/500` 다시 요청 -> 필터 -> 서블릿 -> 인터셉터 -> 컨트롤러(/errorpage/500) -> View

~~~

+ 중요한 점은 웹 브라우저(클라이언트)는 서버 내부에서 이런 일이 일어나는지 전혀 모른다는 점이다. 오직 서버 내부에서 오류 페이지를 찾기 위해 추가적인 호출을 한다.
+ 정리
  + 예외가 발생해서 WAS까지 전파된다
  + WAS는 오류 페이지 경로를 찾아서 내부에서 오류 페이지를 호출한다. 이때 오류 페이지 경로로 필터, 서블릿, 인터셉터, 컨트롤러가 모두 다시 호출된다

### 오류 정보 추가
+ WAS는 오류 페이지를 단순히 다시 요청만 하는 것이 아니라, 오류 정보를 ```request``` 의 ```attribute``` 에 추가해서 넘겨준다.

~~~java

package hello.exception.servlet;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@Slf4j
@Controller
public class ErrorPageController {
  //RequestDispatcher 상수로 정의되어 있음
  public static final String ERROR_EXCEPTION = "javax.servlet.error.exception";
  public static final String ERROR_EXCEPTION_TYPE = "javax.servlet.error.exception_type";
  public static final String ERROR_MESSAGE = "javax.servlet.error.message";
  public static final String ERROR_REQUEST_URI = "javax.servlet.error.request_uri";
  public static final String ERROR_SERVLET_NAME = "javax.servlet.error.servlet_name";
  public static final String ERROR_STATUS_CODE = "javax.servlet.error.status_code";

  @RequestMapping("/error-page/404")
  public String errorPage404(HttpServletRequest request, HttpServletResponse response) {
    log.info("errorPage 404");
    printErrorInfo(request);
    return "error-page/404";
  }

  @RequestMapping("/error-page/500")
  public String errorPage500(HttpServletRequest request, HttpServletResponse response) {
    log.info("errorPage 500");
    printErrorInfo(request);
    return "error-page/500";
  }

  private void printErrorInfo(HttpServletRequest request) {
    log.info("ERROR_EXCEPTION: ex=", request.getAttribute(ERROR_EXCEPTION));
    log.info("ERROR_EXCEPTION_TYPE: {}", request.getAttribute(ERROR_EXCEPTION_TYPE));
    log.info("ERROR_MESSAGE: {}", request.getAttribute(ERROR_MESSAGE)); // ex의 경우 NestedServletException 스프링이 한번 감싸서 반환
    log.info("ERROR_REQUEST_URI: {}", request.getAttribute(ERROR_REQUEST_URI));
    log.info("ERROR_SERVLET_NAME: {}", request.getAttribute(ERROR_SERVLET_NAME));
    log.info("ERROR_STATUS_CODE: {}", request.getAttribute(ERROR_STATUS_CODE));
    log.info("dispatchType={}", request.getDispatcherType());
  }
}

~~~

+ request.attribute에 서버가 담아준 정보
  + javax.servlet.error.exception : 예외
  + javax.servlet.error.exception_type : 예외 타입
  + javax.servlet.error.message : 오류 메시
  + javax.servlet.error.request_uri : 클라이언트 요청 URI
  + javax.servlet.error.servlet_name : 오류가 발생한 서블릿 이름
  + javax.servlet.error.status_code : HTTP 상태 코드

## 서블릿 예외 처리 - 필터
+ 오류가 발생하면 오류 페이지를 출력하기 위해 WAS 내부에서 다시 한번 호출이 발생한다. 이때 필터, 서블릿, 인터셉터도 모두 다시 호출된다.
+ 로그인 인증 체크 같은 경우를 생각해보면, 이미 한번 필터나, 인터셉터에서 로그인 체크를 완료했다. 따라서 서버 내부에서 오류 페이지를 호출한다고 해서 해당 필터나 인터셉트가 한번 더 호출되는 것은 매우 비효율적이다.
+ 결국 클라이언트로 부터 발생한 정상 요청인지, 아니면 오류 페이지를 출력하기 위한 내부 요청인지 구분할 수 있어야 한다. 서블릿은 이런 문제를 해결하기 위해 DispatcherType 이라는 추가 정보를 제공한다.

### DispatcherType
+ 필터는 이런 경우를 위해서 dispatcherTypes 라는 옵션을 제공한다.
+ ```log.info("dispatchType={}", request.getDispatcherType())``` 출력해보면 ```dispatchType=ERROR``` 로 나오는 것을 확인할 수 있다.
+ 고객이 처음 요청하면 ```dispatcherType=REQUEST``` 이다.
+ 이렇듯 서블릿 스펙은 실제 고객이 요청한 것인지, 서버가 내부에서 오류 페이지를 요청하는 것인지 ```DispatcherType``` 으로 구분할 수 있는 방법을 제공한다.

~~~

public enum DispatcherType {
 FORWARD,
 INCLUDE,
 REQUEST,
 ASYNC,
 ERROR
}

~~~

+ DispatcherType
  + ```REQUEST``` : 클라이언트 요청
  + ```ERROR``` : 오류 요청
  + ```FORWARD``` : MVC에서 서블릿에서 다른 서블릿이나 JSP를 호출할 때 ```RequestDispatcher.forward(request, response);```
  + ```INCLUDE``` : 서블릿에서 다른 서블릿이나 JSP의 결과를 포함할 때 ```RequestDispatcher.include(request, response);```
  + ```ASYNC``` : 서블릿 비동기 호출

### 필터와 DispatcherType

#### LogFilter - DispatcherType 로그 추가

~~~java

package hello.exception.filter;

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
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
    HttpServletRequest httpRequest = (HttpServletRequest) request;
    String requestURI = httpRequest.getRequestURI();
    String uuid = UUID.randomUUID().toString();
    try {
      log.info("REQUEST [{}][{}][{}]", uuid, request.getDispatcherType(), requestURI);
      chain.doFilter(request, response);
    } catch (Exception e) {
      throw e;
    } finally {
      log.info("RESPONSE [{}][{}][{}]", uuid, request.getDispatcherType(), requestURI);
    }
  }

  @Override
  public void destroy() {
    log.info("log filter destroy");
  }
}

~~~

+ 로그를 출력하는 부분에 ```request.getDispatcherType()``` 을 추가해두었다.

#### WebConfig

~~~java

package hello.exception;

import hello.exception.filter.LogFilter;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import javax.servlet.DispatcherType;
import javax.servlet.Filter;

@Configuration
public class WebConfig implements WebMvcConfigurer {
  @Bean
  public FilterRegistrationBean logFilter() {
    FilterRegistrationBean<Filter> filterRegistrationBean = new FilterRegistrationBean<>();
    filterRegistrationBean.setFilter(new LogFilter());
    filterRegistrationBean.setOrder(1);
    filterRegistrationBean.addUrlPatterns("/*");
    filterRegistrationBean.setDispatcherTypes(DispatcherType.REQUEST, DispatcherType.ERROR);
    return filterRegistrationBean;
  }
}

~~~

+ ```filterRegistrationBean.setDispatcherTypes(DispatcherType.REQUEST, DispatcherType.ERROR);```
+ 이렇게 두 가지를 모두 넣으면 클라이언트 요청은 물론이고, 오류 페이지 요청에서도 필터가 호출된다.
+ 아무것도 넣지 않으면 기본 값이 DispatcherType.REQUEST 이다. 즉 클라이언트의 요청이 있는 경우에만 필터가 적용된다.
+ 특별히 오류 페이지 경로도 필터를 적용할 것이 아니면, 기본 값을 그대로 사용하면 된다. 
+ 물론 오류 페이지 요청 전용 필터를 적용하고 싶으면 DispatcherType.ERROR 만 지정하면 된다.

## 서블릿 예외 처리 - 인터셉터

### LogInterceptor - DispatcherType 로그 추가

~~~java

package hello.exception.interceptor;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.UUID;

@Slf4j
public class LogInterceptor implements HandlerInterceptor {
  public static final String LOG_ID = "logId";

  @Override
  public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
    String requestURI = request.getRequestURI();
    String uuid = UUID.randomUUID().toString();
    request.setAttribute(LOG_ID, uuid);
    log.info("REQUEST [{}][{}][{}][{}]", uuid, request.getDispatcherType(), requestURI, handler);
    return true;
  }

  @Override
  public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
    log.info("postHandle [{}]", modelAndView);
  }

  @Override
  public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
    String requestURI = request.getRequestURI();
    String logId = (String) request.getAttribute(LOG_ID);
    log.info("RESPONSE [{}][{}][{}]", logId, request.getDispatcherType(), requestURI);
    if (ex != null) {
      log.error("afterCompletion error!!", ex);
    }
  }
}

~~~

+ 인터셉터는 서블릿이 제공하는 기능이 아니라 스프링이 제공하는 기능이다. 따라서 DispatcherType 과 무관하게 항상 호출된다.
+ 대신에 인터셉터는 다음과 같이 요청 경로에 따라서 추가하거나 제외하기 쉽게 되어 있기 때문에, 이러한 설정을 사용해서 오류 페이지 경로를 excludePathPatterns 를 사용해서 빼주면 된다.

~~~java

package hello.exception;

import hello.exception.filter.LogFilter;
import hello.exception.interceptor.LogInterceptor;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import javax.servlet.DispatcherType;
import javax.servlet.Filter;

@Configuration
public class WebConfig implements WebMvcConfigurer {
  @Override
  public void addInterceptors(InterceptorRegistry registry) {
    registry.addInterceptor(new LogInterceptor())
            .order(1)
            .addPathPatterns("/**")
            .excludePathPatterns(
                    "/css/**", "/*.ico"
                    , "/error", "/error-page/**" //오류 페이지 경로
            );
  }
}

~~~

+ ```/error-page/**``` 를 제거하면 ```error-page/500``` 같은 내부 호출의 경우에도 인터셉터가 호출된다.

### 전체 흐름 정리
+ 정상 요청

~~~

WAS(/hello, dispatchType=REQUEST) -> 필터 -> 서블릿 -> 인터셉터 -> 컨트롤러 -> View

~~~

+ 오류 요청
  + 필터는 ```DispatchType``` 으로 중복 호출 제거 ( ```dispatchType=REQUEST``` )
  + 인터셉터는 경로 정보로 중복 호출 제거( ```excludePathPatterns("/error-page/**")``` )

~~~

1. WAS(/error-ex, dispatchType=REQUEST) -> 필터 -> 서블릿 -> 인터셉터 -> 컨트롤러
2. WAS(여기까지 전파) <- 필터 <- 서블릿 <- 인터셉터 <- 컨트롤러(예외발생)
3. WAS 오류 페이지 확인
4. WAS(/error-page/500, dispatchType=ERROR) -> 필터(x) -> 서블릿 -> 인터셉터(x) -> 컨트롤러(/error-page/500) -> View


~~~
