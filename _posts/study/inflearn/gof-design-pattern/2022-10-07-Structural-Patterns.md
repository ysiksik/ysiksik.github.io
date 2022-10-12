---
layout: post
bigtitle: '코딩으로 학습하는 GoF의 디자인 패턴'
subtitle: 구조적 패턴(Structural Patterns)
date: '2022-10-07 00:00:00 +0900'
categories:
    - study
    - inflearn
    - gof-design-pattern
comments: true
---

# 구조적 패턴(Structural Patterns)

# 구조적 패턴(Structural Patterns)
* toc
{:toc}

## 어댑터 (Adapter) 패턴
기존 코드를 클라이언트가 사용하는 인터페이스의 구현체로 바꿔주는 패턴
+ 클라이언트가 사용하는 인터페이스를 따르지 않는 기존 코드를 재사용할 수 있게 해준다.
+ ![img.png](/assets/img/gof-design-pattern/Adapter.png)

### 어댑터 (Adapter) 패턴 구현 방법

#### 기존
+ UserDetails.class

~~~java

public interface UserDetails {

    String getUsername();

    String getPassword();

}

~~~

+ UserDetailsService.class

~~~java

public interface UserDetailsService {

    UserDetails loadUser(String username);

}

~~~

+ LoginHandler.class

~~~java

public class LoginHandler {

    UserDetailsService userDetailsService;

    public LoginHandler(UserDetailsService userDetailsService) {
        this.userDetailsService = userDetailsService;
    }

    public String login(String username, String password) {
        UserDetails userDetails = userDetailsService.loadUser(username);
        if (userDetails.getPassword().equals(password)) {
            return userDetails.getUsername();
        } else {
            throw new IllegalArgumentException();
        }
    }
}

~~~

+ Account.class

~~~java

public class Account {

    private String name;

    private String password;

    private String email;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

}

~~~

+ AccountService.class

~~~java

public class AccountService {

    public Account findAccountByUsername(String username) {
        Account account = new Account();
        account.setName(username);
        account.setPassword(username);
        account.setEmail(username);
        return account;
    }

    public void createNewAccount(Account account) {

    }

    public void updateAccount(Account account) {

    }

}

~~~

#### 변경

+ AccountUserDetails.class

~~~java

public class AccountUserDetails implements UserDetails {

    private Account account;

    public AccountUserDetails(Account account) {
        this.account = account;
    }

    @Override
    public String getUsername() {
        return account.getName();
    }

    @Override
    public String getPassword() {
        return account.getPassword();
    }
}

~~~

+ AccountUserDetailsService.class

~~~java

public class AccountUserDetailsService implements UserDetailsService {

    private AccountService accountService;

    public AccountUserDetailsService(AccountService accountService) {
        this.accountService = accountService;
    }

    @Override
    public UserDetails loadUser(String username) {
        return new AccountUserDetails(accountService.findAccountByUsername(username));
    }
}

~~~

+ App.java

~~~java

public class App {

    public static void main(String[] args) {
        AccountService accountService = new AccountService();
        UserDetailsService userDetailsService = new AccountUserDetailsService(accountService);
        LoginHandler loginHandler = new LoginHandler(userDetailsService);
        String login = loginHandler.login("test", "test");
        System.out.println(login);
    }
}

~~~

### 어댑터 (Adapter) 패턴 구현 복습
+ 장점
  + 기존 코드를 변경하지 않고 원하는 인터페이스 구현체를 만들어 재사용할 수 있다.
  + 기존 코드가 하던 일과 특정 인터페이스 구현체로 변환하는 작업을 각기 다른 클래스롤 분리하여 관리할 수 있다.
+ 단점
  + 새 클래스가 생겨 복잡도가 증가할 수 있다. 경우에 따라서는 기존 코드가 해당 인터페이스를 구현하도록 수정한는 것이 좋은 선택이 될 수도 있다.

### 실무에서 어떻게 쓰이나?
+ 자바
  + java.util.Arrays#asList(T…)
  + java.util.Collections#list(Enumeration), java.util.Collections#enumeration()
  + java.io.InputStreamReader(InputStream)
  + java.io.OutputStreamWriter(OutputStream)

~~~java

public class AdapterInJava {

