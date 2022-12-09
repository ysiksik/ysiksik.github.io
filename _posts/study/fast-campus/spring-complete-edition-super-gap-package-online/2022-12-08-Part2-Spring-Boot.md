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
  
## 버전별 변천사

### 버전별 변천사 훑어보기: 1 vs 2
+ 주요 변경 사항을 체크하는 경로
  + [Spring Official Blog](https://spring.io/blog/category/releases)
  + [Spring Boot Github](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-2.0-Release-Notes)
  + [SpringOne Platform Presentation, 2017](https://youtu.be/TasMZsZxLCA)
  + [Baeldung](https://www.baeldung.com/new-spring-boot-2)
  + Quora
  + StackOverflow
  + 각종 기술 블로그들
+ 주요 변경 사항
  + Java 8 (+Java 9) + Spring Framework 5
  + 써드파티 라이브러리 업그레이드 
  + Reactive Spring 
  + Functional APIs 
  + Kotlin 지원 
  + Configuration properties 
  + Gradle 플러그인 
  + Actuator 변경점 
  + Spring Security
+ 기타 변경 사항
  + Spring Boot Properties 변경사항 
  + Jackson 시간 표시 기본값 
  + MySQL auto_increment 
  + HikariCP 
  + JOOQ 
  + GIF banner

#### 주요 변경 사항
+ Java 8 (+ Java 9) + Spring Framework 5
  + Java 8 이 이제 최소 사양
  + Java 9 공식 최초 지원 - 부트 1.x 는 미지원
  + Spring Framework 5
+ 써드파티 라이브러리 업그레이드
  + Tomcat 8.5
  + Flyway 5
  + Hibernate 5.2
  + Thymeleaf 3
  + Elasticsearch 5.6
  + Gradle 4
  + Jetty 9.4
  + Mockito 2.x
+ Reactive Spring 
  + 무엇을 위해 존재하는가?
    + 한정된 자원 (thread pool) 으로
    + 비동기(asynchronous) 넌블록킹(non-blocking) 알고리즘을 이용해
    + 다수의 요청에도 빠르고 예측 가능한 응답 성능(반응)을 실현
  + 리엑티브 지원 모듈
    + Spring WebFlux 
    + Reactive Spring Data
    + Reactive Spring Security
    + Embedded Netty Server
+ Functional APIs
  + WebFlux.fn
  + WebMvc.fn (Spring Framework 5.2)
  + 기존의 스프링 웹애플리케이션을 함수형 스타일로 작성 가능
  + 스프링 기술과 애노테이션에서 분리된 코드
  + 자바 코드 레벨에서 분석 가능
  + 독립적인 유닛 테스트 가능
  + 스프링 컨테이너에서 독립
+ Kotlin 지원
  + 코틀린으로 본격적인 스프링 부트 프로그래밍을 시작
+ Configuration properties
  + 프로퍼티를 쓸 때: Relaxed binding 은 여전히 지원
  + 프로퍼티를 읽을 때: 양식이 통일
    + 엘리먼트 구분: "."
    + 영어 소문자 + 숫자
    + 단어 구분자로 "-" 사용 가능
  + 환경변수(environment variables)에서 컬렉션 데이터의 인덱스 표현 가능
    + MY_VAR_1= a -> my.var[1] = "a"
    + MY_VAR_1_2= b -> my.var[1][2] = "b"
  + 더 편리한 자료형 인식 (ex: java.time.Duration -> "1s", "2m", "5d")
  + Origin 지원: 스프링 부트가 읽은 프로퍼티의 위치를 기억하고, 에러가 나면 알려준다
    + ex: "origin": "class path resource [application.properties]:1:27"
+ Gradle 플러그인
  + 최소 버전: 4.x
  + bootRepackage -> bootJar & bootWar
  + dependency management 기능을 사용하려면, 플러그인을 명시해야 한다
+ Actuator 변경점
  + 보안성 강화: 1.5 에서 기본으로 보여주던 endpoint 를 더이상 보여주지 않음
  + @Endpoints: 커스텀 endpoint 를 환경(MVC, JMX, Jersey..)에 상관 없이 편하게 구현
  + 이름 변화
    + /autoconfig -> /conditions
    + /trace -> /httptrace
+ Spring Security
  + OAuth 2.0 통합
  + 커스텀 설정이 더 쉬워졌다
  + WebSecurityConfigurerAdapter 순서 문제 해결
    + 기본 설정이 하나로 통합됬다
    + WebSecurityConfigurerAdapter 를 추가하면 기본 설정이 꺼진다.
    + 보안이 중요한 기능들은 명시적으로 작성하게끔 변경 (ex: actuator)

#### 기타 변경 사항
+ Spring Boot Properties 변경사항
  + 이름과 구성에 변화
  + spring-boot-properties-migrator
  + JdbcTemplate 제어 옵션 추가: spring.jdbc.template.*
  + Redis 제어 옵션 추가: spring.cache.redis.*
+ MySQL auto_increment
  + Spring Data JPA, @GeneratedValue strategy 기본 동작이 바뀜
  + 기본값: GenerationType.AUTO
    + Spring Boot 1.5: MySQL AUTO == IDENTITY
    + Spring Boot 2.0: MySQL AUTO == TABLE
+ HikariCP
  + Database 커넥션 풀 관리 프레임워크
  + Tomcat Pool -> HikariCP
+ JOOQ
  + Java Object Oriented Querying
  + Datasource 에 맞게 JOOQ dialect 자동 설정
  + @JooqTest 지원
  + 국내에서는 QueryDSL 에 밀리는 분위기
+ GIF banner
  + gif 지원

### 버전별 변천사 훑어보기: 2.1 ~ 2.3

#### Spring Boot 2.1
> + 성능 향상
> + Spring Data JPA: bootstrap-mode
> + JDK 11 + Spring Framework 5.1
> + 주요 버전 업그레이드
> + Deprecations from 2.0
> + New Spring Actuator Endpoints
> + Logging Refinements
> + JUnit
> + Bean Overriding

+ 성능 향상
  + [https://spring.io/blog/2018/12/12/how-fast-is-spring](https://spring.io/blog/2018/12/12/how-fast-is-spring)
  + GC 속도 향상 - 더 빠른 시작 
  + 더 적은 heap 사용
+ Spring Data JPA: bootstrap-mode
  + Spring Data Lovelace
  + lazy initialization
  + spring.data.jpa.repositories.bootstrap-mode=deferred(or lazy)
+ JDK 11 + Spring Framework 5.1
  + Java 11
  + Spring Framework 5.1
+ 주요 버전 업그레이드
  + Tomcat 9
  + Undertow 2
  + Hibernate 5.3
  + JUnit 5.2
  + Micrometer 1.1
+ Deprecations from 2.0
  + setConnectTimeout(int), setReadTimeout(int)
  + data size 를 int 입력 인자로 받던 메소드들은 Datasize 로 변경 및 deprecated
  + management.endpoints.jmx.unique-names -> spring.jmx.unique-names
  + @AutoConfigureMockMvc 의 secure 속성 -> @WithMockUser
  + RestTemplateBuilder.basicAuthorization -> basicAuthentication
  + AbstractFilterRegistrationBean, FilterRegistrationBean
    + as-is: REQUEST_WRAPPER_FILTER_MAX_ORDER
    + to-be: OrderedFilter.REQUEST_WRAPPER_FILTER_MAX_ORDER
+ New Spring Actuator Endpoints
  + /actuator/caches 추가
  + /actuator/integrationgraph 추가
  + /actuator/health 기능 업데이트
    + HealthIndicator 를 런타임에 추가, 삭제 가능
    + 특정 인디케이터만 관찰 가능 (ex: /actuator/health/db)
+ Logging Refinements 
  + logging.level.web=debug
  + spring.http.log-request-details=true
+ JUnit
  + JUnit 5 사용 가능
  + spring-boot-test -> 5.3.1
  + 그러나 기본 세팅은 JUnit 4
  + JUnit 5로 바꾸려면 빌드 설정에 명시해야 함
  + @ExtendWith(SpringExtension.class) 을 모든 부트 @-Test 애노테이션에 내재화
+ Bean Overriding
  + 사용자가 모르게 빈이 오버라이드 되지 않도록, 기본 동작 false
    + 오버라이드가 감지되면: BeanDefinitionOverrideException
  + spring.main.allow-bean-definition-overriding=true

#### Spring Boot 2.2
> + 성능 향상
> + Java 13 + Spring Framework 5.2
> + 주요 버전 업그레이드
> + Deprecations from 2.1
> + Jakarta EE
> + Junit 5
> + Gradle 4.10

+ 성능 향상
  + 시작 시간과 메모리 사용이 더욱 감소
  + 새 속성 추가: proxyBeanMethods=false
    + @Configuration
    + @SpringBootApplication
    + @SpringBootConfiguration
  + spring-boot:run, bootRun -> -Xverify:none -XX:TieredStopAtLevel=1
    + JDK 13 쓸 경우: -Xverify:none 가 deprecated 되었기 때문에 빠졌다
  + spring.main.lazy-initialization
    + 부작용 1: http request 핸들링 속도가 조금 더 길어졌다
    + 부작용 2: 시작할 때 문제가 있다면 보여주던 실패를 더이상 보여주지 않는다.
+ Java 13 + Spring Framework 5.2
  + Java 13 지원 추가
  + Spring Framework 5.2
+ 주요 버전 업그레이드
  + Spring HATEOAS 1.0 
  + Spring Kafka 2.3 
  + Spring Security 5.2
  + Hamcrest 2.1
  + Mockito 3.1
  + AssertJ 3.12
  + Elasticsearch 6.7
  + Git Commit ID Plugin 3.0
  + Hazelcast 3.12
  + Jackson 2.10
  + Jedis 3.1
  + Lettuce 5.2
+ Deprecations from 2.1 
  + 스프링 부트 2.1 에서 deprecated 된 클래스, 메소드, 프로퍼티들이 삭제됬다.
  + [https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-2.1-Release-Notes#deprecations-in-spring-boot-21](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-2.1-Release-Notes#deprecations-in-spring-boot-21)
+ Jakarta EE
  + avax. group ID -> jakarta. 로 이동
  + com.sun.mail:javax.mail -> com.sun.mail:jakarta.mail
  + org.glassfish:javax.el -> org.glassfish:jakarta.el
+ Junit 5
  + JUnit 5 기본 제공
+ Gradle 4.10
  + 버전의 최소 조건이 4.10 으로 변경

#### Spring Boot 2.3
> + 새 버전의 배포 주기 계획 발표
> + Java 14, Gradle 5.6.x ~ 6.3, developmentOnly Gradle 설정 자동 생성
> + 주요 버전 업그레이드 (R2DBC 지원)
> + 도커 지원
> + Validation Starter 를 web starter 에서 제외
> + Graceful shutdown
> + Jackson 2.11
> + Actuator 향상점
> + 기본 에러 페이지 내용 변화
> + @ActiveProfiles 에 여러 개의 프로파일 설정하기

+ 새 버전의 배포 주기 계획 발표
  + 앞으로 스프링 부트 새 버전은 6개월 주기로 배포하기로 했다.
  + 배포를 예상 가능, 업그레이드 주기를 계획할 수 있다
  + 실제로
    + 2.3: 2020. 5. 15
    + 2.4: 2020. 11. 12
    + 2.5: 2021. 5. 25
    + 2.6: 2021.11. ?? (2.6.0.SNAPSHOT 현재 이용 가능)
  + Spring Framework 는 feature-based 배포 전략을 유지 "준비되면 나가겠다"
+ Java 14, Gradle 5.6.x ~ 6.3, developmentOnly Gradle 설정 자동 생성
  + Java 14 지원, 8과 11도 지원
  + Gradle 6.3 필요 (5.6.x 은 지원하지만 deprecated 형태)
  + developmentOnly 가 스프링 부트 플러그인에 의해 자동 생성됨
    + developmentOnly 에 추가 설정을 수동으로 구성한 코드는 모두 삭제해야 함
    + 그러지 않을 경우: "cannot add a configuration with name 'developmentOnly' as a configuration with that name already exists."
+ 주요 버전 업그레이드 (R2DBC 지원)
  + Spring Data Neumann -> R2DBC 지원
  + R2DBC ConnectionFactory 자동 설정, health indicator, metrics, @DataR2dbcTest
  + Spring HATEOAS 1.1
  + Spring Integration 5.3
  + Spring Kafka 2.5
  + Spring Security 5.3
  + AssertJ 3.16, JUnit Jupiter 5.6, Mockito 3.3
  + Elasticsearch 7.6
  + Hibernate Validator 6.1
  + Jackson 2.11
  + QueryDSL 4.3
  + MongoDB 4.0
+ 도커 지원
  + Cloud Native Buildpacks
    + Maven: spring-boot:build-image
    + Gradle: bootBuildImage
    + Default Java buildpack: Paketo
  + layered jars
    + jar 내용물을 나눠서, 업데이트가 있는 이미지만 빌드하는 방식
    + 도커 이미지를 더 효율적으로 작성하는데 도움
+ Validation Starter 를 web starter 에서 제외
  + javax.validation.* 이 기본으로 포함되지 않게 됨
    + ex: @Valid, @NotNull, @Min, @Max, @Email, ...
  + 이유: 검증 기능이 모든 서비스에서 필요한 것은 아닌데, 디펜던시가 부피를 꽤 차지함
  + implementation 'org.springframework.boot:spring-boot-starter-validation'
+ Graceful shutdown
  + 4가지 임베디드 웹 서버에 이 기능을 제공
    + Jetty, Reactor Netty, Tomcat, Undertow
  + server.shutdown=graceful
  + shutdown 실행되면, 바로 죽지 않고 모든 새로운 요청을 거부, 남은 요청들이 처리되기를 기다림
  + spring.lifecycle.timeout-per-shutdown-phase: grace period 설정
    + 남은 요청이 처리되기를 기다리는 시간 (default: 30s)
+ Jackson 2.11
  + java.util.Date, java.util.Calendar 기본 포매팅에 변화
  + 의도: 정확한 ISO-8601 확장 규격을 준수
    + as-is: "2021-01-02T03:04:56.789+0000"
    + to-be: "2021-01-02T03:04:56.789+00:00"
+ Actuator 향상점
  + /actuator/configprops 가 end-to-end 정보를 추적하여 제공
  + /actuator/metrics: 이름들이 알파벳 순 보기좋게 정렬됨
  + 기타 등등
+ 기본 에러 페이지 내용 변화 
  + 에러 메시지, 바인딩 에러가 기본 에러 페이지에 노출되지 않음
  + 클라이언트에 정보 유출을 방지
  + server.error.include-message
  + server.error.include-binding-errors
+ @ActiveProfiles 에 여러 개의 프로파일 설정하기
  + @ActiveProfiles({"p1","p2"})
  + 이제 이러면 안됨: @ActiveProfiles("p1,p2")
