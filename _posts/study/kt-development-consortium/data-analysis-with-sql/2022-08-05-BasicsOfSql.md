---
layout: post
bigtitle: 'SQL을 활용한 데이터 분석'
subtitle: SQL의 기본
date: '2022-08-05 00:00:00 +0900'
categories:
    - data-analysis-with-sql
comments: true
---

                                                  
# SQL의 기본

# SQL의 기본
* toc
{:toc}

## SQL과 SQL*Plus의 개념
+ SQL(Structured Query Language)란?
  + 관계 DB를 처리하기 위해 고안된 언어로, 독자적인 문법을 갖는 표준 언어(ISO에서 지정)로서 대다수 데이터베이스는 SQL을 사용하여 데이터를 조회, 입력, 수정, 삭제 한다
+ SQL*Plus란?
  + SQL*Plus는 SQL 명령문을 기능을 제공하고, 컬럼이나 데이터의 출력 형식을 설정하거나 환경 설정하는 기능을 제공한다.

## SQL*Plus 로그인
+ 데이터베이스 접속을 시도하면 오라클 데이터베이스를 사용할 수 있는 사용자인지를 검증하기 위해서 사용자 계정과 암호를 묻게 됩니다.
+ 오라클을 설치하게 되면 기본적으로 생성되는 사용자 계정 중에서 scott을 사용합니다. scott의 패스워드는 oracle입니다.
  + 형식 : SQLPLUS 사용자계정/암호
  + 예 : sqlplus scott/oracle@pdb1

## 시스템 권한을 갖는 데이터베이스 관리자
+ 데이터베이스 사용자는 오라클 계정(Account)이라는 용어와 같은 의미로 사용됩니다. 오라클을 설치하면 한개 이상의 데이터베이스 권한을 갖는 디폴트(기본적인) 사용자가 존재합니다. 오라클에서 제공되는 사용자 계정으 다음과 같습니다.

| 사용자계정   | 설명                                                                                             |
|---------|------------------------------------------------------------------------------------------------|
| SYS     | 오라클 Super 사용자 계정이며 데이터베이스에서 발생하는 모든 문제들을 처리할 수 있는 권한을 가지고 있다.                                  |
| SYSTEM  | 오라클 데이터베이스를 유지보수 관리할 때 사용하는 사용자 계정이며, SYS 사용자와 차이점은 데이터베이스를 생성할 수 있는 권한이 없으며 불완전한 복구를 할 수 없다.  |
| SCOTT   | 처음 오라클을 사용하는 사용자의 실습을 위해 만들어 놓은 연습용 계정이다.

## 데이터 딕셔너리 TAB
+ 오라클을 설치하면 제공되는 사용자인 SCOTT은 학습을 위해서 테이블들이 제공됩니다.SCOTT이 소유하고 있는 데이블을 살펴보기 위해서 다음과 같은 명령을 입력한다.
+ TAB은 TABLE의 약자로서 SCOTT 사용자가 소유하고 있는 테이블의 정보를 알려주는 데이터 딕셔너리이다.

~~~sql

    SELECT * FROM TAB;

~~~

## 테이블 구조를 살펴보기 위한 DESC
+ 테이블에서 데이터를 조회하기 위해서는 테이블의 구조를 알아야 한다. 테이블의 구조를 확인하기 위한 명령어로는 DESCRIBE가 있다.
  + DESC 명령어는 테이블의 컬럼 이름, 데이터 형, 길이와 NULL 허용 유무 등과 같은 특정 테이블의 정보를 알려준다.
  + DESC[RIBE] 테이블명
+ 오라클을 설치하면 학습용으로 제공되는 DEPT 테이블은 부서의 정보를 저장하고 있으며, 이에 대한 구조를 살펴보기 위해서는 desc 명령어를 사용해야 한다.
  + desc dept -- dept 테이블의 구조를 살펴보기 위해서는 desc 명령어를 사용해야 한다.
  + desc 명령어는 테이블의 컬럼 이름, 데이터 형, 길이와 NULL 허용 유무 등과 같은 특정 테이블의 정보를 알려준다.

## 데이터를 조회하기 위한 SELECT 문
+ SELECT 문은 데이터를 조회하기 위한 SQL 명령어 
  + SQL 명령어는 하나의 문장으로 구성되어야 하는데 반드시 세미콜론으로 마쳐야 한다.
  + SELECT 문은 반드시 SELECT와 FROM 이라는 2개의 키워드로 구성되야 한다.
  + SELECT절은 출력하고자 하는 컬럼 이름을 기술한다.
  + 특정 컬럼 이름 대신 * 를 기술할 수 있는데, * 는 테이블 내의 모든 컬럼을 출력하고자 할 경우 사용한다.,
  + FROM절은 조회하고자 하는 테이블 이름을 기술한다.
  + SQL 문에서 사용하는 명령어들은 대문자와 소문자를 구분하지 않는다는 특징이 있다.

## DUAL 테이블 
+ DUAL 테이블은 DUMMY라는 단 하나의 컬럼으로 구성되어 있다.
+ 이 컬럼 최대 길이는 1이다.
+ DUAL 테이블은 DUMMY라는 단 하나의 컬럼에 X라는 단 하나의 로우만을 저장하고 있으나 이 값은 아무런 의미가 없다.
+ 쿼리문의 수행결과가 하나의 로우로 출력되도록 하기 위해서 단 하나의 로우를 구성하고 있을 뿐이다.

## 산술 연산자 

| 종류   | 예                            |
|:-----|:-----------------------------|
| +    | SELECT sal + comm FROM emp;  |
| -    | SELECT sal - 100 FROM emp;   |
| *    | SELECT sal * 12 FROM emp;    |
| /    | SELECT sal / 2 FROM emp;     |


