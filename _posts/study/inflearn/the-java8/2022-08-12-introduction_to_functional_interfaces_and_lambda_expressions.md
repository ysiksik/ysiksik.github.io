---
layout: post
bigtitle: '더 자바, Java 8'
subtitle: 함수형 인터페이스와 람다 표현식
date: '2022-08-12 00:00:01 +0900'
categories:
    - study
    - inflearn
    - the-java8
comments: true
---

# 함수형 인터페이스와 람다 표현식

# 함수형 인터페이스와 람다 표현식
* toc
{:toc}

## 함수형 인터페이스와 람다 표현식 소개

### 함수형 인터페이스 (Functional Interface)
+ 추상 메소드를 딱 하나만 가지고 있는 인터페이스
  + 인터페이스 안에 static, default 메소드가 있어도 함수형 인터페이스 ( 중요한건 추상 메소드의 수 )
+ SAM (Single Abstract Method) 인터페이스
+ @FuncationInterface 어노테이션을 가지고 있는 인터페이스
  + JAVA가 제공
  + 함수형 인터페이스를 견고하게 관리할 수 있다.
+ java 8 이전 

~~~java
        // 익명 내부 클래스 anonymous inner class
        RunSomething runSomething = new RunSomething() {
            @Override
            public int doIt(int number) {
                return 0;
            }
        };

~~~

+ java 8 이후

~~~java

    RunSomething runSomething2 = number -> 0;

~~~

+ 함수를 정의한 것처럼 보이긴 하지만 실질 적으로 자바에서는 특수한 형태의 object로 본다.

### 람다 표현식 (Lambda Expressions)
+ 함수형 인터페이스의 인스턴스를 만드는 방법으로 쓰일 수 있다.
+ 코드를 줄일수 있다.
+ 매소드 매개변수, 리턴 타입, 변수로 만들어 사용할 수도 있다.

### 자바에서 함수형 프로그래밍
+ 함수를 First class object 로 사용 할 수 있다.
+ 순수 함수 (Pure function)
  + 사이드 이팩트가 없다. (함수 밖에 있는 값을 변경하지 않는다.)
  + 상태가 없다. (함수 밖에 있는 값을 사용하지 않는다.)
  + 입력받은 값이 동일할 경우 값이 같아야 한다.
  
~~~java

        int baseNumber = 10; // 함수의 밖
        RunSomething runSomething = new RunSomething() {
            int baseNumber = 10; // 함수의 밖
            @Override
            public int doIt(int number) {
                return number + baseNumber;
            }
        };

~~~

~~~java

        int baseNumber = 10; // 함수의 밖
        RunSomething runSomething = number -> number + baseNumber;
        
        baseNumber++; // 변경 불가 하다. 컴파일 에러 발생
        
        // 이렇게 사용 할 경우 baseNumber 값 변경 불가 final 이라고 생각하고 사용.

~~~

+ 고차 함수 (Higher-Order Function)
  + 함수가 함수를 매개변수로 받을 수 있고 함수를 리턴할 수도 있다.
+ 불변성