---
layout: post
bigtitle: '한 번에 끝내는 Spring 완.전.판 초격차 패키지 Online.'
subtitle: Part 1. Spring Framework
date: '2022-11-17 00:00:01 +0900'
categories:
    - study
    - fast-campus
    - spring-complete-edition-super-gap-package-online
comments: true
---

# Part 1. Spring Framework

# Part 1. Spring Framework
* toc
{:toc}

## Ch 01. 강의소개, 프로개발자로 성장하는 법

### 개발자의 소프트 스킬
+ 취직, 이직을 위한 짧은 팁
  + 애매하게 아는 것을 항상 경계해야 한다.
  + 자신이 했던 업무, 프로젝트, 성과를 해당 분야를 전혀 모르는 사람에게 설명할 줄 알아야 한다.
+ 원활한 협업을 위한 업무 스킬
  + 애매하게 아는 것은 물어본다.
  + 질문이 오면 최선을 다해 설명한다.
  + 끊임없이 일정을 확인하고, 다듬어야 한다.

### 개발자의 기초 체력을 키우는 방법
+ 검색을 잘하는 방법
  + 신뢰할 수 있는 사이트: baeldung, medium, github
  + Reference site: spring.io, kotlinlang.org
  + 질의 응답: stackoverflow
  + 조금 더 다양한 토론: reddit
  + google.com
    + 검색도구 사용법(site, filetype), 도구를 활용해서 기간을 확인
+ 에러 코드를 읽는 방법
  + 에러 검색 방법
    + 가장 아래 또는 가장 위 에러부터 천천히 읽어본다.
    + 바로 해결하거나 혹은 구글에 검색해본다. 

### Intellij 소개 및 스프링 프로젝트 살펴보기
+ Intellij 소개
  + 강력한 검색 성능
  + 잘 관리되는 플러그인
  + 유료
+ Spring 프로젝트 살펴보기, 동작시키기
  + src/main/java : 우리가 만들어야할 Java 코드
  + src/main/resources : java코드가 아닌 기타 프로젝트 관련 자료
  + src/test : 테스트 관련된 것들이 main과 동일한 구조로 위치
  + build.gradle : 이 프로젝트가 사용하는 프레임워크와 라이브러리가 버전정보와 함께 포함

