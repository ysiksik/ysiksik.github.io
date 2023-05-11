---
layout: post
bigtitle: '스프링 MVC 2편 - 백엔드 웹 개발 핵심 기술'
subtitle: 타임리프 - 기본 기능
date: '2023-05-11 00:00:00 +0900'
categories:
- spring-mvc-part2
comments: true

---

# 타임리프 - 기본 기능

# 타임리프 - 기본 기능 
* toc
{:toc}


## 프로젝트 생성
+ 스프링 부트 3.0
  + Java 17 이상을 사용해야 한다
  + javax 패키지 이름을 jakarta로 변경해야 한다
    + 오라클과 자바 라이센스 문제로 모든 javax 패키지를 jakarta로 변경하기로 했다
  + 스프링 부트 3.0 관련 자세한 내용 [https://bit.ly/springboot3](https://bit.ly/springboot3)
+ IntelliJ Gradle 대신에 자바 직접 실행
  + 최근 IntelliJ 버전은 Gradle을 통해서 실행 하는 것이 기본 설정이다. 이렇게 하면 실행속도가 느리다. 
  + Preferences -> Build, Execution, Deployment -> Build Tools -> Gradle
    + Build and run using: Gradle -> IntelliJ IDEA
    + Run tests using: Gradle -> IntelliJ IDEA
