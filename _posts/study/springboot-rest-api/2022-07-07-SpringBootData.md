---
layout: post
bigtitle: 'Spring Boot 기반 REST API 개발'
subtitle: 스프링 부트 데이터
date: '2022-07-07 00:00:01 +0900'
categories:
    - study
    - springBoot-REST-API
tags: RestAPI
comments: true
---

# 스프링 부트 데이터

# 스프링 부트 데이터 
* toc
{:toc}

## Spring Data : ORM과 JPA
+ ORM은 "관계형 데이터베이스의 구조화된 데이터와 자바와 같은 객체 지향 언어 간의 구조적 불일치를 어떻게 해소할 수 있을까" 라는 질문에서 나온 객체-관계 매핑 프레임워크 이다.
+ JPA는 Java Persistence API의 약자 입다. Persistence라는 단어는 Java DTO(Data Tranfer Object)에게 '없어지지 않고 오랫동안 지속'되는 '영속성(persistence)'을 부여해준다는 의미이다.
+ JPA는 ORM을 위한 자바 EE 표준이다.

## Spring Data : Spring-Data-JPA
+ Spring-Data-JPA는 JPA를 쉽게 사용하기 위해 스프링에서 제공하고 있는 프레임워크이다.
+ 추상화 정도는 Spring-Data-JPA -> JPA -> Hiberante -> Datasource (왼쪽에서 오른쪽으로 갈수록 구체화) 입니다. 참고로 Hibernate는 ORM 프레임워크 이며 DataSource는 스프링과 연결된 MySQL, PostgreSQL 같은 DB를 연결한 인터페이스이다.
+ Spring Data JPA는 "JpaRepository“ 라는 기능을 사용하면 매우 간단히 데이터를 검색/등록 할 수 있다.
+ Repository 인터페이스는 org.springframework.data.jpa.repository 패키지의 "JpaRepository"라는 인터페이스를 상속하여 맊든다.

## Entity 클래스 작성하기
+ Entity란 DB에서 영속적으로 저장된 데이터를 자바 객체로 매핑하여 '인스턴스 형태'로 존재하는 데이터를 말한다.
+ @Entity - 이는 자바 객체를 DB에 저장하기 위한 정보를 나타내는 어노테이션이다.
+ @Id - 이는 객체의 고유 식별자를 나타내는 어노테이션이다. (Primary Key)
+ @GeneratedValue - 이는 객체의 고유 식별자를 자동으로 생성하는 어노테이션이다.
+ @Column - 이는 객체의 필드를 DB에 저장하기 위한 정보를 나타내는 어노테이션이다.
  + Entity클래스의 모든 필드는 데이터베이스의 컬럼과 매핑 되어 따로 명시하지 않아도 된다. 하지만 매핑 될 컬럼명이 다르거나, default 값이 다른 경우에 사용한다.
  + 이름은 카멜표기법이 소문자 스네이크 표기법으로 전화되고, length는 255, nullable은 true가 default 값이다.
+ @ManyToOne - 다른 Entity클래스와의 외래키 다대일(N:1)관계를 명시한다.
+ Entity 클래스에서 enum을 Java Enum 타입으로 사용하려면 @Enumerated Annotation을 사용한다.
  + EnumType.ORDINAL : int형으로 DB Access
  + EnumType.STRING : enum명으로 DB Access

## ModelMapper란?
+ DB Layer에는 Entity 클래스, View Layer에서 DTO 클래스를 사용하여 역할을 분리하는 것이 좋다.
+ Entity와 DTO를 연결할 때 ModelMapper를 사용한다. [http://modelmapper.org/getting-started/](http://modelmapper.org/getting-started/)
