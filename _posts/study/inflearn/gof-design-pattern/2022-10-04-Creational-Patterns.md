---
layout: post
bigtitle: '코딩으로 학습하는 GoF의 디자인 패턴'
subtitle: 생성 패턴(Creational Patterns)
date: '2022-10-04 00:00:00 +0900'
categories:
    - study
    - inflearn
    - gof-design-pattern
comments: true
---

# 생성 패턴(Creational Patterns)

# 생성 패턴(Creational Patterns)
* toc
{:toc}

## 싱글톤 (Singleton) 패턴
+ 인스턴스를 오직 한개만 제공하는 클래스
+ 시스템 런타임, 환경 세팅에 대한 정보 등, 인스턴스가 여러개 일 때 문제가 생길 수 있는 경우가 있다. __인스턴스를 오직 한개만 만들어 제공하는__ 클래스가 필요하다

~~~mermaid
classDiagram
    class BankAccount
    BankAccount : +String owner
    BankAccount : +Bigdecimal balance
    BankAccount : +deposit(amount)
    BankAccount : +withdrawal(amount)

~~~

