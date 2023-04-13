---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 포키의 Parameter와 Argument
date: '2023-04-13 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 포키의 Parameter와 Argument
[https://youtu.be/fW1WGmj10rA](https://youtu.be/fW1WGmj10rA)

# 포키의 Parameter와 Argument
* toc
{:toc}

## Parameter의 정의
+ parameter는 우리말로 매개 변수라고 직역
+ 함수 등 서브루틴의 input으로 제공되는 여러 데이터 중 하나를 가리키기 위해 사용되는 변수의 한 종류
+ 여러 데이터 중 하나를 가리킨다는 말은 함수 내부에서 각각의 값이 어떻게 사용되어야 할지 명확하게 해준다는 것을 의미하고 다시 말하면 해당 값이 함수 내에서 어떤 역할을 할지 그 역할에 대한 정의이다

## Argument의 정의
+ 일반적인 의미에서 argument란 어떤 논리의 근거를 의미한다
+ 수학에서 argument라고 하면 함수의 결과를 얻기 위해 제공되어야만 하는 각 함수의 인수를 의미한다
+ 프로그래밍에서 말하는 argument는 전달 인자라고 번역 되고 프로그램, 서브루틴 또는 함수 간의 전달되는 값을 의미


## Parameter와 Argument의 차이
+ parameter는 나눗셈 연산에 필요한 제수 그리고 피제수라는 역할 그 자체가 parameter이다
+ 자바에서는 이를 parameter 변수를 선언해서 정의해주게 된다
+ 그리고 제수와 피제수 이 역할에 쓰여서 연산 결과를 결정할 수 있게 해준 2 그리고 4라는 각각의 값이 argument가 된다, 프로그램에서는 이 값을 parameter 변수에다가 전달해 주게 된다
+ 메서드 선언부에서 정의한 변수를 가리킬 때는 parameter
+ 메서드 호출부에서 전달해 주는 값을 의미할 때는 argument


## JAVA의 Parameter와 Argument
+ 자바에서는 argument가 parameter에게 그대로 전달되지 않는다 복사해서 전달한다 
+ 자바에서는 원시 자료형을 제외한 모든 자료형이 참조 변수이다 참조 변수는 객체가 살고 있는 주소를 값으로 가지기 때문에
  참조 변수끼리 값을 복사한다는 것은 이 객체의 주소값을 복사한다는 것이고 이것은 곧 두 변수가 한 객체를 가리키게 됨을 의미 한다

## 정리
+ parameter는 역할에 대한 정의를 위해 선언하는 변수
+ argument는 연산의 근거를 제공하기 위해 전달되는 값을 의미
+ 선언부엔 parameter, 호출부엔 argument
+ 그리고 자바에서는 parameter에게 argument의 값을 전달할 때 오직 값 복사를 통해서만 전달
