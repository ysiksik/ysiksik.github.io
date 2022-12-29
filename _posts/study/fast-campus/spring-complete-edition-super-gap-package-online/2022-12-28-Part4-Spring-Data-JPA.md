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