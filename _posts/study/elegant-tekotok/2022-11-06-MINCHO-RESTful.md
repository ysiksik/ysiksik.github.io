---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 민초의 RESTful
date: '2022-11-06 00:00:01 +0900'
categories:
    - study
    - elegant-tekotok
comments: true
---

# 민초의 RESTful  
[https://youtu.be/xWA1eTPSzDE](https://youtu.be/xWA1eTPSzDE)

# 민초의 RESTful
* toc
{:toc}

## REST + -ful
+ REST의 제약을 준수했다는 의미를 가지고 있다.
+ REST: __웹__ 에서 사용하는 아키텍처 
  + 웹에 대해서 간략한 역사를 파악하자.
    + 초기의 웹: 단순함, 읽기만 
    + 진화하는 웹: 복잡함 , 읽고 + 쓰고, 고치고, 지우고 -> 전부 서버와 클라이언트 사이의 통신으로 이루어진다. 
    + 서버-클라이언트 통신 횟수가 기하 급수적으로 증가하게 된다.
      + 만약에 일괄된 통신 방식이 없다면?
        + 통신 방식이 전부 다르다면 모든 통신 방식을 알아한다.
    + 통신 방식을 하나로 통일하자는 필요성이 제기 
      + 그중에 하나로 등장것이 SOAP라는 개념이다. 
    + SOAP 를 사용하게 되면 
      + 모든 다르게 통신 했던 방식을 SOAP 하나의 방식으로 통신 할 수 있게 된다. 
    + 현재 SOAP 는 많이 사용되고 있지 않다. 
      + 이유는 어렵고, 느리고, 복잡하다 
    + 현재는? REST라는 개념이 많이 쓰인다. 

## REST (Representational State Transfer)
+ Roy Fielding 이 2000년 박사학위 논문에서 총 180페이지에 달하는 분량으로 처음으로 제시했던 개념 중 하나이다. 
+ 서버와 클라이언트 간 통신 방식 중 하나
+ 자원을 이름으로 구분하여 
+ 자원의 상태를 주고 받는다 

### 자원을 이름으로 구분하여 
+ 자원의 표현
  + REST에서는 자원을 표현할 때 URI라는 방식으로 표현을 한다.
    + Uniform Resource Identifiers
    + REST에서 자원을 구분하고 처리하기 위해 사용
    + URI를 잘 네이밍할수록 API가 직관적이고 사용하기 쉽다 
  + Singleton and Collection Resources
    + URI는 Singleton이나 Collection으로 표현한다.
    + /customer (Singleton Resource)
    + /customers (Collection Resource)
  + Collection and Sub-collection Resources
    + URI는 서브 컬렉션을 포함할 수 있다.
    + 특정 고객의 계좌?
      + /customers/{customerId}/accounts
+ URI 네이밍 규칙
  + URI 네이밍 규칙이 없다면? 
    + 일괄성이 없다. 
    + 의도를 쉽게 파악할 수 없다. 
  + URI 네이밍 규칙을 지키면?
    + 개발자들의 공용어처럼 사용할 수가 있다.
  + Use nouns to represent resources
    + 명사를 사용해서 자원을 표현한다.
    + 예외적으로 동사를 허용하는 경우, controller 역할을 하는 경우에
      + 예) /game/play에 접근 시 게임이 시작된다면?
        + 게임의 시작 여부를 컨트롤하는 URI
        + 동사 play로 표현 
  + Use forward slash (/) to indicate hierarchical relationships
    + 자원 간 계층 관계를 표현하기 위해 / (슬레시)를 사용
  + Do not use trailing forward slash (/) in URIs
    + URI 경로 마지막에는 / (슬레시)를 붙이지 않는다
  + Use hyphens (-) to improve the readability of URIs
    + 하이픈 (-) 기호를 사용하여 URI의 가독성을 향상할 수 있다. 
  + Do not use underscores(_)
    + URI에는 가급적 밑줄을 사용하지 않는다.
    + 일부 브라우저나 화면에서 글꼴에 따라 (_) 문자가 가려지거나 숨겨질 수 있다.
  + Use lowercase letters in URIs
    + URI에는 소문자를 사용한다.
  + Do not use file extensions
    + URI에 파일 확장자를 표시하지 않는다.
  + Never use CRUD function names in URIs
    + URI에 CRUD 함수의 이름을 사용하지 않는다. 
  + Use query component to filter URI collection
    + 자원의 필터링을 위해 새로운 API를 만들지 않는다.
    + 필터링을 위해 새로운 API를 만들지 않고 Query string을 이용
    + 특정 주소로 접근할 때 페이지에 대한 옵션으로 활용

### 자원의 상태를 주고 받는다
+ 자원의 상태를 주고받는 기본적인 방식은 클라이언트와 서버 간의 통신으로 이루어지는데 클라이언트가 HTTP 메서드를 보내면 서버는 HTTP 상태 코드를 통해서 정상적으로 처리되었는지 아니면 실패 했는지 여부를
알려주는 방식으로 소통을 한다.
+ HTTP 메서드
  + 자원의 상태를 주고 받기 위해 사용하는 메서드
  + 같은 URI 사용 + 다른 동작
  + CRUD 메서드의 이름을 URI에 표현하지 않을 수 있다. 
  + GET: 자원을 검색할 때 사용  
  + POST: 자원을 생성할 때 사용
  + PUT: 자원을 업데이트할 때 사용 
    + 보내지 않은 정보는 null 값으로 업데이트
  + PATCH: 자원을 업데이트할 때 사용
    + 보내지 않은 데이터는 기존 데이터를 유지 
  + DELETE: 자원을 삭제할 때 사용
+ HTTP 상태코드 
  + 1xx: 조건부 응답
  + 2xx: 성공
  + 3xx: 리다이렉션
  + 4xx: 클라이언트 오류
  + 5xx: 서버 오류
  



  