---
layout: post
bigtitle: '업무 프로세스 분석과 데이터베이스 모델링'
subtitle: DW 데이터 모델링
date: '2022-06-26 00:00:01 +0900'
categories:
    - study
    - kt-development-consortium
    - database-modeling
tags: databaseModeling
comments: true
---

# DW 데이터 모델링

# DW 데이터 모델링
* toc
{:toc}

## DW(Data Warehouse) 개념과 정의

### DW 정의
> + 데이터 웨어하우스(Data Warehouse)란 데이터 창고라는 의미로 OLTP에서 축적된 데이터를 통합해서 관리하는 데이터베이스를 말한다
> + ![예제](/assets/img/database-modeling/DataWarehouse.png)
> + OLTP(Online Transaction Processing)
> + OLAP(Online Analytical Processing)
        DW를 구축하는 이유 ? 의사 결정의 성공률을 높이기 위해서

### 요약 Table과 집합화(Aggregation)
> + 요약된 데이터란?
>   + 미리 정의된 fact data를 누적
>   + 직접적이고 쉽게 접근할 수 있도록 data를 집합화
> + 왜 요약된 데이터를 갖는가?
>   + 질의 응답시간을 개선하기 위하여
>   + 자원의 활용도를 최적화 하기 위하여
>   + 분석 처리를 강화하기 위하여
> + 집합화된 data(Aggergated data)
>   + DW내의 SUM, MAX, MIN, COUNT등으로 미리 계산되고 요약된 data
>   + 일반적으로 요약된 fact table에 저장

## 스타 스키마와 눈송이 스키마

### 스타 스키마
> + 스타 스키마는 차원(Dimension) 테이블과 팩트(Fact) 테이블로 구성되어 있으며 차원 테이블은 정규화되지 않은 형태로 저장되어 있다.
> + ![예제](/assets/img/database-modeling/Star.png)
> + ![예제](/assets/img/database-modeling/Star2.png)

        스타 스키마의 최대 장점은 원하는 정보가 주제별로 하나의 테이블에 모두 정리되어 잇다는 점이다.

#### 스타 스키마의 장점
> + 데이터를 단순화된 형태로 저장
> + 쿼리에 대해 높은 성능을 제공
> + 스타 조인 최적화 기능 활용
> + 많은 BI 도구에서 표준처럼 지원
> + 낮은 유지보수 비용(추가, 병경이 용이)

### 눈송이 스키마
> + 스타 스키마에서 차원이 대용량일 경우 발생하는 처리속도 저하 문제를 해결하기 위해 제시된 데이터모델링 기법
> + 스타 스키마의 차원 테이블을 완전 정규화 시킨 것
> + ![예제](/assets/img/database-modeling/Snowflake.png)

### 다차원 모델링 기법 비교

| 구분 | Star Schema 모델(반정규화된 모델) | Snowflake Schema 모델(정규화된 모델) |
|:----:|:--------------------------------:|:-----------------------------------:|
| 장 점 | 1.모델이 단순하여 사용자 이해가 빠름 <br/> 2.계층 구조를 정의하기가 쉽다. <br/> 3.조인 횟수를 줄임으로써 응답 성능 향상 <br/> 4.Meta Data 단순  | 1.데이터 무결성 유지가 보다 용이 <br/> 2.Star Schema에 비해 상대적으로 작은 저장 공간을 요구 <br/> 3.애플리케이션의 유연성 증가 <br/> 4.데이터 중복성 최소화  |
| 단 점 | 1.Fact 테이블 내의 요약 데이터를 추출할 경우 수행속도 저하됨(계층이 여러 단계인 디멘젼이 반정규화되어 디멘젼이 큰경우) <br/> 2.자료의 불일치 위험 <br/> 3.중복 데이터 포함 <br/> 4.모델이 유연하지 못함 <br/> 5.더 많은 저장 공간이 필요  | 1.구조가 복잡해져 Mart 구축의 장점이 희석 <br/> 2.데이터 베이스 내 관리 테이블 수가 증가 <br/> 3.Dimension 테이블 간의 조인으로 인해 응답성능 저하 <br/> 4.모델에 대한 상용자의 이해도가 Star Schema에 비해 상대적으로 어려움 |

                Snowflake Schema의 최대 장점은 정규화를 통해서 저장공간을 절약하는 것인데
                비용부담이 적어지면서 검색속도만 저하시키는 결과를 초래하여 별로 사용되지 않음
## XML 이해

### XML(Extened Markup Language) 개요
![예제](/assets/img/database-modeling/XML.png)

### XML(Extened Markup Language) 문서구조
![예제](/assets/img/database-modeling/XML2.png)
