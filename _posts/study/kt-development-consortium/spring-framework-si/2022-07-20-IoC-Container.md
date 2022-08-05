---
layout: post
bigtitle: 'Spring 전자정부 프레임워크 기반 SI 실무'
subtitle: IoC & Container
date: '2022-07-20 00:00:00 +0900'
categories:
    - study
    - kt-development-consortium
    - spring-framework-si
tags: spring
comments: true
---

# IoC & Container

# IoC & Container
* toc
{:toc}

  
  
## IoC (Inversion of Control, 제어의 역행)

+ IoC/DI
+ 객체지향 언어에서 Object간의 연결 관계를 런타임에 결정
+ 객체 간의 관계가 느슨하게 연결됨(loose coupling)
+ IoC의 구현 방법 중 하나가 DI(Dependency Injection)
  

## IoC 유형

<div class="language-mermaid">
graph LR;
    IoC-->A[Dependency Lookup];
    A-->B[JNDI Lookup];
    IoC-->C[Dependency Injection];
    C-->D[Setter Injection];
    C-->E[Constructor Injection];
    C-->F[Method Injection];
</div>

+ Dependency Lookup
  + 컨테이너가 lookup context를 통해서 필요한 Resource나 Object를 얻는 방식.
  + JNDI 이외의 방법을 사용한다면 JNDI관련 코드를 오브젝트 내에서 일일이 변경해 주어야 함.
  + Lookup 한 Object를 필요한 타입으로 Casting 해 주어야 함.
  + Naming Exception을 처리하기 위한 로직이 필요.
+ Dependency Injection
  + Object에 lookup 코드를 사용하지 않고 컨테이너가 직접 의존 구조를 Object에 설정 할 수 있도록 지정해 주는 방식.
  + Object가 컨테이너 존재 여부를 알 필요가 없음.
  + Lookup 관련된 코드들이 Object 내에서 사라짐.
  + Setter Injection과 Constructor Injection.

## Container
+ Container 란?
  + 객체의 생성, 사용, 소멸에 해당하는 라이프사이클을 담당
  + 라이프사이클을 기본으로 애플리케이션 사용에 필요한 주요 기능을 제공
+ Container 기능
  + 라이프사이클 관리
  + Dependency 객체 제공
  + Tread 관리
  + 기타 애플리케이션 실행에 필요한 환경
+ Container 필요성
  + 비즈니스 로직 외의 부가적인 기능들에 대해서는 독립적으로 관리되도록 하기 위함.
  + 서비스 look up 이나 Configuration에 대한 일괄성을 갖기 위함.
  + 서비스 객체를 사용하기 위해 각각 Factory 또는 Singleton 패턴을 직접 구현하지 않아도 됨.
+ IoC Container
  + 오브젝트 생성과 관계설정, 사용, 제거 등의 작업을 애플리케이션 코드 대신 독립된 컨테이너가 담당.
  + 컨테이너가 코드 대신 오브젝트에 대한 제어권을 갖고 있어 IoC라고 부름.
  + 이런 이유로, 스프링 컨테이너를 Ioc 컨테이너라고 부르기도 함.
  + 스프링에서 IoC를 담당하는 컨테이너에는 BeanFactory, ApplicationContext가 있음.
+ Spring DI Container
  + Spring DI Container가 관리하는 객체를 빈(Bean)이라 하고, 이 빈들의 생명주기(Life-Cycle)를 관리하는 의미로 빈팩토리(BeanFactory)라 한다.
  + BeanFactory에 여러가지 기능을 추가하여 ApplicationContext라 한다.

    <div class="language-mermaid">
    graph LR;
    A[interface ApplicationContext]-->B[interface BeanFactory];
    </div>
  
  + BeanFactory
    + Bean을 등록, 생성, 조회, 반환 관리.
    + 일반적으로 BeanFactory보다는 이를 확장한 ApplicationContext를 사용.
    + getBean() method가 정의되어 있음. 
  + ApplicationContext
    + Bean을 등록, 생성, 조회, 반환 관리기능은 BeanFactory와 같음.
    + Spring의 각종 부가 서비스를 추가로 제공
    + Spring이 제공하는 ApplicationContext 구현클래스는 여러가지 종류가 있음.

## BeanFactory & ApplicationContext

<div class="language-mermaid">
graph LR;
XmlWebApplicationContext-->A[interface WebApplicationContext];
A-->B[interface ApplicationContext];
GenericXmlApplicationContext-->B;
StaticApplicationContext-->B;
B-->C[interface ApplicationEventPublisher];
B-->D[interface ListableBeanFactory];
B-->E[interface MessageSource];
B-->F[interface ResourceLoader];
C-->G[interface BeanFactory];
D-->G;
E-->G;
F-->G;
</div>

