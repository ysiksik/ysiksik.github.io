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

## 컴포짓 (Composite) 패턴
그룹 전체와 개별 객체를 동일하게 처리할 수 있는 패턴
+ 클라이언트 입장에서는 '전체'나 '부분'이나 모두 동일한 컴포넌트로 인식할 수있는 계층 구조를 만든다. (Part-Whole Hierarchy)
+ ![img.png](/assets/img/gof-design-pattern/Composite.png)

### 컴포짓 (Composite) 패턴 구현 방법
+ ![img.png](/assets/img/gof-design-pattern/Composite2.png)

#### 기존

+ Bag.class

~~~java

public class Bag {

    private List<Item> items = new ArrayList<>();

    public void add(Item item) {
        items.add(item);
    }

    public List<Item> getItems() {
        return items;
    }
}

~~~

+ Item.class

~~~java

public class Item {

  private String name;

  private int price;

  public Item(String name, int price) {
    this.name = name;
    this.price = price;
  }

  public int getPrice() {
    return this.price;
  }
}

~~~

+ Client.class

~~~java

public class Client {

    public static void main(String[] args) {
        Item doranBlade = new Item("도란검", 450);
        Item healPotion = new Item("체력 물약", 50);

        Bag bag = new Bag();
        bag.add(doranBlade);
        bag.add(healPotion);

        Client client = new Client();
        client.printPrice(doranBlade);
        client.printPrice(bag);
    }

    private void printPrice(Item item) {
        System.out.println(item.getPrice());
    }

    private void printPrice(Bag bag) {
        int sum = bag.getItems().stream().mapToInt(Item::getPrice).sum();
        System.out.println(sum);
    }

}

~~~

#### 변경

+ Component.class

~~~java

public interface Component {
  
    int getPrice();

}

~~~

+ Item.class

~~~java

public class Item implements Component {

    private String name;

    private int price;

    public Item(String name, int price) {
        this.name = name;
        this.price = price;
    }

    @Override
    public int getPrice() {
        return this.price;
    }
}

~~~

+ Character.class

~~~java

public class Character implements Component {

    private Bag bag;

    @Override
    public int getPrice() {
        return bag.getPrice();
    }

}

~~~

+ Bag.class

~~~java

public class Bag implements Component {

    private List<Component> components = new ArrayList<>();

    public void add(Component component) {
        components.add(component);
    }

    public List<Component> getComponents() {
        return components;
    }

    @Override
    public int getPrice() {
        return components.stream().mapToInt(Component::getPrice).sum();
    }
}

~~~

+ Client.class

~~~java

public class Client {

    public static void main(String[] args) {
        Item doranBlade = new Item("도란검", 450);
        Item healPotion = new Item("체력 물약", 50);

        Bag bag = new Bag();
        bag.add(doranBlade);
        bag.add(healPotion);

        Client client = new Client();
        client.printPrice(doranBlade);
        client.printPrice(bag);
    }

    private void printPrice(Component component) {
        System.out.println(component.getPrice());
    }
    
}

~~~

### 컴포짓 (Composite) 패턴 구현 복습
+ 장점
  + 복잡한 트리 구조를 편리하게 사용할 수 있다.
  + 다형성과 재귀를 활용할 수 있다.
  + 클라이언트 코드를 변경하지 않고 새로운 엘리먼트 타입을 추가할 수 있다.
+ 단점
  + 트리를 만들어야 하기 때문에 (공통된 인터페이스를 정의해야 하기 때문에) 지나치게 일반화 해야 하는 경우도 생길 수 있다.

### 실무에서 어떻게 쓰이나?
+ 자바
  + Swing 라이브러리
  + JSF (JavaServer Faces) 라이브러리

~~~java

public class SwingExample {

    public static void main(String[] args) {
        JFrame frame = new JFrame();

        JTextField textField = new JTextField();
        textField.setBounds(200, 200, 200, 40);
        frame.add(textField);

        JButton button = new JButton("click");
        button.setBounds(200, 100, 60, 40);
        button.addActionListener(e -> textField.setText("Hello Swing"));
        frame.add(button);

        frame.setSize(600, 400);
        frame.setLayout(null);
        frame.setVisible(true);
    }


}

~~~

## 데코레이터 (Decorator) 패턴 
기존 코드를 변경하지 않고 부가 기능을 추가하는 패턴
+ 상속이 아닌 위임을 사용해서 보다 유연하게(런타임에) 부가 기능을 추가하는 것도 가능핟.
+ ![img.png](/assets/img/gof-design-pattern/Decorator.png)

