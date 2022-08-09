---
layout: post
bigtitle: '실무 적용 SQL 성능 튜닝'
subtitle: 튜닝 방법론 및 SQL 처리 구조
date: '2022-08-05 00:00:00 +0900'
categories:

[//]: # (    - study)

[//]: # (    - kt-development-consortium)

[//]: # (    - sql-performance-tuning)

comments: true
---

# 튜닝 방법론 및 SQL 처리 구조

# 튜닝 방법론 및 SQL 처리 구조
* toc
{:toc}

## TUNING의 개요
+ 정상적인 성능을 제공하던 오라클 데이터베이스가 SELECT, UPDATE, INSERT, DELETE 문을 실행 했더니 갑자기 실행 속도가 너무 떨어져서 운영에 어려움을 겪게 되는 것을 경험할 수 있게 되는데 
이런 경우 튜닝을 통해 성능이 향상될 수 있도록 하는 것

## 시스템 성능 저하의 주요인
+ 대부분의 성능저하 주요인은 DB관련 비효율
+ SQL관련 부분과 DB설계가 전체의 70% 차지
+ 성능저하 문제의 핵심은 CPU/Memory 부하가 아닌 비효율적인 I/O
+ SQL활용 및 DB설계능력이 성능관점에서 중요

## SQL 성능 저하의 원인
+ 오래되거나 누락된 옵티마이저 통계
+ 누락된 엑세스 구조
+ 최적 상태가 아닌 실행 계획 선택
+ 잘못 작성된 SQL

## 비효율적인 SQL Example

### 조회조건 컬럼의 외부적인 변형

~~~sql

SELECT * FROM EMP WHERE SUBSTR(ENAME, 1, 3) = 'JOE'

~~~

↓ TUNING 을 통해 성능을 향상시킬 수 있는 방법

~~~sql
 
SELECT * FROM EMP WHERE LIKE 'JOE%'

~~~

### Data Type 불일치

~~~sql

SELECT * FROM DEPT WHERE DEPTNO = :IN_DEPTNO

-- 조건) DEPTNO - CHAR(3), IN_DEPTNO - NUMBER형 BIND 변수

~~~

↓ 실제 rewrite 되는 SQL

~~~sql

SELECT * FROM DEPT WHERE TO_NUMBER(DEPTNO) = :IN_DEPTNO

~~~

↓ TUNING 을 통해 성능을 향상시킬 수 있는 방법

~~~sql

SELECT * FROM DEPT WHERE DEPTNO = LPAD(TO_CHAR(:IN_DEPTNO), 3, '0')

~~~

:IN_DEPTNO BIND 변수를 CHAR 형으로 선언하여 사용하는 것이 더 좋다

### Correlated subquery(상관 관계가 있는 하위 쿼리)
+ 제품 정가가 평균 제품 가격보다 15% 이상 낮은 제품의 수를 확인하는 SQL

~~~sql

SELECT COUNT(*) FROM products p WHERE prod_list_price < 1.15 * (SELECT AVG(unit_cost) FROM costs c WHERE c.prod_id = p.prod_id)

~~~

↓ TUNING 을 통해 성능을 향상시킬 수 있는 방법

~~~sql

SELECT COUNT(*) FROM products p , (SELECT prod_id ,AVG(unit_cost) ac FROM costs GROUP BY prod_id) c  WHERE p.prod_id = c.prod_id AND p.prod_list_price < 1.15 * c.ac 

~~~

## OPTIMIZER
+ 사용자는 요구만 하고 OPTIMIZER가 실행계획 수립
+ 수립된 실행계획에 따라 엄청난 수행속도 차이발생
+ 실행계획 제어가 어렵다
+ OPTIMIZER가 좋은 실행계획을 수립할 수 있도록 종합적이고 전략적인 FACTOR를 부여
+ 비절차형으로 기술해야 함
+ 집합적으로 접근해야 함
