---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 플린트의 MySQL의 전문 검색 인덱스
date: '2026-05-15 00:00:23 +0900'
categories:
    - elegant-tekotok
comments: true

---

# 플린트의 MySQL의 전문 검색 인덱스
[https://youtu.be/FTC58pJZEYo?si=RtfFd4qMzkv4Kv0I](https://youtu.be/FTC58pJZEYo?si=RtfFd4qMzkv4Kv0I)

# 플린트의 MySQL의 전문 검색 인덱스  
* toc
{:toc}

---


# MySQL 전문 검색(Full-Text Search)이란 무엇인가

MySQL에서 게시글 제목이나 본문 검색 기능을 만들 때 가장 먼저 떠오르는 방식은 보통 `LIKE` 검색이다.

예를 들면 다음과 같다.

```sql
SELECT *
FROM articles
WHERE title LIKE '%스프링%';
```

처음에는 간단하고 잘 동작해 보인다.
하지만 데이터가 많아지고 실제 서비스 환경으로 가면 다음과 같은 문제가 발생한다.

* 검색 속도가 매우 느려짐
* 특정 단어가 검색되지 않음
* 띄어쓰기 차이 때문에 검색 누락 발생
* Full Table Scan 발생

이러한 문제를 해결하기 위해 MySQL은 **전문 검색(Full-Text Search)** 기능을 제공한다.

---

# LIKE 검색의 한계

## 1. 성능 문제

LIKE 검색은 와일드카드 위치에 따라 성능 차이가 매우 크다.

---

## 인덱스를 사용할 수 있는 경우

```sql
SELECT *
FROM article
WHERE title LIKE 'spring%';
```

이 경우는 `"spring"` 으로 시작하는 범위를 인덱스에서 바로 찾을 수 있다.

즉:

```text
springA
springB
springboot
```

처럼 정렬된 범위를 빠르게 탐색 가능하다.

---

## 인덱스를 사용할 수 없는 경우

하지만 대부분 실제 검색은 다음 형태다.

```sql
SELECT *
FROM article
WHERE title LIKE '%spring%';
```

이 경우 문제는:

```text
앞에 무엇이 올지 알 수 없음
```

이다.

즉 인덱스의 정렬 구조를 사용할 수 없다.

결국 MySQL은:

```text
Full Table Scan
```

을 수행하게 된다.

---

## 왜 Full Table Scan이 위험한가

예를 들어 데이터가 100만 건이라면:

```text
1건씩 전부 검사
→ 문자열 비교 수행
→ CPU 증가
→ 디스크 I/O 증가
→ 응답 지연
```

이 발생한다.

실제 서비스에서는 P99 응답 시간이 급격히 증가할 수 있다.

---

# LIKE 검색의 정확도 문제

LIKE 검색은 단순 문자열 비교다.

즉:

```text
완전히 일치해야 함
```

이라는 문제가 있다.

---

## 예시

데이터:

```text
전문 검색 질문입니다
```

검색:

```sql
LIKE '%전문 검색%'
```

→ 검색 성공

---

하지만:

```sql
LIKE '%전문검색%'
```

→ 검색 실패

띄어쓰기 하나 때문에 검색되지 않는다.

---

# Full-Text Search란 무엇인가

MySQL 전문 검색은:

```text
단어와 의미 기반 검색
```

을 수행하는 기능이다.

단순 문자열 비교가 아니라:

* 단어 분석
* 토큰화
* 역인덱스
* 관련성 점수

를 활용한다.

---

# 전문 검색의 핵심 원리

전문 검색은 크게 두 단계로 동작한다.

```text
1. 텍스트 분석
2. 역인덱스 저장
```

---

# 1. 텍스트 분석 — N-Gram

MySQL 전문 검색은 한국어 환경에서 보통:

```text
N-Gram
```

방식을 많이 사용한다.

---

## N-Gram이란

문장을 N글자 단위로 분해하는 방식이다.

예를 들어:

```text
안녕하세요
```

를 2-Gram으로 분해하면:

```text
안녕
녕하
하세
세요
```

처럼 나뉜다.

---

# 왜 N-Gram이 중요한가

한국어는 띄어쓰기와 형태 변화가 많다.

예를 들어:

```text
전문검색
전문 검색
```

처럼 띄어쓰기 여부가 달라도 검색 가능해야 한다.

N-Gram은 기계적으로 잘라 저장하기 때문에 이런 문제를 해결할 수 있다.

---

# N-Gram 상세 동작 과정

예시:

```text
전문 검색 기능
```

---

## 1단계 — 공백 분리

```text
전문
검색
기능
```

---

## 2단계 — N글자 단위 분리

2-Gram 기준:

```text
전문
문검
검색
```

같은 토큰 생성 가능하다.

---

# 역인덱스(Inverted Index)

전문 검색의 핵심 성능 비밀이다.

---

## 일반 인덱스 vs 역인덱스

일반 인덱스:

```text
문서 → 단어
```

역인덱스:

```text
단어 → 문서
```

---

## 예시

```text
문서1 : 전문 검색
문서2 : 전문 기능
```

역인덱스:

```text
전문 → [1,2]
검색 → [1]
기능 → [2]
```

즉 `"전문"` 검색 시:

```text
바로 문서 1,2 반환 가능
```

하다.

---

# Full-Text Search 사용 조건

MySQL에서 전문 검색을 사용하려면 조건이 있다.

---

## 지원 버전

```text
MySQL 5.7.6 이상
```

---

## 지원 스토리지 엔진

```text
InnoDB
MyISAM
```

---

## 지원 타입

```text
CHAR
VARCHAR
TEXT
```

문자 타입만 가능하다.

---

# Full-Text Index 생성 방법

전문 검색을 사용하려면 반드시:

```text
FULLTEXT INDEX
```

를 생성해야 한다.

---

## 기본 생성 예시

```sql
CREATE FULLTEXT INDEX idx_title
ON article(title);
```

---

## N-Gram 사용 시

```sql
CREATE FULLTEXT INDEX idx_title
ON article(title)
WITH PARSER ngram;
```

`WITH PARSER ngram` 을 반드시 명시해야 한다.

---

# MATCH AGAINST 문법

전문 검색은 일반 WHERE LIKE가 아니라:

```sql
MATCH(column)
AGAINST(keyword)
```

문법을 사용한다.

---

## 예시

```sql
SELECT *
FROM article
WHERE MATCH(title)
AGAINST('스프링');
```

이 문법을 사용해야 FullText Index가 적용된다.

---

# 실제 성능 비교

발표에서 진행한 테스트:

```text
데이터 100만 건
```

---

## LIKE 검색

```text
1.044초
```

---

## MATCH AGAINST

```text
0.856초
```

약 18% 성능 향상이 있었다.

---

# 존재하지 않는 키워드 검색

더 큰 차이가 난다.

---

## LIKE

```text
0.892초
```

---

## MATCH AGAINST

```text
0초 수준
```

역인덱스를 통해 존재 여부를 즉시 판단 가능하기 때문이다.

---

# 자연어 모드(Natural Language Mode)

전문 검색은 단순 검색만 하지 않는다.

관련성 점수 기반 정렬도 가능하다.

---

## 관련성 점수란

문서와 검색어 간의 연관도다.

다음 요소를 고려한다.

```text
등장 빈도
희귀성
중요도
```

---

## 특징

ORDER BY 없이도:

```text
가장 관련성 높은 결과 우선 반환
```

가능하다.

---

# Boolean Mode

조건 기반 검색도 가능하다.

---

## AND 검색

```sql
MATCH(title)
AGAINST('+스프링 +JPA'
IN BOOLEAN MODE);
```

→ 둘 다 포함

---

## NOT 검색

```sql
MATCH(title)
AGAINST('+스프링 -JPA'
IN BOOLEAN MODE);
```

→ 스프링 포함 + JPA 제외



---

# 전문 검색의 한계점

Full-Text Search도 만능은 아니다.

---

# 1. 비실시간 인덱스 갱신

트랜잭션 Commit 이전에는:

```text
FullText Index 반영 안됨
```

즉:

```sql
INSERT
→ 아직 검색 안됨
COMMIT
→ 검색 가능
```

상황이 발생할 수 있다.

---

# 2. 쓰기 부하 증가

N-Gram은 토큰을 엄청 많이 생성한다.

예시:

```text
100만 건 데이터
→ 728만 토큰 생성
```

즉 인덱스 저장 비용이 커진다.

---

# Full-Text Search가 적합한 상황

다음과 같은 경우 매우 효과적이다.

```text
게시글 검색
블로그 검색
문서 검색
채팅 검색
상품 검색
```

특히:

```text
부분 문자열 검색
띄어쓰기 유연성
관련도 기반 검색
```

이 필요할 때 강력하다.

---

# 하지만 Elasticsearch와 비교하면?

MySQL Full-Text는 가볍고 간단하다.

하지만:

* 형태소 분석
* 복잡한 랭킹
* 대규모 검색
* 오타 교정
* 자동완성

같은 고급 기능은 Elasticsearch가 훨씬 강력하다.

즉:

```text
간단 검색 → MySQL FullText
대규모 검색 플랫폼 → Elasticsearch
```

구조로 많이 사용한다.

---

# 정리

LIKE 검색은:

```text
성능 한계
정확도 한계
Full Table Scan 위험
```

이 존재한다.

반면 MySQL Full-Text Search는:

```text
N-Gram 분석
역인덱스
관련성 점수
```

를 활용해 훨씬 빠르고 정확한 검색을 제공한다.

특히:

```text
MATCH AGAINST
FULLTEXT INDEX
```

를 통해 검색 성능을 크게 향상시킬 수 있다.

다만:

```text
비실시간 인덱스 갱신
쓰기 부하 증가
```

같은 특성도 반드시 고려해야 한다.

