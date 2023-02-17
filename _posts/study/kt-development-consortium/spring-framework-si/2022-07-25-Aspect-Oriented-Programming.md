---
layout: post
bigtitle: 'Spring 전자정부 프레임워크 기반 SI 실무'
subtitle: 관점 지향 프로그래밍(AOP, Aspect Oriented Programming)
date: '2022-07-25 00:00:00 +0900'
categories:
    - spring-framework-si
tags: spring
comments: true
---

# 관점 지향 프로그래밍(AOP, Aspect Oriented Programming)

# 관점 지향 프로그래밍(AOP, Aspect Oriented Programming)
* toc
{:toc}

## AOP개요와 용어
+ 핵심 관심 사항과 공통(부가) 관심 사항
  + 핵심 관심 사항(core concern)과 공통 관심 사항(cross-cutting concern)
  + 기존 OOP에서는 공통관심사항을 여러 모듈에서 적용하는데 있어 중복된 코드를 양상 하는 한계가 존재함.
  + 이를 해결하기 위해 AOP가 등장
  + Aspect Oriented Programming은 문제를 해결하기 위한 핵심 관심 사항과 전체에 적용되는 공통 관심 사항을 기준으로 프로그래밍함으로써 공통 모듈을 손쉽게 적용할 수 있게 함.
+ AOP(Aspect Oriented Programming) 개요.
  + AOP는 application에서 관심사 분리(기능의 분리) 즉, 핵심적인 기능에서 부가적인 기능을 분리한다.
  + 분리한 부가기능을 어스펙트(Aspect)라는 독특한 모듈형태로 만들어서 설계하고 개발하는 방법.
  + OOP를 적용하여도 핵심기능에서 부가기능을 쉽게 분리된 모듈로 작성하기 어려운 문제점을 AOP가 해결
  + AOP는 부가기능을 어스펙트(Aspect)로 정의하여, 핵심기능에서 부가기능을 분리함으로써 핵심기능을 설계하고 구현할 때 객체지향적인 가치를 지킬 수 있도록 도와주는 개념
+ AOP 적용 예
  + 간단한 메소드의 성능 검사
    + 개발 도중 특히 DB에 다향의 데이터를 넣고 빼는 등의 배치 작업에 대하여 시간을 측정해 보고 쿼리를 개선하는 작업은 매우 의미가 있다. 이 경우 매번 해당 메소드의 처음과 끝에 System.currentTimeMillis();를 사용하거나,
    스프링이 제공하는 StopWatch코드를 사용하기는 매우 번거롭다.
    + 이런 경우 해당 작업을 하는 코드를 밖에서 설정하고 해당 부분을 사용하는 것이 편리하다.
  + 트랜젝션 처리
    + 트랜젝션의 경우 비즈니스 로직의 전후에 설정된다.
    + 하지만 매번 사용하는 트랙젝션의 코드는 번거롭고, 소스를 더욱 복잡하게 보여준다.
  + 예외반환
    + 스프링에는 DataAccessException이라는 매우 잘 정의되어 있는 예외 계층 구조가 있다. 
    예전 하이버네이트 예외들은 몇 개 없었고 그나마도 UncatchedException이 아니었다.
    이렇게 구조가 별로 안 좋은 예외들이 발생했을 때, 그걸 잡아서 잘 정의되어있는 예외 계층 구조로 변환해서 다시 던지는 Aspect는 제 3 프레임워크를 사용할 때, 본인의 프레임워크나 애플리케이션에서 별도의 예외 계층 구조로 변환 하고 싶을 때 유용하다.
  + 아키텍처 검증
  + 기타
    + 하이버네이트와 JDBC를 같이 사용할 경우, DB 동기화 문제 해결
    + 멀티스레드 Safety 관련하여 작업해야 하는 경우, 메소들에 일괄적으로 락을 설정하는 Aspect
    + 데드락등으로 인한 PessimisticLockingFailureException등의 예외를 만났을 때 재 시도하는 Aspect
    + 로깅, 인증, 권한등..