## 컬럼 이름에 별칭 지정하기(alias)
+ AS로 컬럼에 별칭 부여
  + 컬럼 이름 대신 별칭을 출력하고자 하면 컬럼을 기술한 바로 뒤에 AS 라는 키워드를 쓴 후 별칭을 기술한다.
+ AS 없이 컬럼에 별칭 부여
+ " "로 별칭 부여
  + 위 예제를 살펴보면 별칭을 부여 할 때에는 대소문자를 섞어서 기술하였는데 출력 결과를 보면 일괄적으로 대문자로 출력된 것을 확인 할 수 있다.
  + 대소문자를 구별하고 싶으면 " "을 사용한다.
  + " "을 사용하여 별칭을 부여할 경우에는 별칭에 공백문자나 $,_#등 특수 문자를 포함시킬 수 있다.
+ SQL에서 쿼리문의 결과가 출력 될 때, 컬럼 이름이 컬럼에 대한 헤딩(heading)으로 출력된다.
+ 별칭으로 한글 사용하기
  + 오라클에서 한글을 지원하므로 별칭이 아닌 테이블을 생성할 때 컬럼을 설정하면 컬럼 이름도 한글로 부여할 수 있다.

## NULL도 데이터이다.
+ 오라클에서의 널은 매우 중요한 데이터이다. 왜냐하면 오라클에서는 컬럼에 널값이 저장되는 것을 허용하는데 널 값을 제대로 이해하지 못한 채 쿼리문을 사용하면 원하지 않는 결과를 얻을 수 있기 때문이다.
+ 다음은 널에 대한 이해를 돕기 위해서 다양한 널의 정의를 살펴본 것이다.
  + 0(zero)도 아니고 빈 공간도 아니다
  + 미확정(해당 사항 없음), 알 수 없는(unknown) 값을 의미한다.
  + 어떤 값인지 알 수 없지만 어떤 값이 존재하고 있다
  + ? 혹은 ∞의 의미이므로 연산, 할당, 비교가 불가능하다.
  + NULL 은 미확정, 알 수 없는 값이기 때문에 연산, 할당, 비교가 불가능하다.
  + 산술연산에서 NULL
    + 어떤 값 산술 연산자 NULL = NULL 
    + 0.09 * NULL = NULL
  
~~~sql

SELECT ename, sal, job, comm, sal*12, sal*12*comm FROM emp;

~~~

> 영업직인 경우 받을 커미션(comm)이 없더라도 0으로 저장되어 있으므로 연봉 계산이 정상적으로 된다.
>
> 영업직이 아닌 경우에는 커미션에 널값이 저장되어 있어서 연봉 계산 결과도 널값으로 구해지는 모순이 발생한다.

~~~sql

SELECT ename, comm, sal*12+comm, nvl(comm,0), sal*12*nvl(comm,0) FROM emp;

~~~

> 연봉 계산을 위해 사원 테이블에서 급여와 커미션 컬럼을 살펴본 결과 영업사원이 아닌 사원들의 커미션은 NULL로 지정 되어 있으므로 연봉을 올바르게 계산하기 위해서는 커미션이 NULL인 경우 0으로 변경하여 계산에 참여하도록 해야 한다.
> 
> 오라클에서는 NULL을 0 또는 다른 값으로 변환하기 위해서 사용하는 함수로 NVL을 제공한다. 커미션에 널이 저장 되어 있더라도 널을 다른 값으로 변환하는 NVL 함수를 사용하면 제대로 된 계산 결과를 얻을 수 있다.  

## Concatenation 연산자의 정의와 사용
+ 오라클에서는 Concatenation 연산자를 제공해 준다.
+ Concatenation 의 사전적인 의미는 연결이다
+ 따라서 오라클에서의 Concatenation 연산자 역시 여러 개의 컬럼을 연결할 때 사용한다 Concatenation 연산자로 "||" 수직바를 사용한다.
+ 컬럼과 특정 값 사이의 공백이 생기는 것을 확인할 수 있다. "||"를 컬럼과 문자열 사이에 기술하여 하나로 연결하여 출력하면 된다.

## DISTINCT 키워드
+ DISTINCT
  + 독특한 유일한 값을 반환
  + SELECT DISTINCT 컬럼 OR 표현식 ~ 형태
  + NULL도 하나의 유일한 값에 포함된다
  + DISTINCT 는 컬럼값을 기준으로 중복값을 판별해 내며 조회된는 로우의 수에 영향을 미친다.
+ ALL
  + 모든 값을 조회
  + Default 값으로 생략 가능

## 정렬을 위한 ORDER BY 절
+ 정렬이란 크기 순서대로 나열하는 것을 의미한다.
+ 오름차순(ascending) 정렬 방식
  + 작은 것이 위에 출력되고 아래로 갈수록 큰 값이 출력
+ 내림차순(descending) 정렬 방식
  + 큰 값이 위에 출력되고 아래로 갈수록 작은 값이 출력
+ 로우를 정렬하기 위해서는 SELECT 문에 ORDER BY 절을 추가하고 어떤 컬럼을 기준으로 어떤 정렬을 할 것인지를 결정해야 한다.

|             |  ASC(오름차순)   | DESC(내림차순)     |
|-------------|--------------|-------------------|
| 숫자          | 작은 값부터 정렬    | 큰 값부터 정렬        |
| 문자          | 사전 순서로 정열    | 사전 반대 순서로 정렬  |
| 날짜          | 빠른 날짜 순서로 정렬 | 늦은 날짜 순서로 정렬 | 
| NULL        | 가장 마지막에 나온다  | 가장 먼저 나온다     | 


