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

## 커맨드 (Command) 패턴
요청을 캡슐화 하여 호출자(invoker)와 수신자(receiver)를 분리하는 패턴.
+ 요청을 처리하는 방법이 바뀌더라도, 호출자의 코드는 변경되지 않는다.
+ ![img.png](/assets/img/gof-design-pattern/Command.png)

### 커맨드 (Command) 패턴 구현 방법
+ ![img.png](/assets/img/gof-design-pattern/Command2.png)

#### 기존

+ Light.class

~~~java

public class Light {

    private boolean isOn;

    public void on() {
        System.out.println("불을 켭니다.");
        this.isOn = true;
    }

    public void off() {
        System.out.println("불을 끕니다.");
        this.isOn = false;
    }

    public boolean isOn() {
        return this.isOn;
    }
}

~~~

+ Game.class

~~~java

public class Game {

    private boolean isStarted;

    public void start() {
        System.out.println("게임을 시작합니다.");
        this.isStarted = true;
    }

    public void end() {
        System.out.println("게임을 종료합니다.");
        this.isStarted = false;
    }

    public boolean isStarted() {
        return isStarted;
    }
}

~~~

+ Button.class

~~~java

public class Button {

    private Light light;

    public Button(Light light) {
        this.light = light;
    }

    public void press() {
        light.off();
    }

    public static void main(String[] args) {
        Button button = new Button(new Light());
        button.press();
        button.press();
        button.press();
        button.press();
    }
}

~~~

+ MyApp.class

~~~java

public class MyApp {

    private Game game;

    public MyApp(Game game) {
        this.game = game;
    }

    public void press() {
        game.start();
    }

    public static void main(String[] args) {
        Button button = new Button(new Light());
        button.press();
        button.press();
        button.press();
        button.press();
    }
}

~~~

#### 변경

+ Command.class

~~~java

public interface Command {

    void execute();

    void undo();

}

~~~

+ GameEndCommand.class

~~~java

public class GameEndCommand implements Command {

    private Game game;

    public GameEndCommand(Game game) {
        this.game = game;
    }

    @Override
    public void execute() {
        game.end();
    }

    @Override
    public void undo() {
        new GameStartCommand(this.game).execute();
    }
}

~~~

+ GameStartCommand.class

~~~java

public class GameStartCommand implements Command {

    private Game game;

    public GameStartCommand(Game game) {
        this.game = game;
    }

    @Override
    public void execute() {
        game.start();
    }

    @Override
    public void undo() {
        new GameEndCommand(this.game).execute();
    }
}

~~~

+ LightOffCommand.class

~~~java

public class LightOffCommand implements Command {

    private Light light;

    public LightOffCommand(Light light) {
        this.light = light;
    }

    @Override
    public void execute() {
        light.off();
    }

    @Override
    public void undo() {
        new LightOnCommand(this.light).execute();
    }
}

~~~

+ LightOnCommand.class

~~~java

public class LightOnCommand implements Command {

    private Light light;

    public LightOnCommand(Light light) {
        this.light = light;
    }

    @Override
    public void execute() {
        light.on();
    }

    @Override
    public void undo() {
        new LightOffCommand(this.light).execute();
    }
}

~~~

+ Button.class

~~~java

public class Button {

    private Stack<Command> commands = new Stack<>();

    public void press(Command command) {
        command.execute();
        commands.push(command);
    }

    public void undo() {
        if (!commands.isEmpty()) {
            Command command = commands.pop();
            command.undo();
        }
    }

    public static void main(String[] args) {
        Button button = new Button();
        button.press(new GameStartCommand(new Game()));
        button.press(new LightOnCommand(new Light()));
        button.undo();
        button.undo();
    }

}

~~~

+ MyApp.class

~~~java

public class MyApp {

    private Command command;

    public MyApp(Command command) {
        this.command = command;
    }

    public void press() {
        command.execute();
    }

    public static void main(String[] args) {
        MyApp myApp = new MyApp(new GameStartCommand(new Game()));
    }
}

~~~

### 커맨드 (Command) 패턴 구현 복습
+ 장점
  + 기존의 코드를 변경하지 않고 새로운 커맨드를 만들 수 있다.
  + 수신자의 코드가 변경되어도 호출자의 코드는 변경되지 않는다.
  + 커맨드 객체를 로깅, DB에 저장, 네트워크로 전송 하는 등 당양한 방법으로 활용할 수도 있다.
+ 단점
  + 코드가 복잡하고 클래스가 많아진다.

### 실무에서 어떻게 쓰이나?
+ 자바
  + Runnable
  + 람다
  + 메소드 레퍼런스

~~~java

public class CommandInJava {

    public static void main(String[] args) {
        Light light = new Light();
        Game game = new Game();
        ExecutorService executorService = Executors.newFixedThreadPool(4);
        executorService.submit(light::on);
        executorService.submit(game::start);
        executorService.submit(game::end);
        executorService.submit(light::off);
        executorService.shutdown();
    }
}

~~~

+ 스프링
  + SimpleJdbcInsert
  + SimpleJdbcCall

~~~java

public class CommandInSpring {

    private DataSource dataSource;

    public CommandInSpring(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public void add(Command command) {
        SimpleJdbcInsert insert = new SimpleJdbcInsert(dataSource)
                .withTableName("command")
                .usingGeneratedKeyColumns("id");

        Map<String, Object> data = new HashMap<>();
        data.put("name", command.getClass().getSimpleName());
        data.put("when", LocalDateTime.now());
        insert.execute(data);
    }

}

~~~

## 인터프리터 (Interpreter) 패턴
자주 등장하는 문제를 간단한 언어로 정의하고 재사용하는 패턴
+ 반복되는 문제 패턴을 언어 또는 문법으로 정의하고 확장할 수 있다.
![img.png](/assets/img/gof-design-pattern/Interpreter.png)

### 인터프리터 (Interpreter) 패턴 구현 방법
+ 요청을 캡슐화 하여 호출자(invoke)와 수신자(receiver)를 분리하는 패턴
+ ![img.png](/assets/img/gof-design-pattern/Interpreter2.png)

### 인터프리터 (Interpreter) 패턴 구현 복습
+ 장점
  + 자주 등장하는 문제 패턴을 언어와 문법으로 정의할 수 있다.
  + 기존 코드를 변경하지 않고 새로운 Expression을 추가 할 수 있다.
+ 단점
  + 복잡한 문법을 표현하려면 Expression와 Parser가 복잡해진다.
  
### 실무에서 어떻게 쓰이나?
+ 자바
  + 자바 컴파일러 
  + 정규 표현식
+ 스프링
  + SpEL(스프링 Expression Language)

