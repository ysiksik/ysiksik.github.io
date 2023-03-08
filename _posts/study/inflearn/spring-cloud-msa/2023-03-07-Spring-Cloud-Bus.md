---
layout: post
bigtitle: 'Spring Cloud로 개발하는 마이크로서비스 애플리케이션(MSA)'
subtitle: Spring Cloud Bus
date: '2023-03-07 00:00:00 +0900'
categories:
    - spring-cloud-msa
comments: true
---

# Spring Cloud Bus

# Spring Cloud Bus
* toc
{:toc}

## Changed configuration values
+ 서버 재기동
+ Actuator refresh
  + Spring Boot Actuator
    + Application 상태, 모니터링
    + Metric 수집을 위한 Http End point 제공
    + ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service13.png)
+ Spring cloud bus 사용
  + 분산 시스템의 노드를 경량 메시지 브로커와 연결
  + 상태 및 구성에 대한 변경 사항을 연결된 노드에게 전달(Broadcast)

## Spring Cloud Bus
+ ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus.png)
+ AMQP(Advanced Message Queuing Protocol), 메시지 지향 미들웨어를 위한 개방형 표준 응용 계층 프로토콜
  + 메시지 지향, 큐잉, 라우팅 (P2P, Publisher-Subcriber), 신뢰성, 보안
  + Erlang, RabbitMQ에서 사용
+ Kafka 프로젝트
  + Apache Software Foundation이 Scalar 언어로 개발한 오픈 소스 메시지 브로커 프로젝트
  + 분산형 스트리밍 플랫폼
  + 대용량의 데이터를 처리 가능한 메시징 시스템
+ RabbitMQ VS Kafka
  + RabbitMQ
    + 메시지 브로커
    + 초당 20+ 메시지를 소비자에게 전달
    + 메시지 전달 보장, 시스템 간 메시지 전달
    + 브로커, 소비자 중심 
  + Kafka
    + 초당 100k+ 이상의 이벤트 처리
    + Pub/Sub, Topic에 메시지 전달 
    + Ack를 기다리지 않고 전달 가능
    + 생산자 중심 
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus2.png)
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus3.png)
+ Actuator bus-refresh Endpoint
  + 분산 시스템의 노드를 경량 메시지 브로커와 연결
  + 상태 및 구성에 대한 변경 사항을 연결된 노드에게 전달(Broadcast)
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus4.png)

## Rabbit MQ 설치
+ ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus5.png)
+ MacOS)
  + $ brew update
  + $ brew install rabbitmq
    + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus6.png)
    + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus7.png)
    + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus8.png)
    + ![img_1.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus9.png)
  + $ export PATH=$PATH:/usr/local/sbin
  + $ rabbitmq-server
    + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus10.png)
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus11.png)
  + ![img_1.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus12.png)

### Rabbit MQ 설치 – Windows 10
+ Erlang 설치
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus13.png)
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus14.png)
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus15.png)
  + ![img_1.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus16.png)
+ RabbitMQ 설치
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus17.png)
  + ![img_1.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus18.png)
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus19.png)
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus20.png)
  + ![img_1.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus21.png)
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus22.png)
  + ![img_1.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus23.png)
  + ![img_2.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus24.png)
  + ![img_3.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus25.png)
+ Management Plugin 설치
  + ![img_4.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus26.png)
  + ![img_5.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus27.png)
+ http://127.0.0.1:15672
  + ![img_6.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus28.png)
  + ![img_7.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus29.png)
  + ![img_8.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus30.png)
  
## AMQP 사용

### Dependencies 추가
+ Config Server
  + AMQP for Spring Cloud Bus, Actuator
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus31.png)
+ Users Microservice, Gateway Service
  + AMQP for Spring Cloud Bus
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus32.png)

### application.yml 수정
+ Config Server, Users Microservice, Gateway Service
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus33.png)
  + ![img_1.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus34.png)
  + Spring Cloud 2020.0.0에서 bus-env -> busenv, bus-refresh -> busrefresh

## Actuator
+ Stop RabbitMQ server
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus35.png)
+ Start RabbitMQ server again
  + ![img.png](../../../../assets/img/spring-cloud-msa/Spring-Cloud-Bus36.png)
