---
layout: post
bigtitle: 'Spring Boot 기반 REST API 개발'
subtitle: 스프링 부트 데이터(Maria DB 사용)
date: '2022-07-07 00:00:05 +0900'
categories:
    - study
    - kt-development-consortium
    - springboot-rest-api
tags: RestAPI
comments: true
---

# 스프링 부트 데이터(Maria DB 사용)

# 스프링 부트 데이터(Maria DB 사용)
* toc
{:toc}


## Spring Data : DBCP
  + 스프링 부트가 지원하는 DBCP(Database Connection Pooling) 
  + DBCP는 Connection 객체를 만드는 것이 큰 비용을 지불하기 때문에 미리 만들어진 Connection 정보를 재사용 하기 위해 나온 테크닉이다.
  + 스프링 부트에서는 기본적으로 HikariCP라는 DBCP를 기본적으로 제공한다. [https://github.com/brettwooldridge/HikariCP#frequently-used](https://github.com/brettwooldridge/HikariCP#frequently-used)
  + 스프링에서 DBCP를 설정하는 방법
    + spring.datasource.hikari.maximum-pool-size=4 커넥션 객체의 최대 수를 4개로 설정

## MySQL DataSource

~~~properties
spring.datasource.url=jdbc:mysql://127.0.0.1:3306/boot_db?useUnicode=true&charaterEncoding=utf-8&useSSL=false&serverTimezone=UTC
spring.datasource.username=boot
spring.datasource.password=boot
spring.datasource.driverClassName=com.mysql.cj.jdbc.Driver
~~~

## JPA를 사용한 데이터베이스 초기화

~~~properties
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.properties.hibernate.format_sql=true
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE
~~~

+ spring.jpa.properties.hibernate.format_sql=true
  + JPA가 생성한 SQL문을 콘솔에 출력할지 여부를 알려 주는 프로퍼티
+ logging.level.org.hibernate.SQL=DEBUG , logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE
  + logger를 성정하여 SQL문을 콘솔에 출력할지 여부를 알려주는 프로퍼티
+ spring.jpa.hibernate.ddl-auto=|create|create-drop|update|validate
  + create - JPA가 DB와 상호작용할 때 기존에 있던 스키마(테이블)을 삭제하고 새로 만드는 것을 뜻한다.
  + create-drop - JPA 종료 시점에 기존에 있었던 테이블을 삭제한다.
  + update - 기존 스키마는 유지하고, 새로운 것만 추가하고, 디존 데이터도 유지한다. 변경된 부분만 반영함 주로 개발 할 때 적합하다.
  + validate - 엔티티와 테이블 정상 매핑 되어 있는지를 검증한다.
+ spring.jpa.properties.hibernate.format_sql=true
  + JPA가 생성한 SQL문을 콘솔에 출력할지 여부를 알려 주는 프로퍼티이다 포맷팅 해준다.