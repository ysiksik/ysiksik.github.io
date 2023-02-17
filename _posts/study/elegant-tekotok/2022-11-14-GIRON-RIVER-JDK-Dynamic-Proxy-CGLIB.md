---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 기론, 리버의 JDK Dynamic Proxy와 CGLIB
date: '2022-11-14 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 기론, 리버의 JDK Dynamic Proxy와 CGLIB
[https://youtu.be/MFckVKrJLRQ](https://youtu.be/MFckVKrJLRQ)

# 기론, 리버의 JDK Dynamic Proxy와 CGLIB
* toc
{:toc}

## Proxy 란?
+ 사전적 의미로 대리라는 뜻을 가지고 있다. 
+ 클라이언트로부터 타겟을 대시해서 요청을 받은 대리인
+ 실제 오브젝트인 타겟을 프록시를 통해 최종적으로 요청받아 처리한다.
+ 따라서 타겟을 자신의 기능에만 집중하고 부가기능은 프록시에게 위임한다. 

### Proxy사용 목적
프록시는 사용 목적에 따라 두 가지로 구분할 수 있다.
+ 클라이언트가 타깃에 접근하는 방법을 제어하는 것 
+ 타깃에 부가적인 기능을 부여해주기 위한 것

## 프록시 패턴
+ 프록시 패턴을 통해 Proxy를 직접 구현할 수 있다.
+ 예시 코드 - 인터페이스 구현
  + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB.png)
+ 예시 코드 - Target과 Proxy
  + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB2.png)
  + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB3.png)
+ 프록시 패턴이란?
특정 객체에 대한 접근을 제어하거나 부가기능을 구현하는데 사용하는 패턴 
  + 초기화 지연, 접근 권한 제어, 부가기능 등에 사용될 수 있다. 

### 프록시 정리
+ 특정 객체에 대한 접근을 제어하거나 기능을 추가할 수 있는 객체를 의미
+ 장점
  + OCP: 기존 코드를 변경하지 않고 새로운 기능을 추가할 수 있다.
  + SRP: 기존 코드가 해야 하는 일만 유지할 수 있다.
  + 기능 추가, 접근 제어 등 다양하게 응용하여 활용할 수 있다.
+ 단점
  + 코드의 복잡도가 증가한다.
    + 프록시를 직접 구현하려면 인터페이스를 구현해야 하고 또 프록시 객체를 생성해 주어야 한다.
  + 중복 코드가 발생한다.
  + 이런 문제들은 동적 프록시를 통해 해결할 수 있다.

## 동적 프록시 
+ JDK Dynamic Proxy
  + 프록시 클래스를 직접 구현하지 않아도 된다.
    + 코드 복잡도 해소
  + Invocation Handler (호출 처리기)
    + 중복 코드 제거 
+ Invocation Handler
  + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB4.png)
  + ![img_1.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB5.png)
    + 메서드 이름이 say로 시작하면 적용
+ Reflection API
  + 구체적인 클래스 타입을 알지 못해도 런타임에 클래스 정보에 접근할 수 있게 해주는 자바 API
  + 리플렉션은 동적일 때. 해결되는 타입을 포함하므로 JVM의 optimization(최적화)이 작동하지 않아 성능이 느리다. 

### JDK Dynamic Proxy - 구현
+ 프로젝트 구조
  + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB6.png)
+ Target
  + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB7.png)
+ InvocationHandler
  + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB8.png)
  + 메서드 이름이 get으로 시작하면 조회 메서드 호출이라는 로그를 찍는다. 이후 타겟에게 위임
+ JDK Dynamic Proxy
  + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB9.png)
  + Proxy.newProxyInstance를 사용해서 JDK Proxy를 사용할 수 있는데 처음에는 프록시 로딩에 사용할 클래스 로더(ClassLoader)를 적어주고 타겟의 인터페이스를 적어준 후, 부가기능과 위임할 타겟을 적어주면 된다. 

### JDK Dynamic Proxy 특징
+ JDK에서 지원하는 프록시 생성 방법
  + 외부 라이브러리에 의존하지 않는다.
+ Reflection API를 사용한다. 
  + 조금 느리다. 
+ 인터페이스가 반드시 있어야 한다.
+ Invocation Handler를 재정의한 invoke를 구현해줘야 부가기능이 추가된다. 

## CGLIB
+ ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB10.png)
+ 스프링에서는 클라이언트가 메소드를 요청하면 ProxyFactoryBean에서 인터페이스 유무를 확인하여 인터페이스가 있으면 JDK Dynamic Proxy를 호출하고 인터페이스가 없으면 CGLIB 방식으로 프록시를 생성한다. 

### CGLIB 특징
+ 상속을 통한 프록시 구현
+ 바이트 코드를 조작해서 프록시 생성
+ MethodInterceptor를 재정의한 intercept를 구현해야 부가기능이 추가된다. 
+ 인터페이스에도 강제로 적용할 수도 있다. 이때는 클래스에도 프록시를 적용시켜야 한다.
+ 메서드에 final을 붙이면 오버 라이딩이 불가능하다.
+ net.sf.cglib.proxy.Enhancer 의존성을 추가해야 한다.
+ Default 생성자 필요하다.
+ 타겟의 생상자 두번 호출한다. 

