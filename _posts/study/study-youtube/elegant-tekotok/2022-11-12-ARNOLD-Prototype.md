---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 아놀드의 프로토타입 뽀개기
date: '2022-11-12 00:00:01 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 아놀드의 프로토타입 뽀개기
[https://youtu.be/TqFwNFTa3c4](https://youtu.be/TqFwNFTa3c4)

# 아놀드의 프로토타입 뽀개기
* toc
{:toc}

## 프로토타입이란?
+ 자바스크립트의 모든 객체는 자신의 부모 역할을 담당하는 객체와 연결되어 있는데 이 부모 객체를 프로토타입이라고 한다. 
+ 코드와 그림을 통해 알아보자
  + ![img.png](/assets/img/elegant-tekotok/ARNOLD-Prototype.png)
    + crew는 Object 생성자 함수에 의해 생성된다. 
    + crew는 crew.__proto__라는 내부 링크를 통해 Object 생성자 함수가 미리 가지고 있던 Object.prototype과 연결이 된다. 
    + Object.prototype을 프로토타입 객체라고 한다.
    
## 프로토타입 체인 
+ ![img.png](/assets/img/elegant-tekotok/ARNOLD-Prototype2.png)
  + array 에는 hawOwnProperty 메서드가 없다. 
  + 어떤 객체에 특정 프로퍼티나 메서드에 접글할 때 특정 프로퍼티나 메서드가 없다면 내부 링크를 통해 상위 프로토타입으로 접근하는 행위를 프로토타입 체인이라고 한다.
  + ![img.png](/assets/img/elegant-tekotok/ARNOLD-Prototype3.png)
    + 자바스크립트의 모든 객체의 프로토타입 Object.prototype에서 끝나게 된다.   
    + Object.prototype은 프로토타입 체인의 종점이라고 한다.
    
## constructor 프로퍼티
+ 자신을 생성한 생성자 함수를 가리키는 역할을 한다. 
+ ![img.png](/assets/img/elegant-tekotok/ARNOLD-Prototype4.png)
+ crew.constructor은 프로토타입 체인을 통해 crew.__proto__.constructor 를 가르키게 되어 Object를 가르킨다.

## Function.prototype 과 (function() {}).prototype
+ ![img.png](/assets/img/elegant-tekotok/ARNOLD-Prototype5.png)
+ ![img.png](/assets/img/elegant-tekotok/ARNOLD-Prototype6.png)
  + Crew 생저자 함수를 통해 만든 객체들 에게 공통으로 공유할 수 있는 공간을 지원해주기 위해서 함수 객체는 프로토타입 프로퍼티를 가지고 생성이된다. 
  + 공통 변수 선언 및 메모리 절약의 이점을 가질 수 있다.
  
## Object.__proto__ 는 무엇일까?
+ ![img.png](/assets/img/elegant-tekotok/ARNOLD-Prototype7.png)
  + Object도 결국엔 Object.prototype을 가지는 함수 객체이다. 
  + Function 생성자 함수에 의해 생성이 되었다는 뜻이다.
  + Object.__proto__는 Function.prototype을 가리키게 된다.
  
## Function.prototype.__proto__ 는 무엇일까?
+ ![img.png](/assets/img/elegant-tekotok/ARNOLD-Prototype8.png)
  + Object.prototype이다.
  + Function.prototype도 결국엔 Object 생성자 함수에 의해 생성된 객체이기 때문이다.
  
## class와 prototype의 차이 
+ 클래스는 객체를 생성하려면 설계도 즉, 클래스를 작성해야 한다. 
+ 클래스는 힙 메모리에 존재하지 않는다. new 연산자를 사용하면 힘 메모리에 존재한다. 
+ 프로토타입은 새로운 객체를 생성해도 Object 생성자 함수를 통해 만들게 된다. 하지만 Object 생성자 함수도 결국은 함수 객체이기 때문에 힙 메모리에 존재하는 상태이다. 
+ 객체의 범주화의 개념이 다르다 
  + 클래스는 같은 속성을 가지고 있다고 판단되면 같은 범주로 묶을 수 있다. 
  + 프로토타입은 메모리에 존재하는 원형과 비교를 해서 범주화를 한다. 
    + 원형이란 각 범주에서 대표할만한 객체를 일컫는다. 
