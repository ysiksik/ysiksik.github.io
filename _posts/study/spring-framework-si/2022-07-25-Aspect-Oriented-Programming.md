---
layout: post
bigtitle: 'Spring 전자정부 프레임워크 기반 SI 실무'
subtitle: 관점 지향 프로그래밍(AOP, Aspect Oriented Programming)
date: '2022-07-25 00:00:00 +0900'
categories:
    - study
    - spring-framework-si
tags: spring
comments: true
---

# 관점 지향 프로그래밍(AOP, Aspect Oriented Programming)

# 관점 지향 프로그래밍(AOP, Aspect Oriented Programming)
* toc
{:toc}

## AOP개요와 용어
+ 핵심 관심 사항과 공통(부가) 관심 사항
  + 핵심 관심 사항(core concern)과 공통 관심 사항(cross-cutting concern)
  + 기존 OOP에서는 공통관심사항을 여러 모듈에서 적용하는데 있어 중복된 코드를 양상 하는 한계가 존재함.
  + 이를 해결하기 위해 AOP가 등장
  + Aspect Oriented Programming은 문제를 해결하기 위한 핵심 관심 사항과 전체에 적용되는 공통 관심 사항을 기준으로 프로그래밍함으로써 공통 모듈을 손쉽게 적용할 수 있게 함.
+ AOP(Aspect Oriented Programming) 개요.
  + AOP는 application에서 관심사 분리(기능의 분리) 즉, 핵심적인 기능에서 부가적인 기능을 분리한다.
  + 분리한 부가기능을 어스펙트(Aspect)라는 독특한 모듈형태로 만들어서 설계하고 개발하는 방법.
  + OOP를 적용하여도 핵심기능에서 부가기능을 쉽게 분리된 모듈로 작성하기 어려운 문제점을 AOP가 해결
  + AOP는 부가기능을 어스펙트(Aspect)로 정의하여, 핵심기능에서 부가기능을 분리함으로써 핵심기능을 설계하고 구현할 때 객체지향적인 가치를 지킬 수 있도록 도와주는 개념
+ AOP 적용 예
  + 간단한 메소드의 성능 검사
    + 개발 도중 특히 DB에 다향의 데이터를 넣고 빼는 등의 배치 작업에 대하여 시간을 측정해 보고 쿼리를 개선하는 작업은 매우 의미가 있다. 이 경우 매번 해당 메소드의 처음과 끝에 System.currentTimeMillis();를 사용하거나,
    스프링이 제공하는 StopWatch코드를 사용하기는 매우 번거롭다.
    + 이런 경우 해당 작업을 하는 코드를 밖에서 설정하고 해당 부분을 사용하는 것이 편리하다.
  + 트랜젝션 처리
    + 트랜젝션의 경우 비즈니스 로직의 전후에 설정된다.
    + 하지만 매번 사용하는 트랙젝션의 코드는 번거롭고, 소스를 더욱 복잡하게 보여준다.
  + 예외반환
    + 스프링에는 DataAccessException이라는 매우 잘 정의되어 있는 예외 계층 구조가 있다. 
    예전 하이버네이트 예외들은 몇 개 없었고 그나마도 UncatchedException이 아니었다.
    이렇게 구조가 별로 안 좋은 예외들이 발생했을 때, 그걸 잡아서 잘 정의되어있는 예외 계층 구조로 변환해서 다시 던지는 Aspect는 제 3 프레임워크를 사용할 때, 본인의 프레임워크나 애플리케이션에서 별도의 예외 계층 구조로 변환 하고 싶을 때 유용하다.
  + 아키텍처 검증
  + 기타
    + 하이버네이트와 JDBC를 같이 사용할 경우, DB 동기화 문제 해결
    + 멀티스레드 Safety 관련하여 작업해야 하는 경우, 메소들에 일괄적으로 락을 설정하는 Aspect
    + 데드락등으로 인한 PessimisticLockingFailureException등의 예외를 만났을 때 재 시도하는 Aspect
    + 로깅, 인증, 권한등..
+ Spring AOP 용어
  + Target
    + 핵심 기능을 담고 있는 모듈로, 타겟은 부가기능을 부여할 대상이 됨.
  + Advice
    + 어느 시점(method 수행 전/후, 예외발생 후 등)에 어떤 공통 관심 기능(Aspect)을 적용할 지 정의 한 것. 타겟에 제공할 부가기능을 담고 있는 모듈.
  + JoinPoint
    + Aspect가 적용 될 수 있는 지점(method, field)
    + 즉 타겟 객체가 구현한 인터페이스의 모든 method는 JoinPoint가 됨.
  + Pointcut
    + 공통 관심 사항이 적용될 JoinPoint.
    + Advice를 적용할 타겟의 method를 설별하는 정규표현식.
    + Pointcut 표현식은 execution으로 시작하고, method의 Signature를 비교하는 방법을 주로 이용.
  + Aspect
    + 여러 객체에서 공통으로 적용되는 공통 관심 사항(transaction, logging, security,..)
    + AOP의 기본 모듈
    + Aspect = Advice + Pointcut
    + Aspect는 Singleton 형태의 객체로 존재.
  + Advisor
    + Advisor = Advice + Pointcut
    + Advisor는 Spring AOP에서만 사용되는 특별한 용어
  + Weaving
    + 어떤 Advice를 어떤 Pointcut(핵심사항)에 적용시킬 것인지에 대한 설정(Advisor)
    + 즉 Pointcut에 의해서 결정된 타겟의 Joinpoint에 부가기능(Advice)을 삽입하는 과정을 뜻함.
    + Weaving은 AOP의 핵심기능(Target)의 코드에 영향을 주지 않으면서 필요한 부가기능(Advice)을 추가 할 수 있도록 해주는 핵심적인 처리과정