## Ch 02. 스프링의 핵심 기술 익히기
[노션으로 이동](https://productive-pullover-f3e.notion.site/6a09636c5dd942a6bb1d8574768e2593?v=b1bc50f032174c10a3c845c2c7ba09ec)

### 자바, 그리고 스프링, 스프링 부트
+ JAVA: 객체지향적 프로그래밍 언어 
  + 우리가 배우게 될 스프링의 근간이 되는 언어
  + 스프링은 자바 뿐 아니라 코틀린, 그루비로도 사용할 수 있다.
  + 스프링 자체는 거의 대부분 자바로 만들어져 있다.
+ Spring Framework : 기업용 어플리케이션을 만드는데 사용 가능한 오픈소스 프레임워크
  + 자바를 이용해서 어플리케이션을 만들기 위해 활용하는 프레임워크
  + 자바, 서블릿, J2EE >>>>> 스프링 프레임워크
  + ![img.png](/assets/img/spring-complete-edition-super-gap-package-online/Part1-Spring-Framework.png)
  + 스프링 내에는 동일한 역할을 하는 다양한 기능이 있으며, 그 중에서 적합한 툴을 선택할 수 있어야한다.
+ Spring boot : 스프링 기반으로 자주 사용되는 설정으로 손쉽게 개발할 수 있게 해주는 상위 프레임워크
  + 스프링(각종 도구가 있는 템플릿)보다 한층 더 편리한 프레임워크
  + 웹 어플리케이션(톰캣 등) 서버 내장
  + 자동 설정, 설정 표준화
  + 원한다면 마음대로 설정할 수 있다.

### 스프링의 Core Technology
+ 스프링 프레임워크 핵심기술
  + ![img.png](/assets/img/spring-complete-edition-super-gap-package-online/Part1-Spring-Framework.png)
  + Core (DI, IoC)
    + 스프링의 근간, 내가 만든 클래스를 스프링이 직접 관리하여 어플리케이션을 동작하게 한다.
  + AOP(Aspect Oriented Programming)
    + 공통적인 코드를 프레임워크 레벨에서 지원해주는 방법
  + Validation, Data binding
    + 검증 그리고 외부에서 받은 데이터를 담아내는 방법
  + Resource
    + 스프링 내부에서 설정이 들어있는 파일들에 접근하는 동작 원리
  + SpEL
    + 짧은 표현식을 통해 필요한 데이터나 설정 값을 얻어올 수 있게 하는 특별한 형태의 표현식에 가까운 간편한 언어
  + Null-Safety
+ 스프링의 디자인 철학 
  + 모든 기능에서 다양한 가능성(다양한 모듈)을 사용 가능, 심지어 외부 모듈을 활용 가능
    + 너무 높은 자유도 어떤 점에서는 스프링을 어렵게 하는 요소 
  + 유연하게 계속 추가 개발을 하고 있는 프레임워크
  + 이전 버전과의 강력한 호환성
    + 너무 많은 레거시 때문에 코드의 복잡성이 높아지긴 하다.
  + API 디자인을 섬세하게 노력한다
    + 스프링 코드 자체가 하나의 좋은 참고 소스
  + 높은 코드 품질을 유지하려 한다.
    + 스프링 프로젝트 github은 아주 좋은 참고 소스이자 PR과 이슈 관리도 좋은 프로세스 참고용
  + 한마디로 높은 자유도를 주고 계속 발전하는 고품질의 다양성이 있는 프로젝트, 그런데 너무 자유로워서 때론 어렵다.

### DI - Dependency Injection
+ IoC(Inversion of Control), DI(Dependency Injection)
  + IoC나 DI는 레고와 같은것
    + 스프링이 바닥판처럼 깔려있고, 우리는 그 위에서 멋진 조립(어플리케이션)을 만들면 된다.
+ Bean이란?
  + 자바에서의 javaBean
    + 데이터를 저장하기 위한 구조체로 자바 빈 규약이라는 것을 따르는 구조체
    + private 프로퍼티와 getter/setter로만 데이터를 접근한다.
    + 인수(argument)가 없는 기본 생성자가 있다.

  ~~~java
  
  public class JavaBean {
      private String id;
      private Integer count;
  
      public JavaBean(){}
  
      public String getId() {
          return id;
      }
  
      public void setId(String id) {
          this.id = id;
      }
  
      public Integer getCount() {
          return count;
      }
  
      public void setCount(Integer count) {
          this.count = count;
      }
  }
  
  ~~~

  + 스프링에서의 Bean
    + 스프링 IoC 컨테이너에 의해 생성되고 관리되는 객체
    + 자바에서처럼 new Object(); 로 생성하지 않는다
    + 각각의 Bean들 끼리는 서로 편리하게 의존(사용)할 수 있다.
    + ![img.png](../../../../assets/img/spring-complete-edition-super-gap-package-online/Part1-Spring-Framework2.png)
  + 스프링 컨테이너 개요
    + ApplicationContext 인터페이스를 통해 제공되는 스프링 컨테이너는 Bean 객체의 생성 및 Bean들의 조립(상호 의존성 관리)을 담당한다.
  + Bean의 등록
    + 과거에는 xml로 설정을 따로 관리하여 등록(불편)
    + 현재는 annotation 기반으로 Bean 등록
      + @Bean, @Controller, @Service
  + Bean 등록 시 정보
    + Class 경로
    + Bean 이름
      + 기본적으로는 원 Class 이름에서 첫 문자만 소문자로 변경 
      + 원하는 경우 변경 가능
    + Scope: Bean을 생성하는 규칙
      + singleton: 컨테이너에 단일로 생성
      + prototype: 작업 시마다 Bean을 새로 생성하고 싶을 경우
      + request: http 요청마다 새롭게 Bean을 생성하고 싶은 경우
  + Bean LifeCycle callback(빈 생명주기 콜백함수)
    + callback: 어떤 이벤트가 발생하는 경우 호출되는 메서드 
    + lifecycle callback
      + Bean을 생성하고 초기화하고 파괴하는 등 특정 시점에 호출되도록 정의된 함수
    + 주로 많이 사용되는 콜백
      + @PostConstruct: 빈 생성 시점에 필요한 작업을 수행
      + @PreDestory: 빈 파괴(주로 어플리케이션 종료) 시점에 필요한 작업을 수행

### AOP
+ 관점 지향 프로그래밍 - Aspect Oriented Programming
  + 특정한 함수 호출 전이나 후에 공통적인 처리가 필요하다면 -> AOP
    + 로깅
    + 트랜젝션
    + 인증
  + OOP로 처리하기에는 다소 까다로운 부분을 AOP라는 처리 방식을 도입하여 손쉽게 공통 기능을 추가/수정/삭제 할 수 있도록 했다.
+ AOP의 기본 개념들
  + Aspect
    + 여러 클래스나 기능에 걸쳐서 있는 관심사, 그리고 그것들을 모듈화 한 것
    + AOP 중에서 가장 많이 활용되는 부분은 @Transactional (트랜젝션 관리) 기능
  + Advice
    + 조언, AOP에서 실제로 적용하는 기능(로깅, 트랜젝션, 인증 등)을 뜻한다.
  + Join point
    + 모듈화된 특정 기능이 실행될 수 있는 연결 포인트
  + Pointcut
    + Join point 중에서 해당 Aspect를 정요할 대상을 뽑을 조건식
  + Target Object
    + Advice가 적용될 대상 오브젝트
  + AOP Proxy
    + 대상 오브젝트에 Aspect를 적용하는 경우 Advice를 덧붙이기 위해 하는 작업을 AOP Porxy라고 한다.
    + 주로 CGLIB(Code Generation Library, 실행 중에 실시간으로 코드를 생성하는 라이브러리) 프록시를 사용하여 프록싱 처리를 한다.
  + Weaving
    + Advice를 비즈니스 로직 코드에 삽입하는 것을 말한다.
    + ![img.png](../../../../assets/img/spring-complete-edition-super-gap-package-online/Part1-Spring-Framework3.png)
+ AspectJ 지원
  + AspectJ는 AOP를 제대로 사용하기 위해 꼭 필요한 라이브러리
  + 기본적으로 제공되는 Spring AOP로는 다양한 기법(Pointcut 등)의 AOP를 사용할 수 없다.
  + Aspect의 생성
    
  ~~~java
    
  package org.xyz;
  import org.aspectj.lang.annotation.Aspect;
  
  @Aspect
  @Component  // Component를 붙인 것은 해당 Aspect를 스프링의 Bean으로 등록해서 사용하기 위함
  public class UsefulAspect {
  
  }
    
   ~~~
  
  + Pointcut 선언
    + 해당 Aspect의 Advice(실행할 액션)이 적용될 Join point를 찾기 위한 패턴 또는 조건 생성
    + 포인트 컷 표현식이라고 부른다.
    
  ~~~java
  
  package org.xyz;
  import org.aspectj.lang.annotation.Aspect;
  
  @Aspect
  @Component  // Component를 붙인 것은 해당 Aspect를 스프링의 Bean으로 등록해서 사용하기 위함
  public class UsefulAspect {
  
      @Pointcut("execution(* transfer(..))")
      private void anyOldTransfer() {}
  }
  
  ~~~

  + Pointcut 결합

  ~~~java
  
  package org.xyz;
  import org.aspectj.lang.annotation.Aspect;
  
  @Aspect
  @Component  // Component를 붙인 것은 해당 Aspect를 스프링의 Bean으로 등록해서 사용하기 위함
  public class UsefulAspect {
  
      @Pointcut("execution(public * *(..))")
      private void anyPublicOperation() {} //public 메서드 대상 포인트 컷
  
      @Pointcut("within(com.xyz.myapp.trading..*)")
      private void inTrading() {} // 특정 패키지 대상 포인트 컷
      
      @Pointcut("anyPublicOperation() && inTrading()")
      private void tradingOperation() {} // 위의 두 조건을 and(&&) 조건으로 결합한 포인트 컷
  }
  
  ~~~
  
+ Advice 정의
  + 포인트컷들을 활용하여 포인트컷의 전/후/주변에서 실행될 액션을 정의한다.
  + Before Advice
    + dataAccessOperation()이라는 미리 정의된 포인트 컷의 바로 전에 doAccessCheck가 실행

  ~~~java
  
  import org.aspectj.lang.annotation.Aspect;
  import org.aspectj.lang.annotation.Before;
  
  @Aspect
  public class BeforeExample {
  
      @Before("com.xyz.myapp.CommonPointcuts.dataAccessOperation()")
      public void doAccessCheck() {
          // ...
      }
  }
  
  ~~~

  + After Returning Advice
    + dataAccessOperation()라는 미리 정의된 포인트컷에서 return이 발생된 후 실행

  ~~~java
  
  import org.aspectj.lang.annotation.Aspect;
  import org.aspectj.lang.annotation.AfterReturning;
  
  @Aspect
  public class AfterReturningExample {
  
      @AfterReturning("com.xyz.myapp.CommonPointcuts.dataAccessOperation()")
      public void doAccessCheck() {
          // ...
      }
  }
  
  ~~~
  
  + Around Advice
    + businessService()라는 포인트컷의 전/후에 필요한 동작을 추가

  ~~~java
  
  import org.aspectj.lang.annotation.Aspect;
  import org.aspectj.lang.annotation.Around;
  import org.aspectj.lang.ProceedingJoinPoint;
  
  @Aspect
  public class AroundExample {
  
      @Around("com.xyz.myapp.CommonPointcuts.businessService()")
      public Object doBasicProfiling(ProceedingJoinPoint pjp) throws Throwable {
          // start stopwatch
          Object retVal = pjp.proceed();
          // stop stopwatch
          return retVal;
      }
  }
  
  ~~~
    