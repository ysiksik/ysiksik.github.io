---
layout: post
bigtitle: '업무 프로세스 분석과 데이터베이스 모델링'
subtitle: 개념적 데이터 모델링
date: '2022-06-23 00:00:00 +0900'
categories:
    - database-modeling
tags: databaseModeling
comments: true
---

# 개념적 데이터 모델링

# 개념적 데이터 모델링
* toc
{:toc}

## 데이터 모형 공정
![예제](/assets/img/database-modeling/DataModelProcess.png)

## 개념적 데이터 모델링에 대한 이해

### 실체-관계 모델(Entity-Relationship Model)
> + 실체 관계 모델은 1976년 P.Chen이 제안한 것
> + 실체-관계 모델의 장점은 표현력이 풍부하고 직관적이어서 일반적으로 사람의 관점과 유사한 모델을 제공
>   + ![예제](/assets/img/database-modeling/EntityRelationshipModel.png)
> + 실체-관계 모델을 통해서 표현된 결과물을 E-R Diagram이라고 한다.
>   + ![예제](/assets/img/database-modeling/E-R%20Diagram.png)


## 개념적 데이터 모델링

### 실체(Entity) 정의
> + 현실 세계에서 다른 모든 것들과 구분되는 유형, 무형의 것을 실체라고 정의
> + 업무 수행을 위해서 알아야 될 대상이 되는 유형, 무형의 것을 실체라고 정의
> + 데이터로 관리되어야 하는 항목을 실체로 정의
> + ![예제](/assets/img/database-modeling/Entity.png)

### 실체(Entity) 파악 요령
> + 관련 분야에 대한 지식 필요
> + 상식/논리/관찰력 필요
> + 문서를 중심으로 파악
> + 분석된 내용을 토대로 명사 위주로 파악
> + 담당자와의 인터뷰를 통해서 파악

### 엔티티 작성 예
* 엔티티 정의서 작성
![예제](/assets/img/database-modeling/EntityDefinition.png)

### 속성(Attribute) 정의
+ 속성(Attribute)이란 정보의 요소로써 관리되는 항목으로 실체의 성질, 분류, 수량, 특성 등을 나타내는 세부항목
> + 한 실체에 정의되는 속성의 숫자는 10개 내외로 정의하자
> + 속성의 명칭을 정의할 때에는 가독성이 높은 용어를 사용하자
> + 속성을 정의할 때에 세분화해서 정의하도록 하자
> + ![예제](/assets/img/database-modeling/Attribute.png)

### 속성(Attribute) 유형
> + ![예제](/assets/img/database-modeling/Attribute2.png)

### 식별자(Identifier) 정의
> + 식별자란 하나의 실체 내에서 각각의 인스턴스를 유일(Unique)하게 구분해 낼 수 있는 속성 또는 그룹
> + 하나의 실체는 하나 이상의 식별자를 반드시 보유하고 있어야만 한다.

### 식별자(Identifier)의 유형
> 1. 후보 식별자(Candidate Identifier)
> 2. 주 식별자(Primary Identifier)
> 3. 대체 식별자(Alternate Identifier)
> 4. 복합 식별자(Composite Identifiter)
> 5. 대리 식별자(Surrogate Identifiter)
> 6. 외래 식별자(Foreign Identifier)
> + ![예제](/assets/img/database-modeling/Identifier.png)

### 차수성 정의
![예제](/assets/img/database-modeling/count.png)

### 관계의 표현 방식
> + 정보공학(Information Engineering)표기방식
> + ![예제](/assets/img/database-modeling/InformationEngineering.png)

### 선택성 정의
![예제](/assets/img/database-modeling/Select.png)

### 개념적 데이터 모델링 정리
![예제](/assets/img/database-modeling/Modeling.png)

## 엔티티 관계도의 예
![예제](/assets/img/database-modeling/EntityExample.png)