### 데코레이터 (Decorator) 패턴 구현 방법
+ ![img.png](/assets/img/gof-design-pattern/Decorator2.png)

#### 기존

+ CommentService.java

~~~java

public class CommentService {
    public void addComment(String comment) {
        System.out.println(comment);
    }
}

~~~

+ SpamFilteringCommentService.class

~~~java

public class SpamFilteringCommentService extends CommentService {

    @Override
    public void addComment(String comment) {
        boolean isSpam = isSpam(comment);
        if (!isSpam) {
            super.addComment(comment);
        }
    }

    private boolean isSpam(String comment) {
        return comment.contains("http");
    }
}

~~~

+ TrimmingCommentService.class

~~~java

public class TrimmingCommentService extends CommentService {

    @Override
    public void addComment(String comment) {
        super.addComment(trim(comment));
    }

    private String trim(String comment) {
        return comment.replace("...", "");
    }

}

~~~

+ Client.class

~~~java

public class Client {

    private CommentService commentService;

    public Client(CommentService commentService) {
        this.commentService = commentService;
    }

    private void writeComment(String comment) {
        commentService.addComment(comment);
    }

    public static void main(String[] args) {
        Client client = new Client(new SpamFilteringCommentService());
        client.writeComment("오징어게임");
        client.writeComment("보는게 하는거 보다 재밌을 수가 없지...");
        client.writeComment("http://whiteship.me");
    }

}

~~~

#### 변경

+ CommentService.class

~~~java

public interface CommentService {

    void addComment(String comment);
}

~~~

+ DefaultCommentService.class

~~~java

public class DefaultCommentService implements CommentService {
    @Override
    public void addComment(String comment) {
        System.out.println(comment);
    }
}

~~~

+ CommentDecorator.class

~~~java

public class CommentDecorator implements CommentService {

    private CommentService commentService;

    public CommentDecorator(CommentService commentService) {
        this.commentService = commentService;
    }

    @Override
    public void addComment(String comment) {
        commentService.addComment(comment);
    }
}

~~~

+ SpamFilteringCommentDecorator.class

~~~java

public class SpamFilteringCommentDecorator extends CommentDecorator {

    public SpamFilteringCommentDecorator(CommentService commentService) {
        super(commentService);
    }

    @Override
    public void addComment(String comment) {
        if (isNotSpam(comment)) {
            super.addComment(comment);
        }
    }

    private boolean isNotSpam(String comment) {
        return !comment.contains("http");
    }
}

~~~

+ TrimmingCommentDecorator.class

~~~java

public class TrimmingCommentDecorator extends CommentDecorator {

    public TrimmingCommentDecorator(CommentService commentService) {
        super(commentService);
    }

    @Override
    public void addComment(String comment) {
        super.addComment(trim(comment));
    }

    private String trim(String comment) {
        return comment.replace("...", "");
    }
}

~~~

+ Client.class

~~~java

public class Client {

    private CommentService commentService;

    public Client(CommentService commentService) {
        this.commentService = commentService;
    }

    public void writeComment(String comment) {
        commentService.addComment(comment);
    }
}

~~~

App.class

~~~java

public class App {

    private static boolean enabledSpamFilter = true;

    private static boolean enabledTrimming = true;

    public static void main(String[] args) {
        CommentService commentService = new DefaultCommentService();

        if (enabledSpamFilter) {
            commentService = new SpamFilteringCommentDecorator(commentService);
        }

        if (enabledTrimming) {
            commentService = new TrimmingCommentDecorator(commentService);
        }

        Client client = new Client(commentService);
        client.writeComment("오징어게임");
        client.writeComment("보는게 하는거 보다 재밌을 수가 없지...");
        client.writeComment("http://whiteship.me");
    }
}

~~~

### 데코레이터 (Decorator) 패턴 구현 복습
+ 장점 
  + 새로운 클래스를 만들지 않고 기존 기능을 조합할 수 있다.
  + 컴파일 타임이 아닌 런타임에 동적으로 기능을 변경할 수 있다.
+ 단점
  + 데코레이터를 조합하는 코드가 복잡할 수 있다.

### 실무에서 어떻게 쓰이나?
+ 자바
  + InputStream, OutputStream, Reader, Write의 생성자를 활용한 랩퍼
  + java.util.Collections 가 제공하는 메소드들 활용한 랩퍼
  + javax.servlet.http.HttpServletRequest/ResponseWrapper