+ Spring AOP 용어
  + Target
    + 핵심 기능을 담고 있는 모듈로, 타겟은 부가기능을 부여할 대상이 됨.
  + Advice
    + 어느 시점(method 수행 전/후, 예외발생 후 등)에 어떤 공통 관심 기능(Aspect)을 적용할 지 정의 한 것. 타겟에 제공할 부가기능을 담고 있는 모듈.
  + JoinPoint
    + Aspect가 적용 될 수 있는 지점(method, field)
    + 즉 타겟 객체가 구현한 인터페이스의 모든 method는 JoinPoint가 됨.
  + Pointcut
    + 공통 관심 사항이 적용될 JoinPoint.
    + Advice를 적용할 타겟의 method를 설별하는 정규표현식.
    + Pointcut 표현식은 execution으로 시작하고, method의 Signature를 비교하는 방법을 주로 이용.
  + Aspect
    + 여러 객체에서 공통으로 적용되는 공통 관심 사항(transaction, logging, security,..)
    + AOP의 기본 모듈
    + Aspect = Advice + Pointcut
    + Aspect는 Singleton 형태의 객체로 존재.
  + Advisor
    + Advisor = Advice + Pointcut
    + Advisor는 Spring AOP에서만 사용되는 특별한 용어
  + Weaving
    + 어떤 Advice를 어떤 Pointcut(핵심사항)에 적용시킬 것인지에 대한 설정(Advisor)
    + 즉 Pointcut에 의해서 결정된 타겟의 Joinpoint에 부가기능(Advice)을 삽입하는 과정을 뜻함.
    + Weaving은 AOP의 핵심기능(Target)의 코드에 영향을 주지 않으면서 필요한 부가기능(Advice)을 추가 할 수 있도록 해주는 핵심적인 처리과정

## Spring AOP 특징
+ Spring은 프록시(Proxy) 기반 AOP를 지원
  + Spring은 Target 객체에 대한 Proxy를 만들어 제공.
  + Target을 감싸는 Proxy는 실시간(Runtime)에 생성.
  + Proxy는 Advice를 Target 객체에 적용하면서 생성되는 객체.
+ 프록시(Proxy)가 호출을 가로챈다(Intercept)
  + Proxy는 Target 객체에 대한 호출을 가로챈 다음 Advice의 부가기능 로직을 수행하고 난 후에 Target의 핵심 기능 로직을 호출한다.(전처리 Advice)
  + 또는 Target의 핵심 기능 로직 method를 호출한 후에 부가기능(Advice)을 수행하는 경우도 있다.(후처리 Advice)
+ Spring AOP는 method JoinPoint만 지원
  + Spring은 동적 Proxy를 기반으로 AOP를 구현하므로 method JoinPoint만 지원한다
  + 즉, 핵심기능(Target)의 method가 호출되는 런타임 시점에만 부가기능(Advice)를 적용할 수 있다.
  + 반면 AspectJ 같은 고급 AOP framework를 사용하면 객체의 생성, 필드값의 조회와 조작, static method 호출 및 초기화 등의 다양한 작업에 부가기능을 적용할 수 있다.

## Spring AOP 구현
+ AOP 구현방법
  + POJO Class를 이용한 AOP 구현
  + Spring AOP를 이용한 AOP 구현
  + 어노테이션(Annotation)을 이용한 AOP 구현
