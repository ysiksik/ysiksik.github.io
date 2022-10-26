---
layout: post
bigtitle: '코딩으로 학습하는 GoF의 디자인 패턴'
subtitle: 행동 관련 패턴(Behavioral Patterns)
date: '2022-10-26 00:00:00 +0900'
categories:
    - study
    - inflearn
    - gof-design-pattern
comments: true
---

# 행동 관련 패턴(Behavioral Patterns)

# 행동 관련 패턴(Behavioral Patterns)
* toc
{:toc}

## 책임 연쇄 패턴 (Chain-of-Responsibility) 패턴
요청을 보내는 쪽(sender)과 요청을 처리하는 쪽(receiver)의 분리하는 패턴
+ 핸들러 체인을 사용해서 요청을 처리한다.
+ 단일 책임 원칙에서의 책임 
+ ![img.png](/assets/img/gof-design-pattern/Chain-of-Responsibility.png)

### 책임 연쇄 패턴 (Chain-of-Responsibility) 패턴 구현 방법

#### 기존
+ Request.class

~~~java

public class Request {

    private String body;

    public Request(String body) {
        this.body = body;
    }

    public String getBody() {
        return body;
    }

    public void setBody(String body) {
        this.body = body;
    }
}

~~~

+ RequestHandler.class

~~~java

public class RequestHandler {

    public void handler(Request request) {
        System.out.println(request.getBody());
    }
}

~~~

+ AuthRequestHandler.class

~~~java

public class AuthRequestHandler extends RequestHandler {

    public void handler(Request request) {
        System.out.println("인증이 되었나?");
        System.out.println("이 핸들러를 사용할 수 있는 유저인가?");
        super.handler(request);
    }
}

~~~

+ LoggingRequestHandler.class

~~~java

public class LoggingRequestHandler extends RequestHandler {

    @Override
    public void handler(Request request) {
        System.out.println("로깅");
        super.handler(request);
    }
}

~~~

+ Client.class

~~~java

public class Client {

    public static void main(String[] args) {
        Request request = new Request("무궁화 꽃이 피었습니다.");
        RequestHandler requestHandler = new LoggingRequestHandler();
        requestHandler.handler(request);
    }
}

~~~

#### 변경
+ RequestHandler.class

~~~java

public abstract class RequestHandler {

    private RequestHandler nextHandler;

    public RequestHandler(RequestHandler nextHandler) {
        this.nextHandler = nextHandler;
    }

    public void handle(Request request) {
        if (nextHandler != null) {
            nextHandler.handle(request);
        }
    }
}

~~~

+ PrintRequestHandler.class

~~~java

public class PrintRequestHandler extends RequestHandler {

    public PrintRequestHandler(RequestHandler nextHandler) {
        super(nextHandler);
    }

    @Override
    public void handle(Request request) {
        System.out.println(request.getBody());
        super.handle(request);
    }
}

~~~

+ LoggingRequestHandler.class

~~~java

public class LoggingRequestHandler extends RequestHandler {

    public LoggingRequestHandler(RequestHandler nextHandler) {
        super(nextHandler);
    }

    @Override
    public void handle(Request request) {
        System.out.println("로깅");
        super.handle(request);
    }
}

~~~

+ AuthRequestHandler.class

~~~java

public class AuthRequestHandler extends RequestHandler {

    public AuthRequestHandler(RequestHandler nextHandler) {
        super(nextHandler);
    }

    @Override
    public void handle(Request request) {
        System.out.println("인증이 되었는가?");
        super.handle(request);
    }
}

~~~

+ Client.class

~~~java

public class Client {

    private RequestHandler requestHandler;

    public Client(RequestHandler requestHandler) {
        this.requestHandler = requestHandler;
    }

    public void doWork() {
        Request request = new Request("이번 놀이는 뽑기입니다.");
        requestHandler.handle(request);
    }

    public static void main(String[] args) {
        RequestHandler chain = new AuthRequestHandler(new LoggingRequestHandler(new PrintRequestHandler(null)));
        Client client = new Client(chain);
        client.doWork();
    }
}

~~~

### 책임 연쇄 패턴 (Chain-of-Responsibility) 패턴 구현 복습
+ 장점
  + 클라이언트 코드를 변경하지 않고 새로운 핸들러를 체인에 추가할 수 있다.
  + 각각의 체인은 자신이 해야하는 일만 한다.
  + 체인을 다양한 방법으로 구성할 수 있다.
+ 단점 
  + 디버깅이 조금 어렵다.

### 실무에서 어떻게 쓰이나?
+ 자바
  + 서블릿 필터

~~~java

public class CoRInJava {

    public static void main(String[] args) {
        Filter filter = new Filter() {
            @Override
            public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
                // TODO 전처리
                chain.doFilter(request, response);
                // TODO 후처리
            }
        };
    }
}

~~~

~~~java

@WebFilter(urlPatterns = "/hello")
public class MyFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        System.out.println("게임에 참하신 여러분 모두 진심으로 환영합니다.");
        chain.doFilter(request, response);
        System.out.println("꽝!");
    }
}

~~~

~~~java

@ServletComponentScan
@SpringBootApplication
public class App {

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }
}

~~~

~~~java

@RestController
public class HelloController {

    @GetMapping("/hello")
    public String hello() {
        return "hello";
    }
}

~~~

+ 스프링
  + 스프링 시큐리티 필터

~~~java

@Configuration
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests().anyRequest().permitAll().and();
    }

}

~~~

+ ![img.png](/assets/img/gof-design-pattern/Chain-of-Responsibility2.png)