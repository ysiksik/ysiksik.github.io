---
layout: post
bigtitle: '더 자바, 애플리케이션을 테스트하는 다양한 방법'
subtitle: 운영 이슈 테스트
date: '2022-09-28 00:00:01 +0900'
categories:
    - the-java-test-application
comments: true
---

# 운영 이슈 테스트

# 운영 이슈 테스트
* toc
{:toc}

## Chaos Monkey 소개
+ [카오스 엔지니어링](http://channy.creation.net/blog/1173) 툴
  + 프로덕션 환경, 특히 분산 시스템 환경에서 불확실성을 파악하고 해벽 방안을 모색하는데 사용하는 툴
+ 운영 환경 불확실성의 예
  + 네트워크 지연
  + 서버 장애
  + 디스크 오작동
  + 메모리 누누
  + 등등...
+ [https://codecentric.github.io/chaos-monkey-spring-boot/](https://codecentric.github.io/chaos-monkey-spring-boot/)
  + 스프링 부트 애플리케이션에 카오스 멍키를 손쉽게 적용해 볼 수 있는 툴
  + 즉, 스프링 부트 애플리케이션을 망가트릴 수 있는 툴
+ 카오스 멍키 스프링 부트 주요 개념
  + 공격 대상(Watcher)
    + @RestController
    + @Controller
    + @Service
    + @Repository
    + @Component
  + 공격 유형(Assaults)
    + 응답 지연 (Latency Assault)
    + 예외 발생 (Exception Assault)
    + 애플리케이션 종료 (AppKiller Assault)
    + 메모리 누수 (Memory Assault)

## Chaos Monkey 설치
+ 의존성 추가 

~~~xml

<dependency>
    <groupId>de.codecentric</groupId>
    <artifactId>chaos-monkey-spring-boot</artifactId>
    <version>2.1.1</version>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>

~~~

+ [Chaos-monkey-spring-boot](https://codecentric.github.io/chaos-monkey-spring-boot/2.1.1/)
  + 스프링 부트용 카오스 멍키 제공
+ Spring-boot-starter-actuator
  + 스프링 부트 운영 툴로, 런터임 중에 카오스 멍키 설정을 변경할 수 있다.
  + 그밖에도 헬스 체크, 로그 레벨 변경, 메트릭스 데이터 조회 등 다양한 운영 툴로 사용 가능하다.
  + /actuator
+ 카오스 멍키 활성화
  + spring.profiles.active=chaos-monkey
+ 스프링 부트 Actuator 엔드 포인트 활성화

~~~properties

management.endpoint.chaosmonkey.enabled=true
management.endpoints.web.exposure.include=health,info,chaosmonkey

~~~

## CM4SB 응답 지연

### 응답 지연 이슈 재현 방법
1. Repository Watcher 활성화
   + chaos.monkey.watcher.repository=true
2. 카오스 멍키 활성화
   + http post localhost:8080/actuator/chaosmonkey/enable
3. 카오스 멍키 활성화 확인
   + http localhost:8080/actuator/chaosmonkey/status
4. 카오스 멍키 와처 확인
   + http localhost:8080/actuator/chaosmonkey/watchers
5. 카오스 멍키 지연 공격 설정
   + http POST localhost:8080/actuator/chaosmonkey/assaults level=3 latencyRangeStart=2000 latencyRangeEnd=5000 latencyActive=true
6. 테스트
   + JMeter 확인

### 참고
+ [https://codecentric.github.io/chaos-monkey-spring-boot/2.1.1/#_customize_watcher](https://codecentric.github.io/chaos-monkey-spring-boot/2.1.1/#_customize_watcher)
  + 특정한 메서드만 응답 지연 시키기
  
## CM4SB 에러 발생

### 에러 발생 재현 방법
+ http POST localhost:8080/actuator/chaosmonkey/assaults level=3 latencyActive=false exceptionsActive=true exception.type=java.lang.RuntimeException

### 참고 
+ [https://codecentric.github.io/chaos-monkey-spring-boot/2.1.1/#_examples](https://codecentric.github.io/chaos-monkey-spring-boot/2.1.1/#_examples)
