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

