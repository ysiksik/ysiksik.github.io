---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 파랑, 아키의 리플렉션
date: '2022-09-10 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 파랑, 아키의 리플렉션
[https://youtu.be/67YdHbPZJn4](https://youtu.be/67YdHbPZJn4)

# 파랑, 아키의 리플렉션
* toc
{:toc}

## 리플렉션이란?
+ 스프링은 어떻게 __실행시점__ 에 빈을 주입할 수 있는 걸까?
+ JPA의 Entity는 왜 꼭 __기본 생성자__ 를 가져야만 할까 ?
+ 자바 세상에서는 실체는 Class 이고 거울은 JVM 메모리 영역이다.
+ ![img.png](/assets/img/elegant-tekotok/reflection.png)
  + 클레스 데이터는 메소드 영역에 인스턴스 정보는 힙 영역에 저장된다.
+ 리슬렉션 기능을 지원하지 않는 언어도 있다.
  + C, C++, Pascal

## 리플렉션의 기능
+ 리플렉션의 기본은 Class
 

### Class
+ Class 는 실행중인 자바 어플리케이션의 클래스와 인터페이스의 정보를 가진 클래스
+ public 생성자가 존재하지 않는다.
+ Class 객체는 JVM에 의해 자동으로 생성된다.

### Class 기능들
+ 클래스에 붙은 어노테이션 조회
+ 클래스 생성자 조회
+ 클래스 필드 조회
+ 클래스 메서드 조회
+ 부모 클래스, 인터페이스 조회
+ 등등

### Class 가져오기

1. {클래스 타입}.class

~~~java

Class<?> clazz = Test.class; 

~~~

2. {인스턴스}.getClass()

~~~java

Test test = new test("test");
Class<?> clazz = test.getClass();

~~~

3.Class.forName("{전체 도메인 네임}")

~~~java

Class<?> clazz = Class.forName("org.test.Test");

~~~

### Class의 메서드 사용 시 주의점
+ getXXX 와 getDeclaredXXX를 잘 구분해서 사용해야 한다.
+ getMethods
  + 상위 클래스와 상위 인터페이스에서 상속한 메서드를 포함하여 public인 메서드를 모두 가져온다.
+ getDeclaredMethods
  + 접근 제어자와 관계 없이 상속한 메서드를 제외하고 직접 클래스에서 선언한 메서들을 모두 가져온다.


### 생성자를 통한 객체 생성 
+ 생성자의 파라미터로 구분하여 클래스에 선언된 생성자를 가져올 수 있다.

~~~java

Class<?> clazz = Class.forName("org.test.Test");
        
Constructor<?> constructor1 = clazz.getDeclaredConstructor();
Constructor<?> constructor2 = clazz.getDeclaredConstructor(String.class);
Constructor<?> constructor3 = clazz.getDeclaredConstructor(String.class, int.class);

Object test = constructor1.newInstance(); //생성자의 접근제어자가 private 라서 접근이 불가

~~~

+ 접근제어자가 public이 아닌 경우 setAccessible 메서드를 이용하면 접근할 수 있다.

~~~java

constructor1.setAccessible(true);
Object test = constructor1.newInstance();
Object test = constructor2.newInstance("test");
Object test = constructor3.newInstance("test", 5);

~~~

### 필드 정보 조회
+ 필드의 접근제어자, 타입, 네임, 값 등의 정보를 조회할 수 있다.

~~~java

Object test = constructor3.newInstance("test", 5);

Field[] fields = clazz.getDeclaredFields();

for(Field field : fields){

    field.setAccessible(true);
    System.out.println(field);
    System.out.println("value : " + field.get(test));
    
}

~~~

### 필드 값 변경
+ private 필드의 값도 변경할 수 있다.

~~~java

Field field = clazz.getDeclaredField("name");
field.setAccessible(true);
System.out.println("기존 : " + field.get(test));
field.set(test, "test2")
System.out.println("변경 : " + field.get(test));

~~~

### 메서드 정보 조회
+ 메서드의 접근제어자, 리턴 타입, 네임, 파라미터 타입, 등의 정보를 가져올 수 있다.

~~~java

Method[] methods = clazz.getDeclaredMethods();
for(Method method : methods){
        method.setAccessible(true);
        System.out.println(method);
}

~~~

### 메서드 호출
+ private 메서드도 호출할 수 있다.

~~~java

Method method = clazz.getDeclaredMethod("testing", String.class, int.class);
method.setAccessible(true);
method.invoke(dog, "test", 5)

~~~

## 리플렉션이 사용되는 곳
+ 리플렉션을 평소에 사용할 일이 없다 보니 생소할 수 있는데 실은 정말 많은 곳에서 사용되고 있다.

### 리플렉션을 왜 쓸까?
+ 리플렉션은 주로 프레임워크나 라이브러리에서 많이 사용한다.
  + 우리가 직접 코딩을 할때는 객체의 타입을 모르는 일이 거의 없다. 프레임워크나 라이브러리에서는 사용자가 생성한 객체가 어떤 타입인지 컴파일 시점까지는 알 수가 없다. 이러한 문제를 동적으로 해결하기 위해 리플렉션을 사용

### 리플렉션이 사용되는 곳
+ JPA
+ Jackson
+ Mockito
+ JUnit
+ 인텔리제이의 자동완성 기능

### 많은 프레임워크나 라이브러리에서는 객체에 __기본생성자__ 가 왜 필요할까?
+ 기본 생성자로 객체를 생성하고, 필드를 통해 값을 넣어주는 것이 __가장 간단한 방법__ 이기 때문이다.
+ 기본 생성자가 없다면 생성자의 종류가 많은 경우 어떤 생성자를 사용할지 고르기 어렵다.
+ 생성자에 로직이 있는 경우 원하는 값을 바로 넣어줄 수 없다.
+ 파라미터들의 타입이 같은 경우 필드와 이름이 다르면 값을 알맞게 넣어주기 힘들다.

### 어노테이션
1. 리플렉션을 통해 클래스나 메서드, 파라미터 정보를 가져온다.
2. 리플렉션의 getAnnotation(s), getDeclaredAnnotation(s) 등의 메서드를 통해 원하는 어노테이션이 붙어 있는지 확인한다. 
3. 어노테이션이 붙어 있다면 원하는 로직을 수행한다.

## 리플렉션의 단점
+ 일반 메서드 호출보다 성능이 훨씬 떨어진다.
  + Reflection API 는 컴파일 시점이 아니라 런타임 시점에서 클래스를 분석한다.
    + JVM을 최적화할 수 없기 때문에 성능저하 발생
  + 메서드 호출을 10만번 반혹한 결과
    + 일반메서드 호출시 : 7ms
    + 리플렉션을 사용했을 경우 : 170ms
    + 24배 차이가 발생 했다.
+ 컴파일 시점에서 타입 체크 기능을 사용할 수 없다.
  + 리플렉션은 런타임 시점에 클래스 정보를 알게 된다.
+ 코드가 지저분하고 장황해진다.
+ 내부를 노출해서 추상화를 파괴한다.
  + 리플렉션을 사용하면 접근할 수 없는 필드나 메서드에도 접근이 가능하고 , 모든 클래스의 정보를 알게 된다.
    + 추상화를 파괴하고 따라서 불변성 또한 지킬 수가 없게 된다.