### CGLIB - 예시 코드
+ 프로젝트 구조 
  + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB11.png)
+ Target
  + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB12.png)
+ MethodInterceptor
  + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB13.png)
  + intercept라는 메서드를 재정의하여 사용한다.  
  + 메서드 이름이 get으로 시작하면 조회 메서드 호출 이라고 출력하고 그렇지 않으면 조회가 아닌 메서드 호출이라고 로그를 출력한다. 
+ CGLIB
  + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB14.png)
  + Enhancer라는 외부 의존성을 사용하여 CGLIB을 사용할 수 있다.

## JDK Dynamic Proxy VS CGLIB
+ CGLIB 성능
  + 메소드가 처음 호출되었을 때 동적으로 타깃의 클래스의 바이트 코드를 조작
  + 이후 호출시엔 조작된 바이트 코드 재사용
+ CGLIB이 Dynamic Proxy 보다 3배 가까이 빠르다. 
+ JDK Dynamic Proxy VS CGLIB
  + Reflection을 사용해 느리다.
  + 인터페이스가 있으면 작동한다.
+ CGLIB
  + 바이트 코드를 조작해서 빠르다.
  + 클래스만 있어도 동작한다. 

## Spring Boot와 CGLIB
+ 스프링 부트에서 인터페이스와 클래스를 구별하여 동작을 하면 CGLIB이 작동하는 것을 확인할 수 있다. 
  + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB15.png)
    + 이유는 스프링에서 기본으로 proxy-target-class:true로 되어있기 때문에 CGLIB이 기본으로 작동하기 때문이다.
    + 해당 설정을 false로 하면 JDK Proxy가 작동하는 것을 확인할 수 있다. 
+ 스프링에서 인터페이스를 활용하여 DI 적극 사용하는 방식을 두고 CGLIB을 사용하는 이유 
  + Phil Webb이라는 스프링 부트를 개발한 총 책임자가 말했다
    + 인터페이스 기반 프록시는 때때로 ClassCast Exceptions를 추적하기 어렵게 한다. 
+ net.sf.cglib.proxy.Enhancer 의존성을 추가해야 한다.
  + 3.2 version Spring Core 패키지 포함해서 해결
+ Default 생성자 필요하다.
  + 4.0 version Objensis 라이브러리를 사용해서 해결 
+ 타겟의 생상자 두번 호출한다. 
  + 4.0 version Objensis 라이브러리를 사용해서 해결
+ Spring 4.3과 Spring boot 1.4부터 기존으로 CGLIB 프록시를 사용하게 되었다.  

## 정리
+ JDK Dynamic Proxy
  + reflection api를 사용한다.
  + 인터페이스가 반드시 필요하다.
+ CGLIB
  + 바이트 코드를 조작해서 빠르다.
  + 상속을 이용해서 프록시를 만든다.
  + 메서드에 final을 붙이면 안된다. 

## Spring의 프록시 구현
+ 스프링에서 프록시를 빈으로 직접 사용하겠다고 하면 ProxyFactoryBean을 사용해서 구현할 수 있다.
+ ProxyFactoryBean
  + Spring에서는 프록시를 Bean으로 만들어주는 ProxyFactoryBean을 제공한다. 
  + ProxyFactoryBean을 통해 Proxy를 생성할 수 있다.
+ ProxyFactoryBean의 주요 특징
  + 타깃의 인터페이스 정보를 파라미터로 줄 필요없다. 
  + 프록시 빈을 생성해준다. 
  + 부가기능을 MethodInterceptor로 구현 
    + CGLIB의 MethodInterceptor와는 다른 개념이다. JDK Dynamic Proxy와 비교하면 JDK Dynamic Proxy는 InvocationHandler를 통해서 프록시 부가기능을 구현하고 실행해 주었다 
    그런데 ProxyFactoryBean은 MethodInterceptor라는 인터페이스를 통해서 부가기능을 구현하고 사용한다.
  + 타겟에 의존적인 InvocationHandler
    + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB16.png)
    + 같은 기능을 매번 Bean으로 등록하고 객체를 생성해 줘야한다.  
    + 그래서 ProxyFactoryBean은 MethodInterceptor를 통해서 이러한 단점을 극복했다.

+ ProxyFactoryBean의 프록시 생성 메커니즘
  + ![img.png](/assets/img/elegant-tekotok/GIRON-RIVER-JDK-Dynamic-Proxy-CGLIB17.png)
    + 이때 실제 원하는 기능을 가지고 있는 객체는 프록시이다. 
    + MethodInterceptor는 부가기능을 독립적으로 유지하기 위해서 타겟을 가지지 않는다
      + 부가기능을 싱글톤으로 공유하여 사용 가능하다. 
+ 정리
  + Spring에서 지원하는 프록시 생성 방법
  + MethodInterceptor를 재정의한 invoke를 구현해줘야 부가기능이 추가된다.
  + 인터페이스가 반드시 필요하지 않다.
+ ProxyFactoryBean 한계
  + ProxyFactoryBean도 매번 생성해 주어야 한다.


