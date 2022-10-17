---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 라라, 제로의 데이터베이스 인덱스
date: '2022-09-18 00:00:00 +0900'
categories:
    - study
    - elegant-tekotok
comments: true
---

# 라라, 제로의 데이터베이스 인덱스
[https://youtu.be/edpYzFgHbqs](https://youtu.be/edpYzFgHbqs)

# 라라, 제로의 데이터베이스 인덱스
* toc
{:toc}

## 인덱스란?
+ 색인 
  + 쉽게 찾아볼 수 있도록 __일정한 순서__ 에 따라 놓은 __목록__
+ 원하는 값을 빠르게 찾는다 데 초점이 있다.
  
### 데이터베이스 인덱스란?
+ 정의
  + 인덱스 기준이 하나도 압혀 있지 않을 때 
    + 전체 데이터에서 순차적으로 확인하기 때문에 매우 느릴것이다.
    + 데이터가 특정 기준으로 __정렬__ 되어 있다면 검색을 빠르게 할 수 있다.
  + 인덱스를 정한 경우
    + 빠르게 찾을 수 있다.
    + __인덱스가__ 적용된 대상을 __WHERE__ 절을 통해서 검색
  + 데이터베이스 테이블에 대한 검색 성능을 향상시키는 자료 구조이며 WHERE 절 등을 통해 활용된다. 
+ 특징
  + 인덱스는 항상 최신의 정렬상태를 유지
  + 인덱스도 하나의 데이터베이스 객체
  + 데이터베이스 크기의 약 10% 정도의 저장공간이 필요 

### 인덱스 알고리즘 
+ 페이지
  + 데이터가 저장되는 단위 (MySql 16 Kbyte)
    + MySQL 은 16 Kbyte 이는 데이터베이스 환경마다 다를 수 있다.

#### Full Table Scan
+ PPP 찾기 (SELECT)
  + ![img.png](/assets/img/elegant-tekotok/index.png)
  + 검증 과정으로는 총 3개의 페이지와 12번의 검색이 있었다.
+ Full Table Scan 특징 
  + 순차적으로 접근
  + 접근 비용 감소 
+ Full Table Scan 사용
  + 적용 가능한 인덱스가 없는 경우
  + 인덱스 처리 범위가 넓은 경우
  + 크기가 작은 테이블에 엑세스하는 경우 

#### B-Tree
+ 이해를 돕기 위해 먼저 Binary Search Tree 설명 
  + 이진 탐색 + 연결리스트의 장점이 합쳐져 만들어진 자료구조 이다.
  + ![img.png](/assets/img/elegant-tekotok/index2.png)
    + 균형 없는 이진탐색트리 시간 복잡도는 O(n) 이다. 이는 BST 의 장점을 살렸다고 볼 수 없다.
      + BST 의 단점을 극복하기 위해서 여러 자료 구조가 나왔고 그중 하나가 B-Tree(Balanced-Tree) 이다.
+ B-Tree(Balanced-Tree)
  + 트리 높이가 같음
  + 자식 노드를 2개 이상 가질 수 있다.
  + __기본 데이터베이스 인덱스 구조__
  + ![img.png](/assets/img/elegant-tekotok/index3.png)
  + PPP 찾기 (SELECT)
    + ![img.png](/assets/img/elegant-tekotok/index4.png)
  + INSERT 로 인한 페이지 분할
    + ![img.png](/assets/img/elegant-tekotok/index5.png)
    + 페이지 분할
      + 페이지에 새로운 데이터를 추가할 여유공간이 없어 페이지에 변화가 발생
      + DB가 느려지고 성능에 영향을 준다.
  + 인덱스의 DELETE
    + 인덱스의 데이터를 실제로 지우지 않고 사용안함 표시를 한다.
  + 인덱스의 UPDATE
    + 실제로 인덱스는 UPDATE(인덱스의 UPDATE) 라는 개념이 없다. 
    + DELETE (기존 값 사용안함 표시) 를 하고  INSERT (변경된 값 삽입) 를 하여 UPDATE 를 진행
  + UPDATE ,DELETE 에 INDEX 영향
    + WHERE 절로 처리할 대상을 찾기 위한 조회 성능은 향상된다.
    + 사용하지 않는 인덱스가 적용되었다면 불필요한 처리량 증가한다.
    + 사용안함 표시로 페이지 낭비 및 인덱스 조각화 심해진다.
  + 정리
    + SELECT 
      + 성능이 향상된다.
    + INSERT, UPDATE, DELETE 
      + 페이지 분할과 사용안함 표시로 인덱스의 조각화가 심해져 성능이 저하된다.

## 인덱스의 종류

### 클러스터란?
+ 클러스터 (Cluster)
  + 무리, 군집
  + 무리를 이루다

### 데이터베이스에서 클러스트링이란?
+ 클러스트링
  + 실제 데이터와 무리를 이룸
+ 논-클러스트링
  + 실제데이터와 무리를 이루지 않음
+ 클러스트링 인덱스
  + 실제 데이터와 같은 무리의 인덱스
  + ex) 실제 데이터가 정렬된 사전 
  + primary key 