+ POJO 기반 AOP 구현
  + XML Schema 확장기법을 통해 설정파일을 작성
    + XML Schema를 이용한 AOP 설정
      + aop namespace와 XML shema 추가 
        + ![예제](/assets/img/springFramework/aop.jpg)
      + aop namespace를 이용한 설정
        + ![예제](/assets/img/springFramework/aop2.jpg)
      + AOP 설정 태그
      
        | Tag |              설명               |
        | :--: | :----------------------------------: |
        | < aop:config > | aop 설정의 root 태그(weaving들의 묶음) |
        | < aop:aspect > | Aspect 설정(하나의 weaving에 대한 설정) |
        | < aop:pointcut > | Pointcut 설정|
      + Advice 설정 태그
      
        | Tag |              설명               |
        | :--: | :----------------------------------: |
        | < aop:before > | method 실행 전 실행 될 Advice |
        | < aop:after-returning > | method가 정상 실행 후 실행 될 Advice |
        | < aop:after-throwing > | method에서 예외 발생시 실행 될 Advice (catch block) |
        | < aop:after > | method가 정상 또는 예외 발생에 상관없이 실행 될 Advice (finally block) |
        | < aop:around > | 모든 시점(실행 전, 후)에서 적용시킬 수 있는 Advice |
      + < aop:aspect >
        + 한 개의 Aspect(공통 관심 기능)을 설정
        + ref 속성을 통해 공통기능을 가지고 있는 bean 연결
        + id는 이 태그 식별자 설정
        + 자식 태그로 < aop:pointcut > advice관련 태그가 올 수 있다, 
        + ![예제](/assets/img/springFramework/aop3.jpg)
      + < aop:pointcut >
        + Pointcut(공통 기능이 적용될 곳)을 지정하는 태그
        + < aop:config >나 < aop:aspect >의 자식 태그
          + < aop:config > 전역적으로 사용
          + < aop:aspect > 내부에서 사용
        + AspectJ 표현식을 통해 pointcut 지정
        + 속성
          + id : 식별자로 advice 태그에서 사용됨
          + expression : pointcut 지정 표현식
            + 예제 : execution( * com.spring.aop.service.impl.MemberServiceImpl.getMember(..) )
          + ![예제](/assets/img/springFramework/aop4.jpg)
       AspectJ 표현식
        + AspectJ에서 지원하는 패턴 표현식
        + Spring은 method 호출 관련 명시자만 지원
        + 명시자 ( 제한자패턴 ? 리턴타입패턴 ? 이름패턴 (파라미터패턴) )
          + ? : 생략가능
        + 명시자
          + execution : 실행시킬 method 패턴을 직접 입력하는 경우.
          + within : method가 아닌 특정 타입에 속하는 method들을 설정할 경우.
          + bean : 2.5버전에서 추가됨. 설정파일에 지정된 빈의 이름(name 속성)을 이용해 pointcut 설정 
        + 표현 : execution( public * a.b..*Service.get*(..) )
          + 명시자 ( 제한자패턴 ? 리턴타입패턴 ? 이름패턴 (파라미터패턴) )
        + 제한자 패턴에는 public, protected 또는 생략
          + '*' : 1개의 모든 값을 표현
            + argument에서 쓰인 경우 : 1개의 argument
            + package에서 쓰인 경우 : 1개의 하위 package
          + .. : 0개 이상의 모든 값을 표현
            + argument에서 쓰인 경우 : 0개 이상의 argument
            + package에서 쓰인 경우 : 1개 이상의 하위 package
          + 위 예 설명
            + 적용 하려는 method들의 패턴은 public 제한자를 가지며 리턴 타입에는 모든 타입이 올 수 있다. 이름은 a.b로 시작하는 package와 그 하위 패키지에 있는 모든 클래스 중 Service로 끝나는 class중에서 get으로 시작하는 method이며
            argument는 0개 이상 오며 반환 타입은 상관 없다.
        + Example
        
        | Pointcut                                                               | 선택된 Joinpoints                                       |
        |------------------------------------------------------|--------------------------------| 
        | execution(public * *(..))                                              | public 메소드 실행                                        | 
        | execution(* set*(..))                                                  | 이름이 set으로 시작하는 모든 메소드명 실행                            |
        | execution(* com.test.serviceAccountService.*(..))                      | AccountSerice 인터페이스의 모든 메소드 실행                       |
        | execution(* com.test.service.*.*(..))                                  | service 패키지의 모든 메소드 실행                               |
        | execution(* com.test.service..*.*(..))                                 | service 패키지와 하위 패키지의 모든 메소드 실행                       |
        | within(com.test.service.*)                                             | service 패키지 내의 모든 결합점                                |
        | within(com.test.service..*)                                            | service 패키지 및 하위 패키지의 모든 결합점                         |
        | this(com.test.service.AccountService)                                  | AccountService 인터페이스를 구현하는 프록시 개체의 모든 결합점            |
        | target(com.test.service.AccountService)                                | AccountService 인터페이스를 구현하는 대상 객체의 모든 결합점             |
        | args(java.io.Serializable)                                             | 하나의 파라미터를 갖고 전달된 인자가 Serializable인 모든 결합점            |
        | @target(org.springframework.transaction.annotation.Transactional)      | 대상 객체가 @Transactional 어노테이션을 갖는 모든 결합점               |
        | @within(org.springframework.transaction.annotation.Transactional)      | 대상 객체가 선언 타입이 @Transactional 어노테이션을 갖는 모든 결합점        | 
        | @annotation(org.springframework.transaction.annotation.Transactional)  | 실행 메소드가 @Transactional 어노테이션을 갖는 모든 결합점              |
        | @args(com.test.security.Classified)                                    | 단일 파라미터를 받고 전달된 인자 타입이 @Classified 어노테이션을 갖는 모든 결합점  | 
        | bean(accountRepository)                                                | "accountRepository"빈                                 |
        | !bean(accountRepository)                                               | "accountRepository"빈 제외한 모든 빈                        |
        | bean(*)                                                                | 모든 빈                                                 |
        | bean(account*)                                                         | 이름이 'account'로 시작되는 모든 빈                             |
        | bean(*Repository)                                                      | 이름이 'Repository'로 끝나는 모든 빈                           |
        | bean(account/*)                                                        | 이름이 'account/'로 시작되는 모든 빈                            |
  + POJO 기반 Advice Class 작성.
    + Advice 작성
      + 설정 파일의 advice 관련 태그에 맞게 작성한다.
      + <bean>으로 등록 하며 < aop:aspect >의 ref 속성으로 참조한다.
      + 공통 기능 메소도 : advice 관련 태그들의 method 속성의 값이 method 이름이 된다.
    + Advice 정의 관련 태그
      + 속성
        + pointcut : 직접 pointcut을 설정. 호출 할 method의 패턴 지정.
        + pointcut-ref : < aop:pointcut > 태그의 id명을 넣어 pointcut 지정
        + method : Aspect bean에서 호출할 method명 지정
        + ![예제](/assets/img/springFramework/aop5.jpg)
    + Advice Class
      + POJO 기반의 Class로 작성
        + class명이나 method명에 대한 제한은 없다.
        + method 구문은 호출되는 시점에 따라 달라 질 수 있다.
        + method의 이름은 advice 태그( < aop:before/ > )에서 method 속성의 값이 method명이 된다.
    + Advice 종류
      + before Advice 
        + 대상 객체의 메소드가 실행되기 전에 실행됨.
        + return type : 리턴 값을 갖더라도 실제 Advice의 적용과정에서 사용되지 않기 때문에 void를 쓴다.
        + argument : 없거나 대상객체 및 호출되는 메소드에 대한 정보 또는 파라미터에 대한 정보가 필요하다면 JoinPoint 객체를 전달.
        + ![예제](/assets/img/springFramework/aop6.jpg)
        + ![예제](/assets/img/springFramework/aop7.jpg)
      + before Advice 실행순서
        + 메소드에서 exception을 발생 시킬 경우 대상 객체의 메소드가 호출 되지 않는다.
        1. 빈 객체를 사용하는 코드에서 스프링이 생성한 AOP 프록시의 메소드를 호출
        2. AOP 프록시는 < aop:before >에서 지정한 메소드를 호출
        3. AOP 프록시는 Aspect 기능 실행 후 실제 빈 객체의 메소드를 호출
      
      <div class="language-mermaid">
      graph LR;
      client--1 : operation-->A[aop proxy];
      A--2 : before method-->B[before aspect];
      A--3 : operation-->C[target bean];
      </div>
  
      + After Throwing Advice
        + 대상 객체의 method 실행 중 예외가 발생한 경우 실행됨
        + return type : void
        + argument : 
          + 없거나 JoinPoint 객체를 받는다. JoinPoint는 항상 첫 argument로 사용.
          + 대상 method에서 전달되는 예외객체를 argument로 받을 수 있다.
          + ![예제](/assets/img/springFramework/aop8.jpg)
          + ![예제](/assets/img/springFramework/aop9.jpg)
          + ![예제](/assets/img/springFramework/aop10.jpg)
        + after Throwing Advice 실행순서.
          1. 빈 객체를 사용하는 코드에서 스프링이 생성한 AOP 프로시의 메소드를 호출
          2. AOP 프록시는 실제 빈 객체의 메소드를 호출(exception 발생)
          3. AOP 프록시는 < aop:after-throwing >에서 지정한 메소드를 호출

      <div class="language-mermaid">
      graph LR;
      client--1 : operation-->A[aop proxy];
      A--2 : operation-->C[target bean];
      A--3 : after method-->B[after aspect];
      </div>

      + After Advice
        + 대상 객체의 method가 정상적으로 실행 되었는지 아니면 exception을 발생 시켯는 지의 여부와 상관 없이 메소드 실행 종료 후 공통 기는 적용
        + return type : void
        + argument
          + 없거나 JoinPoint 객체를 받는다. JoinPoint는 항상 첫 argument로 사용.
          + ![예제](/assets/img/springFramework/aop11.jpg)
          + ![예제](/assets/img/springFramework/aop12.jpg)
        + After Advice 실행 순서
          1. 빈 객체를 사용하는 코드에서 스프링이 생성한 AOP 프록시의 메소드를 호출
          2. AOP 프록시는 실제 빈 객체의 메소드를 호출(정상 실행, exception 발생 : java의 finally와 같음)
          3. AOP 프록시는 < aop : after >에서 지정한 메소드를 호출
          
      <div class="language-mermaid">
      graph LR;
      client--1 : operation-->A[aop proxy];
      A--2 : operation-->C[target bean];
      A--3 : after method-->B[after aspect];
      </div>
      
       + Around Advice
         + 위의 네가지 Advice를 다 구현 할 수 있는 Advice
         + return type : void
         + argument
           + org.aspectj.lang.ProceedingJoinPoint를 반드시 첫 argument로 지정
           + ![예제](/assets/img/springFramework/aop13.jpg)
           + ![예제](/assets/img/springFramework/aop14.jpg)
         + Around Advice 실행 순서
           1. 빈 객체를 사용하는 코드에서 스프링이 생성한 AOP 프로시의 메소드를 호출
           2. AOP 프록시는 < aop:around >에서 지정한 메소드를 호출
           3. AOP 프록시는 실제 빈 객체의 메소드를 호출
           4. AOP 프록시는 < aop:around >에서 지정한 메소드를 호출

      <div class="language-mermaid">
      graph LR;
      client--1 : operation-->A[aop proxy];
      A--2 : proceed method 이전 작업-->B[around aspect];
      A--3 : operation-->C[target bean];
      A--4 : proceed method 이후 작업-->B[around aspect];
      </div>
  
+ JoinPoint Object 구성요소
  + 대상 객체에 대한 정보를 가지고 있는 객체로 Spring Container로 부터 받는다.
  + org.aspectj.lang 패키지에 있다.
  + 반드시 Aspect method의 첫 argument로 와야 한다.
  + 주요 method
  
    | Method                   | 설명                                                      | 
     |--------------------------|---------------------------------------------------------|
    | Object getTarget()       | 대상 객체를 리턴                                               |
    | Object[] getArgs()       | 파라미터로 넘겨진 값들을 배열로 리턴 넘어온 값이 없으면 빈 배열이 리턴                |
    | Signature getSignature() | 호출 되는 method의 정보, Signature : 호출되는 method에 대한 정보를 가진 객체 |
    | String getName()         | Method 이름                                               |
    | String toLongString()    | Method 전체 syntax를 리턴                                    |
    | String toShortString()   | Method를 축약해서 리턴 - 기본은 Method 이름                         |
+ @Aspect Annotation을 이용한 AOP
  + @Aspect Annotation을 이용하여 Aspect Class에 직접 Advice 및 Pointcut등을 설정
  + 설정 파일에 < aop:aspectj-autoproxy/ >를 반드시 추가
  + Aspect Class를 < bean >으로 등록
  + 어노테이션(Annotation)
    + @Aspect : Aspect Class 선언
    + @Before("pointcut")
    + @AfterReturning(pointcut="",returning="")
    + @AfterThrowing(pointcut="",throwing="")
    + @After("pointcut")
    + @Around("pointcut")
  + Around를 제외한 나머지 method들은 첫 argument로 JoinPoint를 가질 수 있다.
  + Around method는 argument로 ProceedingJoinPoint를 가질 수 있다.
  + ![예제](/assets/img/springFramework/aop15.jpg)
