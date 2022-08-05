---
layout: post
bigtitle: '업무 프로세스 분석과 데이터베이스 모델링'
subtitle: 논리적 데이터 모델링
date: '2022-06-24 00:00:00 +0900'
categories:
    - study
    - kt-development-consortium
    - database-modeling
tags: databaseModeling
comments: true
---

# 논리적 데이터 모델링

# 논리적 데이터 모델링
* toc
{:toc}

## 논리적 데이터베이스 모델링에 대한 이해

### 논리적 데이터베이스 모델링이란?
> + 논리적 데이터베이스 모델링 단계부터는 관계형 데이터베이스 이론이 적용되는 단계
> + 실제 DBMS를 고려하지 않은 상태로 데이터베이스 내의 스키마를 정의하는 단계
> + ![예제](/assets/img/database-modeling/LogicalDataModeling.png)

### 메핑룰(Mapping Rule)이란?
> + 개념적 데이터 모델링 단계에서 정의된 E-R Diagram을 관계형 데이터베이스 이론에 맞게 변환시키는 작업
> + 단계
>   1. 실체(Entity) -> 테이블로
>   2. 속성(Attribute) -> 컬럼으로
>   3. 주 식별자 -> 기본키로
>   4. 관계 -> 포린키로
> + ![예제](/assets/img/database-modeling/MappingRule.png)
> + 일대일 관계
>   + ![예제](/assets/img/database-modeling/OneToOne.png)
> + 일대다 관계
>   + ![예제](/assets/img/database-modeling/OneToMany.png)
> + 다대다 관계
>   + ![예제](/assets/img/database-modeling/ManyToMany.png)

## 정규화

### 정규화 정의
> + 1972년 E.F CODE 박사에 의해 제안된 이론
> + 실세계에서 발생하는 데이터를 수학적인 방법에 의해 구조화시켜 체계적으로 관리할 수 있도록 한 이론

### 정규화 목적
> + 정보의 중복을 최소화
> + 정보모형의 단순화
> + 정보 공유도 증대
> + 정보의 일관성 확보
> + 정보 품질 증대

### 정규화의 필요성
> + 엔티티를 구성하는 속성간에 중복을 제거하여 데이터베이스를 최적화
> + 속성간의 함수종속성에 의해 발생하는 이상현상을 제거
> + 정규화를 통해 Data 감소 및 중복된 Data 제거는 가능하지만 조인의 증가로 성능 저하 발생

| 이상현상 | 내용 |
|:-------:|:-----------------------------------------------:|
| 입력이상 | 데이터 입력 시 필요 없는 속성까지 입력 해야하는 현상 |
| 수정이상 | 데이터 수정 시 원하지 않는 데이터까지 수정되는 현상 |
| 삭제이상 | 데이터 삭제 시 필요한 데이터까지 삭제되는 현상 |

### 제 1 정규형
> + 반복되는 속성이나 그룹의 속성을 제거하고, 새로운 실체를 추가한 후에 기존 실체와 일대다의 관계를 형성

### 제 2 정규형
> + 복합키(Composit Primary Key)로 구성된 경우 해당 테이블 안의 컬럼들은 복합키 전체에 의존적이여야 한다
> + 만일 복합키 일부에 의존적인 컬럼이 존재한다면 이를 제거해야 한다

### 제 3 정규형
> + 한 테이블 안의 모든 키가 아닌 컬럼들은 기본키(Primary Key)에 의존해야 한다
> + 만일 키가 아닌 컬럼에 종속되는 속성이 존재한다면 이를 제거해야 한다

      정규화(Normalization)란 속성이 제 위치에 제대로 위치하게끔 정의하는 과정을 말하며
      정규형(Normal Form)이란 정규화를 수행하는데 있어서의 규칙을 말한다

## 1차 정규화
> + 반복되는 속성이나 그룹의 속성을 제거하고, 새로운 엔티티를 추가한 후에 기존의 엔티티와 일대다의 관계를 형성
> + 예) 하나의 제품에 대해 여러 개의 주무서가 접수된 내용
>   + ![예제](/assets/img/database-modeling/Normalization1.png)
>   + 입력 이상 : 주문이 발생 되어야만 제품 정보들 등록할 수 있다.
>   + 수정 이상 : 마우스 수량을 9702에서 15000으로 변경하고자 한다면 데이터를 3번 수정해야 한다
>   + 삭제 이상 : 제품 번호가 1201인 스피커를 주문한 내역을 삭제하면 제품명, 재고수량 정보도 모두 삭제된다
>   + 제품에 관련된 정보로부터 반복되어 생성되는 주문 관련 정보를 분리함으로써 1차 정규화를 수행
>     + ![예제](/assets/img/database-modeling/Normalization1-1.png)

