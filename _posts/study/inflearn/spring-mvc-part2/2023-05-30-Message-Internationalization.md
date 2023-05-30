---
layout: post
bigtitle: '스프링 MVC 2편 - 백엔드 웹 개발 핵심 기술'
subtitle: 메시지, 국제화
date: '2023-05-30 00:00:00 +0900'
categories:
- spring-mvc-part2
comments: true

---

# 메시지, 국제화

# 메시지, 국제화
* toc
{:toc}

## 메시지, 국제화 소개
+ messages.properties

~~~properties

item=상품
item.id=상품 ID
item.itemName=상품명
item.price=가격
item.quantity=수량

~~~

+ ```<label for="itemName" th:text="#{item.itemName}"></label>```
+ 영어를 사용하는 사람이면 ```messages_en.properties``` 를 사용
+ 한국어를 사용하는 사람이면 ```messages_ko.properties``` 를 사용
+ 한국에서 접근한 것인지 영어에서 접근한 것인지는 인식하는 방법은 HTTP accept-language 해더 값을 사용하거나 사용자가 직접 언어를 선택하도록 하고, 쿠키 등을 사용해서 처리하면 된다.
+ 메시지와 국제화 기능을 직접 구현할 수도 있겠지만, 스프링은 기본적인 메시지와 국제화 기능을 모두 제공한다.
+ 그리고 타임리프도 스프링이 제공하는 메시지와 국제화 기능을 편리하게 통합해서 제공한다.

## 스프링 메시지 소스 설정
+ 스프링은 기본적인 메시지 관리 기능을 제공한다
+ 메시지 관리 기능을 사용하려면 스프링이 제공하는 MessageSource 를 스프링 빈으로 등록하면 되는데, MessageSource 는 인터페이스이다. 따라서 구현체인 ResourceBundleMessageSource 를 스프링 빈으로 등록하면 된다.
+ 직접 등록

~~~java

@Bean
public MessageSource messageSource() {
 ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
 messageSource.setBasenames("messages", "errors");
 messageSource.setDefaultEncoding("utf-8");
 return messageSource;
}

~~~

+ basenames : 설정 파일의 이름을 지정한다.
  + messages 로 지정하면 messages.properties 파일을 읽어서 사용한다.
  + 추가로 국제화 기능을 적용하려면 messages_en.properties , messages_ko.properties 와 같이 파일명 마지막에 언어 정보를 주면된다. 만약 찾을 수 있는 국제화 파일이 없으면 messages.properties (언어정보가 없는 파일명)를 기본으로 사용한다.
  + 파일의 위치는 /resources/messages.properties 에 두면 된다.
  + 여러 파일을 한번에 지정할 수 있다. 여기서는 messages , errors 둘을 지정했다.
+ defaultEncoding : 인코딩 정보를 지정한다. utf-8 을 사용하면 된다.

### 스프링 부트
+ 스프링 부트를 사용하면 스프링 부트가 MessageSource 를 자동으로 스프링 빈으로 등록한다.
+ 스프링 부트 메시지 소스 설정
  + application.properties

~~~properties

spring.messages.basename=messages,config.i18n.messages

~~~

+ 스프링 부트 메시지 소스 기본 값
  + spring.messages.basename=messages
  + MessageSource 를 스프링 빈으로 등록하지 않고, 스프링 부트와 관련된 별도의 설정을 하지 않으면 messages 라는 이름으로 기본 등록된다. 따라서 messages_en.properties , messages_ko.properties , messages.properties 파일만 등록하면 자동으로 인식된다.

## 스프링 메시지 소스 사용
+ MessageSource 인터페이스

~~~java

public interface MessageSource {
  String getMessage(String code, @Nullable Object[] args, @Nullable String defaultMessage, Locale locale);

  String getMessage(String code, @Nullable Object[] args, Locale locale) throws NoSuchMessageException;
}

~~~

+ MessageSource 인터페이스를 보면 코드를 포함한 일부 파라미터로 메시지를 읽어오는 기능을 제공한다.

~~~java


