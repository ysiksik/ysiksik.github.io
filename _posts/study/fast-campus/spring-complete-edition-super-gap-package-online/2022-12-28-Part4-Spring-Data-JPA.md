---
layout: post
bigtitle: '한 번에 끝내는 Spring 완.전.판 초격차 패키지 Online.'
subtitle: Part 4. Spring Data JPA
date: '2022-12-28 00:00:00 +0900'
categories:
    - study
    - fast-campus
    - spring-complete-edition-super-gap-package-online
comments: true
---

# Part 4. Spring Data JPA

# Part 4. Spring Data JPA
* toc
{:toc}


## JPA 기본기

### ORM, JPA, JPQL 개요

#### ORM
Object Relational Mapping
+ 객체 지향 언어를 이용하여, 서로 호환되지 않는 타입간의 데이터를 변환하는 길술
+ 좁은 의미: DB(RDBMS) 테이블 데이터를 (자바) 객체와 매핑하는 기술
+ 효과: RDBMS를 객체 지향 DB로 가상화하는 것
+ ORM 으로 얻고자 하느 것
  + DB의 추상화: 특정 DB에 종속된 표현(ex: SQL)이나 구현이 사라지고 DB 변경에 좀 더 유연해진다.
  + 객체의 이점을 활용: 객체간 참조, type-safety
  + 관심사 분리: DB 동작에 관한 코드 작성의 반복을 최소화하고 비즈니스 로직에 집중

#### JPA
Jakarta(Java) Persistence API
+ 자바에서 ORM 기술을 사용해 RDBMS를 다루기 위한 인터페이스 표준 명세
+ API + JPQL + metadata (+ Criteria API)
+ 기본적으로 관계형 데이터베이스의 영속성(persistence)만을 규정
  + JPA 구현체 중에 다른 유형의 데이터베이스 모델을 지원하는 경우가 있지만, 원래 JPA 스펙과는 무관
+ 이름의 변화
  + Java Persistence API -> Jakarta Persistence API
  + 2017년 9월, 오라클이 Java EE를 이클리스 재단으로 이관 -> 상표권 문제로 이름을 변경
  + Spring Boot: 2.2 부터 Jakarta EE 로 의존성이 변경된다.
    + 현재: JPA 2.2.3 (패키지명은 아직 javax.persistence.*)
    + 미래: JPA 3.0 이 도입되면 패키지명이 완전히 jakarta.persistence.* 로 변경될 전망
+ Persistence (영속성)
  + 프로세스가 만든 시스템의 상태가 종료된 후에도 사라지지 않는 특성
  + 구현 방법: 시스템의 상태를 데이터 저장소에 데이터로 저장한다.
  + 사라지는 데이터 - 주기억장치(휘발성 스토리지)에 저장된 데이터
    + 프로세스 메모리 안의 데이터(변수, 상수, 객체, 함수 등)
  + 사라지지 않는 데이터 - 보조기억장치(비휘발성 스토리지)에 저장된 데이터
    + 하드디스트, SSD 에 기록된 데이터 (파일, 데이터베이스 등)
  + 영속성 프레임워크: 영속성을 관리하는 부분을 persistence layer 로 추상화하고, 이를 전담하는 프로레임워크에게 관리를 위임
  + JPA 에 persistence 란: 프로세스가 DB로부터 읽거나 DB에 저장한 정보의 특성
  
#### JPQL
Jakarta(Java) Persistence Query Languag
+ 플랫폼으로 부터 독립적인 객체 지향 쿼리 언어
+ JPA 표준의 일부로 정의된다.
+ RDBMS의 엔티티(Entity)를 다루는 쿼리를 만드는데 사용
+ SQL의 영향을 받아서 형식이 매우 유사
+ SQL 과 JPQL 은 다른 언어이다.
  + SQL: 표준 ANSI SQL 을 기준으로 만든, 특정 DB에 종속적인 언어
  + JPQL: 특정 DB에 종속적인 언어가 아니다
+ JPA 프레임워크를 사용한다면
  + 특별한 요구사항이 있지 않은 한, JPQL을 몰라도 된다.
  + JPQL을 직접 코드에서 사용하고 있다면, 반드시 필요했던 일인지 검토

