---
layout: post
bigtitle: 'Spring Cloud로 개발하는 마이크로서비스 애플리케이션(MSA)'
subtitle: 장애 처리와 Microservice 분산 추적
date: '2023-03-13 00:00:00 +0900'
categories:
    - spring-cloud-msa
comments: true
---

# 장애 처리와 Microservice 분산 추적

# 장애 처리와 Microservice 분산 추적
* toc
{:toc}

## Microservice 통신 시 연쇄 오류
+ ![img.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace.png)
+ ![img_1.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace2.png)

## CircuitBreaker
+ [https://martinfowler.com/bliki/CircuitBreaker.html](https://martinfowler.com/bliki/CircuitBreaker.html)
+ 장애가 발생하는 서비스에 반복적인 호출이 되지 못하게 차단
+ 특정 서비스가 정상적으로 동작하지 않을 경우 다른 기능으로 대체 수행 -> 장애 회피
+ ![img_3.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace3.png)
+ ![img_4.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace4.png)

## Spring Cloud Betflix Hystrix
+ Spring Cloud Netflix Hystrix
  + pom.xml (User-ws)
    + ![img_5.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace5.png)
  + Application.java (User-ws)
    + ![img_6.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace6.png)
  + application.yml (User-ws)
    + ![img_7.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace7.png)
+ Hystrix 지원 끝 Resilience4j 사용
  + ![img_8.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace8.png)

## Resilience4j
+ resilience4j-circuitbreaker: Circuit breaking
+ resilience4j-ratelimiter: Rate limiting
+ resilience4j-bulkhead: Bulkheading
+ resilience4j-retry: Automatic retrying (sync and async)
+ resilience4j-timelimiter: Timeout handling
+ resilience4j-cache: Result caching
+ [https://resilience4j.readme.io/docs/getting-started](https://resilience4j.readme.io/docs/getting-started)
+ [https://github.com/resilience4j/resilience4j](https://github.com/resilience4j/resilience4j)
+ ![img_9.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace9.png)

### Resilience4j – CircuitBreaker
+ DefaultConfiguration
  + pom.xml
    + ![img_10.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace10.png)
  + UserServiceImpl.java
    + ![img_11.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace11.png)
    + ![img_12.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace12.png)
  + ![img_13.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace13.png)
+ Customize CircuitBreakerFactory -> Resilience4JCircuitBreakerFactory
  + ![img_14.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace14.png)
  + ![img_15.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace15.png)

## Microservice 분산 추적
+ Zipkin
  + [https://zipkin.io/](https://zipkin.io/)
  + Twitter에서 사용하는 분산 환경의 Timing 데이터 수집, 추적 시스템 (오픈소스)
  + Google Drapper에서 발전하였으며, 분산환경에서의 시스템 병목 현상 파악
  + Collector, Query Service, Databasem WebUI로 구성
  + Span
    + 하나의 요청에 사용되는 작업의 단위
    + 64 bit unique ID
  + Trace
    + 트리 구조로 이뤄진 Span 셋
    + 하나의 요청에 대한 같은 Trace ID 발급
  + ![img_16.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace16.png)
+ Spring Cloud Sleuth
  + 스프링 부트 애플리케이션을 Zipkin과 연동
  + 요청 값에 따른 Trace ID, Span ID 부여
  + Trace와 Span Ids를 로그에 추가 가능
    + servlet filter
    + rest template
    + scheduled actions
    + message channels
    + feign client
+ Spring Cloud Sleuth + Zipkin
  + ![img_17.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace17.png)
+ Zipkin server 설치
  + ![img_18.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace18.png)
  + ![img_19.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace19.png)
+ Zipkin server 기동
  + ![img_20.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace20.png)
  + ![img_21.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace21.png)

### Users Microservice 수정
+ ![img_22.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace22.png)
+ Trace ID and Span ID
  + ![img_23.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace23.png)
  + ![img_24.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace24.png)
  + ![img_25.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace25.png)
  + ![img_26.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace26.png)
+ Zipkin server 활용
  + ![img_27.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace27.png)
  + ![img_28.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace28.png)
+ Zipkin에서의 추적
  + ![img_29.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace29.png)
+ Orders Microservice 장애 발생
  + ![img_30.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace30.png)
  + ![img_31.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace31.png)
  + ![img_32.png](../../../../assets/img/spring-cloud-msa/Resilience4J-Trace32.png)
