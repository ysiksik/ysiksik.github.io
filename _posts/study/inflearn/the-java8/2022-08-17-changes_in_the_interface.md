---
layout: post
bigtitle: '더 자바, Java 8'
subtitle: 인터페이스의 변화
date: '2022-08-17 00:00:00 +0900'
categories:
    - study
    - inflearn
    - the-java8
comments: true
---

# 인터페이스의 변화

# 인터페이스의 변화
* toc
{:toc}


## 인터페이스 기본 메소드와 스태틱 메소드

### 기본 메소드(Default Method)
+ 인터페이스에 메소드 선언이 아니라 구현체를 제공하는 방법이다.
+ 해당 인터페이스를 구현한 클래스를 깨트리지 않고 새 기능을 추가할 수 있다.
+ 기존 메소드는 구현체가 모르게 추가된 기능으로 그만큼 리스크가 있다.
  + 컴파일 에러는 아니지만 구현체에 따라 런타임 에러가 발생할 수 있다.
  + 반드시 문서화 해야한다. (@implSpec 자바독 태그 사용)
+ Object가 제공하는 기능 (equals,hashCode)는 기본 메소드로 제공할 수 없다.
  + 구현체가 재정의해야 한다.
+ 본인이 수정할 수 있는 인터페이스에만 기본 메소드를 제공할 수 있다.
+ 인터페이스를 상속받은 인터페이스에서 다시 추상 메소드로 변경 할 수 있다.
+ 인터페이스 구현체가 재정의 할 수도 있다.
+ 두 개를 상속받을 때 디폴트 메서드가 충돌 난 경우는 직접 오버라이딩 해야 한다.  

### 스태틱 메소드
+ 해당 타입 관련 헬퍼 또는 유틸리티 메소드를 제공할 때 인터페이스에 스태틱 메소드를 제공할 수 있다.

### Default Method Vs Abstract Class
+ Default Method
  + 상수만 사용할 수 있기 때문에 추상클래스보다 변수사용에 있어서 제한적이다.
  + private, protected, public 접근제어자를 사용할 수 없다.
  + 생성자가 없어서 생성시에 초기화해주는 작업이 필요한 경운에는 적합하지 않다.


## 자바 8 API의 기본 메소드와 스태틱 메소드
+ 자바 8 에서 추가한 기본 메소드로 인한 API 변화

+ Iterable의 기본 메소드
  + forEach()
  + spliterator()
+ Collection의 기본 메소드
  + stream() / parallelStream()
  + removeIf(Predicate)
  + spliterator()
+ Comparator의 기본 메소드 및 스태틱 메소드
  + reversed()
  + thenComparing(Comparator)
  + static reverseOrder() / naturalOrder()
  + static nullsFirst() / nullsLast()
  + static comparing()