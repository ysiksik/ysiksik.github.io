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

## 함수형 인터페이스와 람다 표현식 소개

### JAVA 가 기본으로 제공하는 함수형 인터페이스
+ [java.util.function 패키지](https://docs.oracle.com/javase/8/docs/api/java/util/function/package-summary.html)
  + 자바에서 미리 정의해둔 자주 사용할 만한 함수 인터페이스
    + Function<T, R>
    + BiFunction<T, U, R>
    + Consumer<T>
    + Supplier<T>
    + Predicate<T>
    + UnaryOperator<T>
    + BinaryOperator<T>

### Function<T, R>
+ T 타입을 받아서 R 타입을 리턴하는 함수 인터페이스
  + R apply(T t)
+ 함수 조합용 메소드
  + andThen
  + compose

~~~java

Function<Integer, Integer> plus = (i) -> i + 10;
System.out.println(plus.apply(2)); //12
        
// compose : plus 하기 전에 multiply 하고 plus 하겠다 

// 방법 1         
Function<Integer, Integer> multiply = (i) -> i * 2;
System.out.println(plus.compose(multiply).apply(2)); //14

// 방법 2
Function<Integer, Integer> multiplyNextPlus = plus.compose(multiply);
System.out.println(multiplyNextPlus.apply(2));//14

// andThen : plus 하고 multiply 하겠다
// 방법 1         
Function<Integer, Integer> multiply = (i) -> i * 2;
System.out.println(plus.andThen(multiply).apply(2)); //24

// 방법 2
Function<Integer, Integer> multiplyNextPlus = plus.compose(multiply);
System.out.println(multiplyNextPlus.apply(2));//24

~~~

### BiFunction<T, U, R>
+ 두개의 값(T, U)를 받아서 R 타입을 리턴하는 함수 인터페이스
  + R apply(T t, U u)

### Consumer<T>
+ T 타입을 받아서 아무값도 리턴하지 않는 함수 인터페이스
  + void Accept(T t)
+ 함수 조합용 메소드
  + andThen

~~~java

Consumer<String> print = (s) -> System.out.println(s);
print.accept("Hello");

~~~

### Supplier<T>
+ T 타입의 값을 제공하는 함수 인터페이스
  + T get
+ 받지 않고 받아올 타입을 정의하는 것이다.

~~~java

Supplier<String> supplier = () -> "Hello";
System.out.println(supplier.get());

~~~


### Predicate<T>
+ T 타입을 받아서 boolean 을 리턴하는 함수 인터페이스
  + boolean test(T t)
+ 함수 조합용 메소드
  + And
  + Or
  + Negate

~~~java

Predicate<String> isEmpty = (s) -> s.isEmpty();
System.out.println(isEmpty.test(""));

~~~

### UnaryOperator<T>
+ Funcion<T, R>의 특수한 형태로, 입력값 하나를 받아서 동일한 타입을 리턴하는 함수 인터페이스
+ 입력하는 타입과 리턴하는 타입이 같을 때

~~~java

UnaryOperator<Integer> plus = (i) -> i + 10;
System.out.println(plus.apply(2));

~~~

### BinaryOperator<T>
+ BiFunction<T, U, R>의 특수한 형태로, 동일한 타입의 입력값 두개를 받아 리턴하는 함수 인터페이스
+ 세개의 타입이 전부 같을 때