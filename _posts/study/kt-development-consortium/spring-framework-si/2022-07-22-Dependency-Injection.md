---
layout: post
bigtitle: 'Spring 전자정부 프레임워크 기반 SI 실무'
subtitle: 의존성 주입(DI, Dependency Injection)
date: '2022-07-22 00:00:00 +0900'
categories:
    - spring-framework-si
tags: spring
comments: true
---

# 의존성 주입(DI, Dependency Injection)

# 의존성 주입(DI, Dependency Injection)
* toc
{:toc}

  

## 빈 생성 범위
+ 싱글톤 빈(Singleton Bean)
  + 스프링 빈은 기본적으로 싱글톤으로 만들어진다.
  + 그르므로, 컨테이너가 제공하는 모든 빈의 인스턴스는 항상 동일하다.
  + 컨테이너가 항상 새로운 인스턴스를 반환하게 만들고 싶은 경우 scope를 prototype로 설정해야 한다.
  
## 빈 범위 지정

|    범위     |                설명                 |
|:---------:|:---------------------------------:|
| singleton | 스프링 컨테이너당 하나의 인스턴스 빈만 생성(default) |
| prototype |   컨테이너에 빈을 요청할 때마다 새로운 인스턴스 생성    |
| request | Http Request 별로 새로운 인스턴스 생성 |
| session | Http Session 별로 새로운 인스턴스 생성 |


## 스프링 빈 설정
+ 스프링 빈 설정 메타정보

<div class="language-mermaid">
graph LR;
A[XML Document]-->B[BeanDefinition meta data];
Annotation-->B;
C[Java Code]-->B;
B-->D[IoC Container];
</div>

+ XML
  + XML문서 형태로 빈의 설정 메타 정보를 기술.
  + 단순하며 사용하기 쉬움, 가장 많이 사용하는 방식.
  + < bean > 태그를 통해 세밀한 제어 가능.
+ Annotation
  + 어플리케이션의 규모가 커지고 빈의 갯수가 많아질 경우 XML 파일을 관리하는 것이 번거로움.
  + 빈으로 사용될 클래스에 특별한 annotation을 부여해 주면 자동으로 빈 등록 가능.
  + "오브젝트 빈 스캐너"로 "빈 스캐닝"을 통해 자동 등록
    + 빈 스캐너는 기본적으로 클래스 이름을 빈의 아이디 사용.
    + 정확히는 클래스 이름의 첫 글자만 소문자로 바꾼 것을 사용.
  + stereotype annotation 종류
    + 빈 자동등록에 사용할 수 있는 annotation
    + AOP Pointcut 표현식을 사용하면 특정 annotation이 달린 클래스만 설정 가능.
    + 특정 계층의 빈에 부가기능을 부여

    | Stereotype |                                               적용 대상                                               |
    |:-------------------------------------------------------------------------------------------------:|:---------:|
    | @Repository | Data Access Layer의 DAO 또는 Repository 클래스에 사용. DataAccessException 자동변화과 같은 AOP의 적용 대상을 선정하기 위해사용. |
    | @Service |                                      Service Layer의 클래스에 사용.                                      |
    | @Controller |           Presentation Layer의 MVC Controller에 사용. 스프링 웹 서블릿에 의해 웹 요청을 처리하는 컨토롤러 빈으로 선정.           |
    | @Component |                                 위의 Layer 구분을 적용하기 어려운 일반적인 경우에 설정                                 |

## 의존관계 주입(DI)
+ Dependency Injection
  + 객체간의 의존관계를 자신이 아닌 외부의 조립기가 수행.
  + 제어의 역행(inversion of control, IoC) 이라는 의미로 사용.
  + DI를 통해 시스템에 있는 각 객체를 조정하는 외부 개체가 객체들에게 생성시에 의존관계를 주어짐
  + 느슨한 결합(loose coupling)의 주요 강점
    + 객체는 인터페이스에 의한 의존관계만을 알고 있으며, 이 의존 관계는 구현 클래스에 대한 차이를 모르는 채 서로 다른 구현으로 대채가 가능.

## 스프링의 DI 지원
+ Spring Container가 DI 조립기를 제공
  + 스프링 설정파일을 통하여 객체간의 의존관계를 설정.
  + Spring Container가 제공하는 api를 이용해 객체를 사용.

