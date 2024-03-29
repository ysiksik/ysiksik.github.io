---
layout: post
bigtitle: '스프링 입문 - 코드로 배우는 스프링 부트, 웹 MVC, DB 접근 기술'
subtitle: 스프링 빈과 의존관계
date: '2023-03-20 00:00:02 +0900'
categories:
    - spring-introduction
comments: true
---

# 스프링 빈과 의존관계

# 스프링 빈과 의존관계
* toc
{:toc}

## 컴포넌트 스캔과 자동 의존관계 설정
+ 생성자에 @Autowired 가 있으면 스프링이 연관된 객체를 스프링 컨테이너에서 찾아서 넣어준다. 이렇게
  객체 의존관계를 외부에서 넣어주는 것을 DI (Dependency Injection), 의존성 주입이라 한다
+ 스프링 빈을 등록하는 2가지 방법
  + 컴포넌트 스캔과 자동 의존관계 설정
  + 자바 코드로 직접 스프링 빈 등록하기
+ 생성자에 @Autowired 를 사용하면 객체 생성 시점에 스프링 컨테이너에서 해당 스프링 빈을 찾아서 주입한다. 생성자가 1개만 있으면 @Autowired 는 생략할 수 있다.
+ 스프링은 스프링 컨테이너에 스프링 빈을 등록할 때, 기본으로 싱글톤으로 등록한다(유일하게 하나만
  등록해서 공유한다) 따라서 같은 스프링 빈이면 모두 같은 인스턴스다. 설정으로 싱글톤이 아니게 설정할 수
  있지만, 특별한 경우를 제외하면 대부분 싱글톤을 사용한다.

### 컴포넌트 스캔 원리
+ @Component 애노테이션이 있으면 스프링 빈으로 자동 등록된다
+ @Controller 컨트롤러가 스프링 빈으로 자동 등록된 이유도 컴포넌트 스캔 때문이다.
+ @Component 를 포함하는 다음 애노테이션도 스프링 빈으로 자동 등록된다.
  + @Controller
  + @Service
  + @Repository

## 자바 코드로 직접 스프링 빈 등록하기
+ XML로 설정하는 방식도 있지만 최근에는 잘 사용하지 않으므로 생략한다.
+ DI에는 필드 주입, setter 주입, 생성자 주입 이렇게 3가지 방법이 있다. 의존관계가 실행중에 동적으로 변하는 경우는 거의 없으므로 생성자 주입을 권장한다
+ 실무에서는 주로 정형화된 컨트롤러, 서비스, 리포지토리 같은 코드는 컴포넌트 스캔을 사용한다.
  그리고 정형화 되지 않거나, 상황에 따라 구현 클래스를 변경해야 하면 설정을 통해 스프링 빈으로
  등록한다.
+ 개방-폐쇄 원칙(OCP, Open-Closed Principle)
  + 확장에는 열려있고, 수정, 변경에는 닫혀있다.
+ 스프링의 DI (Dependencies Injection)을 사용하면 기존 코드를 전혀 손대지 않고, 설정만으로 구현 클래스를 변경할 수 있다.

