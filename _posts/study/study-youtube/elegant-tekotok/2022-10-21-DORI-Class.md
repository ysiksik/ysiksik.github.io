---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 도리의 Class
date: '2022-10-21 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 도리의 Class  
[https://youtu.be/HujbNZ9IWF8](https://youtu.be/HujbNZ9IWF8)

# 도리의 Class
* toc
{:toc}

## Class?
+ 클래스는 객체 지향 프로그래밍에서 특정 __객체(instance)__ 를 생성하기 위해 변수와 메소드를 정의하는 일종의 틀로, 객체를 정의하기 위한 상태(멤버변수)와 메서드(method)로 구성된다. 

### 상속 
+ ![img.png](/assets/img/elegant-tekotok/inheritance.png)

## 자바스크립트의 클래스 
+ 생긴지 얼마 안 됐다. 
+ 원래는 자바스크립트에 클래스가 존재하지 않았다. 
+ 프로토타입을 사용해서 클래스를 흉내 낼 순 있었다. 
  + 매우 복잡하고 어렵다.
+ ES6에 클래스가 등장 하였다.
  + 프로토타입 기반의 객체지향을 버리고 클래스 기반으로 변경한 것이 아니라 프로토타입을 기반으로 하는 클래스 형을 추가한 것에 불과하다. 
  + 클래스를 객체를 생성하는 새로운 메커니즘이라고 생각하면 좋다.

### 자바스크립트의 클래스 문법 
+ ![img.png](/assets/img/elegant-tekotok/JavascriptClass.png)
  + 클래스는 class 키워드를 용하여 클래스를 생성한다.
  + 클래스 이름은 파스칼케이스를 사용하는 것이 일반적이다.
  + 클래스 바디는 0개 이상의 메서드를 정의할 수 있다. 
  + 바디의 내부는 strict 모드로 동작한다.
  + method 로는 constructor(성성자), 프로토타입 메서드, 정적 메서드가 가능하다.
  + 인스턴스를 생성할 때는 생성자 함수와 동일하게 new 키워드를 사용한다.
  + constructor(성성자)
    + class 로 객체를 생성하고 초기화하기 위한 메서드 암묵적으로 this. 인스턴스를 반환하기 때문에 내부에 return 문이 있으면 안 된다. 
    + 바디에는 최대 한 개의 constructor 가 정의될 수 있으며  만약에 이를 정의하지 않을 시 암시적으로 빈 constructor 가 정의된다. 
  + 프로토타입 메서드
    + class body 에서 정의한 메서드 
  + static 메서드
    + 인스턴스를 생성하지 않아도 호출할 수 있는 메서드 Person.iamHuman()

### 자바스크립트의 클래스 상속
+ ![img.png](/assets/img/elegant-tekotok/JavascriptClass2.png)
  + 상속은 extends 키워드를 사용해서 정의한다. 기존의 클래스를 상속하여 넓혀서 새로운 클래스를 정의한다는 의미를 띄고 있다.
  + super
    + super class 의 constructor 를 호출
    + super 를 참조하여 super class 의 메서드를 호출 
    + 서브 클래스의 constructor 에서 this 키워드를 사용하기 전에만 사용 가능핟. 
    + super 참조
      + ![img.png](/assets/img/elegant-tekotok/JavascriptClass3.png)
        + 상위 클래스의 메서드 전체를 교체하지 않고. 상위 메스드를 토대로 일부 기능만 변경하고 싶을 때
  + ![img.png](/assets/img/elegant-tekotok/JavascriptClass4.png)
    + 클래스는 함수의 한 종류이다.
    + 함수 선언과 동일하게 런타임 이전에 선언되어 함수 객체가 생성되게 된다. 
  + ![img.png](/assets/img/elegant-tekotok/JavascriptClass5.png)
    + 클래스로 생성된 함수는 생성자 함수로 constructor 이다. 
    + 생성자 함수는 선언될 때 프로토타입이 자동으로 생성되게 된다. 
    + 클래스는 let, const 와 동일하게 호이스팅이 발생하여 일시적 사각지대 TDZ 에 빠지게 되어 호이스팅이 발생하지 않은 것처럼 보이게 된다. 

### Class 의 instance 생성 과정 
+ ![img.png](/assets/img/elegant-tekotok/JavascriptClass6.png)
  + 상속 클래스의 생성자 함수는 빈 객체를 만들고 this에 이 객체를 할당하는 일을 부모 클래스의 생성자가 처리해주길 기대
    + this 를 사용하기 전에 super 키워들 꼭 사용해야 한다. 

### 도식화 
+ ![img.png](/assets/img/elegant-tekotok/JavascriptClass7.png)
  + 크루가 Person 을 extends 하는 것은 크루의 프로토타입의 __proto__ 를 Person 의 프로토타입에 연결하는 거와 같다 

## 위임
+ ![img.png](/assets/img/elegant-tekotok/JavascriptClass8.png)
  + 자바스크립트의 클래스는 복사가 아닌 연결이 되어 있다.
+ ![img.png](/assets/img/elegant-tekotok/JavascriptClass9.png)
  + 상속은 sub 클래스가 super 클래스를 복사해서 생성하게 된다. 따라서 시작점이 다르게 되어 서로 다른 클래스가 되는 것이다. 
  그리고 이의 인스턴스들도 클래스를 복사하여 생성하기 때문에 서로 연관관계가 없다. 
  + 위임은 super 클래스가 sub 클래스를 포함하고 각각의 인스턴스들도 각각의 클래스에 연관관계가 있다. 그래서 자바스크립트에서는 위임이라는 단어가 더 적절하다. 

## 믹스인(Mixin) 복사를 흉내 내 보자
+ 자바스크립트의 객체는 서로 연결되어 있다. 그래서 복사를 흉내내기 위해 믹스인이라는 방법을 사용하기도 한다. 이를 통해서 다양한 클래스의 메서드를 상속해서 쓸 수 도 있다. 
+ 프로토 타입 사용
  + ![img.png](/assets/img/elegant-tekotok/JavascriptClass10.png)
+ assign 사용 
  + ![img.png](/assets/img/elegant-tekotok/JavascriptClass11.png)
+ 직접 믹스인 function 을 만들어 복사 하는 방법 
  + ![img.png](/assets/img/elegant-tekotok/JavascriptClass12.png)
+ 하지만 이를 완전한 복사라고 볼 수 없다. 완전한 복사는 불가능하다. 
+ ![img.png](/assets/img/elegant-tekotok/JavascriptClass13.png)
  + Car 도 결론적으로 object 이기 때문에 프로토타입으로 iAmDory 를 호출하게 된다.
  + 이처럼 자바스크립트에서 클래스는 프로토타입과 매우 연관이 많다. 