#### Reference
+ [https://en.wikipedia.org/wiki/Object%E2%80%93relational_mapping](https://en.wikipedia.org/wiki/Object%E2%80%93relational_mapping)
+ [https://docs.oracle.com/javaee/7/tutorial/persistence-intro.htm](https://docs.oracle.com/javaee/7/tutorial/persistence-intro.htm)
+ [https://en.wikipedia.org/wiki/Persistence_(computer_science)](https://en.wikipedia.org/wiki/Persistence_(computer_science))
+ [https://en.wikipedia.org/wiki/Jakarta_Persistence_Query_Language](https://en.wikipedia.org/wiki/Jakarta_Persistence_Query_Language)

### 기존의 기술들- iBATIS, MyBatis, JdbcTemplate
SQL Mapper
+ RDBMS 쿼리문의 실행 결과를 자바 코드에 매핑하는 프레임워크
+ JDBC API를 사용
+ persistence framework
+ 프로그램 코드와 SQL을 분리

#### iBATIS
Apache iBATIS
+ SQL 데이터베이스와 객체 가 매핑을 지원해주는 persistence framework
+ 지원 언어: Java, NET, Ruby
+ SQL 문을 별도의 XML 문서로 작성하여 프로그래 코드와 분리한 형식
+ 2001년 Clinton Begin 이 개발
+ 2004년 iBATIS 2.0 릴리즈 - 아파치 소프트웨어 재단에 기증, 아파치에서 6년간 운영됨
+ 2010년 iBATIS 3.0 릴리즈 - MyBatis로 개발 프로젝트 이동, 아파치 애틱(Attic) 프로젝트로 분류됨
+ DAO 패턴이 발전하던 시기
  + Data Access Object 패턴: 애플리케이션 비즈니스 레이어와 영속성 레이어를 추상화된 API를 이용하여 분리
  + DB 접근 구현 클래스를 ~~~Dao 라고 네이밍하는 관례가 많았던 시기

#### MyBatis
+ iBATIS 3.0 에서 출발한 persistence framework (iBATIS 랑 비교할 필요 없이 이거 쓰면 됨)
+ 스프링, 스프링 부트와 연동을 지원
  + 스프링: org.mybatis:mybatis-spring
  + 스프링 부트: org.mybatis.spring.boot:mybatis-spring-boot-starter
+ 다양한 프레임워크와 연동을 지원
  + Freemarker, Velocity, Hazelcast, Memcached, Redis, Ignite, Guice
+ ORM VS MyBatis
  + ORM: 자바 객체를 DB 테이블과 매핑
  + MyBatis: 자바 메소드를 SQL 실행 결과와 매핑
+ MyBatis VS iBATIS 사소한 팁
  + 당연히 디테일에서 많은 변화와 차이가 있지만 특별히 알면 좋은 차이점 - 쿼리 실행 결과
  + INSERT
    + iBATIS - NULL
    + MyBatis - 1
  + UPDATE
    + iBATIS - 1
    + MyBatis - UPDATE된 행의 개수
  + DELETE
    + iBATIS - DELETE된 행의 개수
    + MyBatis - DELETE된 행의 개수

#### JdbcTemplate
JDBC API (Spring JDBC)
+ 스프링에서 제공하는 jdbc 기반 persistence framework
+ spring-boot-starter-jdbc (spring-boot-starter-data-jdbc 랑 다름 JPA와 관련된 기술)
+ JdbcTemplate: Spring JDBC 에서 제공하는 템플릿 클래스. 쿼리 실행과 결과 전달 기능을 제공

#### SQL Mapper: 사용평
나쁘진 않지만 아쉬운 영속성 프레임워크
+ 프로그램 코드에서 아직 SQL을 완전히 분리하지 못함
  + 개발자가 여전히 SQL을 알아야한다 
  + 프로그램이 (특정 DB에 종속된) SQL을 알아야한다 -> 전체 코드가 특정 DB 기술과 결합을 가진다.
  + XML 관리: SQL 을 분리하는 목적으로 만들었지만 결국 XML 을 알아야 한다
+ type-safety 를 온전히 활용하지 못한다: 쿼리 실행 결과는 대체로 Map, ResultSet 구조로 넘어온다.
  + 결국 매핑은 구현해 줘야한다.
  + Map 구조가 데이터 클래스와 비교해서 갖는 단점
    + 어떤 "필드"(맵에서는 key)가 있음을 보장하지 않는다
    + 각 데이터 타입을 보장하지 않는다
+ 결론: 객체 지향적이지 않다.

#### Reference
+ [https://en.wikipedia.org/wiki/Java_Database_Connectivity](https://en.wikipedia.org/wiki/Java_Database_Connectivity)
+ [https://en.wikipedia.org/wiki/Data_access_object](https://en.wikipedia.org/wiki/Data_access_object)
+ [https://ibatis.apache.org/](https://ibatis.apache.org/)
+ [https://blog.mybatis.org/](https://blog.mybatis.org/)
+ [https://en.wikipedia.org/wiki/Apache_iBATIS](https://en.wikipedia.org/wiki/Apache_iBATIS)
+ [https://en.wikipedia.org/wiki/MyBatis](https://en.wikipedia.org/wiki/MyBatis)
+ [https://spring.io/guides/gs/relational-data-access/](https://spring.io/guides/gs/relational-data-access/)
+ [https://docs.spring.io/spring-framework/docs/current/reference/html/data-access.html#jdbc](https://docs.spring.io/spring-framework/docs/current/reference/html/data-access.html#jdbc)

### Hibernate vs Spring Data JPA

#### Hibernate
"MORE THAN AN ORM, DISCOVER THE HIBERNATE GALAXY."
+ 자바 생태계를 대표하는 ORM framework
+ 스프링 부트에서 채택한 메인 framework
+ JPA 표준 스펙을 구현한 JPA Provider
+ 고성능, 확장성, 안정성을 표방
+ 다양한 하위 제품들로 나뉨
  + Hibernate ORM (최신: 5.5, 스프링 부트: 5.4.32)
  + Hibernate Validator
  + Hibernate Reactive
+ Hibernate Query Language
  + 하이버네이트가 사용하는 SQL 스타일 비표준 쿼리 언어
  + 객체 모델에 초첨을 맞춰 설계됨
  + JPQL 의 바탕인 됨  (JPQL 은 HQL 의 subset)
    + JPQL 은 완벽한 HQL 문장이지만, 반대로는 성립하지 않는다.
+ Criteria query
  + type-safety 를 제공하는 JPQL의 대안 표현법
+ Native SQL Query
  + 특정 DB에 종속된 SQL 도 사용 가능

#### Spring Data JPA
스프링에서 제공하는 JPA 추상화 모듈
+ JPA 구현체의 사용을 한 번 더, Repository 라는 개념으로 추상화
+ JPA 구현체의 사용을 감추고, 다양한 지원과 설정 방법을 제공
+ JPA 기본 구현체로 Hibernate 사용
+ Querydsl 지원

##### Spring Data JPA 사용하면서 알아야 할 사실
JPA, 하이버네이트를 몰라도 되어야 한다
+ EntityManager 를 직접 사용하지 않는다
+ JPQL 을 직접 사용하지 않는다
+ persist(), merge(), close() 를 직접 사용하지 않는다
+ 트랜잭션을 getTransaction(), commit(), rollback() 으로 관리하지 않는다
+ 코드가 하이버네이트를 직접 사용하고 있다면
  + 꼭 필요한 코드인지, 아니면 Spring Data JPA 로 할 수 있는 일인지 확인
  + 그 코드는 하이버네이트와 직접적인 연관 관계를 가지게 된다
  + 추상화의 이점을 포기
  
#### Reference
+ [https://hibernate.org/](https://hibernate.org/)
+ [https://en.wikipedia.org/wiki/Hibernate_(framework)](https://en.wikipedia.org/wiki/Hibernate_(framework))
+ [https://docs.spring.io/spring-data/jpa/docs/2.5.5/reference/html/#reference](https://docs.spring.io/spring-data/jpa/docs/2.5.5/reference/html/#reference)

### in memory 테스트 DB - H2

#### H2
+ "Java SQL database"
+ 스프링 부트가 지원하는, 가장 세팅하기 편한 인메모리 DB
+ 빠르다, 오픈소스, JDBC API
+ 다양한 모드 지원: embedded, server, in-memory
+ 브라우저 콘솔 지원 (h2-console)
+ 경량 jar: 약 2 MB
+ 순수 자바로 구현
+ Compatibility mode: IBM DB2, Derby, HSQLDB, MSSQL, MySQL, Oracle, PostgreSQL

#### Reference
+ [https://www.h2database.com/](https://www.h2database.com/)

## Spring Data JPA 와 테크닉

### @Repository
스프링 스테레오타입 애노테이션
+ persistence layer 를 구현하는 클래스에 사용
+ @Component 와 마찬가지로 해당 클래스를 빈으로 등록
+ DAO 패턴을 적용한 클래스에도 사용 가능
+ persistence layer 에서 발생하는 예외를 잡아서 DataAccessException 으로 처리해 준다
  + PersistenceExceptionTranslationPostProcessor
+ Spring Data JPA 를 사용한다면, "직접 사용할 일은 없다"고 봐도 무방하다

#### Spring Data JPA 와 주요 인터페이스들
Spring Data JPA 인터페이스
+ 단계별로 필요한 기능까지만 사용 가능
+ Repository: 기본 repository 인터페이스, 어떤 메소드도 제공하지 않는다
+ CrudRepository: Repository + CRUD 기능 제공
+ PagingAndSortingRepository: CrudRepository + 페이징, 정렬 기능 제공
+ JpaRepository: PagingAndSortingRepository + Spring Data JPA repository 전체 기능

#### Query method
인터페이스에 작성한 메소드 이름이 곧 쿼리 표현이 된다.
+ ex: List<Event> findByEventStatusAndEventNameOrCapacity(String eventStatus, String eventName, Integer capacity);
+ 다이나믹 쿼리를 만들 수는 없다.
+ 사용 가능한 키워드
  + distinct, and, or, is, not, between, lessThan, lessThanEqual, greaterThen, greaterThenEqual
  + null, isNotNull, like, startingWith, endingWith, containing, orderBy, in, true, false, ignoreCase
  + [https://docs.spring.io/spring-data/jpa/docs/2.5.5/reference/html/#jpa.query-methods.query-creation](https://docs.spring.io/spring-data/jpa/docs/2.5.5/reference/html/#jpa.query-methods.query-creation)
+ join 등 복잡한 표현은 불가

#### 몇가지 애노테이션들
+ @Param: 쿼리 메소드 입력 파라미터에 사용하여 애노테이션 기반 파라미터 바인딩할 때 사용 
+ @Query: 직접 JPQL을 작성하고 싶을 때 사용
+ @NoRepositoryBean: 빈으로 등록하고 싶지 않은 인터페이스를 지정할 수 있다.
  + 특정 쿼리 메소드를 기본 메소드로 지정하는 방식으로 운영 가능
  + 특정 메소드를 선택적으로 사용하거나 api에 노출하고자 할 때도 사용하는 테크닉

#### Reference
+ [https://docs.spring.io/spring-data/jpa/docs/2.5.5/reference/html/#reference](https://docs.spring.io/spring-data/jpa/docs/2.5.5/reference/html/#reference)
+ [https://spring.io/guides/gs/accessing-data-jpa/](https://spring.io/guides/gs/accessing-data-jpa/)

### @Entity 디자인

#### @Entity
엔티티 클래스 애노테이션
+ 데이터베이스에 저장(persist)할 자바 객체를 정의
+ 다양한 애노테이션을 이용해 보다 자세한 테이블 스키마 정보를 표현
+ 애노테이션으로 표현한 스키마 정보와 실제 테이블 스키마가 완벽히 일치해야 할 필요는 없다.
+ 하나의 도메인(domain)으로 간주

#### @Entity: JPA 애노테이션
@Entity 클래스 안에서 사용되는 주요 JPA 애노테이션
+ @Table, @Index, @UniqueConstraint: 테이블 기본 정보와 인덱스, unique 키를 설정
+ @Id, @GeneratedValue: primary key 설정
+ @Column: 각 컬럼 설정
+ @Enumerated: enum 을 처리하는 방법을 설정
+ @Transient: 특정 필드를 DB 영속 대상에서 제외
+ @OneToOne, @OneToMany, @ManyToOne, @ManyToMany: 연관 관계 설정
+ @MappedSuperClass: 상속을 이용한 공통 필드 정의
+ @Embedded, @Embeddable: 클래스 멤버를 이용한 공통 필드 정의
+ @DateTimeFormat: 스프링에서 제공하는 애노테이션, 날짜 입력 포맷을 정의

#### @Entity: JPA 엔티티의 lifecycle event 를 활용한 Auditing 테크닉
JPA 엔티티에 생성일시, 수정일시 같이 일정하게 작성하는 메타데이터를 처리 가능
+ @PrePersist
+ @PostPersist
+ @PreRemove
+ @PostRemove
+ @PreUpdate
+ @PostUpdate
+ @PostLoad

#### @Entity: Spring JPA Auditing 애노테이션
엔티티의 생성일시, 수정일시, 생성자, 수정자를 자동으로 관리해주는 애노테이션 
+ 설정
  + @EnableJpaAuditing
  + @EntityListeners(AuditingEntityListener.class)
+ 활용
  + @CreatedBy
  + @CreatedDate
  + @LastModifiedBy
  + @LastModifiedDate

#### Reference
+ [https://docs.spring.io/spring-data/jpa/docs/2.5.5/reference/html/#reference](https://docs.spring.io/spring-data/jpa/docs/2.5.5/reference/html/#reference)

### DataSource, TransactionManager

#### DataSource
물리적인 데이터소스(데이터베이스) 정보를 담는 인터페이스
+ 하나의 물리 데이터베이스를 표현
+ 다양한 구현체를 사용
  + EmbeddedDatabaseBuilder: HSQL, Derby, H2 등 임베디드 DB 세팅할 때 사용
  + DataSourceBuilder: JDBC DataSource 빌더
  + DriverManagerDataSource: JDBC 드라이버로 세팅하는 DataSource
  + SimpleDriverDataSource: DriverManagerDataSource 를 간편하게 만든 버전
  + HikariDataSource: HikariCP 를 connection pool 로 사용하는 DataSource
  + 기타 등등

#### TransactionManager
스프링 트랜젝션 관리 기능을 담당하는 인터페이스
+ 용도에 따라 다양한 인터페이스와 구현체들
  + PlatformTransactionManager, ReactiveTransactionManager
  + JpaTransactionManager: Spring Data JPA 일반적인 상황에 사용하는 구현체, 단일 EntityManagerFactory 를 사용
  + DataSourceTransactionManager: 단일 JDBC DataSource 를 사용하는 구현체
  + HibernateTransactionManager: 하이버네이트 SessionFactory 를 사용하는 구현체
  + ChainedTransactionManager: 여러 개의 트랜잭션 매니저를 묶어서 사용하는 구현체
    + @Deprecated (as of Boot 2.5)
  + 등등

#### JPA DB 수동 설정 (Java code)
자바 코드로 DataSource, TransactionManager 를 수동 세팅해야 하는 경우가 있다
+ 언제?
  + configuration properties 로 커버되지 않은 세밀한 옵션을 줄 때 
  + 다중 DataSource
+ 세팅해야 하는 요소
  + DataSource
  + EntityManagerFactory -> LocalContainerEntityManagerFactoryBean
    + 추가적인 예외 처리 기능 때문에, 인터페이스 말고 구현체를 직접 빈으로 등록해야 한다
  + PlatformTransactionManager
+ 세팅 구성: DataSource (DB 설정) -> EntityManagerFactory (JPA 엔티티 관리) -> PlatformTransactionManager (트랜잭션 관리)

#### @Transactional
스프링이 애노테이션 기반 트랜잭션 관리 기능을 제공
+ EntityManager 불러오고 -> 구역 지정하고 -> commit(), rollback() 직접 할 필요 없다
+ 서비스 클래스, 메소드에 적용하는 것으로 간단히 트랜잭션 구역을 설정
  + 동시에 설정하면 메소드가 우선
+ JpaRepository 는 메소드 단위 @Transactional 이 이미 붙어있다
+ 관련 애노테이션
  + 스프링 테스트 지원 애노테이션: @DataJpaTest와 좋은 궁합 
    + @Commit
    + @Rollback
  + javax.transaction.@Transactional: 스플이 패키지가 아니다, 기대하는 기능을 주지 않으므로 주의

#### @Transactional: attributes
@Transactional 이 제공하는 다양한 옵션들
+ transactionManager(value): 사용할 트랜잭션 매니저를 이름으로 특정
+ label: 트랜잭션 구분 짓고 식별하는 레이블
+ propagation: 트랜잭션이 중첩될 경우 동작(트랜잭션 효과의 전파) 규칙 (default:REQUIRED)
+ isolation: 트랜잭션 내부 데이터의 격리 레벨 (default:DEFAULT)
+ timeout,timeoutString: 시간 제한을 거는 것이 가능
+ readOnly: "이 트랜잭션 안에서는 select만 일어난다"를 표현
  + 강제성이 없음을 주의 - 힌트로 생각하자
  + 이 옵션을 처리하지 않는 트랜잭션 매니저 구현체를 사용할 경우, 별도의 예외처리를 안 한다
+ rollbackFor, rollbackForClassName
+ noRollbackFor, noRollbackForClassName

#### @Transactional: Propagation
중첩된 트랜잭션의 동작 규칙
+ REQUIRED(default): 현재 있으면 보조, 없으면 새로 만들기
+ SUPPORTS: 현재 있으면 보조, 없으면 트랜잭션 없이 실행
+ MANDATORY: 있으면 보조, 없으면 예외 처리
+ REQUIRES_NEW: 트랜잭션을 생성하고 실행, 현재 있던 것은 미룬다
+ NOT_SUPPORTED: 트랜잭션 없이 실행, 현재 있던 것은 미룬다
+ NEVER: 트랜잭션 없이 실행, 현재 트랜잭션이 있었으면 예외 처리
+ NESTED: 현재 있으면 그 안에서 중첩된 트랜잭션 형성

#### @Transactional: Isolation
트랜잭션 내부 데이터의 격리 수준
+ DEFAULT: 데이터베이스에게 맡긴다
+ READ_UNCOMMITTED: dirty read + non-repeatable read + phantom read
+ READ_COMMITTED: non-repeatable read + phantom read
+ REPEATABLE_READ: phantom read
+ SERIALIZABLE: 완전 직렬 수행

#### Reference
+ [https://docs.spring.io/spring-data/jpa/docs/2.5.5/reference/html/#jpa.java-config](https://docs.spring.io/spring-data/jpa/docs/2.5.5/reference/html/#jpa.java-config)
+ [https://github.com/spring-projects/spring-data-commons/issues/2232](https://github.com/spring-projects/spring-data-commons/issues/2232) 

### JPA 테스트

#### @DataJpaTest
persistence layer 를 슬라이스 테스트하기 위한 각종 자동 설정을 지원
+ 단순 select, insert 등 기본 쿼리 메소드의 테스트를 하지 않는 편
+ 복잡한 JPQL 이나 쿼리 표현을 테스트하기 적합
+ 잘 사용하는 세부 기능들
  + TestEntityManager: 테스트 데이터를 주입할 EntityManager 를 사용 가능
  + @AutoConfigureTestDatabase: 테스트용 인메모리 DB 를 다른 환경으로 바꾸고자 할 때
+ 기타 스프링 부트 테스트 애노테이션
  + @JdbcTest: Spring Data 기능 없이 DataSource 만 테스트
  + @DataJdbcTest: DataSource + Spring Data JDBC

#### Reference
+ [https://docs.spring.io/spring-boot/docs/2.5.4/reference/htmlsingle/#features.testing.spring-boot-applications.autoconfigured-spring-data-jpa](https://docs.spring.io/spring-boot/docs/2.5.4/reference/htmlsingle/#features.testing.spring-boot-applications.autoconfigured-spring-data-jpa)

## 복잡한 쿼리의 작성과 응용

### Querydsl VS Jooq

#### Querydsl
"Unified Queries for Java. Querydsl is compact, safe and easy to learn." ("Java에 대한 통합 쿼리. Querydsl은 작고 안전하며 배우기 쉽습니다.")
+ 자바 코드(엔티티) -> DB 쿼리 생성 도구
+ HQL 생성 라이브러리
  + type-safety 가 부족한 HQL(JPQL)의 대한
  + 읽기 어려운 Criteria API의 대안
+ 기존 기술과의 비교
  + JPQL: type-safety 가 좀 아쉽다
  + Criteria: 어렵다
+ Querydsl 코드
  + 보다 편리한 readable 한 쿼리 작성
  + 편리한 join
  + 스프링 Pageable 과 매끄러운 연동

#### Jooq
"jOOQ generates Java code from your database and lets you build type safe SQL queries through its fluent API." ("jOOQ는 데이터베이스에서 Java 코드를 생성하고 유창한 API를 통해 유형 안전 SQL 쿼리를 작성할 수 있습니다.")
+ DB schema -> Java class 도구
+ ORM framework 가 아니다
+ "jOOQ is not a replacement for JPA" ("Jooq는 JPA를 대체하지 않습니다.")
  + SQL 이 잘 어울리는 곳엔, Jooq 가 잘 맞아요
  + Object Persistence 가 잘 어울리는 곳엔, JPA 가 잘 맞아요
+ Jooq says: "Jooq + JPA

#### Reference
+ [https://querydsl.com/](https://querydsl.com/)
+ [https://www.jooq.org/](https://www.jooq.org/)
+ [https://www.jooq.org/doc/3.15/manual-single-page/#jooq-and-jpa](https://www.jooq.org/doc/3.15/manual-single-page/#jooq-and-jpa)