~~~java

public class DecoratorInJava {

    public static void main(String[] args) {
        // Collections가 제공하는 데코레이터 메소드
        ArrayList list = new ArrayList<>();
        list.add(new Book());

        List books = Collections.checkedList(list, Book.class);


//        books.add(new Item());

        List unmodifiableList = Collections.unmodifiableList(list);
        list.add(new Item());
        unmodifiableList.add(new Book());


        // 서블릿 요청 또는 응답 랩퍼
        HttpServletRequestWrapper requestWrapper;
        HttpServletResponseWrapper responseWrapper;
    }

    private static class Book {

    }

    private static class Item {

    }
}

~~~

+ 스프링
  + ServerHttpRequestDecorator

~~~java

public class DecoratorInSpring {

    public static void main(String[] args) {
        // 빈 설정 데코레이터
        BeanDefinitionDecorator decorator;

        // 웹플럭스 HTTP 요청 /응답 데코레이터
        ServerHttpRequestDecorator httpRequestDecorator;
        ServerHttpResponseDecorator httpResponseDecorator;
    }
}

~~~

## 퍼사드 (Facade) 패턴
복잡한 서브 시스템 의존성을 최소화하는 방법.
+ 클라이언트가 사용해야 하는 복잡한 서브 시스템 의존성을 간단한 인터페이스로 추상화 할 수 있다. 
+ ![img.png](/assets/img/gof-design-pattern/Facade.png)

### 퍼사드 (Facade) 패턴 구현 방법

#### 기존

+ Client.class

~~~java

public class Client {

    public static void main(String[] args) {
        String to = "test@whiteship.me";
        String from = "whiteship@whiteship.me";
        String host = "127.0.0.1";

        Properties properties = System.getProperties();
        properties.setProperty("mail.smtp.host", host);

        Session session = Session.getDefaultInstance(properties);

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
            message.setSubject("Test Mail from Java Program");
            message.setText("message");

            Transport.send(message);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
}

~~~

#### 변경

+ EmailMessage.class

~~~java

public class EmailMessage {

  private String from;

  private String to;
  private String cc;
  private String bcc;

  private String subject;

  private String text;

  public String getFrom() {
    return from;
  }

  public void setFrom(String from) {
    this.from = from;
  }

  public String getTo() {
    return to;
  }

  public void setTo(String to) {
    this.to = to;
  }

  public String getSubject() {
    return subject;
  }

  public void setSubject(String subject) {
    this.subject = subject;
  }

  public String getText() {
    return text;
  }

  public void setText(String text) {
    this.text = text;
  }

  public String getCc() {
    return cc;
  }

  public void setCc(String cc) {
    this.cc = cc;
  }

  public String getBcc() {
    return bcc;
  }

  public void setBcc(String bcc) {
    this.bcc = bcc;
  }
}

~~~

+ EmailSettings.class

~~~java

public class EmailSettings {

    private String host;

    public String getHost() {
        return host;
    }

    public void setHost(String host) {
        this.host = host;
    }
}

~~~

+ EmailSender.class

~~~java

public class EmailSender {

    private EmailSettings emailSettings;

    public EmailSender(EmailSettings emailSettings) {
        this.emailSettings = emailSettings;
    }

    /**
     * 이메일 보내는 메소드
     * @param emailMessage
     */
    public void sendEmail(EmailMessage emailMessage) {
        Properties properties = System.getProperties();
        properties.setProperty("mail.smtp.host", emailSettings.getHost());

        Session session = Session.getDefaultInstance(properties);

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(emailMessage.getFrom()));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(emailMessage.getTo()));
            message.addRecipient(Message.RecipientType.CC, new InternetAddress(emailMessage.getCc()));
            message.setSubject(emailMessage.getSubject());
            message.setText(emailMessage.getText());

            Transport.send(message);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }


}

~~~


+ Client.class

~~~java

public class Client {

    public static void main(String[] args) {
        EmailSettings emailSettings = new EmailSettings();
        emailSettings.setHost("127.0.0.1");

        EmailSender emailSender = new EmailSender(emailSettings);

        EmailMessage emailMessage = new EmailMessage();
        emailMessage.setFrom("test");
        emailMessage.setTo("whiteship");
        emailMessage.setCc("일남");
        emailMessage.setSubject("오징어게임");
        emailMessage.setText("밖은 더 지옥이더라고..");

        emailSender.sendEmail(emailMessage);
    }
}

~~~