## IoC 개념
  + 객체 제어 방식
    + 기존 : 필요한 위치에서 개발자가 필요한 객체 생성 로직 구현
    + IoC : 객체 생성을 Container에게 위임하여 처리
  + IoC 사용에 따른 장점
    + 객체간의 결합도를 떨어뜨릴 수 있음 (loose coupling)
  + 객체간 결합도가 높으면?
    + 해당 클래스가 유지보수 될 때 그 클래스와 결합된 다른 클래스도 같이 유지보수 되어야 할 가능성이 높음
  + 객체간 강한 결합
    + 클래스 호출 방식
    + 클래스내에 선언과 구현이 모두 되어 있기 때문에 다양한 형태로 변화가 불가능.
    
    <div class="language-mermaid">
    graph LR;
    Class--생성, 사용, 호출-->A[Class];
    </div>
    
  + 객체간의 강한 결합을 다형성을 통해 결합도를 낮춤 
    + 인터페이스 호출 방식
    + 구현클래스 교체가 용이하며 다양한 형태로 변화 가능
    + 하지만 인터페이스 교체 시 호출클래스도 수정해야함

    <div class="language-mermaid">
    graph LR;
    Class--사용-->interface;
    Class--생성, 호출-->A[Class];
    A--구현-->interface;
    </div>

  + 객체간의 강한 결합을 Factory를 통해 결합도를 낮춤
    + 팩토리 호출 방식
    + 팩토리방식은 팩토리가 구현클래스를 생성하므로 클래스는 팩토리를 호출
    + 인터페이스 변경 시 팩토리만 수정하면 됨. 호출 클래스에는 영향을 미치지 않음
    + 하지만 클래스에 팩토리를 호출하는 소스가 들어가야함. 그것 자체가 팩토리에 의존함을 의미한다.
      
    <div class="language-mermaid">
    graph LR;
    Class--사용-->interface;
    Class--호출-->Factory;
    Factory--생성-->A[Class];
    A--구현-->interface;
    </div>

    + 각 Service를 생성하여 반환하는 Factory 사용,
    + Service를 이용하는 쪽에서는 Interface만 알고 있으면 어떤 구현체가 어떻게 생성되는지에 대해서는 알 필요 없음.
    + 이 Factory 패턴이 적용된 것이 Container의 기능이며 이 Container의 기능을 제공해 주고자 하는 것이 IoC모둘.
  + 객체간의 강한 결합을 Assembler를 통해 결함도를 낮춤.
    + IoC 호출 방식.
    + 팩토리 패턴의 장점을 더하여 어떠한 것 에도 의존하지 않은 형태가 됨.
    + 실행시점(Runtime)에 클래스 간의 관계가 형성이 됨.

    <div class="language-mermaid">
    graph LR;
    Class--사용-->interface;
    Class--의존성 주입-->Assembler;
    Assembler--생성-->A[Class];
    A--구현-->interface;
    </div>

    + 각 Service의 LifeCycle을 관리하는 Assembler를 사용
    + Spring Container가 외부 조립기(Assembler)역할을 함. 

## Spring DI 용어
+ 빈(Bean)
  + 스프링이 IoC 방식으로 관리하는 오브젝트를 말한다.
  + 스프링이 직접 그 생성과 제어를 담장하는 오브젝트만을 Bean이라고 부른다.
+ 빈 팩토리(Bean Factory)
  + 스프링이 IoC를 담당하는 핵심 컨테이너.
  + Bean을 등록, 생성, 반환하는 기능을 담당.
  + 일반적으로 BeanFactory를 바로 사용하지 않고 이를 확장한 ApplicationContext를 이용한다.
+ 애플리케이션 컨텍스트(Applicaion Context)
  + BeanFactroy를 확장한 IoC 컨테이너이다.
  + Bean을 등록하고 관리하는 기본적인 기능은 BeanFactory와 동일하다.
  + 스프링이 제공하는 각종 부가 서비스를 추가로 제공한다.
  + BeanFactory라고 부를 때는 주로 빈의 생성과 제어의 관점에서 이야기하는 것이고, 애플리케이션 컨텍스트라고 할 때는 애플리케이션 지원 기능을 모두 포함해서 이야기하는 것이라고 보면 된다.
+ 설정정보/설정 메타정보(configuration metadata)
  + 스프링의 설정정보란 ApplicationContext 또는 BeanFactory가 IoC를 적용하기 위해 사용하는 메타정보를 말한다. 이는 구성정보 내지는 형상정보라는 의미이다.
  + 설정정보는 IoC 컨테이너에 의해 관리되는 Bean 객체를 생성하고 구성할 때 사용됨.
+ 스프링 프레임워크
  + 스프링 프레임워크는 IoC 컨테이너, ApplicationContext를 포함해서 스프링이 제공하는 모든 기능을 통틀어 말할 때 주로 사용한다.

## Spring Container

<div class="language-mermaid">
graph LR;
A[interface WebApplicationContext]-->B[interface ApplicationContext];
B-->C[interface BeanFactory];
</div>

+ BeanFactory
  + 빈(Bean) 객체에 대한 생성과 제공을 담당.
  + 단일 유형의 객체를 생성하는 것이 아니라, 여러 유형의 빈을 생성, 제공.
  + 객체간의 연관 관계를 설정, 클라이언트의 요청 시 빈을 생성.
  + 빈의 라이플 사이클을 관리.
+ ApplicationContext
  + BeanFactory가 제공하는 모든 기능 제공.
  + 엔터프라이즈에 애플리케이션을 개발하는데 필요한 여러 기능을 추가함.
  + I18N, 리소르 로딩, 이벤트 발생 및 통지.
  + 컨테이 생성시 모든 빈 정보를 메모리에 로딩함.
+ WebApplicationContext
  + 웹 환경에서 사용할 때 필요한 기능이 추가된 애플리케이션 컨텍스트.
  + 가장 많이 사용하며, 특히 XmlWebApplicationContext를 가장 많이 사용.
