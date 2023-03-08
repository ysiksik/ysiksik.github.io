---
layout: post
bigtitle: 'Spring Cloud로 개발하는 마이크로서비스 애플리케이션(MSA)'
subtitle: 마이크로서비스간 통신
date: '2023-03-09 00:00:00 +0900'
categories:
    - spring-cloud-msa
comments: true
---

# 마이크로서비스간 통신

# 마이크로서비스간 통신
* toc
{:toc}

## Communication Types
+ Synchronous HTTP communication - 동기식 HTTP 통신
+ Asynchronous communication over AMQP - AMQP를 통한 비동기 통신
  + ![img.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices.png)
+ Rest Template
  + ![img_1.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices2.png)

## RestTemplate

### Users Service -> Order Service
+ ![img.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices3.png)
+ ![img_1.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices4.png)
+ ![img_2.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices5.png)
+ ![img_3.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices6.png)
+ ![img_4.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices7.png)

## Feign Web Service Client
+ FeignClient -> HTTP Client
  + REST Call을 추상화 한 Spring Cloud Netflix 라이브러리
+ 사용방법
  + 호출하려는 HTTP Endpoint에 대한 Interface를 생성
  + @FeignClient 선언
+ Load balanced 지원

### Feign Client 적용
+ Spring Cloud Netflix 라이브러리 추가
+ @FeignClient Interface 생성
+ ![img.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices8.png)
+ ![img_1.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices9.png)

### Feign Client 생성
+ UserServiceImpl.java에서 Feign Client 사용
+ ![img_2.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices10.png)
+ ![img_3.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices11.png)

### Feign Client에서 로그 사용
+ ![img_4.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices12.png)
+ ![img_5.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices13.png)

### FeignException
+ ![img.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices14.png)
+ FeignException 처리
  + ![img_1.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices15.png)

### FeignErrorDecoder 
+ ErrorDecoder 구현
  + ![img_2.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices17.png)
+ Application 클래스에 ErrorDecoder 빈 등록
  + ![img_3.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices18.png)
+ Properties 파일적용
  + ![img_4.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices19.png)

## Multiple Orders Service
+ Orders Service 2개 기동
+ Orders 데이터도 분산 저장 -> 동기화 문제
  + ![img.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices20.png)
  + 하나의 Database 사용
    + ![img.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices21.png)
  + Database간의 동기화
    + ![img.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices22.png)
  + Kafka Connector + DB
    + ![img.png](../../../../assets/img/spring-cloud-msa/Communication-Between-Microservices23.png)