### 퍼사드 (Facade) 패턴 구현 복습
+ 장점
  + 서브 시스템에 대한 의존성을 한곳으로 모을 수 있다.
+ 단점
  + 퍼사드 클래스가 서브 시스템에 대한 모든 의존성을 가지게 된다.

### 실무에서 어떻게 쓰이나?
+ 스프링
  + Spring MVC
  + 스프링이 제공하는 대부분의 기술 독립적인 인터페이스와 그 구현체

~~~java

public class FacadeInSpring {

    public static void main(String[] args) {
        MailSender mailSender = new JavaMailSenderImpl();

        PlatformTransactionManager platformTransactionManager = new JdbcTransactionManager();
    }
}

~~~

## 플라이웨이트 (Flyweight) 패턴
객체를 가볍게 만들어 메모리 사용을 줄이는 패턴
+ 자주 변하는 속성(또는 외적인 속성, extrinsit)과 변하지 않는 속성(또는 내적인 속성, intrinsit)을 분리하고 재사용하여 메모리 사용을 줄일 수 있다.
+ ![img.png](/assets/img/gof-design-pattern/Flyweight.png)
+ 애플리케이션에서 굉장히 많은 인스턴스를 만드는 그런 특징을 가지고 있는 애플리케이션에서 주로 사용한다. 

### 플라이웨이트 (Flyweight) 구현 방법

#### 기존

+ Character.class

~~~java

public class Character {

    private char value;

    private String color;

    private String fontFamily;

    private int fontSize;

    public Character(char value, String color, String fontFamily, int fontSize) {
        this.value = value;
        this.color = color;
        this.fontFamily = fontFamily;
        this.fontSize = fontSize;
    }
}

~~~

+ Client.class

~~~java

public class Client {

    public static void main(String[] args) {
        Character c1 = new Character('h', "white", "Nanum", 12);
        Character c2 = new Character('e', "white", "Nanum", 12);
        Character c3 = new Character('l', "white", "Nanum", 12);
        Character c4 = new Character('l', "white", "Nanum", 12);
        Character c5 = new Character('o', "white", "Nanum", 12);
    }
}

~~~

#### 변경 

+ Font.class

~~~java

public final class Font {

    final String family;

    final int size;

    public Font(String family, int size) {
        this.family = family;
        this.size = size;
    }

    public String getFamily() {
        return family;
    }

    public int getSize() {
        return size;
    }
}

~~~

+ FontFactory.class

~~~java

public class FontFactory {

    private Map<String, Font> cache = new HashMap<>();

    public Font getFont(String font) {
        if (cache.containsKey(font)) {
            return cache.get(font);
        } else {
            String[] split = font.split(":");
            Font newFont = new Font(split[0], Integer.parseInt(split[1]));
            cache.put(font, newFont);
            return newFont;
        }
    }
}

~~~

+ Character.class

~~~java

public class Character {

    private char value;

    private String color;

    private Font font;

    public Character(char value, String color, Font font) {
        this.value = value;
        this.color = color;
        this.font = font;
    }
}

~~~

+ Client.class

~~~java

public class Client {

    public static void main(String[] args) {
        FontFactory fontFactory = new FontFactory();
        Character c1 = new Character('h', "white", fontFactory.getFont("nanum:12"));
        Character c2 = new Character('e', "white", fontFactory.getFont("nanum:12"));
        Character c3 = new Character('l', "white", fontFactory.getFont("nanum:12"));
    }
}

~~~

### 플라이웨이트 (Flyweight) 구현 복습
+ 장점
  + 애플리케이션에서 사용하는 메모리를 줄일 수 있다.
+ 단점
  + 코드의 복잡도가 증가한다.