## 2차 정규화
> + 복합식별자 일부에 의존적인 속성이 존재한다면 이를 제거(부분 종속 속성 제거)
> + ![예제](/assets/img/database-modeling/Normalization2.png)
>   + 제품번호 + 주문번호 : 주문수량
>   + 주문번호 : 수출여부, 고객번호, 사업자번호, 우선순위
>     + 입력 이상 : 고객정보 입력 시 주문정보도 입력해야 함
>     + 수정 이상 : 만약 주문번호 AB345의 우선순위를 1 에서 10으로 수정할 경우 1001+AB345와 1007+AB345를 같이 수정해야 함
>     + 삭제 이상 : 주문번호 삭제 시  고객번호도 함께 삭제됨
>     + 주문번호에 완전히 종속적인 속성을 분리하여 별도의 엔티티를 구성
>       + ![예제](/assets/img/database-modeling/Normalization2-1.png)

## 3차 정규화
> + 한 엔티티 안의 모든 주식별자가 아닌 속성들은 주식별자에 의존해야한다
> + ![예제](/assets/img/database-modeling/Normalization3.png)
>   + 속성에 종속적인(이전종속) 속성이 있다면
>   + 고객번호 : 수출, 사업자번호, 우선순위
>     + 입력 이상 : 새로운 고객 등록 시 주문이 없으면 입력이 안됨
>     + 수정 이상 : 한 고객이 여러 번 주문한 경우 고객 정보가 반복적으로 발생, 고객 정보 수정시 여러 개의 데이터를 수정해야 함
>     + 삭제 이상 : 고객번호 4520이 주문을 취소하면 주문 정보만 삭제되는 것이 아니라 고객 정보도 모두 삭제된다.
>     + 고객번호에 종속정인 속성을 분리하여 별도의 엔티티를 구성
>       + ![예제](/assets/img/database-modeling/Normalization3-1.png)

## 특수한 경우의 엔티티 모델링

### 수퍼 타입과 서브 타입
> + 하나의 실체는 두 개 이상의 실체로 분할될 수 있으며, 이들의 공통 분모를 모아서 수퍼 타입으로 정의하고 나머지 배타적인 속성들을 모아서 서브타입으로 정의
> + ![예제](/assets/img/database-modeling/SuperAndSub.png)
> + ![예제](/assets/img/database-modeling/SuperAndSub2.png)

### 재귀적 관계
> + 자기 자신과 관계를 맺음으로 해서 자기 자신의 기본키가 자기 자신에게 포린키로 전이되는 관계
> + 계층적인 구조를 정의할 때 재귀적 관계를 사용한다
> + ![예제](/assets/img/database-modeling/Recursion.png)

### 다대다 관계 해소 방법
> + 교차 실체를 통해 해소
>   + ![예제](/assets/img/database-modeling/MAndM1.png)
> + 한 단계 거쳐서 해소
>   + ![예제](/assets/img/database-modeling/MAndM2.png)

### 코드 테이블 작성
> + 동일한 데이터가 반복되는 경우 코드 테이블을 작성한다
> + ![예제](/assets/img/database-modeling/CodeTable.png)


## 일반화

### 일반화 관계

> + 공통 속성을 가지는 슈퍼타입과, 공통 부분을 제외하고 두 개 이상의 엔티티 간의 속성에 차이가 있을 때 별도의 서브타입으로 존재
> + Exclusive(배타적) 관계 : 슈퍼타입의 엔티티가 반드시 하나의 서브타입에는 속하는 관계
>   + ![예제](/assets/img/database-modeling/Exclusive.png)
> + Inclusive(포함) 관계 : 슈퍼타입의 엔티티가 두 개 이상의 서브타입에 포함될 수 있는 관계
>   + ![예제](/assets/img/database-modeling/Inclusive2.png)

## 논리모델의 다양한 요구에 따른 Relationship 형태

* 병렬관계
> + 엔티티와 엔티티가 독립적으로 분리 되어 있으면서 두 개 이상의 관계가 상호간에 존재하는 형태
> + ![예제](/assets/img/database-modeling/Parallel2.png)


* 재귀적 관계
> + 하나의 엔티티 내에서 엔티티와 엔티티가 관계를 맺고 있는 형태
> + 부서, 부품, 메뉴 등과 같이 계층 구조 형태를 표현할 때 유용
> + ![예제](/assets/img/database-modeling/Recursion2.png)

* RoleName
> + FK Attribute의 역할 이름(별칭)
> + 원치 않은 Unification 현상 해결
> + ![예제](/assets/img/database-modeling/RoleName.png)

## 엔티티관계도(ERD) 작성
> + 정의된 엔티티와 그들의 관계를 도형으로 표기
> + 목적
>   + 전체적인 업무의 정보 개념을 표현
>   + 표기법을 이용한 사용자와의 의사 소통 원활화
> + 도형의 요소
>   + ![예제](/assets/img/database-modeling/Figure.png)
> + 식별관계 : 부모 테이블의 기본키가 자식 테이블에 기본키로 전이되는 관계
> + 비식별관계 : 부모 테이블의 기본키가 자식 테이블에 일반 속성으로 전이되는 관계
