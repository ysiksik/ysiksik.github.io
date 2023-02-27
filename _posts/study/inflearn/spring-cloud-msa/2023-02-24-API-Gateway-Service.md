---
layout: post
bigtitle: 'Spring Cloud로 개발하는 마이크로서비스 애플리케이션(MSA)'
subtitle: API Gateway Service
date: '2023-02-24 00:00:00 +0900'
categories:
    - spring-cloud-msa
comments: true
---

# API Gateway Service

# API Gateway Service
* toc
{:toc}

## API Gateway Service
+ 인증 및 권한 부여
+ 서비스 검색 통합
+ 응답 캐싱
+ 정책, 회로 차단기 및 QoS 다시 시도
+ 속도 제한
+ 부하 분산
+ 로깅, 추적, 상관 관계
+ 헤더, 쿼리 문자열 및 청구 변환
+ IP 허용 목록에 추가 
+ ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service.png)
+ ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service2.png)

## Netflix Ribbon
+ Spring Cloud에서의 MSA간 통신
  + RestTemplate
    + RestTemplate restTemplate = new RestTemplate();
    restTemplate.getForObject("http://localhost:8080\", User.class, 200); 
  + Feign Client
    + @FeignClient("stores")
      @RequestMapping(method = RequestMethod.GET, value = "/stores") List<Store> getStores();
      List<Store> getStores();
+ Ribbon: Client side Load Balancer
  + 서비스 이름으로 호출
  + Health Check
  + Spring Cloud Ribbon은 Spring Boot 2.4에서 Maintenance상태
    + Maintenance상태 : 새로운 기능을 추가 하지 않는다 
  + 비동기 처리 방식이 안 돼서 최근에는 잘 사용하지 않는다 
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service3.png)

## Netflix Zuul 구현
+ 구성 
  + First Service
  + Second Service
  + Netflix Zuul - Gateway
+ ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service4.png)
+ Spring Cloud Zuul은 Spring Boot 2.4에서 Maintenance상태
  + [https://spring.io/blog/2018/12/12/spring-cloud-greenwich-rc1-available-now#spring-cloud-netflix-projects-entering-maintenance-mode](https://spring.io/blog/2018/12/12/spring-cloud-greenwich-rc1-available-now#spring-cloud-netflix-projects-entering-maintenance-mode)
+ Step1) First Service, Second Service
  + Spring Boot: 2.3.8
  + Dependencies: Lombok, Spring Web, Eureka Discovery Client
+ Step2) First Service, Second Service
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service5.png)
+ Step3) Test
+ Step4) Zuul Service
  + Spring Boot: 2.3.8
  + Dependencies: Lombok, Spring Web, Zuul
+ Step5) Zuul Service
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service6.png)
+ Step6) ZuulFilter
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service7.png)

## Spring Cloud Gateway – 기본
+ 비동기 처리 방식이 가능하다
+ Netty 서버가 동작
+ Step1) Dependencies
  + DevTools, Eureka Discovery Client, Gateway
+ Step2) application.properties (or application.yml)
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service8.png)
+ Step3) Test

## Spring Cloud Gateway – Filter
+ ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service9.png)
+ Step4) Filter using Java Code – FilterConfig.java
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service10.png)
+ Step4) Filter using Java Code – FirstServiceController.java, SecondServiceController.java
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service11.png)
+ Step4) Test
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service12.png)
+ Step5) Filter using Property – application.yml
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service13.png)
+ Step5) Test
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service14.png)

## Spring Cloud Gateway – Custom Filter
+ Step6) Custom Filter – CustomFilter.java
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service15.png)
+ Step6) Custom Filter – application.yml
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service16.png)
+ Step6) Custom Filter – FirstServiceController.java, SecondServiceController.java
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service17.png)

## Spring Cloud Gateway – Global Filter
+ Step7) Global Filter – GlobalFilter.java
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service18.png)
+ Step7) Global Filter – application.yml
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service19.png)
+ Step7) Global Filter – Test
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service20.png)

## Spring Cloud Gateway – Custom Filter (Logging)
+ Step8) Logging Filter – LoggingFilter.java
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service21.png)
+ Step8) Logging Filter – application.yml
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service22.png)
+ Step8) Logging Filter – Test
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service23.png)
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service24.png)

## Spring Cloud Gateway – Eureka 연동
+ ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service25.png)
+ Step1) Eureka Client 추가 – pom.xml, application.yml
  + Spring Cloud Gateway, First Service, Second Service
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service26.png)
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service27.png)
+ Step2) Eureka Client 추가 –application.yml
  + Spring Cloud Gateway
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service28.png)
+ Step3) Eureka Server – Service 등록 확인
  + Spring Cloud Gateway, First Service, Second Service
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service29.png)

## Spring Cloud Gateway – Load Balancer
+ Step4) First Service, Second Service를각각2개씩기동
  1. VM Options à-Dserver.port=[다른포트]
  2. mvn spring-boot:run -Dspring-boot.run.jvmArguments='-Dserver.port=9003'
  3. mvn clean compile package
  $ java -jar -Dserver.port=9004 ./target/user-service-0.0.1-SNAPSHOT.jar
+ Step5) Eureka Server – Service 등록확인
+ Step6) Random port 사용
  + Spring Cloud Gateway, First Service, Second Service
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service30.png)
+ Step6) Post 확인 – FirstController.java
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service31.png)
+ Step6) Random port 사용
  + Spring Cloud Gateway, First Service, Second Service
  + ![img.png](../../../../assets/img/spring-cloud-msa/API-Gateway-Service32.png)