+ 논-클러스트링 인덱스
  + 실제 데이터와 다른 무리의 별도의 인덱스 
  + ex) 실제 데이터 탐색에 도움을 주는 별도의 찾아보기 페이지
  + unique 제약조건

### 클러스트링 인덱스
+ 클러스트링 인덱스 추가 방법
  + ALTER TABLE member ADD CONSTRAINT pk_id PRIMARY KEY (id);
  + ALTER TABER member MODIFY COLUM id int NOT NULL; 
  ALTER TABER member ADD CONSTRAINT nuq_id UNIQUE (id);
+ ![img.png](/assets/img/elegant-tekotok/index6.png)
  + 클러스트링 인덱스를 적용하면 적용한 컬럼을 기준으로 데이터 정렬을 한다. 
  + 데이터 정렬된 기준으로 루트페이지가 생성된다. 
  + 루트페이지와 리프페이지는 B-Tree 구조로 이루어져 있다.
  + 파란색 숫자는 데이터 페이지의 주소를 의미한다.
  + 데이터 페이지
    + 실제 데이터가 저장되는 페이지를 의미  
    + 어떤 인덱스에 관련된 것이 아니라 모든 컬럼에 대한 실제 데이터를 다 담고 있는 페이지를 데이터 페이지라고 한다. 
+ 특징
  + 실제 데이터 자체가 정렬
  + 테이블당 1개만 존재가능
  + 리프 페이지가 데이터 페이지 
  + 아래의 제약조건 시 자동생성
    + primary key(우선 순위)
    + unique + not null 

### 논-클러스트링 인덱스
+ 논-클러스트링 인덱스 추가 방법
  + ALTER TABLE member ADD CONSTRAINT unq_name UNIQUE (name);
  + CREATE UNIQUE INDEX unq_idx_name ON member (name);
  + CREATE INDEX inx_name ON member (name);
+ ![img.png](/assets/img/elegant-tekotok/index7.png)
  + 실제 데이터가 저장된 데이터 페이지는 어떠한 정렬이나 변경도 일어나지 않는다. 
  + 데이터 페이지가 리프 페이지였던 크러스트링 인덱스 와는 다르게 별도의 인덱스 페이지가 추가로 생성된다. 
    + 루트페이지와 리프페이지는 B-Tree 구조로 이루어져 있다.
  + 1002 + #3
    + 1002 = 실제 데이터 페이지의 주소 
    + #3 = 1002 페이지의 세 번째에 데이터가 존재한다는 주소를 의민한다. 
+ 특징
  + 실제 데이터 페이지는 그대로
  + 별도의 인덱스 페이지 생성 -> 추가 공간 필요 
  + 테이블당 여러 개 존대
  + 리프 페이지에 실제 데이터 페이지 주소를 담고 있음 
  + unique 제약조건 적용시 자동 생성
  + 직접 index 생성시 논-클러스터링 인덱스 생성 

### 클러스트링 인덱스 + 논-클러스트링 인덱스
+ 클러스트링 인덱스와 논-클러스트링 인덱스를 함께 적용하면 ?
+ ![img.png](/assets/img/elegant-tekotok/index8.png)
  + 데이터 페이지의 주소 값이 아닌 클러스트링 인덱스가 적용된 Id 컬럼 값이 들어 있다. 
+ 데이터 페이지의 주소가 들어있지 않은 이유 
  + ![img.png](/assets/img/elegant-tekotok/index9.png)
  + 데이터가 추가되거나 삭제 될때마다 인덱스 페이지들의 주소들을 계속해서 변경해야 하는 영향을 주기 때문이다. 
+ 리프 페이지에 클러스트링 인덱스가 적용된 컬럼의 실제 값 존재 

### 인덱스 적용 기준 
+ 카디널리티(Cardinality)
  + 사전적 의미 : 그룹 내 요소의 개수 
+ 카디널리키 가 높은 것 = 중복 수치가 낮은 것 
+ WHERE, JOIN, ORDER BY 절에 자주 사용되는 컬럼
  + 인덱스는 추가 공간이 필요로 된다.
  + 조건 절이 없다면 인덱스가 사용되지 않는다. 
+ INSERT / UPDATE / DELETE 가 자주 발생하지 않는 컬럼
+ 규모가 작지 않은 테이블 

### 인덱스 사용시 주의사항 
+ 잘 사용되지 않는 인덱스는 과감히 제거하자
  + WHERE 절에 사용되더라도 자주 사용해야 가치가 있다
  + 불필요한 인덱스로 성능저하가 발생할 수 있다
+ 데이터 중복도가 높은 컬럼은 인덱스 효과가 적다
+ 자주 사용되더라도 INSERT / UPDATE / DELETE 가 자주 일어나는지 고려해야 한다
  + 일반적인 웹 서비스와 같은 온라인 트랜잭션 환경에서 쓰기와 일기 비율은 2:8 또는 1:9 이다
  + 조금 느린 쓰기를 감수하고 빠른 읽기를 선택하는 것도 하나의 방법이다 