    public static void main(String[] args) {
        // collections
        List<String> strings = Arrays.asList("a", "b", "c");
        Enumeration<String> enumeration = Collections.enumeration(strings);
        ArrayList<String> list = Collections.list(enumeration);

        // io
        try(InputStream is = new FileInputStream("input.txt");
            InputStreamReader isr = new InputStreamReader(is);
            BufferedReader reader = new BufferedReader(isr)) {
            while(reader.ready()) {
                System.out.println(reader.readLine());
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}

~~~

+ 스프링
  + HandlerAdapter: 우리가 작성하는 다양한 형태의 핸들러 코드를 스프링 MVC가 실행할 수 있는 형태로 변환해주는 어댑터용 인터페이스 

~~~java

public class AdapterInSpring {

    public static void main(String[] args) {
        DispatcherServlet dispatcherServlet = new DispatcherServlet();
        HandlerAdapter handlerAdapter = new RequestMappingHandlerAdapter();
    }
}

~~~

## 브릿지 (Bridge) 패턴
추상적인 것과 구체적인 것을 분리하여 연결하는 패턴
+ 하나의 계층 구조일 때 보다 각기 나누었을 때 독립적인 계층 구조로 발전 시킬 수 있다.
+ ![img.png](/assets/img/gof-design-pattern/Bridge.png)

### 브릿지 (Bridge) 패턴 구현 방법

#### 기존 

+ Skin.class

~~~java

public interface Skin {
    String getName();
}

~~~

+ Champion.class

~~~java

public interface Champion extends Skin {

    void move();

    void skillQ();

    void skillW();

    void skillE();

    void skillR();

}

~~~

+ KDA아리.class

~~~java

public class KDA아리 implements Champion {

    @Override
    public void move() {
        System.out.println("KDA 아리 move");
    }

    @Override
    public void skillQ() {
        System.out.println("KDA 아리 Q");
    }

    @Override
    public void skillW() {
        System.out.println("KDA 아리 W");
    }

    @Override
    public void skillE() {
        System.out.println("KDA 아리 E");
    }

    @Override
    public void skillR() {
        System.out.println("KDA 아리 R");
    }

    @Override
    public String getName() {
        return null;
    }
}

~~~

+ PoolParty아리.class

~~~java

public class PoolParty아리 implements Champion {

    @Override
    public void move() {
        System.out.println("PoolParty move");
    }

    @Override
    public void skillQ() {
        System.out.println("PoolParty Q");
    }

    @Override
    public void skillW() {
        System.out.println("PoolParty W");
    }

    @Override
    public void skillE() {
        System.out.println("PoolParty E");
    }

    @Override
    public void skillR() {
        System.out.println("PoolParty R");
    }

    @Override
    public String getName() {
        return null;
    }
}

~~~

+ App.class

~~~java

public class App {

    public static void main(String[] args) {
        Champion kda아리 = new KDA아리();
        kda아리.skillQ();
        kda아리.skillR();
    }
}

~~~

#### 변경

+ DefaultChampion.class

~~~java

public class DefaultChampion implements Champion {

    private Skin skin;

    private String name;

    public DefaultChampion(Skin skin, String name) {
        this.skin = skin;
        this.name = name;
    }

    @Override
    public void move() {
        System.out.printf("%s %s move\n", skin.getName(), this.name);
    }

    @Override
    public void skillQ() {
        System.out.printf("%s %s Q\n", skin.getName(), this.name);
    }

    @Override
    public void skillW() {
        System.out.printf("%s %s W\n", skin.getName(), this.name);
    }

    @Override
    public void skillE() {
        System.out.printf("%s %s E\n", skin.getName(), this.name);
    }

    @Override
    public void skillR() {
        System.out.printf("%s %s R\n", skin.getName(), this.name);
    }

    @Override
    public String getName() {
        return null;
    }
}

~~~

+ KDA.class

~~~java

public class KDA implements Skin{
    @Override
    public String getName() {
        return "KDA";
    }
}

~~~

+ PoolParty.class

~~~java

public class PoolParty implements Skin {
    @Override
    public String getName() {
        return "PoolParty";
    }
}

~~~

+ 아리.class

~~~java

public class 아리 extends DefaultChampion {

    public 아리(Skin skin) {
        super(skin, "아리");
    }
}


~~~

+ 아칼리.class

~~~java

public class 아칼리 extends DefaultChampion{

    public 아칼리(Skin skin) {
        super(skin, "아칼리");
    }
}


~~~

+ App.class

~~~java

public abstract class App implements Champion {

    public static void main(String[] args) {
        Champion kda아리 = new 아리(new KDA());
        kda아리.skillQ();
        kda아리.skillW();

        Champion poolParty아리 = new 아리(new PoolParty());
        poolParty아리.skillR();
        poolParty아리.skillW();
    }
}

~~~

### 브릿지 (Bridge) 패턴 구현 복습
+ 장점
  + 추상적인 코드를 구체적인 코드 변경 없이도 독립적으로 확장할 수 있다.
  + 추상적인 코드와 구체적인 코드를 분리할 있다.
+ 단점
  + 계층 구조가 늘어나 복잡도가 증가할 수 있다.

### 실무에서 어떻게 쓰이나?
+ 자바
  + JDBC API, DriverManger와 Driver

~~~java

public class JdbcExample {

    public static void main(String[] args) throws ClassNotFoundException {
        Class.forName ("org.h2.Driver");

        try (Connection conn = DriverManager.getConnection ("jdbc:h2:mem:~/test", "sa","")) {

            String sql =  "CREATE TABLE  ACCOUNT " +
                    "(id INTEGER not NULL, " +
                    " email VARCHAR(255), " +
                    " password VARCHAR(255), " +
                    " PRIMARY KEY ( id ))";

            Statement statement = conn.createStatement();
            statement.execute(sql);

//            PreparedStatement statement1 = conn.prepareStatement(sql);
//            ResultSet resultSet = statement.executeQuery(sql);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}

~~~

  + SLF4J, 로깅 퍼사드와 로거

~~~java

public class Slf4jExample {

    private static Logger logger = LoggerFactory.getLogger(Slf4jExample.class);

    public static void main(String[] args) {
        logger.info("hello logger");
    }
}

~~~

+ 스프링
  + Portable Service Abstraction

~~~java

public class BridgeInSpring {

    public static void main(String[] args) {
        MailSender mailSender = new JavaMailSenderImpl();

        PlatformTransactionManager platformTransactionManager = new JdbcTransactionManager();
    }
}

~~~