## 스프링 설정
+ XML 문서이용
  + Application에서 사용할 Spring 자원들을 설정하는 파일
  + Spring Container는 설정파일에 설정된 내용을 읽어 Application에서 필요한 기능들을 제공.
  + Root tag는 < beans >
  + 파일명은 상관 없다.
+ 기본설정 - 빈 객체 생성 및 주입
  + 주입 할 객체를 설정파일에 설정
    + < bean > : 스프링 컨테이너가 관리할 Bean 객체를 설정
  + 기본 속성
    + name : 주입 받는 곳에서 호출 할 이름 설정
    + id : 주입 받는 곳에서 호출 할 이름 설정(유일 값)
    + class : 주입 할 객체의 클래스
    + factory-method : 패턴으로 작성된 객체의 factory 메소드 호출
+ 기본설정 - 빈 객체 얻기
  + 설정 파일에 설정한 bean을 Container가 제공하는 주입기 역할의 api를 통해 주입 받는다.
  
## 스프링 빈 의존 관계 설정 - xml
+ Constructor 이용
  + 객체 또는 값을 생성자를 통해 주입 받는다.
    + < construct-arg > : < bean >의 하위태그로 설정한 bean 객체 또는 값을 생성자를 통해 주입하도록 설정.
      + 설정 방법 : < ref >, < value >와 같은 하위태그를 이용하여 설정 하거나 또는 속성을 이용하여 설정.
        + 하위태그 이용
          + 객체 주입시 : < ref bean = "bean name" />
          + 문자열(String), primitive data 주입 시 : < value >값< /value >
            + type 속성 : 값은 기본적으로 Spring으로 처리 값의 타입을 명시해야 하는 경우는 < value type = "int">10< /value >
        + 속성이용
          + 객체 주입 시 : < constructor-arg ref="bean name" />
          + 문자열(String), primitive data 주입 시 : < constructor-arg value="값" />
  + 생성자의 argument의 순서를 지키지 않을 경우.
    + 속성(type, index, name)을 이동하여 match 시켜준다.
+ Property 이용
  + property를 통해 객체 또는 값을 주입 받는다. - setter method
    + 주의 : setter를 통해서는 하나의 값만 받을 수 있다.
  + < property > : < bean >의 하위 태그로 설정한 bean 객체 또는 값을 property를 통해 주입하도록 설정
    + 설정 방법 : < ref >, < value >와 같은 하위태그를 이용하여 설정 하거나 또는 속성을 이용하여 설정.
      + 하위태그 이용
        + 객체 주입시 : < ref bean = "bean name" />
        + 문자열(String), primitive data 주입 시 : < value >값< /value >
      + 속성이용 : name - 값을 주입할 property의 이름(setter 이름)
        + 객체 주입 시 : < property name="propertyname" ref="bean name" />
        + 문자열(String), primitive data 주입 시 : < property name="propertyname" value="값" />
      + xml namespace를 이용하여 설정
        + < bean > 태그의 스키마 설정에 namespace 등록
          + xmlns:p="http://www.springframework.org/schema/p"
        + Bean 설정 시 < bean > 태그 속성으로 설정
          + 기본 데이터 주입 > p:propertyname="값"
          + bean 주입 > p:propertyname-ref="bean_id"
+ Collection 계열 주입
  + < construct-arg > 또는 < property >의 하위 태그로 Collection값을 설정하는 태그를 이용하여 값 주입 설정
  + 설정 태그

    | 태그 | Collection 종류 | 설명 |
    | :----: | :--------: | :--- |   
    | < list > | java.util.List | List 계열 컬렉션 값 목록 전달 |
    | < set > | java.util.Set | Set 계열 컬렉션 값 목록 전달 |
    | < map > | java.util.Map | Map 계열 컬렉션에 key value 의 값 목록 전달 |
    | < props > | java.util.Properties | Properties에 key(String) value(String) 의 값 목록 전달 |
  
    + < list >
      + List계열 컬렉션이나 배열에 값들을 넣기
      + < ref >,< value > 태그를 이용해 값 설정
      + < ref bean="bean_id" > : bean 객체를 list에 추가
      + < value [type="type"] 값 < /value > : 문자열 (String), Primitive 값 list 에 추가
    + < set > 
      + Set계열에 객체 넣기
        + 속성 : value-type -> 값의 타입을 지정할 수 있다.
        + < ref >,< value > 태그를 이용해 값 설정
    + < map >
      + Map계열에 객체 넣기
        + 속성 : key-type, value-type -> 값의 타입을 지정할 수 있다.
      + < entry >를 이용해 key-value를 map에 등록
        + 속성
          + key, key-ref : key 설정
          + value, value-ref : 값 설정
    + < props > 
      + java.util.Properties에 값(문자열) 넣기
      + < prop >를 이용해 key-value를 properties에 등록
        + 속성
          + key : key 설정
        + 값은 태그 사이에 넣는다 : < prop key="username" >이름< /prop >

