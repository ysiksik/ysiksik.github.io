---
layout: post
bigtitle: '업무 프로세스 분석과 데이터베이스 모델링'
subtitle: 빅데이터 설계 기법
date: '2022-06-27 00:00:00 +0900'
categories:
    - study
    - kt-development-consortium
    - database-modeling
tags: databaseModeling
comments: true
---

# 빅데이터 설계 기법

# 빅데이터 설계 기법
* toc
{:toc}

## 빅데이터 소개

### 데이터베이스 관리 시스템 연혁
![예제](/assets/img/database-modeling/BigData.png)

## 빅 데이터와 NoSQL

### NoSql
> + NoSql은 Not Only SQL의 약자로 기존 RDBMS 형태의 관계형 데이터베이스가 아닌 다른 형태의 데이터 저장 기술을 의미한다.
> + NoSql

### NoSql의 특징
> + NoSql은 데이터 간의 관계를 정의하지 않는다.
> + RDBMS에 비해 훨씬 더 대용량의 데이터를 저장할 수 있다.
> + 분산형 구조를 통해 데이터를 여러 서버에 분산해 저장하고, 분산시에 데이터를 상호 복제해 특정 서버에 장애가 발생했을 때에도 데이터 유실이나 서비스 중지가 없는 형태의 구조다.
> + 스키마가 고정되어있지 않기 때문에 다양한 구조의 데이터를 저장 할 수 있다.
> + 조회해서 출력하고자 하는 형태로 테이블을 디자인 한다.

### NoSql 데이터 모델링
+ 고정되지 않은 테이블 스키마
![예제](/assets/img/database-modeling/NoSql.png)

### NoSql의 분류
+ NoSql은 데이터 저장 구조에 따라 다름과 같이 세 가지로 크게 분류한다.

> + Key/Value Store
>   + Unique한 Key에 (Column, Value) 조합으로 된 여러 개의 필드를 갖는다.
>   + 이러한 구조를 Column Family 구조라고 한다.
>   + ![예제](/assets/img/database-modeling/KeyValueStore.png)

                Oracle Coherence나 Redis 제품 등이 이에 해당한다.

> + Order Key/Value Store
>   + Key를 중심으로 정렬된 상태로 저장된다.
>   + ![예제](/assets/img/database-modeling/OrderKeyValueStore.png)

                아파치(Apache)의 HBase, Cassandra 제품 등이 이에 해당한다.

> + Document Key/Value Store
>   + Key/Value Store의 확장으로 저장되는 Value의 데이터 형식이 Document라는 타입을 사용한다.
>   + ![예제](/assets/img/database-modeling/DocumentKeyValueStore.png)

                MongoDB, CouchDB, Risk 제품 등이 이에 해당한다.

### 시장 점유율
![예제](/assets/img/database-modeling/NoSql2.png)