@SpringBootTest
public class MessageSourceTest {
  @Autowired
  MessageSource ms;
  @Test
  void helloMessage() {
    String result = ms.getMessage("hello", null, null);
    assertThat(result).isEqualTo("안녕");
  }
  @Test
  void notFoundMessageCode() {
    assertThatThrownBy(() -> ms.getMessage("no_code", null, null))
            .isInstanceOf(NoSuchMessageException.class);
  }
  @Test
  void notFoundMessageCodeDefaultMessage() {
    String result = ms.getMessage("no_code", null, "기본 메시지", null);
    assertThat(result).isEqualTo("기본 메시지");
  }
  @Test
  void argumentMessage() {
    String result = ms.getMessage("hello.name", new Object[]{"Spring"}, null);
    assertThat(result).isEqualTo("안녕 Spring");
  }
}


~~~

+ 메시지가 없는 경우에는 NoSuchMessageException 이 발생한다.
+ 메시지가 없어도 기본 메시지( defaultMessage )를 사용하면 기본 메시지가 반환된다.
+ hello.name=안녕 {0} -> Spring 단어를 매개변수로 전달 -> 안녕 Spring

+ 국제화 파일 선택
  + locale 정보를 기반으로 국제화 파일을 선택한다.
  + Locale이 en_US 의 경우 messages_en_US -> messages_en -> messages 순서로 찾는다.
  + Locale 에 맞추어 구체적인 것이 있으면 구체적인 것을 찾고, 없으면 디폴트를 찾는다고 이해하면 된다.

~~~java

@Test
void defaultLang() {
 assertThat(ms.getMessage("hello", null, null)).isEqualTo("안녕");
 assertThat(ms.getMessage("hello", null, Locale.KOREA)).isEqualTo("안녕");
}

@Test
void enLang() {
        assertThat(ms.getMessage("hello", null,Locale.ENGLISH)).isEqualTo("hello");
}

~~~

+ ms.getMessage("hello", null, null) : locale 정보가 없으므로 messages 를 사용
+ ms.getMessage("hello", null, Locale.KOREA) : locale 정보가 있지만, message_ko 가 없으므로 messages 를 사용
+ ms.getMessage("hello", null, Locale.ENGLISH) : locale 정보가 Locale.ENGLISH 이므로 messages_en 을 찾아서 사용
+ Locale 정보가 없는 경우 Locale.getDefault() 을 호출해서 시스템의 기본 로케일을 사용
  + 예) locale = null 인 경우 -> 시스템 기본 locale 이 ko_KR 이므로 messages_ko.properties 조회 시도 -> 조회 실패 -> messages.properties 조회
  + 참고: [https://www.inflearn.com/questions/286899](https://www.inflearn.com/questions/286899)

## 웹 애플리케이션에 메시지 적용하기
+ 타임리프 메시지 적용
  + 타임리프의 메시지 표현식 ```#{...}``` 를 사용하면 스프링의 메시지를 편리하게 조회할 수 있다.
+ 참고로 파라미터는 다음과 같이 사용할 수 있다.
  + ```hello.name=안녕 {0}```
  + ```<p th:text="#{hello.name(${item.itemName})}"></p>```

## 웹 애플리케이션에 국제화 적용하기
+ 웹으로 확인하기
  + 웹 브라우저의 언어 설정 값을 변경하면서 국제화 적용을 확인해보자. 크롬 브라우저 -> 설정 -> 언어를 검색하고, 우선 순위를 변경하면 된다.
  + 웹 브라우저의 언어 설정 값을 변경하면 요청시 Accept-Language 의 값이 변경된다.
+ 스프링의 국제화 메시지 선택
  + 메시지 기능은 Locale 정보를 알아야 언어를 선택할 수 있다.
  + 결국 스프링도 Locale 정보를 알아야 언어를 선택할 수 있는데, 스프링은 언어 선택시 기본으로 AcceptLanguage 헤더의 값을 사용한다.
+ LocaleResolver
  + 스프링은 Locale 선택 방식을 변경할 수 있도록 LocaleResolver 라는 인터페이스를 제공하는데, 스프링 부트는 기본으로 Accept-Language 를 활용하는 AcceptHeaderLocaleResolver 를 사용한다.
+ LocaleResolver 인터페이스

~~~java

public interface LocaleResolver {
    
Locale resolveLocale(HttpServletRequest request);
void setLocale(HttpServletRequest request, @Nullable HttpServletResponse response, @Nullable Locale locale);

}

~~~

+ LocaleResolver 변경
  + 만약 Locale 선택 방식을 변경하려면 LocaleResolver 의 구현체를 변경해서 쿠키나 세션 기반의 Locale 선택 기능을 사용할 수 있다.
  + 예를 들어서 고객이 직접 Locale 을 선택하도록 하는 것이다. 