### 실무에서 어떻게 쓰이나?
+ 자바 
  + Integer.valueOf(int)
  + 캐시를 제공한다.
  + [https://docs.oracle.com/javase/8/docs/api/java/lang/Integer.html#valueOf-int-](https://docs.oracle.com/javase/8/docs/api/java/lang/Integer.html#valueOf-int-)

~~~java

public class FlyweightInJava {

    public static void main(String[] args) {
        Integer i1 = Integer.valueOf(10);
        Integer i2 = Integer.valueOf(10);
        System.out.println(i1.equals(i2));
    }
}

~~~

## 프록시 (Proxy) 패턴
특정 객체에 대한 접근을 제어하거나 기능을 추가할 수 있는 패턴
+ 초기화 지연, 접근 제어, 로깅, 캐싱, 등 다양하게 응용해서 사용 할 수 있다.
+ ![img.png](/assets/img/gof-design-pattern/Proxy.png)

### 프록시 (Proxy) 패턴 구현 방법

#### 기존 

+ GameService.class

~~~java

public class GameService {

    public void startGame() {
        System.out.println("이 자리에 오신 여러분을 진심으로 환영합니다.");
    }

}

~~~


+ Client.class

~~~java

public class Client {

    public static void main(String[] args) throws InterruptedException {
        GameService gameService = new GameService();
        gameService.startGame();
    }
}

~~~

#### 변경

기존을 코드를 변경하지 않고 적용하는 방법 - 상속 사용

+ GameService.class

~~~java

public class GameService {

  public void startGame() throws InterruptedException {
    System.out.println("이 자리에 오신 여러분을 진심으로 환영합니다.");
    Thread.sleep(1000L);
  }

}

~~~

+ GameServiceProxy.class

~~~java

public class GameServiceProxy extends GameService {

    @Override
    public void startGame() throws InterruptedException {
        long before = System.currentTimeMillis();
        super.startGame();
        System.out.println(System.currentTimeMillis() - before);
    }
}

~~~

+ Client.class

~~~java

public class Client {

    public static void main(String[] args) throws InterruptedException {
        GameService gameService = new GameServiceProxy();
        gameService.startGame();
    }
}

~~~

기존을 코드를 변경하고 적용하는 방법 - 인터페이스 사용


+ GameService.class

~~~java

public interface GameService {

    void startGame();

}

~~~


+ DefaultGameService.class

~~~java

public class DefaultGameService implements GameService {

    @Override
    public void startGame() {
        System.out.println("이 자리에 오신 여러분을 진심으로 환영합니다.");
    }
}

~~~

+ GameServiceProxy.class

~~~java

public class GameServiceProxy implements GameService {

    private GameService gameService;

    @Override
    public void startGame() {
        long before = System.currentTimeMillis();
        if (this.gameService == null) {
            this.gameService = new DefaultGameService();
        }

        gameService.startGame();
        System.out.println(System.currentTimeMillis() - before);
    }
}

~~~


+ Client.class

~~~java

public class Client {

    public static void main(String[] args) {
        GameService gameService = new GameServiceProxy();
        gameService.startGame();
    }
}

~~~


### 프록시 (Proxy) 패턴 구현 복습
+ 장점
  + 기존 코드를 변경하지 않고 새로운 기능을 추가할 수 있다.
  + 기존 코드가 해야 하는 일만 유지할 수 있다.
  + 기능 추가 및 초기화 지연 등으로 다양하게 활용할 수 있다.
+ 단점
  + 코드의 복잡도가 증가한다.

### 실무에서 어떻게 쓰이나?
+ 자바 
  + 다이나믹 프록시, java.lang.reflect.Proxy

~~~java

// 다이나믹 프록시
public class ProxyInJava {

    public static void main(String[] args) {
        ProxyInJava proxyInJava = new ProxyInJava();
        proxyInJava.dynamicProxy();
    }

    private void dynamicProxy() {
        GameService gameServiceProxy = getGameServiceProxy(new DefaultGameService());
        gameServiceProxy.startGame();
    }

    private GameService getGameServiceProxy(GameService target) {
        return  (GameService) Proxy.newProxyInstance(this.getClass().getClassLoader(),
                new Class[]{GameService.class}, (proxy, method, args) -> {
                    System.out.println("O");
                    method.invoke(target, args);
                    System.out.println("ㅁ");
                    return null;
                });
    }
}

~~~

+ 스프링
  + 스프링 AOP

+ PerfAspect.class

~~~java

@Aspect
@Component
public class PerfAspect {

    @Around("bean(gameService)")
    public void timestamp(ProceedingJoinPoint point) throws Throwable {
        long before = System.currentTimeMillis();
        point.proceed();
        System.out.println(System.currentTimeMillis() - before);
    }
}

~~~

+ GameService.class

~~~java

@Service
public class GameService {

    public void startGame() {
        System.out.println("이 자리에 오신 여러분을 진심으로 환영합니다.");
    }

}

~~~

+ App.class

~~~java

@SpringBootApplication
public class App {

    public static void main(String[] args) {
        SpringApplication app = new SpringApplication(App.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        app.run(args);
    }

    @Bean
    public ApplicationRunner applicationRunner(GameService gameService) {
        return args -> {
            gameService.startGame();
        };
    }
}

~~~