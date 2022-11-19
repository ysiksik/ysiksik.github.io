---
layout: post
bigtitle: '한 번에 끝내는 Spring 완.전.판 초격차 패키지 Online.'
subtitle: Part 1. Spring Framework
date: '2022-11-17 00:00:01 +0900'
categories:
    - study
    - fast-campus
    - spring-complete-edition-super-gap-package-online
comments: true
---

# Part 1. Spring Framework

# Part 1. Spring Framework
* toc
{:toc}

## Ch 01. 강의소개, 프로개발자로 성장하는 법

### 개발자의 소프트 스킬
+ 취직, 이직을 위한 짧은 팁
  + 애매하게 아는 것을 항상 경계해야 한다.
  + 자신이 했던 업무, 프로젝트, 성과를 해당 분야를 전혀 모르는 사람에게 설명할 줄 알아야 한다.
+ 원활한 협업을 위한 업무 스킬
  + 애매하게 아는 것은 물어본다.
  + 질문이 오면 최선을 다해 설명한다.
  + 끊임없이 일정을 확인하고, 다듬어야 한다.

### 개발자의 기초 체력을 키우는 방법
+ 검색을 잘하는 방법
  + 신뢰할 수 있는 사이트: baeldung, medium, github
  + Reference site: spring.io, kotlinlang.org
  + 질의 응답: stackoverflow
  + 조금 더 다양한 토론: reddit
  + google.com
    + 검색도구 사용법(site, filetype), 도구를 활용해서 기간을 확인
+ 에러 코드를 읽는 방법
  + 에러 검색 방법
    + 가장 아래 또는 가장 위 에러부터 천천히 읽어본다.
    + 바로 해결하거나 혹은 구글에 검색해본다. 

### Intellij 소개 및 스프링 프로젝트 살펴보기
+ Intellij 소개
  + 강력한 검색 성능
  + 잘 관리되는 플러그인
  + 유료
+ Spring 프로젝트 살펴보기, 동작시키기
  + src/main/java : 우리가 만들어야할 Java 코드
  + src/main/resources : java코드가 아닌 기타 프로젝트 관련 자료
  + src/test : 테스트 관련된 것들이 main과 동일한 구조로 위치
  + build.gradle : 이 프로젝트가 사용하는 프레임워크와 라이브러리가 버전정보와 함께 포함

## Ch 02. 스프링의 핵심 기술 익히기
[노션으로 이동](https://productive-pullover-f3e.notion.site/6a09636c5dd942a6bb1d8574768e2593?v=b1bc50f032174c10a3c845c2c7ba09ec)

### 자바, 그리고 스프링, 스프링 부트
+ JAVA: 객체지향적 프로그래밍 언어 
  + 우리가 배우게 될 스프링의 근간이 되는 언어
  + 스프링은 자바 뿐 아니라 코틀린, 그루비로도 사용할 수 있다.
  + 스프링 자체는 거의 대부분 자바로 만들어져 있다.
+ Spring Framework : 기업용 어플리케이션을 만드는데 사용 가능한 오픈소스 프레임워크
  + 자바를 이용해서 어플리케이션을 만들기 위해 활용하는 프레임워크
  + 자바, 서블릿, J2EE >>>>> 스프링 프레임워크
  + ![img.png](/assets/img/spring-complete-edition-super-gap-package-online/Part1-Spring-Framework.png)
  + 스프링 내에는 동일한 역할을 하는 다양한 기능이 있으며, 그 중에서 적합한 툴을 선택할 수 있어야한다.
+ Spring boot : 스프링 기반으로 자주 사용되는 설정으로 손쉽게 개발할 수 있게 해주는 상위 프레임워크
  + 스프링(각종 도구가 있는 템플릿)보다 한층 더 편리한 프레임워크
  + 웹 어플리케이션(톰캣 등) 서버 내장
  + 자동 설정, 설정 표준화
  + 원한다면 마음대로 설정할 수 있다.

### 스프링의 Core Technology
+ 스프링 프레임워크 핵심기술
  + ![img.png](/assets/img/spring-complete-edition-super-gap-package-online/Part1-Spring-Framework.png)
  + Core (DI, IoC)
    + 스프링의 근간, 내가 만든 클래스를 스프링이 직접 관리하여 어플리케이션을 동작하게 한다.
  + AOP(Aspect Oriented Programming)
    + 공통적인 코드를 프레임워크 레벨에서 지원해주는 방법
  + Validation, Data binding
    + 검증 그리고 외부에서 받은 데이터를 담아내는 방법
  + Resource
    + 스프링 내부에서 설정이 들어있는 파일들에 접근하는 동작 원리
  + SpEL
    + 짧은 표현식을 통해 필요한 데이터나 설정 값을 얻어올 수 있게 하는 특별한 형태의 표현식에 가까운 간편한 언어
  + Null-Safety
    