## 스프링 빈 의존 관계 설정 - annotation
+ Annotation
  + 멤버변수에 직접 정의 하는 경우 setter method를 만들지 않아도 됨.
  
| annotation  |                                                       설명                                                       |
|:-----------:|:--------------------------------------------------------------------------------------------------------------:|
|  @Resource  |                             Spring 2.5부터 지원, 멤버변수 setter method에 사용가능, 타입에 맞춰서 연결                              |
| @Autowired  |  Spring 2.5부터 지원, Spring에서만 사용 가능, Required 속성을 통해 DI여부 조정, 멤버변수 setter contructor 일반 method 사용가능, 타입에 맞춰서 연결  |
|   @Inject   | Spring 3.0부터 지원, Framework에 종석적이지 않음 , Javax.inject-x.x.x.jar필요,멤버변수 setter contructor 일반 method 사용가능, 이름으로 연결 |  

+ 특정 Bean의 기능 수행을 위해 다른 Bean을 참조해야 하는 경우 사용한다.
+ @Autowired
  + Spring Framework에서 지원하는 Dependency 정의 용도의 Annotation으로, Spring Framework에 종속적이긴 하지만 정밀한 Dependency Injection이 필요한 경우에 유용하다.
  + 동일한 타입의 bean이 여러 개일 경우에는 @Qualifier("name")을로 식별한다.
+ @Resource
  + JSR-250 표준 Annotation으로 Spring Framework 2.5.* 부터 지원하는 Annotation이다. @Resource는 JNDI리소스(datasource , java messaging service destination or environment)와 연관 지어 생각할 수 있으며
  특정 Bean이 JNDI 리소스에 대한 Injection을 필요로 하는 경우에는 @Resource를 사용할 것을 권장한다.
+ @Inject
  + JSR-330 표준 Annotation으로 Spring Framework 3 부터 지원하는 Annotation이다. 특정 Framework에 종속되지 않은 애플리케이션을 구성하기 위해서는 @Inject를 사용할 것을 권장한다.
  @Inject를 사용하기 위해서는 클래스 패스 내에 JSR-330 라이브러리인 javax.inject-x.x.x.jar 파일이 추가되어야 함에 유의해야 한다.

## 기타 설정
+ 빈 객체의 생성단위
  + BeanFactory를 통해 Bean을 요청 시 객체생성의 범위(단위)를 설정
  + < bean >의 scope 속성을 이용해 설정
  + scope 속성은 다음과 같은 값을 사용할 수 있다.
    + singleton : 스프링 컨테이너당 하나의 인스턴스 빈만 생성(default)
    + prototype : 컨테이너에 빈을 요청할 때마다 새로운 인스턴스 생성
    + request : HTTP Request별로 새로운 인스턴스 생성
    + session : HTTP Session별로 새로운 인스턴스 생성
  + request, session은 WebApplicationContext에서만 적용 가능
+ singleton & prototype
  + singleton은 spring application context에서 getBean()을 이용하여 bean 객체를 반환 받을 때 동일한 instance를 반환
  + prototype은 spring application context에서 getBean()을 이용하여 bean 객체를 반환 받을 때 새로운 instance를 반환
+ Factory Method로부터 빈(bean) 생성
  + getBean()으로 호출 시 private 생성자도 호출 하여 객체를 생성한다.그러므로 factory method만 호출 해야 객체를 얻을 수 있는 것은 아니다.
    
## 스프링 빈의 생명 주기(LifeCycle)
+ LifeCycle
<div class="language-mermaid">
graph LR;
A[빈 생성]-->B[의존성 주입];
B-->C[init-method 실행];
C-->D[빈 사용];
D-->E[destroy-method 실행];
E-->F[빈 소멸];
</div>

![예제](/assets/img/springFramework/LifeCycle.jpg)
