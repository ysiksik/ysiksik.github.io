---
layout: post
bigtitle: '한 번에 끝내는 Spring 완.전.판 초격차 패키지 Online.'
subtitle: Part 2. Spring Boot
date: '2022-12-08 00:00:00 +0900'
categories:
    - study
    - fast-campus
    - spring-complete-edition-super-gap-package-online
comments: true
---

# Part 2. Spring Boot

# Part 2. Spring Boot
* toc
{:toc}


## Start with Boot!

### 프로젝트 셋업
+ git 변경
  + master -> main
+ gitignore.io 에서 gitignore 설정


### OOP로 만든 정렬 구현체 3종
+ 소프트웨어를 OOP로 설계하는 것
  + 소프트웨어를 기능, 논리보다는 데이터, 객체로 설계하는 것
+ 객체 지향 설계 (SOLID)
  + SRP: 한 클래스는 하나의 책임만 가져야 한다.
  + OCP: 소프트웨어 요소는 확장에는 열려 있으나 변경에는 닫혀 있어야 한다.
  + LSP: 프로그램의 객체는 프로그램의 정확성을 깨뜨리지 않으면서 하위 타입의 인스턴스로 바꿀 수 있어야 한다.
  + ISP: 특정 클라이언트를 위한 인터페이스 여러 개가 범용 인터페이스 하나보다 낫다.
  + DIP: 프로그래머는 추상화에 의존해야지, 구체화에 의존하면 안된다.

### Spring의 적용
+ Spring 핵심 기능
  + The IoC Container
  + Resources
  + Validation, Data Binding, and Type Conversion
  + Spring Expression Language (SpEL)
  + Aspect Oriented Programming with Spring
  + Null-safety
  + Logging
+ IoC (Inversion of Control)
  + 전통적인 제어 흐름에 비추어 볼 때, 제어 흐름을 반대로 뒤집은 것 - Wikipedia
  + 라이브러리를 사용할 때는 내 코드가 라이브러리 코드를 호출하지만 프레임워크를 사용할 때는 프레임워크가 내 코드를 호출한다. 
+ Resource
  + low-level resource 에 접근할 수 있는 보다 폭넓은 기능을 제공
  + UrlResource
  + ClassPathResource
  + FileSystemResource
  + PathResource
  + ServletContextResource
  + InputStreamResource
  + ByteArrayResource
+ Validation, Data Binding, Type Conversion
  + 데이터의 검증
  + 데이터를 인식하고 자료형에 할당
  + 데이터 자료형의 변환
+ SpEL
  + 스플링 애플리케이션의 런타임에 다양한 데이터에 접근하기 위한 언어
  + JSP Unified EL 과 유사하지만 스프링에 특화되어 더 다양한 기능을 제공
+ Aspect Oriented Programming with Spring
  + AOP: 관전 지향 프로그래밍 - 공통 기능을 개발자의 코드 밖에서 필요한 시점에 적용 가능
  + AOP 를 적극적으로 사용하고 지원하는 프레임워크
  + Proxy, Aspect, Join Point, Advice, Pointcut, Weaving
  + CGLib, AspectJ
  + AOP 를 사용하지 않아도, 심지어 몰라도 여전히 프레임워크를 사용 가능 
+ Null-safety
  + @Nullable
  + @NonNull
  + @NonNullApi
  + @NonNullFields
+ Logging
  + 별도의 외부 설정 없이 로깅 구현체 사용 가능
  + SLF4J + Logback
  + Log4j 2
  + JUL (java.util.logging)
+ 그 밖에...
  + Testing
  + Data Access
  + Web Servlet
  + Web Reactive
  + Integration: REST endpoints, email, scheduling, cache, ...
+ 종합
  + 스프링은 엔터프라이즈 애플리케이션을 만드는데 필요한 거의 모든 요소를 지원해주는 프레임워크

### Spring Boot의 적용
+ 주요 기능
  + Stand-alone 스프링 어플리케이션
  + 임베디드 톰캣 내장 (WAR 파일 배포 필요 없다.)
  + 빌드 설정을 단순화해줄 기초 세팅과 의존성
  + 스프링 및 서드 파티 라이브러리의 자동 설정
  + 제품 레벨로 사용할 수 있는 각종 기능들 
  + XML 설정 필요 없다
+ 요점
  + 스프링이 할 일과 작성할 코드를 줄여주고 (강력한 프레임워크) 스프링 부트가 그것을 더 줄여주었다 (굿 프랙티스)
+ Spring Boot 이 어울리지 않는 경우
  + 프르그램의 세세한 설정과 설계를 내 손으로 일일이 만져야 한다면
  + 실행 중이 애플리케이션 기저에서 무슨 일이 일어나는지 모조리 알아야 한다면
  + 내가 사용하지 않는 기능은 단 하나라도 프로젝트에 남겨두지 않는 최적화를 원한다면 
  